rumor = {}
rumor.__index = rumor

function string:bytes_to_rumor(id)
    local pointer = 1
    local title_len = self:sub(pointer, pointer + 3):bytes_to_int_verify(id, "rumor title")
    pointer = pointer + 4
    local title = self:sub(pointer, pointer + title_len - 1)
    pointer = pointer + title_len
    local content_len = self:sub(pointer, pointer + 3):bytes_to_int_verify(id, "rumor content")
    pointer = pointer + 4
    local content = self:sub(pointer, pointer + content_len - 1)
    pointer = pointer + content_len
    return pointer - 1, rumor.new(title, content)
end

function rumor.new(title, content)
    assert(type(title) == "string")
    assert(type(content) == "string")

    local self = setmetatable({}, rumor)
    self.title = title
    self.content = content
    return self
end

function rumor:serialize()
    return (string.format("(title: %s, content: %s)", self.title, self.content))
end

rumor.__tostring = rumor.serialize
