#!/usr/bin/env python3
"""SCOUT DENY STUDY report (docs/scout_deny.md): tables from tools/study/scout_deny.py's data, the rule ON against OFF on the
same games (map, seed, sides). A measuring tool only.
    python3 tools/study/scout_deny_report.py DATA > docs/scout_deny/tables.md
For each player of each game: its FIRST SCOUT (the computer's first scouting trip: AIScout's first trip, the Brood's first
scouting grub) - did it bring a read (not UNKNOWN) and when did it die; the scouts it lost in the game; whether it read the
enemy GREEDY by 5:00 and what OPTIMAL picked from it; and, as the side that denies, what its scout-deny did (hunts sent,
scouts killed, chases given up, workers sent and lost). Income earned by 5:00 and 8:00, and the outcome at 12:00: the
winner, else the leader by income earned + 2 x army value (10% ahead, the win-rate studies' rule). Paired: each tag's ON
game against its OFF game, a sign test on the leader score of the pairing's first-named faction (P1 in a mirror)."""
import os, sys, json, glob, math
from collections import defaultdict

CODE = {"cr": "crown", "br": "brood", "cw": "clockwork"}
PAIRS = ["crbr", "crcw", "brcw", "crcr", "brbr", "cwcw"]
NAME = {"crbr": "Crown v Brood", "crcw": "Crown v Clockwork", "brcw": "Brood v Clockwork", "crcr": "Crown mirror",
        "brbr": "Brood mirror", "cwcw": "Clockwork mirror"}


