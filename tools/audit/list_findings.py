#!/usr/bin/env python3
"""Plain-words lists of the sprite audit's findings, for docs/sprite_hallucination_audit.md.

    python3 tools/audit/list_findings.py HIGH|MEDIUM|LOW  > fragment.md

One bullet a finding, grouped by area, written to be read aloud: what, where, which frames, what is wrong, the picture
and the likeliest ChatGPT source sheet.
"""
import json
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
FACING = {"s": "south", "se": "south-east", "e": "east", "ne": "north-east", "n": "north", "w": "west", "sw": "south-west", "nw": "north-west"}


def frames_text(fr):
	if not fr:
		return "the whole strip"
	if len(fr) == 1:
		return "frame %d" % fr[0]
	return "frames " + ", ".join(str(f) for f in fr[:-1]) + " and " + str(fr[-1])


def main():
	sev = sys.argv[1]
	data = json.load(open(os.path.join(ROOT, "docs/sprite_audit/findings.json")))
	n = 0
	groups = {}
	for i, x in enumerate(data):
		if x["severity"] != sev:
			continue
		groups.setdefault(x["group"], []).append((i + 1, x))
	for g in sorted(groups):
		print("### %s\n" % g)
		for num, x in groups[g]:
			n += 1
			where = x.get("subject", "")
			bits = []
			if x.get("anim"):
				bits.append(x["anim"])
			if x.get("facing"):
				bits.append(FACING.get(x["facing"], x["facing"]))
			head = "**%d. %s%s**" % (num, where, (", " + " ".join(bits)) if bits else "")
			conf = {"sure": "", "likely": " (likely)", "unsure": " (unsure)"}.get(x.get("confidence", ""), "")
			line = "- %s, %s: %s%s" % (head, frames_text(x.get("frames") or []), x["problem"].rstrip(), conf)
			if x.get("note_lead"):
				line += " " + x["note_lead"]
			line += "\n  File `%s`." % x["file"]
			if x.get("picture"):
				line += " Picture `%s`." % x["picture"]
			if x.get("source"):
				line += " Source sheet (best guess by name): `%s`." % "`, `".join(x["source"][:2])
			print(line)
		print()
	sys.stderr.write("%d %s findings\n" % (n, sev))


if __name__ == "__main__":
	main()
