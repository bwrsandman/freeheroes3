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

coord.__tostring = coord.serialize
