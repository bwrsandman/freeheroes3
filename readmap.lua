#!/usr/bin/env lua
require 'zlib'
require 'h3map'

local mapdir = "TestMaps"

function love.load()
    for i, mapname in ipairs(love.filesystem.enumerate(mapdir)) do
        local filename = mapdir.."/"..mapname
        if love.filesystem.isFile(filename) and not mapname:find('[.]gz$') then
            local contents, size = love.filesystem.read(filename)
            print("Found map: "..filename)
            print("==========="..string.rep("=",filename:len()))
            print()
            local map = h3map.load(contents)
            print(map:serialize())
        end
    end
end

function love.draw()
    love.graphics.print("Game screen", 50, 50)
end
