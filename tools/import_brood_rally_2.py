"""The Brood RALLY icon redrawn (sprite audit finding 89, 2026-11-21: the old one was a skull totem with feathers, out
of tone for creatures with no culture): three claw scratches in mossy ground with a scent mist and the yellow arrow,
ChatGPT's answer in art/ui/icons3/brood_rally_2.png, set in the Brood's bronze frame exactly as tools/import_round13.py
sets its BRONZE sheets (only this icon; running import_round13.py again would redo every icon of that round).

Usage (repo root): python3 tools/import_brood_rally_2.py
"""
import os
import sys

sys.argv = sys.argv[:1]
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import import_round13 as m  # noqa: E402

r = m.r


def main():
    frame = m.faction_frame("brood")
    px = r.load(f"{m.SRC}/brood_rally_2.png")
    bg, _ = r.bg_mask(px)
    sl = r.frame_boxes(px, bg, 1)[0]
    crop = r.brass_crop(px, bg, sl)
    r.save_icon(m.bronze_icon(crop, "rally", frame), "brood/rally")
    print("icons/brood/rally.png: from %dx%d" % (crop.shape[1], crop.shape[0]))


if __name__ == "__main__":
    main()
