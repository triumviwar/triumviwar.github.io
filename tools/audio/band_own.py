"""THE BAND'S OWN PIECES (Claude's melodies, the owner 2026-11-14 21:47-22:12: "this one sounds much better", "I love
this 3 musics"), rendered with the band's instrument samples (make_band_music.py) through band_produce.py (a section
of players, stereo, body, an outdoor room; the study in docs/band_music.md "The band's own pieces"):
  The Pipe Calls (band_pipecalls): the pipes call, the fife answers; the full band's everyday tune.
  The Fife Calls (band_lament): a slow sad lament, the fife leading, the pipes answering; the band at rest.
  The Drums Lead (band_drumslead): a drum feature, the pipes and fife answering; the band in a fight.
  The lone Piper's four tunes (pipes_*): one piper, the same production.
  python3 tools/audio/band_own.py [calls lament drums piper] [--listen]   (game files into assets/audio/band; --listen:
  mp3s into docs/band_sound/ instead)"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import numpy as np
import make_band_music as M
import band_produce as P
ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
LISTEN = "--listen" in sys.argv
GAME_LUFS = -20.0       # every band file (BandSound sets the levels: BAND_DB, LONE_DB)


def out(stem, listen_name):
    if LISTEN:
        return os.path.join(ROOT, "docs", "band_sound", listen_name)
    return os.path.join(ROOT, "assets", "audio", "band", stem + ".ogg")


def target():
    return -15.0 if LISTEN else GAME_LUFS
SR = M.SR
MIX = {0: 1.0, 2: 9 / 8, 4: 5 / 4, 5: 4 / 3, 7: 3 / 2, 9: 5 / 3, 10: 16 / 9}


def drums_stems(tu_six, roll, N, roll_s, snare, bass_hits, tenor_hits, lvl=1.0, muffle=False, seed=50):
    """snare: one string from the roll-off on; bass/tenor: [(t s, velocity)] -> (snare stereo, bass+tenor stereo)."""
    k_ = M.kit()
    sn_st = np.zeros((N, 2))
    for i, (p, ms, _, g) in enumerate(P.SNARES):
        M.rng = np.random.default_rng(seed + i)
        b = M.Buf(N)
        M.play_snare(k_, b, roll_s + snare, lambda j: (j - len(roll_s)) * tu_six + roll + ms / 1000, tu_six, lvl)
        y = b.y
        if muffle:
            y = M.lp(y, 3500)
        sn_st += P.pan(P.eq(y, P.SNARE_EQ), p) * g
    bd = M.Buf(N)
    for t, v in bass_hits:
        bd.add(k_.hit("bass", v), t + M.jit(3))
    low = P.pan(P.eq(bd.y, P.BASS_EQ), 0.0)
    for i, (t, v) in enumerate(tenor_hits):
        b = M.Buf(N)
        b.add(k_.hit("tenor", v), t + M.jit(4))
        low += P.pan(b.y, -0.5 if i % 2 == 0 else 0.5) * 0.8
    return sn_st, low


def env_apply(st, env):
    return st * env[:len(st), None]


def calls():
    CALLS = ["A>B ^c>d | e2 A2", "A>B ^c>e | a>g e2", "f>e f>a | e>^c A2", "A>B ^c>d | e>f g>e"]
    ANS = ["f>e d>^c | B2 A2", "e>^c d>B | ^c2 e2", "d>f e>^c | B2 G2", "e>^c B>G | A4"]
    TOGETHER = "a2 e>^c | d>f e>^c | B>A B>^c | d2 B2 | ^c>e a>e | f>d e>^c | B>G B>d | A4"
    REST = "z4 | z4"

    def part(who):
        bars = []
        for c, a in zip(CALLS, ANS):
            bars.append(c if who == "pipes" else REST)
            bars.append(a if who == "fife" else REST)
        bars.append(TOGETHER)
        one = " | ".join(bars)
        return one + " | " + one + " |"
    M.ROLL_BARS["duet"] = 2
    pt = M.prepare(M.Tune("duet", "The Pipe Calls", 8, 4, 110.0, 0, M.midi_of("A4"), MIX, part("pipes")))
    ft = M.prepare(M.Tune("duet", "The Pipe Calls", 8, 4, 110.0, 0, M.midi_of("A4"), MIX, part("fife")))
    N = max(pt.N, ft.N) + int(2.5 * SR)
    pt.N = ft.N = N
    bar, roll = pt.t(8), pt.roll_s
    pipes = P.ensemble(lambda: P.eq(M.render_pipes(pt, False), P.PIPE_EQ), N, P.PIPERS, 100)
    fife = P.ensemble(lambda: P.eq(M.render_fife(ft, True), P.FIFE_EQ), N, P.FIFERS, 200)
    env = np.ones(N)
    ramp = int(0.12 * SR)
    for rep in range(2):
        base = roll + rep * 24 * bar
        for k in range(4):
            a = base + (4 * k + 2) * bar
            ia, ib = int((a - 0.02) * SR), int((a + 2 * bar - 0.10) * SR)
            env[ia:ib] = 0.22
            env[ia:ia + ramp] = np.linspace(1, 0.22, ramp)
            env[ib - ramp:ib] = np.linspace(0.22, 1, ramp)
    pipes = env_apply(pipes, env)
    bars_s = []
    for rep in range(2):
        for k in range(4):
            bars_s += ["F.t.A.t.", "F.t.t.tt", "F.t.t.t.", "F...t.t."]
        bars_s += ["F.t.A.t.", "F.t.A.tt", "F.t.A.t.", "F...S.t.", "F.t.A.t.", "F.t.A.tt", "F.t.F.t.", "A......."]
    six = pt.six
    bass = []
    for b in range(len(bars_s)):
        bass.append((roll + b * 8 * six, 0.7))
        if b % 2 == 1:
            bass.append((roll + (b * 8 + 4) * six, 0.45))
    sn, low = drums_stems(six, roll, N, "z-----------A...z-----------A...", "".join(bars_s), bass, [], 0.75)
    P.finish([(pipes, -21.0), (fife, -19.5), (sn, -25.0), (low, -27.0)], out("band_pipecalls", "own_the_pipe_calls.mp3"), target())


def lament():
    F1 = "e3 d c2 | B4 A2 | A2 c2 e2 | d6"
    F2 = "e3 f g2 | e4 d2 | c2 B2 A2 | B6"
    P1 = "d2 c2 B2 | A6"
    P2 = "A2 B2 c2 | A6"
    FT = "a3 g e2 | g4 e2 | d2 e2 c2 | B6 | c2 d2 e2 | d3 c B2 | A2 G2 B2 | A6"
    PT = "A6 | c6 | B6 | G6 | A6 | B6 | G6 | A6"
    R2, R4 = "z6 | z6", "z6 | z6 | z6 | z6"
    FORM = [("f", F1, R4), ("p", R2, P1), ("f", F2, R4), ("p", R2, P2), ("t", FT, PT),
            ("f", F1, R4), ("p", R2, P1), ("f", F2, R4), ("p", R2, P2)]
    fife_txt = " | ".join((a if k in ("f", "t") else b) for k, a, b in FORM) + " |"
    pipe_txt = " | ".join((b if k in ("f", "t") else a) for k, a, b in FORM) + " |"
    M.ROLL_BARS["lament"] = 1
    ft = M.prepare(M.Tune("lament", "The Fife Calls", 12, 4, 72.0, 0, M.midi_of("A4"), M.DORIAN, fife_txt, kind="air"))
    pt = M.prepare(M.Tune("lament", "The Fife Calls", 12, 4, 72.0, 0, M.midi_of("A4"), M.DORIAN, pipe_txt, kind="air"))
    N = max(ft.N, pt.N) + int(3.0 * SR)
    ft.N = pt.N = N
    bar, roll = ft.t(12), ft.roll_s
    fife = P.ensemble(lambda: P.eq(M.render_fife(ft, True), P.FIFE_EQ), N, P.FIFE_LEAD, 300)
    pipes = P.ensemble(lambda: P.eq(M.render_pipes(pt, False), P.PIPE_EQ), N, P.PIPERS, 400)
    env = np.full(N, 0.18)
    t = roll
    ramp = int(0.25 * SR)
    for k, _, _ in FORM:
        n = {"f": 4, "p": 2, "t": 8}[k]
        if k != "f":
            lvl = 1.0 if k == "p" else 0.6
            a, b = int((t - 0.15) * SR), int((t + n * bar - 0.25) * SR)
            env[a:b] = lvl
            env[a:a + ramp] = np.linspace(0.18, lvl, ramp)
            env[b - ramp:b] = np.linspace(lvl, 0.18, ramp)
        t += n * bar
    pipes = env_apply(pipes, env)
    bars_s = []
    for k, _, _ in FORM:
        n = {"f": 4, "p": 2, "t": 8}[k]
        for i in range(n):
            bars_s.append("F.......z---" if i == n - 1 else ("F...t...t..." if k == "t" else "A.......t..."))
    six = ft.six
    bass = [(roll + b * 12 * six, 0.6) for b in range(len(bars_s))]
    sn, low = drums_stems(six, roll, N, "z-------A...", "".join(bars_s), bass, [], 0.45, muffle=True)
    P.finish([(fife, -18.5), (pipes, -23.0), (sn, -30.0), (low, -27.5)], out("band_lament", "own_the_fife_calls.mp3"), target(), wet=0.3)


def drums():
    Z = "z4"
    MOTIF = "A>B ^c2 | e4"
    COUNTER = "a>g e>^c | A4"
    TUNE = "a2 e>^c | d>f e>^c | B>A B>^c | d2 B2 | ^c>e a>e | f>d e>^c | B>G B>d | A4"

    def bars(n):
        return " | ".join([Z] * n)
    pipe_txt = " | ".join([bars(8), MOTIF, bars(2), MOTIF, bars(2), bars(8), TUNE, bars(4)]) + " |"
    fife_txt = " | ".join([bars(8), bars(2), COUNTER, bars(2), COUNTER, bars(8), TUNE, bars(4)]) + " |"
    SNARE = {
        "A": ["F.tgD.tg", "F.t.R.tt", "FgtgA.tg", "F.t.S...", "A.tgA.tg", "D.t.D.t.", "F.tgt.R.", "N...A..."],
        "B": ["F.t.A.tg", "F.tgt.tt", "F.t.D.tg", "F...R...", "F.t.A.tg", "F.tgt.tt", "D.t.D.t.", "N...A..."],
        "C": ["F.tgD.tg", "........", "FgtgR.tt", "........", "D.D.D.tg", "........", "F.t.S...", "z---A..."],
        "D": ["F.t.A.t.", "F.tgt.tg", "F.t.A.tg", "F...R.t.", "F.t.A.t.", "F.tgt.tg", "D.t.D.t.", "S...A..."],
        "T": ["FgtgFgtg", "D.D.D.D.", "z-------", "A......."],
    }
    ORDER = ["A", "B", "C", "D", "T"]
    M.ROLL_BARS["drumfeat"] = 2
    pt = M.prepare(M.Tune("drumfeat", "The Drums Lead", 8, 4, 116.0, 0, M.midi_of("A4"), MIX, pipe_txt))
    ft = M.prepare(M.Tune("drumfeat", "The Drums Lead", 8, 4, 116.0, 0, M.midi_of("A4"), MIX, fife_txt))
    nbars = sum(len(SNARE[s]) for s in ORDER)
    six = pt.six
    roll = 2 * 8 * six
    N = int((roll + nbars * 8 * six + 3.0) * SR)
    pt.N = ft.N = N
    pt.roll_s = ft.roll_s = roll
    bar = 8 * six
    pipes = P.ensemble(lambda: P.eq(M.render_pipes(pt, False), P.PIPE_EQ), N, P.PIPERS, 500)
    fife = P.ensemble(lambda: P.eq(M.render_fife(ft, False), P.FIFE_EQ), N, P.FIFERS, 600)
    env = np.full(N, 0.16)
    ramp = int(0.1 * SR)

    def up(b0, nb, lvl):
        a, b = int((roll + b0 * bar - 0.1) * SR), int((roll + (b0 + nb) * bar - 0.12) * SR)
        env[a:b] = lvl
        env[a:a + ramp] = np.linspace(0.16, lvl, ramp)
        env[b - ramp:b] = np.linspace(lvl, 0.16, ramp)
    up(8, 2, 0.8); up(12, 2, 0.8); up(24, 8, 0.55)
    pipes = env_apply(pipes, env)
    bass, tenor = [], []
    b = 0
    for s in ORDER:
        for i, pat in enumerate(SNARE[s]):
            t0 = roll + b * bar
            if s == "C" and pat.startswith("."):
                for kk, (inst, v) in enumerate([("bass", .9), ("tenor", .8), ("tenor", .7), ("bass", .85), ("tenor", .8),
                                                 ("tenor", .7), ("bass", .95), ("tenor", .9)]):
                    (bass if inst == "bass" else tenor).append((t0 + kk * six, v))
            else:
                bass += [(t0, 0.85 if i % 2 == 0 else 0.7), (t0 + 4 * six, 0.55)]
                if s in ("A", "D", "T"):
                    tenor += [(t0 + 2 * six, 0.6), (t0 + 6 * six, 0.5)]
            b += 1
    snare = "".join("".join(SNARE[s]) for s in ORDER)
    sn, low = drums_stems(six, roll, N, "z-----------A...z-----------A...", snare, bass, tenor, 1.0)
    P.finish([(sn, -17.5), (low, -20.0), (pipes, -26.0), (fife, -25.0)], out("band_drumslead", "own_the_drums_lead.mp3"), target(), wet=0.18)


def piper():
    """The lone Piper: his four tunes (make_band_music.py's notes), ONE piper, through the same production."""
    tunes = M.all_tunes()
    for tid, name in (("scotland", "Scotland the Brave"), ("grenadiers", "The British Grenadiers"),
                      ("garryowen", "Garry Owen"), ("minstrel", "The Minstrel Boy")):
        tu = M.prepare(tunes[tid])
        # (his file starts where his tune does: no band roll-off before it, a breath for the strike-in)
        lead_in = max(0.0, tu.roll_s - 0.9)
        y = P.eq(M.render_pipes(tu, False), P.PIPE_EQ)[int(lead_in * M.SR):]
        st = P.pan(y, -0.1) + P.pan(P.fit(np.concatenate([np.zeros(int(0.012 * M.SR)), y]), len(y)), 0.35) * 0.18
        P.finish([(st, -20.0)], out("pipes_" + tid, "own_lone_piper_%s.mp3" % tid), target(), wet=0.3)
        print("  piper", tid, name)


if __name__ == "__main__":
    which = [a for a in sys.argv[1:] if not a.startswith("--")] or ["calls", "lament", "drums", "piper"]
    for w in which:
        {"calls": calls, "lament": lament, "drums": drums, "piper": piper}[w]()
        print("done", w)
