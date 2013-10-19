champ = {}
champ.__index = champ

function string:bytes_to_champ(id)
    if self:len() < 5 then return nil end
    local id = self:sub(1, 1):bytes_to_int()
    local str_len = self:sub(2, 2):bytes_to_int_verify(id, "champ name")
    local unknown = self:sub(3, 5):bytes_to_int()
    if self:len() < 5 + str_len then return 0, nil end
    local name = self:sub(6, 5 + str_len)
    return 5 + str_len, champ.new(id, name, unknown)
end

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
