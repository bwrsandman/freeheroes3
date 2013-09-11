#!/usr/bin/env python

from operator import mul
from functools import reduce
import os
import sys


class grid():
    def __init__(self, buf):
        self.length = len(buf)

    def __str__(self):
        return str(self.length) + " bytes"


def read_h3m_description():
    lines = open('h3m.README').read().split("\n")[2:]
    file_legend = []
    for l in lines:
        if not l:
            continue
        trips = [i.strip() for i in l.split('|') if i]
        assert len(trips) >= 3
        c, z, t, *r = trips
        try:
            t = getattr(sys.modules[__name__], t)
        except:
            t = getattr(__builtins__, t)
        try:
            z = int(z, 0)
        except:
            pass
        trips = c, z, t
        file_legend.append(trips)
    return file_legend


file_legend = read_h3m_description()

for mapname in os.listdir("TestMaps"):
    if os.path.splitext(mapname)[1]:
        continue
    filename = "TestMaps/" + mapname
    with open(filename, 'rb') as h3m:
        print(filename)
        h3m_map = {}
        for k, z, t in file_legend:
            try:
                size = int(z)
            except ValueError:
                # A string, find corresponding value, mult if needed.
                #size = int(h3m_map(z))
                size = 1
                for i in z.split("*"):
                    i = i.strip()
                    if not i:
                        continue
                    try:
                        size *= int(i, 0)
                    except:
                        size *= int(h3m_map[i])
            buf = h3m.read(size)
            if t in [int, bool]:
                buf = t.from_bytes(buf, byteorder='little')
            elif t is str:
                buf = buf.decode("utf-8")
            h3m_map[k] = t(buf)
            print(k + (("(%d)" % len(h3m_map[k])) if t is bytes else "") + ": " + str(h3m_map[k]))
        print()
