champ = {}
champ.__index = champ

function champ.new(id, name)
    assert(type(id) == "number")
    assert(type(name) == "string")

    local self = setmetatable({}, champ)
    self.id = id
    self.name = name
    return self
end

function champ:serialize()
    return (string.format("(id: %d, name: %s)", self.id, self.name))
end

champ.__tostring = champ.serialize
