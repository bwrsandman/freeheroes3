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

def substitute(string, h3m_map):
    ret = string.strip()
    if not ret:
        return
    try:
        ret = int(ret, 0)
    except:
        ret = int(h3m_map[ret])
    return ret



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
                neq = z.split("!=")
                eq = z.split("==")
                if len(neq) == 2:
                    size = int(substitute(neq[0], h3m_map) != substitute(neq[1], h3m_map))
                elif len(eq) == 2:
                    size = int(substitute(eq[0], h3m_map) == substitute(eq[1], h3m_map))
                else:
                    size = 1
                    for i in z.split("*"):
                        size *= substitute(i, h3m_map)
            buf = h3m.read(size)
            if t in [int, bool]:
                buf = t.from_bytes(buf, byteorder='little')
            elif t is str:
                buf = buf.decode("utf-8")
            h3m_map[k] = t(buf)
            print(k + (("(%d)" % len(h3m_map[k])) if t is bytes else "") + ": " + str(h3m_map[k]))
        print()
