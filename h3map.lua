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
    self:parse("info")
    --[[for i, v in pairs(player_colors) do
        local player_color = "player_" .. v
        self:parse(player_color, descs["player"])
        self[player_color].player_color = v
    end
    self:parse("victory", descs["victory"])
    self:parse("teams", descs["teams"])
    self:parse("next", descs["next"])]]
    return self
end

function h3map:parse(key, index, map_version)
    local h3m_map = {}
    for j, v in ipairs(descs[key]) do
        local k = v.datalabel
        local z = v.datalen
        local t = v.datatype
        z = tonumber(z) or z:calculate(h3m_map, map_version)
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
        elseif descs[t] then
            local desc_table = {}
            for i = 1, z do
                desc_table[i] = self:parse(t, i, h3m_map.map_version)
                if t == "player" then desc_table[i].alias = player_colors[i] end
            end
            z = 0
            portion = desc_table
            t = nil
        end
        h3m_map[k] = portion
        self.cleared = self.cleared + z
    end
    h3m_map.desc = descs[key]
    h3m_map.index = index
    if index == nil then
        self[key] = h3m_map
    end
    return h3m_map
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
    -- TODO: Can probably get rid of key
    return (
        (c.print.info and ("Info\n----\n" .. self:header_serialize("info", c.print) ..
            "\n") or "") ..--[[
        (c.print.players and self:players_serialize(c) or "") ..
        (c.print.victory and ("Victory\n-------\n" .. self:header_serialize("victory", c.print) ..
            "\n") or "") ..
        (c.print.teams and ("Teams\n-----\n" .. self:header_serialize("teams", c.print) ..
            "\n") or "") ..
        (c.print.next and ("Next\n----\n" .. self:header_serialize("next", c.print) ..
            "\n") or "") ..
        (c.print.offset and (string.format("Stopped parsing at offset: 0x%X", self.cleared - 1) ..
        "\n") or "") ..]]
        "\n"
    )
end

function h3map:header_serialize(key, print_conf, indent, index)
    local ret = ""
    indent = indent or 0
    local obj = index == nil and self[key] or self.info[key][index]
    local alias = index and obj.alias
    if print_conf[alias] == false then return ret end
    if alias then
        ret = ret..string.rep("\t", indent)..alias.."\n"
        ret = ret..string.rep("\t", indent)..string.rep("-", string.len(alias)).."\n"
    end
    for i, v in ipairs(obj.desc) do
        local label = v.datalabel
        local t = v.datatype
        local out = obj[label]
        if print_conf[label] == nil or print_conf[label] then
            -- Indent if child of another label, in case of lists
            ret = ret..string.rep("\t", indent)
            ret = ret..tostring(label).."\t"
            -- In case of custom data structures and lists
            if type(out) == "table" and getmetatable(out) == nil then
                ret = ret.."["..(table.getn(out) > 0 and "\n" or "]\n")
                for j, w in ipairs(out) do
                    if descs[t] then -- list items
                        ret = ret..self:header_serialize(label, print_conf[t], indent + 1, j).."\n"
                    else -- custom datastructures
                        ret = ret..string.rep("\t", indent + 1)
                        ret = ret..tostring(w).."\n"
                    end
                end
                -- Indent to match parent indentation, unless list was empty
                ret = ret..(table.getn(out) > 0 and (string.rep("\t", indent).."]\n") or " ")
            else
                ret = ret..tostring(out).."\n"
            end
        end
    end
    return ret
end
