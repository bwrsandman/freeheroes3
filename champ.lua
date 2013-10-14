champ = {}
champ.__index = champ

function champ.new(id, name, unknown)
    assert(type(id) == "number")
    assert(type(name) == "string")

    local self = setmetatable({}, champ)
    self.id = id
    self.name = name
    self.unknown = unknown
    return self
end

function champ:serialize()
    return (string.format("(id: %d, name: %s, unknown: %s)", self.id, self.name, self.unknown))
end

champ.__tostring = champ.serialize
