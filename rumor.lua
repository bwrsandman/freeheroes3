rumor = {}
rumor.__index = rumor

function rumor.new(id, title, content)
    assert(type(id) == "number")
    assert(type(title) == "string")
    assert(type(content) == "string")

    local self = setmetatable({}, rumor)
    self.id = id
    self.title = title
    self.content = content
    return self
end

function rumor:serialize()
    return (string.format("(id: %d, title: %s, content: %s)", self.id, self.title, self.content))
end

rumor.__tostring = rumor.serialize
