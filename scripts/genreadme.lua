#!/usr/bin/env lua
require 'conf'

love = {}
c = {}

h3mdesc_conf(c)

out = "# H3M file format\n\n"

for i, v in ipairs(c.filenames) do
    if(v ~= "next") then
        local file = assert(io.open(c.prefix .. v, "r"))
        out = (
            out ..
            "## " .. v:gsub("^%l", string.upper) .. "\n" ..
            file:read("*all") ..
            "\n"
        )
        file:close()
    end
end

local file = assert(io.open("README.md", "w"))
file:write(out)
file:close()

