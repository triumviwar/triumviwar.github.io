#!/usr/bin/env python3
"""Sum up a click sweep run (tools/qa/click_sweep.sh): the numbers per language/size/part and every flag, grouped.

    python3 tools/qa/click_sweep_report.py [/tmp/qa_click_sweep]   (the logs' folder, the wrapper's $OUT)

Prints a Markdown table of screens / presses / flags by kind for each run, then the flags grouped by kind and by
(part, screen, button, detail) with the runs (language_size) each was seen in. EN flags are grouped by text only.
"""
import collections
import glob
import json
import os
import re
import sys

out = sys.argv[1] if len(sys.argv) > 1 else "/tmp/qa_click_sweep"
SUM = re.compile(r"^SWEEP-SUMMARY (\S+) screens (\d+) presses (\d+) (\{.*\})")
FLAG = re.compile(r"^SWEEP ([A-Z]+) (\S+) \| (.*?) \| (.*?) \| (.*)$")

runs = []
flags = collections.OrderedDict()
crashed = []
for log in sorted(glob.glob(os.path.join(out, "*.log"))):
    name = os.path.basename(log)[:-4]
    lang, size, part = name.split("_", 2)
    summary = None
    with open(log, errors="replace") as f:
        for line in f:
            line = line.rstrip("\n")
            m = SUM.match(line)
            if m:
                summary = (int(m.group(2)), int(m.group(3)), json.loads(m.group(4)))
                continue
            m = FLAG.match(line)
            if m:
                kind, prt, screen, button, detail = m.groups()
                key = (kind, detail) if kind == "EN" else (kind, prt, screen, button, detail)
                flags.setdefault(key, set()).add(lang + "_" + size)
    if summary is None:
        crashed.append(name)
        continue
    runs.append((lang, size, part) + summary)

kinds = sorted({k for r in runs for k in r[5]})
print("| run | part | screens | presses | " + " | ".join(kinds) + " |")
print("|---|---|---:|---:|" + "---:|" * len(kinds))
tot = collections.Counter()
for lang, size, part, sc, pr, c in runs:
    print("| %s %s | %s | %d | %d | %s |" % (lang, size, part, sc, pr, " | ".join(str(c.get(k, "")) for k in kinds)))
    tot["screens"] += sc
    tot["presses"] += pr
    for k in kinds:
        tot[k] += c.get(k, 0)
print("| **all** | | **%d** | **%d** | %s |" % (tot["screens"], tot["presses"], " | ".join("**%d**" % tot[k] for k in kinds)))
if crashed:
    print("\nNo summary (crashed or timed out): " + ", ".join(crashed))
print()
by_kind = collections.defaultdict(list)
for key, where in flags.items():
    by_kind[key[0]].append((key, sorted(where)))
for kind in sorted(by_kind):
    print("### %s (%d distinct)" % (kind, len(by_kind[kind])))
    for key, where in by_kind[kind]:
        if kind == "EN":
            print("- %s  [%s]" % (key[1], ", ".join(where)))
        else:
            print("- %s | %s | %s | %s  [%s]" % (key[1], key[2], key[3], key[4][:160], ", ".join(where)))
    print()
