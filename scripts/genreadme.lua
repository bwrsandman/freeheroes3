#!/usr/bin/env lua
require 'h3mdesc'

out = "# H3M file format\n\n"

for i, v in ipairs(desc_filenames) do
    local file = assert(io.open(desc_prefix .. v, "r"))
    out = (
        out ..
        "## " .. v:gsub("^%l", string.upper) .. "\n" ..
        file:read("*all") ..
        "\n"
    )
    file:close()
end

local file = assert(io.open("README.md", "w"))
file:write(out)
file:close()

