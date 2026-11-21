#!/usr/bin/env python3
"""Contact sheets for the sprite hallucination audit (job sprite-hallucination-audit, docs/sprite_hallucination_audit.md).

Every strip the game plays is cut into its frames and laid out on a plain grey background, each frame numbered from 0,
with a thin red line at the feet (the anchor's y) for unit strips, so a frame drawn wrong is easy to spot by eye.

    python3 tools/audit/contact_sheets.py [OUT_DIR] [--only GROUP_OR_NAME ...]

OUT_DIR defaults to /tmp/sprite_audit. Groups: units, buildings, effects, props, icons, ui, world, gear, campaign.
Each unit gets one or more sheets (units_<name>_<k>.png); other folders are grouped by name prefix.

Frame counts: unit cells come from the game's own tables (scripts/art_data.gd, cw_art.gd SHEETS, rebel_art.gd,
band_art.gd, gun_crew_art.gd); any other strip is split by guessing the cell (a width that divides the strip and lands
on see-through columns).

crop(path, frame, out) in this file cuts one frame at 3x for the report's pictures (tools/audit/crop_findings.py).
"""
import glob
import os
import re
import sys

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
BG = (200, 200, 200, 255)
CELL_BG = (214, 214, 214, 255)
FONT_P = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
MAX_W = 1800
MAX_H = 2200


def _font(sz):
	try:
		return ImageFont.truetype(FONT_P, sz)
	except OSError:
		return ImageFont.load_default()


def unit_cells():
	"""name -> (cell_w, cell_h, anchor_y) from the game's tables."""
	out = {}
	pat = re.compile(r'"([a-z_0-9]+)": \{"cell": Vector2i\((\d+), (\d+)\), "anchor": Vector2\(([\d.]+), ([\d.]+)\)')
	for f in ["scripts/art_data.gd", "scripts/campaign/rebel_art.gd", "scripts/band_art.gd", "scripts/gun_crew_art.gd"]:
		p = os.path.join(ROOT, f)
		if os.path.exists(p):
			for m in pat.finditer(open(p).read()):
				out[m.group(1)] = (int(m.group(2)), int(m.group(3)), float(m.group(5)))
	src = open(os.path.join(ROOT, "scripts/cw_art.gd")).read()
	blk = src[src.index("const SHEETS"):src.index("}", src.index("const SHEETS"))]
	for m in re.finditer(r'"([a-z_0-9]+)": \[(\d+), (\d+), ([\d.]+), ([\d.]+)\]', blk):
		out[m.group(1)] = (int(m.group(2)), int(m.group(3)), float(m.group(5)))
	return out


