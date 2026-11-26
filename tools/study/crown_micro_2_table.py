"""(crown-micro-2, docs/crown_micro_2.md) the bench table: each arm against its base, pooled over the ratios.
    python3 tools/study/crown_micro_2_table.py "BASE1+BASE2:ARM1+ARM2" ...      (a row a spec; ';' joins two pairs into one row)
A row: fights, score of the arm, its change against the base (paired by fight name and run where both have it, else the
means), t, k/l, wins. The data: docs/crown_micro_2/bench/<name>.json."""
import json, os, sys, math
DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "../../docs/crown_micro_2/bench")


def load(spec):
    rs = []
    for n in spec.split("+"):
        p = os.path.join(DIR, n + ".json")
        if os.path.exists(p):
            rs += json.load(open(p))["runs"]
    return rs


def row(spec):
    # several "base:arm" pairs joined by ";": the differences of each pair's mean, weighted by fights
    diffs, ses, n_a, kl_k, kl_l, wins, sc = [], [], 0, 0, 0, 0, []
    for pair in spec.split(";"):
        b, a = pair.split(":")
        B, A = load(b), load(a)
        if not A or not B:
            return None
        mb = sum(r["score"] for r in B) / len(B)
        ma = sum(r["score"] for r in A) / len(A)
        vb = sum((r["score"] - mb) ** 2 for r in B) / max(1, len(B) - 1)
        va = sum((r["score"] - ma) ** 2 for r in A) / max(1, len(A) - 1)
        diffs.append((ma - mb, len(A)))
        ses.append((va / len(A) + vb / len(B), len(A)))
        n_a += len(A)
        kl_k += sum(r["killed"] for r in A)
        kl_l += sum(r["lost"] for r in A)
        wins += sum(1 for r in A if r["score"] > 0)
        sc += [r["score"] for r in A]
    w = sum(n for _, n in diffs)
    d = sum(x * n for x, n in diffs) / w
    se = math.sqrt(sum(v * (n / w) ** 2 for v, n in ses))
    return n_a, sum(sc) / len(sc), d, d / se if se > 0 else 0.0, kl_k / max(1, kl_l), wins


if __name__ == "__main__":
    print("| arm | fights | score | change | t | k/l | won |")
    print("|---|---|---|---|---|---|---|")
    for spec in sys.argv[1:]:
        name, _, sp = spec.partition("=")
        r = row(sp or name)
        if r is None:
            print("| %s | (not run) |||||" % name)
            continue
        print("| %s | %d | %+.2f | %+.3f | %+.2f | %.2f | %d |" % ((name,) + r))
