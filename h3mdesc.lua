require 'stringutils'

h3mdesc = {}
h3mdesc.__index = h3mdesc

desc_prefix = "README.h3m."
desc_filenames = {"header", "player", "victory", "next"}

function h3mdesc.getdescs()
    local descs = {}
    for i, v in ipairs(desc_filenames) do
        descs[v] = h3mdesc.read(desc_prefix .. v)
    end
    return descs
end

function h3mdesc.read(filename)
    local self = setmetatable({}, h3mdesc)
    local file = assert(io.open(filename, 'r'))
    file:read('*line', '*line')
    local i = 1
    for line in file:lines() do
        line = line:trim()
        if line ~= "" then
            match = line:gmatch("|([^|]*)|([^|]*)|([^|]*)|.*")
            self[i] = {}
            for c, z, t in match do
                self[i].datalabel = c:trim()
                self[i].datalen = z:trim()
                self[i].datatype = t:trim()
            end
        end
        i = i + 1
    end
    return self
end

function h3mdesc:serialize()
    local ret = ""
    for i, v in ipairs(self) do
            ret = ret..v.datalabel..": "..v.datalen..", "..v.datatype.."\n"
    end
    return ret
end
