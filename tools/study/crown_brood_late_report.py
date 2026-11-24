#!/usr/bin/env python3
"""(crown-brood-late, docs/crown_brood_late.md) The late game of a block of Crown v Brood games (tools/study/crown_brood_late.py
data): per block (several blocks joined with +), the Crown's and the Brood's income, supply (used / cap), army and halls at
8, 12 and 16 minutes (the means over the games that are still on), the Crown's labourers lost (all / from 12:00), its halls
lost from 12:00, its fights (guns near at contact, of them set; fights with guns near where none was set), its siege
pushes, and what the gold went on from 10:00 to 16:00 (result.json minutes "sb", from crown-brood-late on).
    python3 tools/study/crown_brood_late_report.py BLOCK[+BLOCK] ...
A measuring tool: it changes no rule."""
import sys, os, json, glob, collections

DATA = os.path.join(os.path.dirname(os.path.abspath(__file__)), "../../docs/crown_brood_late/data")


def crown(g):
    for i, s in enumerate(g["slots"]):
        if (s.get("faction") if isinstance(s, dict) else s[0]) == "crown":
            return i
    return 0


def cat(k):
    if k == "u:labourer":
        return "labourers"
    if k.startswith("u:"):
        return "army"
    if k == "research":
        return "research"
    b = k[2:]
    if b in ("farm", "powder_mill", "town_hall"):
        return "economy (halls, farms, mills)"
    if b in ("cottage",):
        return "cottages"
    if b in ("barracks", "foundry", "horse_breeder", "armoury", "church"):
        return "production and tech"
    if b in ("wall", "gate", "palisade"):
        return "walls"
    return "other buildings"


def mean(v):
    v = [x for x in v if x is not None]
    return sum(v) / len(v) if v else None


def f0(v):
    return "-" if v is None else "%.0f" % v


def block_rows(names):
    games = []
    for n in names.split("+"):
        for f in sorted(glob.glob(os.path.join(DATA, n, "wcb_*", "result.json"))):
            games.append(json.load(open(f)))
    return games


def report(name):
    games = block_rows(name)
    if not games:
        print(name, "no games")
        return
    at = collections.defaultdict(list)
    lab = lab12 = halls_lost = 0
    fights = guns_near = set_n = nogun_set = 0
    out_f = out_near = out_set = 0
    spend = collections.Counter()
    spend_n = 0
    cbl = collections.Counter()
    pushes = 0
    for g in games:
        si = crown(g)
        oi = 1 - si
        mins = {}
        for x in g["minutes"]:
            mins[(x["p"], int(round(x["t"] / 60)))] = x
        for mn in (8, 12, 16):
            for side, p in (("crown", si), ("brood", oi)):
                x = mins.get((p, mn))
                if x is None or x.get("out"):
                    continue
                at[(side, mn, "income")].append(x["income"])
                at[(side, mn, "sup")].append(x["supply"])
                at[(side, mn, "cap")].append(x["cap"])
                at[(side, mn, "army")].append(x["army"])
                at[(side, mn, "halls")].append(x["halls"])
                at[(side, mn, "workers")].append(x["workers"])
                at[(side, mn, "bank")].append(x["bank"])
        for d in g.get("deaths", []):
            if d[1] == "labourer" and d[2] == si:
                lab += 1
                if d[0] >= 720:
                    lab12 += 1
        hs = [(x["t"], x.get("halls", 0)) for x in g["minutes"] if x["p"] == si]
        top = max([h for t, h in hs if t >= 720] or [0])
        halls_lost += max(0, top - (hs[-1][1] if hs else 0))
        c = g.get("crown_ai", {}).get(str(si), {})
        for f in c.get("guns", {}).get("fights", []):
            fights += 1
            if not f[1]:
                out_f += 1
                out_near += int(f[3])
                out_set += int(f[4])
            if int(f[3]) > 0:
                guns_near += int(f[3])
                set_n += int(f[4])
                if int(f[4]) == 0:
                    nogun_set += 1
        pushes += len(c.get("siege_pushes", []) or [])
        for k, v in c.items():
            if k.startswith("cbl_") or k.startswith("cbf_"):
                cbl[k] += int(v)
        a, b = mins.get((si, 10)), mins.get((si, 16))
        if a and b and "sb" in a and "sb" in b:
            spend_n += 1
            for k in b["sb"]:
                spend[cat(k)] += int(b["sb"][k]) - int(a["sb"].get(k, 0))
    n = len(games)
    print("## %s (%d games)" % (name, n))
    print("| minute | side | games on | income | supply used / cap | bank | workers | army | halls |")
    print("|---|---|---|---|---|---|---|---|---|")
    for mn in (8, 12, 16):
        for side in ("crown", "brood"):
            k = lambda q: mean(at[(side, mn, q)])
            print("| %d:00 | %s | %d | %s | %s / %s | %s | %s | %s | %s |" % (mn, side, len(at[(side, mn, "income")]), f0(k("income")),
                  f0(k("sup")), f0(k("cap")), f0(k("bank")), f0(k("workers")), f0(k("army")), "%.1f" % (k("halls") or 0)))
    print()
    print("labourers lost a game %.1f (from 12:00 %.1f); Crown halls lost from 12:00 %.1f a game" % (lab / n, lab12 / n, halls_lost / n))
    print("fights %.1f a game; guns near at contact %d, of them set %d (%.0f%%); fights with guns near and none set: %d" % (
        fights / n, guns_near, set_n, 100.0 * set_n / max(1, guns_near), nogun_set))
    print("fights out of home %.1f a game; guns near at contact %d, of them set %d (%.0f%%)" % (out_f / n, out_near, out_set,
          100.0 * out_set / max(1, out_near)))
    print("siege pushes %.1f a game; counters: %s" % (pushes / n, ", ".join("%s %.1f" % (k, v / n) for k, v in sorted(cbl.items()))))
    if spend_n:
        tot = sum(spend.values()) or 1
        print("gold spent 10:00-16:00 (%d games, a game): %s" % (spend_n, ", ".join("%s %d (%d%%)" % (k, v / spend_n, round(100 * v / tot))
              for k, v in spend.most_common())))
    print()


if __name__ == "__main__":
    for nm in sys.argv[1:]:
        report(nm)
