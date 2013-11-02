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

function string:bytes_to_int_verify(id, name)
    return self:verify_length(self:bytes_to_int(), id, name)
end

function string:verify_length(len, id, name)
    if(len >= 30000) then
        print(string.format("Data length for %s #%d exceeds 30000(%d).", name, id, len))
        return 0
    end
    return len
end

function string:bytes_to_coord()
    if self:len() ~= 3 then return nil end
    local x = self:sub(1, 1):bytes_to_int()
    local y = self:sub(2, 2):bytes_to_int()
    local u = self:sub(3, 3):bytes_to_int() ~= 0
    return coord.new(x, y, u)
end

function string:substitute(map, map_version)
    local s = self:trim()
    local ret = (s == "map_version" and map_version) or map[s]
    if ret == nil then
        ret = tonumber(s) or s
    elseif type(ret) == "boolean" then
        ret = ret and 1 or 0
    end
    assert(ret ~= nil)
    return ret
end

function string:calculate(map, map_version)
    local ret = nil
    local eq = nil
    -- Contains multiplier, perform calculation
    if self:match("%*") then
        ret = 1
        for i, x in pairs(self:split("*")) do
            local sub = x:substitute(map, map_version)
            if not tonumber(sub) then
                sub = sub:calculate(map, map_version)
            end
            ret = ret * sub
        end
    elseif self:match("!=") then
        eq = self:split("!=")
        assert(#eq == 2)
        ret = (eq[1]:substitute(map, map_version) ~= eq[2]:substitute(map, map_version)) and 1 or 0
    elseif self:match("==") then
        eq = self:split("==")
        assert(#eq == 2)
        ret = (eq[1]:substitute(map, map_version) == eq[2]:substitute(map, map_version)) and 1 or 0
    else
        ret = map[self] or self
    end
    ret = tonumber(ret)
    assert(ret ~= nil)
    return ret
end
