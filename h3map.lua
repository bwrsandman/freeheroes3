require 'h3mdesc'
require 'stringutils'
require 'conf'
require 'coord'

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

function h3map.parse(key, index, parent)
    local self = setmetatable({_parent=parent}, h3map)
    for j, v in ipairs(descs[key]) do
        local size = tonumber(v.length) or v.length:calculate(self)
        if v.type == "str" or v.type == "bytes" then
            if(size >= 30000) then
                size = 0
                print("\27[33mWARNING:\27[39m Data length for " .. v.label .. " exceeds 30000.")
            end
        end
        local portion = content:sub(cleared, cleared + size - 1)
        if v.type == "bytes" then
            portion = string.format("offset: 0x%X, data: %q", cleared - 1, portion)
        elseif v.type == "int" then
            portion = portion:bytes_to_int()
        elseif v.type == "bool" then
            portion = portion:bytes_to_int() ~= 0
        elseif v.type == "coord" then
            portion = portion:bytes_to_coord()
        elseif descs[v.type] then
            portion = {}
            for i = 1, size do
                portion[i] = h3map.parse(v.type, i, self)
                if v.type == "player" then portion[i].alias = player_colors[i] end
            end
            size = 0
        end
        self[v.label] = portion
        cleared = cleared + size
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
        },
    }
    h3map_conf(c)
    return self:_serialize(c.print)
end

function h3map:_serialize(print_conf, indent)
    -- Initialize variables
    local ret = ""
    print_conf = print_conf or {}
    indent = indent or 0
    -- Check if this alias or label was meant to be hidden
    if print_conf[self.alias] == false or print_conf[self.label] == false then
        return ret
    end
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
            if type(data) == "table" and getmetatable(data) == nil then
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
                -- Highlight fields which are bytes
                if (v.type == "bytes") then ret = ret .. "\27[34m" end
                ret = ret:append_indented_line(indent, v.label, v.type, data)
                if (v.type == "bytes") then ret = ret .. "\27[39m" end
            end
        end
    end

    return ret .. "\n"
end

h3map.__tostring = h3map.serialize