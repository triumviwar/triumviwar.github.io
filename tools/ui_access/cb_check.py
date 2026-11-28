#!/usr/bin/env python3
"""Colour-blind check for the team colours (job ui-access-phone, docs/ui_access_phone.md).

Simulates protanopia, deuteranopia and tritanopia (Machado, Oliveira & Fernandes 2009, severity 1.0) on each palette
and prints the smallest CIE76 Lab distance between any two team colours (the first 4, the players of most matches,
and all 8). Over ~20 two colours are told apart at a glance; under ~10 they look the same.
Run: python3 tools/ui_access/cb_check.py   (palettes copied from scripts/ui/colour_access.gd; keep them in step)
"""
import itertools, math, re, sys, pathlib

M = {
    "normal": [[1, 0, 0], [0, 1, 0], [0, 0, 1]],
    "protan": [[0.152286, 1.052583, -0.204868], [0.114503, 0.786281, 0.099216], [-0.003882, -0.048116, 1.051998]],
    "deutan": [[0.367322, 0.860646, -0.227968], [0.280085, 0.672501, 0.047413], [-0.011820, 0.042940, 0.968881]],
    "tritan": [[1.255528, -0.076749, -0.178779], [-0.078411, 0.930809, 0.147602], [0.004733, 0.691367, 0.303900]],
}

def lin(c): return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
def gam(c): c = min(1, max(0, c)); return 12.92 * c if c <= 0.0031308 else 1.055 * c ** (1 / 2.4) - 0.055

def sim(rgb, m):
    l = [lin(x) for x in rgb]
    return [gam(sum(m[i][j] * l[j] for j in range(3))) for i in range(3)]

def lab(rgb):
    r, g, b = [lin(x) for x in rgb]
    x = (0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047
    y = 0.2126 * r + 0.7152 * g + 0.0722 * b
    z = (0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883
    f = lambda t: t ** (1 / 3) if t > 0.008856 else 7.787 * t + 16 / 116
    return [116 * f(y) - 16, 500 * (f(x) - f(y)), 200 * (f(y) - f(z))]

def hexrgb(h): h = h.lstrip("#"); return [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]

def worst(cols, m):
    best = (1e9, None)
    for a, b in itertools.combinations(range(len(cols)), 2):
        d = math.dist(lab(sim(cols[a], m)), lab(sim(cols[b], m)))
        if d < best[0]:
            best = (d, (a, b))
    return best

def palettes():
    src = (pathlib.Path(__file__).resolve().parents[2] / "scripts/ui/colour_access.gd").read_text()
    out = {"default": None}
    defs = (pathlib.Path(__file__).resolve().parents[2] / "scripts/defs.gd").read_text()
    out["default"] = re.findall(r'\["\w+", Color\("(#[0-9a-f]{6})"\)\]', defs)[:8]
    for name in ("RED_GREEN", "BLUE_YELLOW"):
        m = re.search(name + r' := \[(.*?)\n\]', src, re.S)
        out[name] = re.findall(r'"(#[0-9a-fA-F]{6})"', m.group(1))
    return out

NAMES = ["Blue", "Red", "Green", "Yellow", "Purple", "Orange", "Teal", "Pink"]
if __name__ == "__main__":
    for pn, hexes in palettes().items():
        cols = [hexrgb(h) for h in hexes]
        print(pn)
        for vision in M:
            for n in (2, 4, 8):
                d, pair = worst(cols[:n], M[vision])
                print("  %-7s first %d: closest %5.1f (%s / %s)" % (vision, n, d, NAMES[pair[0]], NAMES[pair[1]]))
