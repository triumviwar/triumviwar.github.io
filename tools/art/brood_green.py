"""The Brood is GREEN (owner, 2026-11-04; job brood-green-art, docs/brood_green_art.md): turn the RED spines, crests,
frills and markings of the Brood creatures in the PAINTINGS (menu, campaign stills, portraits) to the Brood's venom green.

Only paintings. Never sprites, icons or anything under assets/units: there pure red is the team-colour key.

Masks and settings live in tools/art/brood_green_masks.json: per image a list of regions, each a hand-drawn polygon (image
pixels) round one creature's red parts, or a "line" with a "width" (a stroke along a ridge of spines), with optional "exclude" polygons (an eye, a bloody mouth). Inside a polygon (feathered) only pixels whose hue is near red and that are
saturated enough are touched: their hue is turned to the target green, saturation scaled, and the brightness kept as the
original's luma (times "luma") so the shading and the brush texture stay. Never a global red -> green swap: fire, blood,
sunsets, cardinals, Clockwork red and banners outside the polygons are untouched, and the hue window keeps browns out.

The ORIGINAL of each picture is read from git (the masks file's "source_rev"), so running it again gives the same result.
--from-file works on the file as it is now instead (e.g. after tools/menu_fix_composite.py rewrote assets/menu/battle.jpg:
run `python3 tools/art/brood_green.py --only assets/menu/battle.jpg --from-file` once after it).

  python3 tools/art/brood_green.py [--only PATH] [--from-file] [--shots] [--dry DIR]
    --shots     before/after crops of every region into docs/shots/brood_green_art/
    --dry DIR   write the results into DIR instead of over the pictures
"""
import argparse
import io
import json
import os
import subprocess
import sys

import cv2
import numpy as np

MASKS = "tools/art/brood_green_masks.json"
SHOTS = "docs/shots/brood_green_art"


def load_original(path, rev, from_file):
    if not from_file:
        try:
            data = subprocess.run(["git", "show", f"{rev}:{path}"], check=True, capture_output=True).stdout
            img = cv2.imdecode(np.frombuffer(data, np.uint8), cv2.IMREAD_UNCHANGED)
            if img is not None:
                return img
        except subprocess.CalledProcessError:
            print(f"  ({path} not in {rev}: using the file as it is)")
    return cv2.imread(path, cv2.IMREAD_UNCHANGED)


def luma(rgb):
    return rgb[..., 0] * 0.299 + rgb[..., 1] * 0.587 + rgb[..., 2] * 0.114


def recolour(bgr, poly_mask, p):
    """bgr uint8 (3 channels); poly_mask float 0..1. Returns the new bgr and the weight used."""
    f = bgr.astype(np.float32) / 255.0
    hsv = cv2.cvtColor(f, cv2.COLOR_BGR2HSV)            # H 0..360, S, V 0..1
    h, s, v = hsv[..., 0], hsv[..., 1], hsv[..., 2]
    d = np.minimum(np.abs(h - p["red_hue"]), 360 - np.abs(h - p["red_hue"]))   # distance from red
    hw = p["hue_width"]
    w_h = np.clip((hw - d) / (hw * 0.4), 0, 1)           # full up to 0.6 * hw, none past hw
    w_s = np.clip((s - p["sat_min"]) / 0.15, 0, 1)
    w_v = np.clip((v - p["val_min"]) / 0.08, 0, 1)
    w = poly_mask * w_h * w_s * w_v
    if "val_max" in p:                                     # dark spines against a bright red sky or fire
        w = w * np.clip((p["val_max"] - v) / 0.08, 0, 1)
    nh = (h - p["red_hue"] + p["hue"]) % 360             # keep the hue's spread round the new centre
    ns = np.clip(s * p["sat"], 0, 1)
    new = cv2.cvtColor(np.dstack([nh, ns, v]).astype(np.float32), cv2.COLOR_HSV2BGR)
    rgb_old, rgb_new = f[..., ::-1], new[..., ::-1]
    lo, ln = luma(rgb_old), luma(rgb_new)
    if not p.get("keep_v", False):                        # keep_v: the painting's own brightness (HSV value) stays
        k = np.where(ln > 1e-4, lo * p["luma"] / np.maximum(ln, 1e-4), 1.0)
        new = np.clip(new * k[..., None], 0, 1)
    out = f * (1 - w[..., None]) + new * w[..., None]
    return (out * 255 + 0.5).astype(np.uint8), w


