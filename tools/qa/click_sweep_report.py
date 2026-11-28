#!/usr/bin/env python3
"""The click sweep's tables (docs/qa_click_sweep.md): reads every <tag>.json a run of tools/qa/click_sweep.gd wrote in
<dir> and writes a report: the numbers (pages, clicks, flags by kind and run) and every flag, ranked by severity, the
same problem seen in several runs folded into one line.
    python3 tools/qa/click_sweep_report.py <dir> [--quick] [--md <file>]
--quick: the report goes to <dir>/report.md only (nothing in the repository changes). Otherwise the report goes to
docs/qa_click_sweep/report.md, the runs' data to docs/qa_click_sweep/data/ and the pictures to docs/shots/qa_click_sweep/.
Exit code 1 if a run found an ERROR or stopped before its end."""
import json, os, re, shutil, sys, glob

SEVERITY = [  # kind, rank, what it means
    ("ERROR", "high", "a script error or engine error while the click ran"),
    ("DEAD", "high", "a button wired to nothing"),
    ("STUCK", "high", "a page no button leads away from, Esc doing nothing"),
    ("OFFSCREEN", "medium", "a button whose middle is outside the window"),
    ("COVERED", "medium", "a button a hand can't click: something else is over its middle"),
    ("HUDOFF", "medium", "a command card button outside the window"),
    ("CUT", "medium", "text cut by its box"),
    ("OFF", "medium", "text reaching outside the window"),
    ("SQUEEZED", "medium", "words broken letter by letter"),
    ("NOBACK", "low", "a page with no BACK button and Esc doing nothing (it may still lead on)"),
    ("OVERLAP", "low", "two texts on top of each other"),
    ("HUDOVERLAP", "low", "card buttons over each other or over the minimap / top bar"),
    ("EN", "low", "English with no translation (pt / es runs)"),
    ("SLOW", "low", "a click that took long to settle (a frame-time spike)"),
    ("NOCHANGE", "look", "wired, but nothing visible changed (often fine: STOP on an idle unit, a sound)"),
]
RANK = {k: i for i, (k, _, _) in enumerate(SEVERITY)}


def norm(detail):
    # the same problem in several runs: numbers and rects folded
    d = re.sub(r"\(\d+(\.\d+)?, \d+(\.\d+)?\)", "(..)", detail)
    d = re.sub(r"@\w+@\d+", "@", d)      # (Godot's made-up node names differ in every run)
    d = re.sub(r"\b\d+ ms\b", "N ms", d)
    d = re.sub(r"text \d+ > (box|room) \d+", r"text > \1", d)
    d = re.sub(r"word \d+ > box \d+", "word > box", d)
    return d


def main():
    args = sys.argv[1:]
    quick = "--quick" in args
    args = [a for a in args if a != "--quick"]
    d = args[0]
    runs = []
    for p in sorted(glob.glob(os.path.join(d, "*.json"))):
        try:
            runs.append(json.load(open(p)))
        except Exception as e:
            print("skipped %s: %s" % (p, e))
    logs = {os.path.basename(p)[:-4]: open(p, errors="replace").read() for p in glob.glob(os.path.join(d, "*.log"))}
    bad = False
    lines = ["# Click sweep report", "",
             "Made by `tools/qa/click_sweep.sh` (docs/qa_click_sweep.md): every clickable thing clicked, one run a "
             "language and screen size. Severity: high (fix), medium (looks broken), low (looks off), look (often fine).", "",
             "## The numbers", "", "| run | minutes | screens | clicks | " + " | ".join(k for k, _, _ in SEVERITY) + " | finished |",
             "|" + "---|" * (len(SEVERITY) + 5)]
    folded = {}
    for r in runs:
        counts = {}
        for f in r["flags"]:
            counts[f["kind"]] = counts.get(f["kind"], 0) + 1
            key = (f["kind"], f["screen"].replace("vet:", ""), norm(f["detail"]))
            folded.setdefault(key, set()).add(r["tag"])
        done = "SWEEP DONE" in logs.get(r["tag"], "SWEEP DONE")
        if counts.get("ERROR") or not done:
            bad = True
        lines.append("| %s | %.0f | %d | %d | %s | %s |" % (r["tag"], r.get("minutes", 0), len(r["pages"]), len(r["presses"]),
                     " | ".join(str(counts.get(k, 0)) for k, _, _ in SEVERITY), "yes" if done else "**no**"))
    for tag, txt in logs.items():
        if tag not in [r["tag"] for r in runs]:
            lines.append("| %s | - | - | - | %s | **no json** |" % (tag, " | ".join("-" for _ in SEVERITY)))
            bad = True
    results = {}
    for r in runs:
        for p in r["presses"]:
            k = p["result"].split(" ")[0]
            results[k] = results.get(k, 0) + 1
    lines += ["", "What the clicks did (all runs): " + ", ".join("%s %d" % (k, v) for k, v in sorted(results.items(), key=lambda x: -x[1])), ""]
    lines += ["## Kinds of flag", "", "| kind | severity | meaning |", "|---|---|---|"]
    lines += ["| %s | %s | %s |" % s for s in SEVERITY]
    lines += ["", "## Every flag, worst first", "",
              "One line a problem; `runs` says where it showed (all = every run).", ""]
    ntags = len(runs)
    for (kind, screen, detail), tags in sorted(folded.items(), key=lambda x: (RANK.get(x[0][0], 99), x[0][1], x[0][2])):
        sev = SEVERITY[RANK[kind]][1] if kind in RANK else "?"
        where = "all" if len(tags) == ntags and ntags > 1 else ", ".join(sorted(tags))
        lines.append("- **%s** (%s) `%s`: %s  [runs: %s]" % (kind, sev, screen, detail.replace("|", "/"), where))
    md = "\n".join(lines) + "\n"
    if quick:
        out = os.path.join(d, "report.md")
    else:
        out = "docs/qa_click_sweep/report.md"
        os.makedirs("docs/qa_click_sweep/data", exist_ok=True)
        for p in glob.glob(os.path.join(d, "*.json")):
            shutil.copy(p, "docs/qa_click_sweep/data/")
        os.makedirs("docs/shots/qa_click_sweep", exist_ok=True)
        for p in glob.glob(os.path.join(d, "shots", "*.jpg")):
            shutil.copy(p, "docs/shots/qa_click_sweep/")
    open(out, "w").write(md)
    total = sum(len(v) for v in folded.values())
    print("report: %s (%d runs, %d distinct problems)" % (out, len(runs), len(folded)))
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
