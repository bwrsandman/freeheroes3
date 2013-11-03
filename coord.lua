coord = {}
coord.__index = coord

function coord.new(x, y, u)
    assert(type(x) == "number")
    assert(type(y) == "number")
    if (type(u) == "number") then u = u ~= 0 end
    assert(type(u) == "boolean")

    local self = setmetatable({}, coord)
    self.x = x
    self.y = y
    self.u = u
    return self
end

function coord:serialize()
    return (string.format("(%d,%d,%d)", self.x, self.y, self.u and 1 or 0))
end

function string:bytes_to_coord()
    if self:len() ~= 3 then return nil end
    local x = self:sub(1, 1):bytes_to_int()
    local y = self:sub(2, 2):bytes_to_int()
    local u = self:sub(3, 3):bytes_to_int() ~= 0
    return coord.new(x, y, u)
end

coord.__tostring = coord.serialize