def mmss(s):
    return "-" if s is None else "%d:%02d" % (int(s) // 60, int(s) % 60)


def mean(xs):
    xs = [x for x in xs if x is not None]
    return sum(xs) / len(xs) if xs else None


def med(xs):
    xs = sorted(x for x in xs if x is not None)
    if not xs:
        return None
    n = len(xs)
    return xs[n // 2] if n % 2 else (xs[n // 2 - 1] + xs[n // 2]) / 2


def binom_p(k, n):
    if n == 0:
        return 1.0
    pk = [math.comb(n, i) / 2 ** n for i in range(n + 1)]
    return min(1.0, sum(p for p in pk if p <= pk[k] + 1e-12))


def pct(a, b):
    return "-" if not b else "%d%% (%d/%d)" % (round(100.0 * a / b), a, b)


def side(g, p):
    """one player's scouting record"""
    facs = [s[0] for s in g["slots"]]
    sc = g.get("scouting", {}).get(str(p), {})
    trips = sc.get("trips", [])
    reads = sorted([r for r in g.get("reads", []) if r["p"] == p and "read" in r], key=lambda r: r["t"])
    picks = sorted([r for r in g.get("reads", []) if r["p"] == p and "pick" in r], key=lambda r: r["t"])
    o = {"fac": facs[p], "first_dead": None, "first_read": None, "first_read_t": None, "lost": 0, "greedy5": False,
         "greedy_picks": [], "deny": (sc.get("deny") or {}).get("n", {}), "kills": (sc.get("deny") or {}).get("kills", [])}
    good = [r for r in reads if r["read"] != "UNKNOWN"]
    if good:
        o["first_read"], o["first_read_t"] = good[0]["read"], good[0]["t"]
    if facs[p] != "brood":
        o["lost"] = sum(1 for t in trips if t[1] == "killed")
        if trips:
            t0 = trips[0]
            o["first_trip"] = True
            o["first_dead"] = t0[0] if t0[1] == "killed" else None
            o["first_ok"] = t0[4] != "UNKNOWN"
    else:
        o["lost"] = sum(1 for t in trips if t[1] == "killed")
        sent = [t for t in trips if t[1] == "sent"]
        if sent:
            o["first_trip"] = True
            t0 = sent[0][0]
            nxt = sent[1][0] if len(sent) > 1 else 1e9
            dead = [t[0] for t in trips if t[1] == "killed" and t0 <= t[0] <= nxt]
            o["first_dead"] = dead[0] if dead else None
            o["first_ok"] = bool(good) and (o["first_dead"] is None or good[0]["t"] <= o["first_dead"] + 1)
    for r in reads:
        if r["read"] == "GREEDY" and r["t"] <= 300:
            o["greedy5"] = True
    for r in picks:
        if "GREEDY" in r["pick"]:
            o["greedy_picks"].append((r["t"], r["pick"]))
    return o


def load(data, arm):
    out = {}
    for d in sorted(glob.glob(os.path.join(data, arm, "base_*"))):
        f = os.path.join(d, "result.json")
        if not os.path.exists(f):
            continue
        g = json.load(open(f))
        tag = os.path.basename(d)
        pair = tag.split("_")[-2]
        facs = [s[0] for s in g["slots"]]
        si = 0 if pair[:2] == pair[2:] else facs.index(CODE[pair[:2]])
        at = {}
        for r in g["minutes"]:
            at[(r["p"], int(round(r["t"] / 60)))] = r
        fin = g["final"]
        sc = [f["income"] + 2 * f["army"] for f in fin]
        if g["winner"] >= 0:
            lead = "W" if g["winner"] == si else "L"
        else:
            lead = "w" if sc[si] > 1.1 * sc[1 - si] else ("l" if sc[1 - si] > 1.1 * sc[si] else "=")
        out[tag] = {"tag": tag, "pair": pair, "si": si, "lead": lead, "g": g, "at": at,
                    "sides": [side(g, 0), side(g, 1)], "winner": g["winner"]}
    return out


def inc(r, p, m):
    x = r["at"].get((p, m))
    return x["income"] if x else None


def score(r):
    return 1 if r["lead"] in ("W", "w") else (-1 if r["lead"] in ("L", "l") else 0)


def main():
    data = sys.argv[1]
    arms = {a: load(data, a) for a in ("on", "off")}
    P = print
    P("# Scout deny study: tables\n")
    P("Made by tools/study/scout_deny_report.py from %s. ON = the rule as built, OFF = `scoutdeny:off`; the same games (tag "
      "= map, seed, sides) in both arms. %d ON and %d OFF games.\n" % (data, len(arms["on"]), len(arms["off"])))
    # ---- the scouts, by the scouting faction against the denying one
    P("## The first scout, by matchup (scouter -> denier)\n")
    P("| scouter -> denier | arm | first scouts | brought a read | killed | median death | its scouts lost a game | GREEDY read by 5:00 |")
    P("|---|---|---|---|---|---|---|---|")
    keys = []
    for a in ("crown", "clockwork", "brood"):
        for b in ("crown", "clockwork", "brood"):
            keys.append((a, b))
    for a, b in keys:
        for arm in ("off", "on"):
            S = []
            for r in arms[arm].values():
                for p in (0, 1):
                    s, d = r["sides"][p], r["sides"][1 - p]
                    if s["fac"] == a and d["fac"] == b:
                        S.append(s)
            if not S:
                continue
            ft = [s for s in S if s.get("first_trip")]
            P("| %s -> %s | %s | %d | %s | %s | %s | %.2f | %s |" % (a, b, arm.upper(), len(ft),
              pct(sum(1 for s in ft if s.get("first_ok")), len(ft)), pct(sum(1 for s in ft if s["first_dead"] is not None), len(ft)),
              mmss(med([s["first_dead"] for s in ft])), mean([s["lost"] for s in S]) or 0.0,
              pct(sum(1 for s in S if s["greedy5"]), len(S))))
    # ---- the denier's counters
    P("\n## What the rule did, by the denying faction (ON games; per player a game)\n")
    P("| denier | players | hunts sent | scouts killed | chases given up | none fit (looks) | workers sent | workers lost | hunters lost | first kill (median) |")
    P("|---|---|---|---|---|---|---|---|---|---|")
    for fac in ("crown", "clockwork", "brood"):
        D = [r["sides"][p] for r in arms["on"].values() for p in (0, 1) if r["sides"][p]["fac"] == fac]
        if not D:
            continue
        m = lambda k: mean([d["deny"].get(k, 0) for d in D]) or 0.0
        fk = [d["kills"][0][0] if d["kills"] else None for d in D]
        P("| %s | %d | %.1f | %.1f | %.1f | %.1f | %.1f | %.2f | %.2f | %s |" % (fac, len(D), m("sent"), m("killed"), m("escaped"),
          m("none_fit"), m("workers_sent"), m("workers_lost"), m("hunters_lost"), mmss(med(fk))))
    P("\nKills by the scout's kind (ON):\n")
    kinds = defaultdict(lambda: defaultdict(int))
    for r in arms["on"].values():
        for p in (0, 1):
            for k in r["sides"][p]["kills"]:
                kinds[r["sides"][p]["fac"]][k[1]] += 1
    for fac in kinds:
        P("- %s killed: %s" % (fac, ", ".join("%s %d" % (k, v) for k, v in sorted(kinds[fac].items(), key=lambda x: -x[1]))))
    # ---- the pairings: income and outcome
    P("\n## The pairings: income and outcome (the first-named faction's view; P1 in a mirror)\n")
    P("| pairing | arm | games | income 5:00 (it / foe) | income 8:00 (it / foe) | W-D-L | won or led / trailed / even | paired ON v OFF better / worse (p) |")
    P("|---|---|---|---|---|---|---|---|")
    for pair in PAIRS:
        for arm in ("off", "on"):
            R = [r for r in arms[arm].values() if r["pair"] == pair]
            if not R:
                continue
            i5 = mean([inc(r, r["si"], 5) for r in R]); f5 = mean([inc(r, 1 - r["si"], 5) for r in R])
            i8 = mean([inc(r, r["si"], 8) for r in R]); f8 = mean([inc(r, 1 - r["si"], 8) for r in R])
            w = sum(r["lead"] == "W" for r in R); l = sum(r["lead"] == "L" for r in R)
            wo = sum(r["lead"] in ("W", "w") for r in R); tr = sum(r["lead"] in ("L", "l") for r in R)
            pr = ""
            if arm == "on":
                better = worse = 0
                for r in R:
                    o = arms["off"].get(r["tag"])
                    if o is None:
                        continue
                    d = score(r) - score(o)
                    better += d > 0
                    worse += d < 0
                pr = "%d / %d (p %.2f)" % (better, worse, binom_p(min(better, worse), better + worse) if better + worse else 1.0)
            P("| %s | %s | %d | %s / %s | %s / %s | %d-%d-%d | %d / %d / %d | %s |" % (NAME[pair], arm.upper(), len(R),
              "{:,}".format(int(i5 or 0)), "{:,}".format(int(f5 or 0)), "{:,}".format(int(i8 or 0)), "{:,}".format(int(f8 or 0)),
              w, len(R) - w - l, l, wo, tr, len(R) - wo - tr, pr))
    # ---- the reads that set off the plans
    P("\n## GREEDY reads and what OPTIMAL picked from them\n")
    for arm in ("off", "on"):
        n = 0
        rows = []
        for r in sorted(arms[arm].values(), key=lambda r: r["tag"]):
            for p in (0, 1):
                s = r["sides"][p]
                for t, pk in s["greedy_picks"]:
                    n += 1
                    res = "won" if r["winner"] == p else ("lost" if r["winner"] == 1 - p else "drew")
                    rows.append("| %s | P%d %s | %s | %s | %s |" % (r["tag"], p + 1, s["fac"], mmss(t), pk, res))
        P("**%s**: %d picks on a GREEDY read.\n" % (arm.upper(), n))
        if rows:
            P("| game | player | at | pick | at 12:00 |")
            P("|---|---|---|---|---|")
            for x in rows:
                P(x)
            P("")
    # ---- the workers
    P("\n## Workers at 5:00 and 8:00 (mean per player, by faction)\n")
    P("| faction | arm | workers 5:00 | workers 8:00 |")
    P("|---|---|---|---|")
    for fac in ("crown", "clockwork", "brood"):
        for arm in ("off", "on"):
            w5, w8 = [], []
            for r in arms[arm].values():
                for p in (0, 1):
                    if r["sides"][p]["fac"] == fac:
                        x5, x8 = r["at"].get((p, 5)), r["at"].get((p, 8))
                        w5.append(x5["workers"] if x5 else None)
                        w8.append(x8["workers"] if x8 else None)
            P("| %s | %s | %.1f | %.1f |" % (fac, arm.upper(), mean(w5) or 0.0, mean(w8) or 0.0))


if __name__ == "__main__":
    main()
