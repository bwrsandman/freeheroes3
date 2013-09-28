require 'h3mdesc'
require 'stringutils'

local player_colors = {"red", "blue", "tan", "green", "orange", "purple", "teal", "pink"}
local descs = descs or h3mdesc.getdescs()

h3map = {}
h3map.__index = h3map

function h3map.load(content)
    local self = setmetatable({}, h3map)
    self.cleared = 1
    self.content = content
    self:parse("info", descs["info"])
    for i, v in pairs(player_colors) do
        local player_color = "player_" .. v
        self:parse(player_color, descs["player"])
        self[player_color].player_color = v
    end
    self:parse("victory", descs["victory"])
    self:parse("next", descs["next"])
    return self
end

function h3map:parse(index, desc)
    local h3m_map = {}
    h3m_map.map_version = self.info and self.info.map_version
    for j, v in ipairs(desc) do
        local k = v.datalabel
        local z = v.datalen
        local t = v.datatype
        if t == "int" or t == "bytes" or t == "bool" then
            z = tonumber(z) or z:calculate(h3m_map)
        -- Variable sizes
        elseif t == "str" or t == "grid" then
            z = z:calculate(h3m_map) or tonumber(z)
        end
        local portion = self.content:sub(self.cleared, self.cleared + z - 1)
        if t == "bytes" then
            h3m_map[k] = string.format("offset: 0x%x, data: %q", self.cleared - 1, portion)
        elseif t == "int" then
            h3m_map[k] = portion:bytes_to_int()
        elseif t == "bool" then
            h3m_map[k] = portion:bytes_to_int() ~= 0
        elseif t == "grid" then
            h3m_map[k] = "grid"
        else
            h3m_map[k] = portion
        end
        self.cleared = self.cleared + z
    end
    if index ~= "info" then
        h3m_map.map_version = nil
    end
    self[index] = h3m_map
end

function h3map:serialize()
    return (
        self:header_serialize("info") ..
        "\n" ..
        self:players_serialize() ..
        self:header_serialize("victory") ..
        "\n" ..
        self:header_serialize("next") ..
        "\n" ..
        string.format("Stopped parsing at offset: 0x%x", self.cleared - 1) ..
        "\n\n"
    )
end

function h3map:players_serialize()
    local ret = ""
    for i, v in pairs(player_colors) do
        local player_color = "player_" .. v
        ret = ret .. v .. " player:\n" .. self:header_serialize(player_color) .. "\n"
    end
    return (
        "Players:\n" ..
        "--------\n" ..
        ret
    )
end

function h3map:header_serialize(index)
    local ret = ""
    local header = self[index]
    for i, v in pairs(header) do
        ret = ret .. tostring(i) .. "\t" .. tostring(v) .. "\n"
    end
    return ret
end