def region_mask(shape, r, feather):
    """The feathered 0..1 mask of one region: its polygon and/or thick line, minus its "exclude" polygons."""
    m = np.zeros(shape[:2], np.uint8)
    if r.get("poly"):
        cv2.fillPoly(m, [np.array(r["poly"], np.int32)], 255)
    if r.get("line"):                                  # a ridge of spines: a thick stroke along it
        cv2.polylines(m, [np.array(r["line"], np.int32)], False, 255, int(r.get("width", 24)))
    for ex in r.get("exclude", []):                    # an eye, a mouth: left as painted
        cv2.fillPoly(m, [np.array(ex, np.int32)], 0)
    mf = m.astype(np.float32) / 255.0
    return cv2.GaussianBlur(mf, (0, 0), feather) if feather > 0 else mf


def apply(bgr, regions, defaults, image_params):
    """Recolour every region of one picture; returns the new bgr and the number of pixels changed."""
    out = bgr.copy()
    changed = 0
    for r in regions:
        p = dict(defaults)
        p.update(image_params)
        p.update(r.get("params", {}))
        out, w = recolour(out, region_mask(bgr.shape, r, p["feather"]), p)
        changed += int((w > 0.05).sum())
    return out, changed


def save(img, path):
    ext = os.path.splitext(path)[1].lower()
    if ext in (".jpg", ".jpeg"):
        ok, buf = cv2.imencode(".jpg", img, [cv2.IMWRITE_JPEG_QUALITY, 90])
    else:
        ok, buf = cv2.imencode(".png", img, [cv2.IMWRITE_PNG_COMPRESSION, 9])
    assert ok
    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
    open(path, "wb").write(buf.tobytes())


def shot(before, after, poly, name):
    x, y, w, h = cv2.boundingRect(np.array(poly, np.int32))
    pad = max(12, int(max(w, h) * 0.25))
    H, W = before.shape[:2]
    x0, y0, x1, y1 = max(0, x - pad), max(0, y - pad), min(W, x + w + pad), min(H, y + h + pad)
    a, b = before[y0:y1, x0:x1], after[y0:y1, x0:x1]
    sc = min(3.0, 300.0 / max(1, y1 - y0), 440.0 / max(1, x1 - x0))
    a = cv2.resize(a, None, fx=sc, fy=sc, interpolation=cv2.INTER_CUBIC)
    b = cv2.resize(b, None, fx=sc, fy=sc, interpolation=cv2.INTER_CUBIC)
    gap = np.zeros((a.shape[0], 8, 3), np.uint8)
    os.makedirs(SHOTS, exist_ok=True)
    out = os.path.join(SHOTS, name + ".jpg")
    cv2.imwrite(out, np.concatenate([a, gap, b], axis=1), [cv2.IMWRITE_JPEG_QUALITY, 82])
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--only")
    ap.add_argument("--from-file", action="store_true")
    ap.add_argument("--shots", action="store_true")
    ap.add_argument("--dry")
    a = ap.parse_args()
    data = json.load(open(MASKS))
    rev = data["source_rev"]
    for path, spec in data["images"].items():
        if a.only and path != a.only:
            continue
        regions = [r for r in spec.get("regions", []) if r.get("poly") or r.get("line")]
        if not regions:
            continue
        img = load_original(path, rev, a.from_file)
        alpha = img[..., 3:] if img.ndim == 3 and img.shape[2] == 4 else None
        bgr = img[..., :3] if img.ndim == 3 else cv2.cvtColor(img, cv2.COLOR_GRAY2BGR)
        before = bgr.copy()
        out, changed = apply(bgr, regions, data["defaults"], spec.get("params", {}))
        if alpha is not None:
            out = np.dstack([out, alpha])
        dest = os.path.join(a.dry, path) if a.dry else path
        save(out, dest)
        print(f"{path}: {len(regions)} region(s), {changed} px")
        if a.shots:
            stem = os.path.splitext(os.path.basename(path))[0]
            for i, r in enumerate(regions):
                shot(before, out[..., :3], r.get("poly") or r["line"], f"{stem}_{r.get('name', i)}")


if __name__ == "__main__":
    sys.exit(main())
