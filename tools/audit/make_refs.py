#!/usr/bin/env python3
"""Reference pictures for the sprite audit's redraw prompts (docs/sprite_hallucination_audit.md, "Redraw requests").

Same look as the older prompt sets (docs/animation_redraw_prompts_2.md): the CURRENT game strips enlarged with hard
pixels on the answer sheet's navy (0, 22, 48), each frame labelled (e.g. `e3` = east, frame 3), a lighter cell box and a
small red tick at the game's ground line. The labels, boxes and ticks are for reading only.

    python3 tools/audit/make_refs.py        # writes docs/redraw_refs/sa_*/ from REFS below
"""
import os
import sys

from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(__file__))
import contact_sheets as cs  # noqa: E402

ROOT = cs.ROOT
NAVY = (0, 22, 48, 255)
BOX = (14, 40, 76, 255)

# prompt id -> [(picture name, [(unit, strip), ...]), ...]  (at most 3 pictures a prompt)
REFS = {
	"sa01_raptor_idle": [
		("1_current_raptor_idle.png", [("raptor", "idle_s"), ("raptor", "idle_se"), ("raptor", "idle_e"), ("raptor", "idle_n")]),
		("2_raptor_walk_model.png", [("raptor", "walk_s"), ("raptor", "walk_se"), ("raptor", "walk_e"), ("raptor", "walk_n")]),
	],
	"sa02_tyrant_challenger_death_n": [
		("1_current_death_n.png", [("tyrant_challenger", "death_n")]),
		("2_death_se_e_model.png", [("tyrant_challenger", "death_se"), ("tyrant_challenger", "death_e")]),
		("3_walk_n_back_view.png", [("tyrant_challenger", "walk_n")]),
	],
	"sa03_rebel_pikeman_walk_s": [
		("1_current_walk_s.png", [("rebel_pikeman", "walk_s")]),
		("2_walk_e_ne_model.png", [("rebel_pikeman", "walk_e"), ("rebel_pikeman", "walk_ne")]),
	],
	"sa04_rebel_pikeman_walk_se": [
		("1_current_walk_se.png", [("rebel_pikeman", "walk_se")]),
		("2_walk_e_ne_model.png", [("rebel_pikeman", "walk_e"), ("rebel_pikeman", "walk_ne")]),
	],
	"sa05_guardsman_idle_s": [
		("1_current_idle_s.png", [("musketeer_armoured", "idle_s")]),
		("2_guardsman_idle_other_views.png", [("musketeer_armoured", "idle_se"), ("musketeer_armoured", "idle_e"), ("musketeer_armoured", "aim_s")]),
	],
	"sa06_cuirassier_attack_n": [
		("1_current_attack_n.png", [("cuirassier", "attack_n")]),
		("2_attack_e_se_model.png", [("cuirassier", "attack_e"), ("cuirassier", "attack_se")]),
		("3_walk_n_back_view.png", [("cuirassier", "walk_n")]),
	],
	"sa07_cuirassier_attack_ne": [
		("1_current_attack_ne.png", [("cuirassier", "attack_ne")]),
		("2_attack_e_se_model.png", [("cuirassier", "attack_e"), ("cuirassier", "attack_se")]),
		("3_walk_n_ne_back_views.png", [("cuirassier", "walk_n"), ("cuirassier", "walk_ne")]),
	],
	"sa08_armoured_dragoon_walk_ne": [
		("1_current_walk_ne_e.png", [("dragoon_armoured", "walk_ne"), ("dragoon_armoured", "walk_e")]),
		("2_walk_n_back_view.png", [("dragoon_armoured", "walk_n")]),
		("3_dragoon_walk_ne_model.png", [("dragoon", "walk_ne")]),
	],
	"sa09_horseman_walk_ne": [
		("1_current_walk_ne.png", [("horseman", "walk_ne")]),
		("2_walk_n_e_model.png", [("horseman", "walk_n"), ("horseman", "walk_e")]),
	],
	"sa10_powder_wagon_walk_n": [
		("1_current_walk_n.png", [("powder_wagon", "walk_n")]),
		("2_walk_s_se_e_model.png", [("powder_wagon", "walk_s"), ("powder_wagon", "walk_se"), ("powder_wagon", "walk_e")]),
	],
	"sa11_dragoon_walk_s": [
		("1_current_walk_s.png", [("dragoon", "walk_s")]),
		("2_walk_se_e_model.png", [("dragoon", "walk_se"), ("dragoon", "walk_e")]),
		("3_dragoon_idle.png", [("dragoon", "idle_s"), ("dragoon", "idle_se")]),
	],
}


def render(rows, out, k=4):
	cells = cs.unit_cells()
	f = cs._font(18)
	items = []
	for unit, strip in rows:
		p = os.path.join(ROOT, "assets/units", unit, strip + ".png")
		if not os.path.isfile(p):
			continue
		c = cells.get(unit)
		im = Image.open(p)
		cell = c if c and abs(im.size[1] - c[1]) <= max(4, c[1] * 0.6) else None
		_, frs = cs.frames_of(p, cell)
		ay = (c[2] + (im.size[1] - c[1])) if cell else None
		items.append((strip, frs, ay))
	if not items:
		return
	gap = 12
	lab_w = 150
	widest = max(len(fr) * (fr[0].size[0] + 3) for _, fr, _ in items)
	k = max(2, min(k, int(2400 / max(1, widest))))
	W = lab_w + max(len(fr) * (fr[0].size[0] * k + gap) for _, fr, _ in items) + gap
	H = sum(fr[0].size[1] * k + 40 for _, fr, _ in items) + gap
	img = Image.new("RGBA", (W, H), NAVY)
	d = ImageDraw.Draw(img)
	y = gap
	for strip, frs, ay in items:
		facing = strip.rsplit("_", 1)[-1]
		d.text((8, y + 20), strip, fill=(200, 200, 200), font=f)
		for i, fr in enumerate(frs):
			x = lab_w + i * (fr.size[0] * k + gap)
			big = fr.resize((fr.size[0] * k, fr.size[1] * k), Image.NEAREST)
			d.rectangle((x, y + 24, x + big.size[0] - 1, y + 24 + big.size[1] - 1), fill=BOX)
			img.alpha_composite(big, (x, y + 24))
			d.text((x + 2, y + 2), "%s%d" % (facing, i), fill=(220, 220, 120), font=f)
			if ay is not None:
				yy = y + 24 + int(ay * k)
				d.line((x - 6, yy, x - 1, yy), fill=(230, 40, 40), width=2)
		y += frs[0].size[1] * k + 40
	img.convert("RGB").save(out)


def main():
	for pid, pics in REFS.items():
		dd = os.path.join(ROOT, "docs/redraw_refs", pid)
		os.makedirs(dd, exist_ok=True)
		for name, rows in pics:
			render(rows, os.path.join(dd, name))
	print("refs in docs/redraw_refs/sa*/")


if __name__ == "__main__":
	main()