def guess_cell(im):
	"""The most likely frame width of a strip of unknown cell."""
	w, h = im.size
	if w <= h * 1.6:
		return w
	a = im.getchannel("A")
	col = [0] * w
	px = a.load()
	for x in range(w):
		s = 0
		for y in range(0, h, max(1, h // 40)):
			if px[x, y] > 8:
				s += 1
		col[x] = s
	cands = []
	for n in range(2, 65):
		if w % n:
			continue
		cw = w // n
		if cw < h * 0.35 or cw > h * 3.2:
			continue
		# boundaries should be see-through, and every cell should hold something
		score = sum(col[i * cw] + col[i * cw - 1] for i in range(1, n)) / (n - 1)
		if any(sum(col[i * cw:(i + 1) * cw]) == 0 for i in range(n)):
			continue
		cands.append((score, n, cw))
	if not cands:
		return w
	lo = min(c[0] for c in cands)
	# among the cleanest cuts, the most frames (two figures side by side are two frames, not one)
	bw = min((c for c in cands if c[0] <= lo + 0.5), key=lambda c: c[2])[2]
	return bw


def frames_of(path, cell=None):
	im = Image.open(path).convert("RGBA")
	w, h = im.size
	cw = cell[0] if cell else guess_cell(im)
	if cw <= 0 or cw > w:
		cw = w
	n = max(1, w // cw)
	return im, [im.crop((i * cw, 0, (i + 1) * cw, h)) for i in range(n)]


def layout(entries, title, out_path, target_h=96, anchor=None):
	"""entries: [(label, [frames], anchor_y_in_frame or None)]; writes one or more sheets, returns their paths."""
	f_lab = _font(14)
	f_num = _font(11)
	f_tit = _font(18)
	rows = []          # (label, [scaled frames], scale, anchor_px)
	for lab, frs, ay in entries:
		if not frs:
			continue
		fh = frs[0].size[1]
		fw = frs[0].size[0]
		sc = max(0.25, min(3.0, target_h / max(1, fh)))
		if fw * sc > MAX_W - 40:
			sc = (MAX_W - 40) / fw
		sf = [f.resize((max(1, int(f.size[0] * sc)), max(1, int(f.size[1] * sc))), Image.NEAREST) for f in frs]
		rows.append((lab, sf, ay * sc if ay is not None else None))
	sheets = []
	cur, cur_h = [], 40
	def row_h(r):
		lab, sf, _ = r
		cw = sf[0].size[0] + 6
		per = max(1, (MAX_W - 20) // cw)
		lines = (len(sf) + per - 1) // per
		return 20 + lines * (sf[0].size[1] + 18) + 6
	for r in rows:
		rh = row_h(r)
		if cur and cur_h + rh > MAX_H:
			sheets.append(cur)
			cur, cur_h = [], 40
		cur.append(r)
		cur_h += rh
	if cur:
		sheets.append(cur)
	paths = []
	for k, sh in enumerate(sheets):
		H = 40 + sum(row_h(r) for r in sh)
		W = 20
		for lab, sf, _ in sh:
			cw = sf[0].size[0] + 6
			per = max(1, (MAX_W - 20) // cw)
			W = max(W, 20 + min(per, len(sf)) * cw, 20 + int(f_lab.getlength(lab)) + 10)
		W = min(max(W, 400), MAX_W)
		img = Image.new("RGBA", (W, H), BG)
		d = ImageDraw.Draw(img)
		d.text((10, 10), "%s (%d/%d)" % (title, k + 1, len(sheets)), fill=(20, 20, 20), font=f_tit)
		y = 40
		for lab, sf, ay in sh:
			d.text((10, y + 2), "%s  [%d]" % (lab, len(sf)), fill=(10, 10, 90), font=f_lab)
			y += 20
			cw = sf[0].size[0] + 6
			chh = sf[0].size[1] + 18
			per = max(1, (W - 20) // cw)
			for i, f in enumerate(sf):
				x0 = 10 + (i % per) * cw
				y0 = y + (i // per) * chh
				d.rectangle((x0, y0 + 14, x0 + f.size[0] - 1, y0 + 14 + f.size[1] - 1), fill=CELL_BG)
				img.alpha_composite(f, (x0, y0 + 14))
				d.text((x0 + 1, y0), str(i), fill=(150, 0, 0), font=f_num)
				if ay is not None:
					yy = y0 + 14 + int(ay)
					d.line((x0, yy, x0 + f.size[0] - 1, yy), fill=(230, 40, 40, 255), width=1)
			lines = (len(sf) + per - 1) // per
			y += lines * chh + 6
		p = out_path % (k + 1)
		img.convert("RGB").save(p)
		paths.append(p)
	return paths


DIR_ORDER = ["s", "se", "e", "ne", "n", "sw", "w", "nw"]


def _strip_key(name):
	base = os.path.splitext(name)[0]
	parts = base.rsplit("_", 1)
	if len(parts) == 2 and parts[1] in DIR_ORDER:
		return (parts[0], DIR_ORDER.index(parts[1]))
	return (base, 99)


def do_units(out, only):
	cells = unit_cells()
	made = []
	for d in sorted(glob.glob(os.path.join(ROOT, "assets/units/*/"))):
		name = os.path.basename(d.rstrip("/"))
		if only and name not in only and "units" not in only:
			continue
		files = sorted(glob.glob(d + "*.png"), key=lambda p: _strip_key(os.path.basename(p)))
		entries = []
		c = cells.get(name)
		for p in files:
			im = Image.open(p)
			cell = None
			ay = None
			if c and abs(im.size[1] - c[1]) <= max(4, c[1] * 0.6):
				cell = c
				ay = c[2] + (im.size[1] - c[1])
			im2, frs = frames_of(p, cell)
			entries.append((os.path.basename(p), frs, ay))
		if entries:
			made += layout(entries, "units/" + name, os.path.join(out, "units_%s_%%d.png" % name))
	# the loose pictures in assets/units/ itself
	loose = sorted(glob.glob(os.path.join(ROOT, "assets/units/*.png")))
	if loose and (not only or "units" in only):
		made += layout([(os.path.basename(p), frames_of(p)[1], None) for p in loose], "units (loose files)", os.path.join(out, "units__loose_%d.png"))
	return made


def do_folder(out, group, folder, only, target_h=96):
	if only and group not in only:
		return []
	files = sorted(glob.glob(os.path.join(ROOT, folder, "**/*.png"), recursive=True))
	files += sorted(glob.glob(os.path.join(ROOT, folder, "**/*.jpg"), recursive=True))
	groups = {}
	for p in files:
		rel = os.path.relpath(p, os.path.join(ROOT, folder))
		key = rel.split("/")[0] if "/" in rel else "_loose"
		groups.setdefault(key, []).append(p)
	made = []
	for key, ps in sorted(groups.items()):
		entries = []
		for p in ps:
			im = Image.open(p)
			if im.size[0] * im.size[1] > 600 * 600:
				# a big picture (a still, a map): shown whole, shrunk
				im = im.convert("RGBA")
				sc = min(1.0, 1500.0 / im.size[0], 900.0 / im.size[1])
				entries.append((os.path.relpath(p, ROOT), [im.resize((int(im.size[0] * sc), int(im.size[1] * sc)), Image.LANCZOS)], None))
			else:
				entries.append((os.path.relpath(p, ROOT), frames_of(p)[1], None))
		made += layout(entries, "%s/%s" % (folder, key), os.path.join(out, "%s_%s_%%d.png" % (group, re.sub(r"[^a-z0-9_]", "_", key.lower()))), target_h)
	return made


def main():
	args = sys.argv[1:]
	only = []
	if "--only" in args:
		i = args.index("--only")
		only = args[i + 1:]
		args = args[:i]
	out = args[0] if args else "/tmp/sprite_audit"
	os.makedirs(out, exist_ok=True)
	made = do_units(out, only)
	made += do_folder(out, "buildings", "assets/buildings", only)
	made += do_folder(out, "effects", "assets/effects", only, 72)
	made += do_folder(out, "props", "assets/props", only)
	made += do_folder(out, "icons", "assets/icons", only, 64)
	made += do_folder(out, "ui", "assets/ui", only, 64)
	made += do_folder(out, "world", "assets/world", only)
	made += do_folder(out, "gear", "assets/gear", only)
	made += do_folder(out, "menu", "assets/menu", only)
	made += do_folder(out, "campaign", "campaign", only, 128)
	print("%d sheets in %s" % (len(made), out))


def crop(path, frame, out, cell=None, scale=3):
	"""One frame of a strip at `scale`x on the plain background (for the report's pictures)."""
	_, frs = frames_of(path, cell)
	f = frs[min(frame, len(frs) - 1)]
	f = f.resize((f.size[0] * scale, f.size[1] * scale), Image.NEAREST)
	bg = Image.new("RGBA", f.size, CELL_BG)
	bg.alpha_composite(f)
	bg.convert("RGB").save(out)


if __name__ == "__main__":
	main()
