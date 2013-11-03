#!/usr/bin/env lua
require 'stringutils'

testnum = 1

function testcalculate(str, expect)
    print("************* TEST " .. testnum)
    print("Expression:", str)
    print("Expected:  ", expect)
    local result = str:calculate(map)
    if expect ~= result then
        print ("    ---- ERROR")
    print("Got:       ", result)
    end
    print()
    testnum = testnum + 1
end

map = {}
map["test"] = 12

testcalculate("test", 12)
testcalculate("test * test", 144)
testcalculate("test != test", 0)
testcalculate("test == test", 1)
testcalculate("test * 5", 60)
testcalculate("test == test * 5", 5)
testcalculate("5 * test == test", 5)
testcalculate("test != test * 5", 0)
testcalculate("0x4 * test != 0xC", 0)
testcalculate("4 * test != 12", 0)
