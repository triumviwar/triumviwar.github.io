#!/usr/bin/env python3
"""Pictures and source sheets for the sprite audit's findings (docs/sprite_hallucination_audit.md).

    python3 tools/audit/crop_findings.py docs/sprite_audit/findings.json docs/shots/sprite_audit

For every finding with a file: the whole strip (or picture) on the plain background, frames numbered, the frames named
in the finding framed in red, at up to 3x (shrunk to 1200 px wide at most). The finding gets "picture" (its path) and
"source" (the likeliest ChatGPT sheets in art/redraws/ and art/ by name), and the JSON is written back.
"""
import glob
import json
import os
import re
import sys

from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(__file__))
import contact_sheets as cs  # noqa: E402

ROOT = cs.ROOT


def strip_picture(path, frames, out):
	name = os.path.basename(os.path.dirname(path))
	cells = cs.unit_cells()
	im = Image.open(path)
	cell = None
	if "/assets/units/" in path and name in cells:
		c = cells[name]
		if abs(im.size[1] - c[1]) <= max(4, c[1] * 0.6):
			cell = c
	if im.size[0] * im.size[1] > 700 * 700:
		frs = [im.convert("RGBA")]
	else:
		_, frs = cs.frames_of(path, cell)
	fw, fh = frs[0].size
	sc = max(1.0, min(3.0, 160.0 / fh))
	sc = min(sc, 1200.0 / (fw * len(frs) + 4 * len(frs)))
	sc = max(sc, 0.2)
	w = int(fw * sc)
	h = int(fh * sc)
	img = Image.new("RGBA", ((w + 6) * len(frs) + 6, h + 26), cs.BG)
	d = ImageDraw.Draw(img)
	f = cs._font(12)
	for i, fr in enumerate(frs):
		x = 6 + i * (w + 6)
		d.rectangle((x, 20, x + w - 1, 20 + h - 1), fill=cs.CELL_BG)
		img.alpha_composite(fr.resize((max(1, w), max(1, h)), Image.NEAREST if sc >= 1 else Image.LANCZOS), (x, 20))
		bad = i in frames
		d.text((x + 2, 3), str(i), fill=(200, 0, 0) if bad else (60, 60, 60), font=f)
		if bad:
			d.rectangle((x - 2, 18, x + w + 1, 21 + h), outline=(220, 0, 0), width=2)
	img.convert("RGB").save(out)


def sources(path):
	"""The likeliest source sheets (ChatGPT answers) for an asset file, by name."""
	rel = os.path.relpath(path, ROOT)
	parts = rel.split("/")
	if parts[1] == "units":
		unit = parts[2]
		stem = os.path.splitext(parts[3])[0]
		anim = stem.rsplit("_", 1)[0] if stem.rsplit("_", 1)[-1] in cs.DIR_ORDER else stem
	else:
		stem = os.path.splitext(parts[-1])[0]
		unit = re.split(r"_(built|construction|damaged|destroyed|anim|\d)", stem)[0]
		anim = ""
	pool = glob.glob(os.path.join(ROOT, "art", "**", "*.*"), recursive=True)
	pool = [p for p in pool if p.lower().endswith((".png", ".jpg", ".jpeg", ".webp"))]
	def score(p):
		b = os.path.basename(p).lower()
		s = 0
		if unit in b:
			s += 3
		elif unit.split("_")[0] in b and len(unit.split("_")[0]) > 3:
			s += 2
		else:
			return 0
		if anim and anim in b:
			s += 2
		if "chatgpt" in b:
			s += 1
		return s
	scored = sorted(((score(p), p) for p in pool), key=lambda t: (-t[0], t[1]))
	best = [os.path.relpath(p, ROOT) for s, p in scored if s >= 2][:3]
	return best


def main():
	src, out = sys.argv[1], sys.argv[2]
	os.makedirs(out, exist_ok=True)
	data = json.load(open(src))
	for k, x in enumerate(data):
		p = x.get("file", "")
		full = os.path.join(ROOT, p)
		if not p or not os.path.isfile(full):
			continue
		pic = os.path.join(out, "%03d_%s.png" % (k + 1, re.sub(r"[^a-z0-9]+", "_", os.path.splitext(p)[0].lower().replace("assets/", ""))))
		try:
			strip_picture(full, x.get("frames") or [], pic)
			x["picture"] = os.path.relpath(pic, ROOT)
		except Exception as e:  # (a picture the tool can't cut: the finding stays without one)
			print("no picture for", p, e)
		x["source"] = sources(full)
	json.dump(data, open(src, "w"), indent=1)
	print("pictures in", out)


if __name__ == "__main__":
	main()
