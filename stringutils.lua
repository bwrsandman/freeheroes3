require 'coord'

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

function string:append_indented_line(indent, ...)
    local ret = self .. string.rep("\t", indent)
    for n = 1, select("#", ...) do
        ret = ret .. (n > 1 and "\t" or "") .. tostring(select(n, ...))
    end
    ret = ret .. "\n"
    return ret
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

function string:substitute(map)
    -- string.substitute("a", {a=1, parent = {a = 2, b=3}}, 0)
    -- 1
    -- string.substitute("b", {a=1, parent = {a = 2, b=3}}, 0)
    -- 3
    local s = self:trim()
    local ret = (map[s] == nil and map._parent and s:substitute(map._parent)) or map[s]
    if ret == nil then
        ret = tonumber(s) or s
    elseif type(ret) == "boolean" then
        ret = ret and 1 or 0
    end
    return ret
end

function string:calculate(map)
    local ret
    local eq
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
        ret = self:substitute(map)
    end
    if tonumber(ret) == nil then
        print("\27[31mERROR:\27[39m Could not substitute " .. ret)
        ret = 0
    end
    ret = tonumber(ret)
    return ret
end
