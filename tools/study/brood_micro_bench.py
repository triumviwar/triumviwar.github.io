#!/usr/bin/env python3
"""(brood-micro, docs/brood_micro.md) The bench's numbers: compare bench result files (tools/bench_brood_micro.gd out:).
    python3 tools/study/brood_micro_bench.py BASE.json [BASE2.json ...] -- ARM.json [ARM2.json ...]
Paired by scenario and run (the same seeds): the mean score of each, the change, its t (the paired differences), k/l,
and the change per foe and per scenario. A measuring tool: it changes no rule."""
import sys, json, math, statistics as st, collections


def load(files):
    out = {}
    for f in files:
        d = json.load(open(f))
        for x in d["runs"]:
            out.setdefault((x["sc"], x["run"]), []).append(x)
    # (two files with the same fights: their mean)
    return {k: {"score": sum(y["score"] for y in v) / len(v), "killed": sum(y["killed"] for y in v) / len(v),
                "lost": sum(y["lost"] for y in v) / len(v), "micro": v[0].get("micro", {})} for k, v in out.items()}


def tval(ds):
    if len(ds) < 2:
        return 0.0
    sd = st.stdev(ds)
    return (sum(ds) / len(ds)) / (sd / math.sqrt(len(ds))) if sd > 0 else 0.0


def main():
    a = sys.argv[1:]
    if "--" in a:
        i = a.index("--")
        base, arm = load(a[:i]), load(a[i + 1:])
    else:
        base, arm = load(a), None
    def summ(d, keys):
        s = [d[k]["score"] for k in keys]
        kl = sum(d[k]["killed"] for k in keys) / max(1.0, sum(d[k]["lost"] for k in keys))
        return sum(s) / len(s), kl
    keys = sorted(base) if arm is None else sorted(set(base) & set(arm))
    by = collections.defaultdict(list)
    for k in keys:
        by[k[0].split(":")[0]].append(k)
    groups = [("ALL", keys)] + sorted(by.items())
    for name, ks in groups:
        b, bkl = summ(base, ks)
        if arm is None:
            print("%-10s n %3d  score %+.3f  k/l %.2f" % (name, len(ks), b, bkl))
        else:
            m, mkl = summ(arm, ks)
            ds = [arm[k]["score"] - base[k]["score"] for k in ks]
            print("%-10s n %3d  base %+.3f (k/l %.2f)  arm %+.3f (k/l %.2f)  change %+.3f  t %.2f" % (name, len(ks), b, bkl, m, mkl, m - b, tval(ds)))
    sc = collections.defaultdict(list)
    for k in keys:
        sc[k[0]].append(k)
    print()
    for s, ks in sorted(sc.items()):
        b, bkl = summ(base, ks)
        if arm is None:
            print("  %-26s %+.2f  k/l %.2f" % (s, b, bkl))
        else:
            m, mkl = summ(arm, ks)
            mic = collections.Counter()
            for k in ks:
                mic.update(arm[k]["micro"])
            print("  %-26s %+.2f -> %+.2f (%+.2f)  k/l %.2f -> %.2f  %s" % (s, b, m, m - b, bkl, mkl, dict(mic)))


main()
