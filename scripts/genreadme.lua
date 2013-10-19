#!/usr/bin/env lua
require 'conf'

function document_file(prefix, filename)
    local file = assert(io.open(prefix .. filename, "r"))
    local ret = (
        "### " .. filename:gsub("^%l", string.upper) .. "\n" ..
        file:read("*all") ..
        "\n"
    )
    file:close()
    return ret
end

love = {}
c = {}

h3mdesc_conf(c)

out = [[# Freeheroes 3


Freeheroes 3 is a reimplementation of Heroes of Might and Magic 3.

The framework used is [LOVE2D](https://love2d.org/) for its simplicity and for the fact it is easily ported to mobile and web.


There is a python branch for implementation using pygame.


The aim of this project is to:
1. [ ] Read the map file formats for all three versions
1. [ ] Display the assets properly
1. [ ] Reimplement gameplay
1. [ ] Reimplement the editor
1. [ ] Improve upon the game


# H3M file format


This is a breakdown (work in progress) of the Heroes of Might and Magic 3 h3m map file format.


The official maps are compressed using gz compression, to have a look at the file contents, rename it to .gz and extract it, then use a hex editor like ghex.


The maps come with the game which you can get through GOG.


For the game to find these maps, edit conf.lua.


## General file structure (in order)

]]

filenames = c.filenames
for i, v in ipairs(c.filenames) do
    if v ~= 'next' then
        out = out..document_file(c.prefix, v)
    end
end

out = out.."## Custom types\n\n"
out = out..document_file(c.prefix, 'champ')
out = out..document_file(c.prefix, 'rumor')

local file = assert(io.open("README.md", "w"))
file:write(out)
file:close()

