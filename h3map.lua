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

cleared = 1
content = ""

function h3map.load(c)
    cleared = 1
    content = c
    return h3map.parse("info")
end

function h3map.parse(key, index, map_version)
    local self = setmetatable({}, h3map)
    for j, v in ipairs(descs[key]) do
        local k = v.label
        local z = v.length
        local t = v.type
        z = tonumber(z) or z:calculate(self, map_version)
        if t == "str" or t == "bytes" then
            if(z >= 30000) then 
                z = 0
                print("\27[31WARNING:\27[39 Data length for "..k.." exceeds 30000.")
            end
        end
        local portion = content:sub(cleared, cleared + z - 1)
        if t == "bytes" then
            portion = string.format("offset: 0x%X, data: %q", cleared - 1, portion)
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
            portion = {}
            for i = 1, z do
                portion[i] = h3map.parse(t, i, self.map_version)
                if t == "player" then portion[i].alias = player_colors[i] end
            end
            z = 0
            t = nil
        end
        self[k] = portion
        cleared = cleared + z
    end
    self.desc = descs[key]
    self.index = index
    return self
end

function h3map:special_type(bytes_to_type, z)
    local list = {}
    for i = 1, z do
        local portion = content:sub(cleared)
        local type_cleared, type_ret = bytes_to_type(portion, i)
        list[i] = type_ret
        cleared = cleared + type_cleared
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
    return self:_serialize(c.print)
end

function h3map:_serialize(print_conf, indent)
    -- Initialize variables
    local ret = ""
    indent = indent or 0
    if print_conf[self.label] == false or print_conf[self.alias] == false then return ret end
    -- Label if there is an alias
    if self.alias then
        ret = ret:append_indented_line(indent, self.alias)
        ret = ret:append_indented_line(indent, string.rep("-", string.len(self.alias)))
    end
    -- Main print loop: desc is numbered for a print order
    for i, v in ipairs(self.desc) do
        -- Only append if not mentioned in conf print section or is set to true
        if print_conf[v.label] == nil or print_conf[v.label] then
            local data = self[v.label]
            -- If type is table, the we have a list of something (eg. players)
            if type(data) == "table" then
                -- Open brackets for list, unless empty
                ret = ret:append_indented_line(indent, v.label, table.getn(data) > 0 and "[" or "empty")
                -- Go through list and print recursively
                for j, node in ipairs(data) do
                    if(getmetatable(node) == h3map) then
                        ret = ret .. node:_serialize(print_conf[v.type], indent + 1)
                    else
                        print("\27[34mINFO:\27[39m "..v.label.." is using a custom class")
                        ret = ret:append_indented_line(indent + 1, tostring(node))
                    end
                end
                -- Close brackets for list, unless empty
                if table.getn(data) > 0 then ret = ret:append_indented_line(indent, "]") end
            else
                ret = ret:append_indented_line(indent, v.label, v.type, data)
            end
        end
    end

    return ret .. "\n"
end

h3map.__tostring = h3map.serialize