#!/usr/bin/env lua

require 'stringutils'

str1 = "\x11\x01\x00\x00\x00a"
len1, champ1 = str1:bytes_to_champ()

str2 = "\x11\x10\x00\x00\x00hello world1234!"
len2, champ2 = str2:bytes_to_champ()

print(tostring(champ1))
print(tostring(champ2))
