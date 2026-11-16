#!/usr/bin/env python3
"""BROOD ROOTMAW COACH, THE GAMES PAIRED (brood-rootmaw-coach, docs/brood_rootmaw_coach.md): the same qa_matches.py
games (`--only brood`, the same tags and seeds) before and after, side by side. For each pairing (Brood v Crown, Brood
v Clockwork) and minute (5, 8, 10, 12): the Brood's primary earned (cumulative) and its opponent's, the Brood's share,
its Rootmaws, workers, bank and army; at each minute only the games still on in BOTH runs. Then W-D-L and how each game
ended. A measuring tool only.
    python3 tools/study/brood_coach_report.py BEFORE_DATA AFTER_DATA"""
import json, os, sys, glob

AT = [5, 8, 10, 12]


def load(d):
    out = {}
    for f in sorted(glob.glob(os.path.join(d, "*", "result.json"))):
        out[os.path.basename(os.path.dirname(f))] = json.load(open(f))
    return out


def side(r):
    facs = [s[0] for s in r["slots"]]
    b = facs.index("brood")
    return b, 1 - b, facs[1 - b]


def rows_of(r, i):
    n = len(r["slots"])
    return [m for k, m in enumerate(r["minutes"]) if k % n == i]


def at(rows, t, key):
    for m in rows:
        if m["t"] == t * 60:
            return m[key]
    return None


def result(r):
    b, o, _ = side(r)
    ws = r.get("winner_side", -1)
    if ws == -1:
        return "D"
    return "W" if ws == r["slots"][b][2] else "L"


def mean(v):
    return sum(v) / len(v) if v else 0.0


def main(bd, ad):
    B, A = load(bd), load(ad)
    tags = sorted(set(B) & set(A))
    for foe in ("crown", "clockwork"):
        ts = [t for t in tags if side(B[t])[2] == foe]
        if not ts:
            continue
        wb = {k: sum(1 for t in ts if result(B[t]) == k) for k in "WDL"}
        wa = {k: sum(1 for t in ts if result(A[t]) == k) for k in "WDL"}
        print("\n### Brood v %s: %d games paired; Brood W-D-L before %d-%d-%d, after %d-%d-%d" % (
            foe.capitalize(), len(ts), wb["W"], wb["D"], wb["L"], wa["W"], wa["D"], wa["L"]))
        print("\n| | " + " | ".join("%d:00" % t for t in AT) + " |")
        print("|---|" + "---|" * len(AT))
        lines = {k: [] for k in ("n", "bb", "ba", "ob", "oa", "sb", "sa", "chg", "mb", "ma", "wkb", "wka", "kb", "ka", "ab", "aa", "up")}
        for t in AT:
            pb, pa, qb, qa, mb, ma, wkb, wka, kb, ka, ab, aa = ([] for _ in range(12))
            up = 0
            for g in ts:
                b, o, _ = side(B[g])
                rb, ro = rows_of(B[g], b), rows_of(B[g], o)
                b2, o2, _ = side(A[g])
                ra, rao = rows_of(A[g], b2), rows_of(A[g], o2)
                if at(rb, t, "income") is None or at(ra, t, "income") is None:
                    continue
                pb.append(at(rb, t, "income")); pa.append(at(ra, t, "income"))
                qb.append(at(ro, t, "income")); qa.append(at(rao, t, "income"))
                mb.append(at(rb, t, "maws")); ma.append(at(ra, t, "maws"))
                wkb.append(at(rb, t, "workers")); wka.append(at(ra, t, "workers"))
                kb.append(at(rb, t, "bank")); ka.append(at(ra, t, "bank"))
                ab.append(at(rb, t, "army")); aa.append(at(ra, t, "army"))
                up += 1 if pa[-1] > pb[-1] else 0
            lines["n"].append("%d" % len(pb))
            lines["bb"].append("%d" % mean(pb)); lines["ba"].append("%d" % mean(pa))
            lines["ob"].append("%d" % mean(qb)); lines["oa"].append("%d" % mean(qa))
            lines["sb"].append("%.2f" % (mean(pb) / max(1.0, mean(qb)))); lines["sa"].append("%.2f" % (mean(pa) / max(1.0, mean(qa))))
            lines["chg"].append("%+.1f%%" % (100.0 * (mean(pa) / max(1.0, mean(pb)) - 1.0)))
            lines["up"].append("%d of %d" % (up, len(pb)))
            lines["mb"].append("%.1f" % mean(mb)); lines["ma"].append("%.1f" % mean(ma))
            lines["wkb"].append("%.0f" % mean(wkb)); lines["wka"].append("%.0f" % mean(wka))
            lines["kb"].append("%.0f" % mean(kb)); lines["ka"].append("%.0f" % mean(ka))
            lines["ab"].append("%.0f" % mean(ab)); lines["aa"].append("%.0f" % mean(aa))
        names = [("n", "games still on in both"), ("bb", "Brood earned, before"), ("ba", "Brood earned, after"),
                 ("chg", "change"), ("up", "games where it earned more"), ("ob", "%s earned, before" % foe.capitalize()),
                 ("oa", "%s earned, after" % foe.capitalize()), ("sb", "Brood / %s, before" % foe.capitalize()),
                 ("sa", "**Brood / %s, after**" % foe.capitalize()), ("mb", "Brood Rootmaws, before"), ("ma", "Brood Rootmaws, after"),
                 ("wkb", "Brood grubs, before"), ("wka", "Brood grubs, after"), ("kb", "Brood bank, before"),
                 ("ka", "Brood bank, after"), ("ab", "Brood army, before"), ("aa", "Brood army, after")]
        for k, nm in names:
            print("| %s | %s |" % (nm, " | ".join(lines[k])))
        print("\nGames (before -> after: result, end):")
        for g in ts:
            print("- %s: %s %s -> %s %s" % (g, result(B[g]), "%d:%02d" % divmod(int(B[g]["end"]), 60),
                                             result(A[g]), "%d:%02d" % divmod(int(A[g]["end"]), 60)))


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)
    main(sys.argv[1], sys.argv[2])
