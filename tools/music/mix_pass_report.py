"""The mix pass's before/after table (job music-mix-pass): docs/music_mix_pass/table.md and summary numbers.

Usage: python3 tools/music/mix_pass_report.py BEFORE.json AFTER.json
       (both written by study_audio.analyse over the 70 pieces: the files before the pass and assets/music after;
        the study's own numbers of 2026-11-14 come from docs/music_study/audio.json; the chain's numbers per piece
        from docs/music_mix_pass/info/)
"""
import json
import os
import sys

import numpy as np

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(ROOT, "docs", "music_mix_pass")


def side(n):
    return "menu" if n.startswith("menu") else n.split("_")[0] if not n.startswith("defeat") else "sting"


def main():
    before = json.load(open(sys.argv[1]))
    after = json.load(open(sys.argv[2]))
    study = json.load(open(os.path.join(ROOT, "docs", "music_study", "audio.json")))
    info = {}
    idir = os.path.join(OUT, "info")
    for fn in os.listdir(idir):
        info[fn[:-5]] = json.load(open(os.path.join(idir, fn)))
    rows = []
    for n in sorted(after):
        b, a, i = before[n], after[n], info.get(n, {})
        rows.append(dict(name=n, title=i.get("title", ""), side=side(n), lra_study=study.get(n, {}).get("lra"),
                         lra_b=b["lra"], lra_a=a["lra"], lufs_b=b["lufs"], lufs_a=a["lufs"],
                         tp_b=b["true_peak_dbtp"], tp_a=a["true_peak_dbtp"], sub_b=b["band_sub"], sub_a=a["band_sub"],
                         crest_b=b["crest_db"], crest_a=a["crest_db"], k=i.get("ride_k"), lim=i.get("limit_db"),
                         shelf=i.get("low_shelf_db"), len_b=b["length_s"], len_a=a["length_s"]))
    lines = ["# The mix pass, piece by piece", "",
             "Measured with tools/music/study_audio.py (the study's own measure) on the files before the pass and "
             "after it. LRA = loudness range (LU), sub = the energy share below 80 Hz, crest = peak to RMS (dB), "
             "k = the fader ride's factor (1 = not ridden), limit = the most the true-peak limiter took off (dB), "
             "shelf = the low-shelf at 100 Hz (dB).", "",
             "| Piece | Title | LRA study | LRA before | LRA after | LUFS before | LUFS after | TP after | sub before |"
             " sub after | crest before | crest after | k | limit | shelf |",
             "|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|"]

    def f(v, p=1):
        return "-" if v is None else ("%." + str(p) + "f") % v
    for r in rows:
        lines.append("| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |" % (
            r["name"], r["title"], f(r["lra_study"]), f(r["lra_b"]), f(r["lra_a"]), f(r["lufs_b"]), f(r["lufs_a"]),
            f(r["tp_a"]), f(r["sub_b"], 2), f(r["sub_a"], 2), f(r["crest_b"]), f(r["crest_a"]), f(r["k"], 2),
            f(r["lim"]), f(r["shelf"])))
    summ = {}
    groups = {"all": rows}
    for s in ("crown", "clock", "brood", "menu"):
        groups[s] = [r for r in rows if r["side"] == s]
    music = [r for r in rows if r["side"] != "sting"]
    groups["all"] = music
    lines += ["", "## Medians by side (the sting left out)", "",
              "| Group | Pieces | LRA before | LRA after | in 8-10 LU after | LUFS before | LUFS after | pieces sub > 25% "
              "before / after | crest before | crest after |", "|---|---|---|---|---|---|---|---|---|---|"]
    for g, rs in groups.items():
        med = lambda k: float(np.median([r[k] for r in rs]))
        n_in = sum(1 for r in rs if 7.95 <= r["lra_a"] <= 10.05)
        sb = sum(1 for r in rs if r["sub_b"] > 0.25)
        sa = sum(1 for r in rs if r["sub_a"] > 0.25)
        summ[g] = dict(n=len(rs), lra_b=med("lra_b"), lra_a=med("lra_a"), n_in=n_in, lufs_b=med("lufs_b"),
                       lufs_a=med("lufs_a"), sub_b=sb, sub_a=sa, crest_b=med("crest_b"), crest_a=med("crest_a"),
                       lufs_a_min=min(r["lufs_a"] for r in rs), lufs_a_max=max(r["lufs_a"] for r in rs),
                       lra_a_min=min(r["lra_a"] for r in rs), lra_a_max=max(r["lra_a"] for r in rs),
                       tp_a_max=max(r["tp_a"] for r in rs))
        lines.append("| %s | %d | %.1f | %.1f | %d | %.1f | %.1f | %d / %d | %.1f | %.1f |" % (
            g, len(rs), summ[g]["lra_b"], summ[g]["lra_a"], n_in, summ[g]["lufs_b"], summ[g]["lufs_a"], sb, sa,
            summ[g]["crest_b"], summ[g]["crest_a"]))
    os.makedirs(OUT, exist_ok=True)
    open(os.path.join(OUT, "table.md"), "w").write("\n".join(lines) + "\n")
    json.dump({"summary": summ, "rows": rows}, open(os.path.join(OUT, "summary.json"), "w"), indent=1)
    print(json.dumps(summ, indent=1))


if __name__ == "__main__":
    main()
