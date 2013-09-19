#!/usr/bin/env lua
require 'zlib'

lfs = love.filesystem

-- trim whitespace from both ends of string
function string:trim()
    return self:find'^%s*$' and '' or self:match'^%s*(.*%S)'
end

function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

function string:bytes_to_int()
    local t = {self:byte(1, -1)}
    local n = 0
    for k = 1, #t do
        n = n + t[k] * 2^((k - 1) * 8)
    end
    return n
end

h3m_description = {}
h3m_file = {}
player_colors = {"red", "blue", "tan", "green", "orange", "purple", "teal", "pink"}

function h3m_description.read(filename)
    description = {}
    file = assert(io.open(filename, 'r'))
    file:read('*line', '*line')
    i = 1
    for line in file:lines() do
        line = line:trim()
        if line ~= "" then
            match = line:gmatch("|([^|]*)|([^|]*)|([^|]*)|.*")
            description[i] = {}
            for c, z, t in match do
                description[i].datalabel = c:trim()
                description[i].datalen = z:trim()
                description[i].datatype = t:trim()
            end
        end
        i = i + 1
    end
    return description
end

function h3m_description.serialize(description)
    local ret = ""
    for i, v in ipairs(description) do
            ret = ret..v.datalabel..": "..v.datalen..", "..v.datatype.."\n"
    end
    return ret
end

-- Read the description file
header_descr_filename = 'README.h3m.header'
player_descr_filename = 'README.h3m.player'
mapdir = "TestMaps"

function string:substitute(map)
    local s = self:trim()
    local ret = map[s]
    if ret == nil then
        ret = s
    elseif type(ret) == "boolean" then
        ret = ret and 1 or 0
    end
    ret = tonumber(ret)
    assert(ret ~= nil)
    return ret
end

function string:calculate(map)
    local ret = nil
    local eq = nil
    if self:match("!=") then
        eq = self:split("!=")
        assert(#eq == 2)
        ret = (eq[1]:substitute(map) ~= eq[2]:substitute(map)) and 1 or 0
    elseif self:match("==") then
        eq = self:split("==")
        assert(#eq == 2)
        ret = (eq[1]:substitute(map) == eq[2]:substitute(map)) and 1 or 0
    -- Contains multiplier, perform calculation
    elseif self:match("%*") then
        ret = 1
        for i, x in pairs(self:split("*")) do
            ret = x:substitute(map) * ret
        end
    else
        ret = map[self]
    end
    ret = tonumber(ret)
    assert(ret ~= nil)
    return ret
end

function parse(contents, desc, cleared, map_version)
    local h3m_map = {}
    h3m_map["map_version"] = map_version
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
        local portion = contents:sub(cleared, cleared + z - 1)
        if t == "bytes" then
            h3m_map[k] = string.format("offset: 0x%x, data: %q", cleared - 1, portion)
        elseif t == "int" then
            h3m_map[k] = portion:bytes_to_int()
        elseif t == "bool" then
            h3m_map[k] = portion:bytes_to_int() ~= 0
        elseif t == "grid" then
            h3m_map[k] = "grid"
        else
            h3m_map[k] = portion
        end
        cleared = cleared + z
    end
    return cleared, h3m_map
end

function h3m_map_print(header)
    for i, v in pairs(header) do
        print(i, v) 
    end
end

function load_map(filename)
    print("Found map: "..filename)
    print("==========="..string.rep("=",filename:len()))
    print()
    local contents, size = lfs.read(filename)
    local cleared, h3m_map_header = parse(contents, header_desc, 1)
    local h3m_map_players = {}
    for i, v in pairs(player_colors) do
        cleared, h3m_map_players[i] = parse(contents, player_desc, cleared, h3m_map_header["map_version"])
    end
    h3m_map_print(h3m_map_header)
    print()
    print("Players:")
    print("--------")
    h3m_map_print(h3m_map_players)
    print()
    print()
end

function love.load()
    header_desc = h3m_description.read(header_descr_filename)
    player_desc = h3m_description.read(player_descr_filename)
    print(h3m_description.serialize(header_desc))
    for i, mapname in ipairs(lfs.enumerate(mapdir)) do
        local filename = mapdir.."/"..mapname
        if lfs.isFile(filename) and not mapname:find('[.]gz$') then
            load_map(filename)
        end
    end
end

function love.draw()
    love.graphics.print("Game screen", 50, 50)
end
