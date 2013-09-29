#!/usr/bin/env lua

require 'stringutils'

str1 = "\x11\x0A\x01"
coord1 = str1:bytes_to_coord()

str2 = ""
coord2 = str2:bytes_to_coord()

print(tostring(coord1))
print(tostring(coord2))
