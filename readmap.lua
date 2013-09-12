#!/usr/bin/env lua
require 'zlib'

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
    ret = ""
    for i, v in ipairs(description) do
            ret = ret..v.datalabel..": "..v.datalen..", "..v.datatype.."\n"
    end
    return ret
end

-- Read the description file
filename = 'h3m.README'
mapdir = "TestMaps"

function string:substitute(map)
    ret = nil
    if not self:match("%*") then
        ret = map[self]
    else -- Contains multiplier, perform calculation
        ret = nil
        for i, x in pairs(self:split("*")) do
            x = x:trim()
            x = map[x] or x
            ret = x * (ret or 1)
        end
    end
    return ret
end

function love.load()
    local lfs = love.filesystem
    desc = h3m_description.read(filename)
    print(h3m_description.serialize(desc))
    for i, mapname in ipairs(lfs.enumerate(mapdir)) do
        filename = mapdir.."/"..mapname
        if lfs.isFile(filename) and not mapname:find('[.]gz$') then
            print("Found map: "..filename)
            contents, size = lfs.read(filename)
            cleared = 1
            h3m_map = {}
            for j, v in ipairs(desc) do
                k = v.datalabel
                z = v.datalen
                t = v.datatype
                if t == "int" or t == "bytes" or t == "bool" then
                    z = tonumber(z) or tonumber(z:substitute(h3m_map))
                -- Variable sizes
                elseif t == "str" or t == "grid" then
                    z = tonumber(z:substitute(h3m_map)) or tonumber(z)
                end
                portion = contents:sub(cleared, cleared + z - 1)
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
                print(j, k, h3m_map[k])
            end
            print()
        end
    end
end

function love.draw()
    love.graphics.print("Game screen", 50, 50)
end
