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
