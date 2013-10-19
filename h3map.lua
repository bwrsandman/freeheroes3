require 'h3mdesc'
require 'stringutils'
require 'conf'
require 'coord'
require 'champ'
require 'rumor'

local player_colors = {"red", "blue", "tan", "green", "orange", "purple", "teal", "pink"}
local descs = h3mdesc.getdescs()

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
    self:parse("teams", descs["teams"])
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
        z = tonumber(z) or z:calculate(h3m_map)
        if t == "str" or t == "bytes" then
            if(z >= 30000) then 
                z = 0
                print("Data length for "..k.." exceeds 30000.")
            end
        end
        local portion = self.content:sub(self.cleared, self.cleared + z - 1)
        if t == "bytes" then
            portion = string.format("offset: 0x%X, data: %q", self.cleared - 1, portion)
        elseif t == "int" then
            portion = portion:bytes_to_int()
        elseif t == "bool" then
            portion = portion:bytes_to_int() ~= 0
        elseif t == "coord" then
            portion = portion:bytes_to_coord()
        elseif t == "grid" then
            portion = "grid"
        elseif t == "champ" then
            z, portion = self:special_type(string.bytes_to_champ, z)
        elseif t == "rumor" then
            z, portion = self:special_type(string.bytes_to_rumor, z)
        end
        h3m_map[k] = portion
        self.cleared = self.cleared + z
    end
    if index ~= "info" then
        h3m_map.map_version = nil
    end
    h3m_map.desc = desc
    self[index] = h3m_map
end

function h3map:special_type(bytes_to_type, z)
    local list = {}
    for i = 1, z do
        local portion = self.content:sub(self.cleared)
        local type_cleared, type_ret = bytes_to_type(portion, i)
        list[i] = type_ret
        self.cleared = self.cleared + type_cleared
    end
    return 0, list
end

function h3map:serialize()
    local c = {
        print = {
            info = true,
            players = true,
            player = {
                red = true,
                blue = true,
                tan = true,
                green = true,
                orange = true,
                purple = true,
                teal = true,
                pink = true,
            },
            victory = true,
            next = true,
            offset = true,
        }
    }
    h3map_conf(c)
    return (
        (c.print.info and ("Info\n----\n" .. self:header_serialize("info") ..
            "\n") or "") ..
        (c.print.players and self:players_serialize(c) or "") ..
        (c.print.victory and ("Victory\n-------\n" .. self:header_serialize("victory") ..
            "\n") or "") ..
        (c.print.teams and ("Teams\n-----\n" .. self:header_serialize("teams") ..
            "\n") or "") ..
        (c.print.next and ("Next\n----\n" .. self:header_serialize("next") ..
            "\n") or "") ..
        (c.print.offset and (string.format("Stopped parsing at offset: 0x%X", self.cleared - 1) ..
        "\n") or "") ..
        "\n"
    )
end

function h3map:players_serialize(c)
    local ret = ""
    for i, v in pairs(player_colors) do
        if c.print.player[v] then
            local player_color = "player_" .. v
            ret = ret .. v .. " player:\n" .. self:header_serialize(player_color) .. "\n"
        end
    end
    return (
        "Players:\n" ..
        "--------\n" ..
        ret
    )
end

function h3map:header_serialize(index)
    local ret = ""
    for i, v in ipairs(self[index].desc) do
        local label = v.datalabel
        local out = self[index][label]
        ret = ret..tostring(label).."\t"
        if type(out) == "table" and getmetatable(out) == nil then
            ret = ret.."["
            for j, w in ipairs(out) do
                ret = ret..tostring(w).."\n"
            end
            ret = ret.."]\n"
        else
            ret = ret..tostring(out).."\n"
        end
    end
    return ret
end
