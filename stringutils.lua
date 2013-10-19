require 'coord'
require 'champ'
require 'rumor'

-- General string functions
function string:trim()
    return self:find'^%s*$' and '' or self:match'^%s*(.*%S)'
end

function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

function string:bytes_to_int()
    local t = {self:byte(1, -1)}
    local n = 0
    for k = 1, #t do
        n = n + t[k] * 2^((k - 1) * 8)
    end
    return n
end

-- Map reading specific functions

function string:bytes_to_coord()
    if self:len() ~= 3 then return nil end
    local x = self:sub(1, 1):bytes_to_int()
    local y = self:sub(2, 2):bytes_to_int()
    local u = self:sub(3, 3):bytes_to_int() ~= 0
    return coord.new(x, y, u)
end

function string:bytes_to_champ()
    if self:len() < 5 then return nil end
    local id = self:sub(1, 1):bytes_to_int()
    local str_len = self:sub(2, 2):bytes_to_int()
    local unknown = self:sub(3, 5):bytes_to_int()
    if(str_len >= 30000) then
        str_len = 0
	print("Data length for champ name exceeds 30000.")
    end
    if self:len() < 5 + str_len then return 0, nil end
    local name = self:sub(6, 5 + str_len)
    return 5 + str_len, champ.new(id, name, unknown)
end

function string:bytes_to_rumor(id)
    local pointer = 1
    local title_len = self:sub(pointer, pointer + 3):bytes_to_int()
    if(title_len >= 30000) then
        print(string.format("Data length for rumor title #%d exceeds 30000(%d).", id, title_len))
        title_len = 0
    end
    pointer = pointer + 4
    local title = self:sub(pointer, pointer + title_len - 1)
    pointer = pointer + title_len
    local content_len = self:sub(pointer, pointer + 3):bytes_to_int()
    if(content_len >= 30000) then
        print(string.format("Data length for rumor content #%d exceeds 30000(%d).", id, content_len))
        content_len = 0
    end
    pointer = pointer + 4
    local content = self:sub(pointer, pointer + content_len - 1)
    pointer = pointer + content_len
    return pointer - 1, rumor.new(id, title, content)
end

function string:substitute(map)
    local s = self:trim()
    local ret = map[s]
    if ret == nil then
        ret = tonumber(s) or s
    elseif type(ret) == "boolean" then
        ret = ret and 1 or 0
    end
    assert(ret ~= nil)
    return ret
end

function string:calculate(map)
    local ret = nil
    local eq = nil
    -- Contains multiplier, perform calculation
    if self:match("%*") then
        ret = 1
        for i, x in pairs(self:split("*")) do
            local sub = x:substitute(map)
            if not tonumber(sub) then
                sub = sub:calculate(map)
            end
            ret = ret * sub
        end
    elseif self:match("!=") then
        eq = self:split("!=")
        assert(#eq == 2)
        ret = (eq[1]:substitute(map) ~= eq[2]:substitute(map)) and 1 or 0
    elseif self:match("==") then
        eq = self:split("==")
        assert(#eq == 2)
        ret = (eq[1]:substitute(map) == eq[2]:substitute(map)) and 1 or 0
    else
        ret = map[self] or self
    end
    ret = tonumber(ret)
    assert(ret ~= nil)
    return ret
end
