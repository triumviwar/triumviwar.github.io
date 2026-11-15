# balance-raptor-horseman: the Raptor and the Horseman, retuned (2026-11-15)

The owner's decisions (2026-11-15 00:38-00:53, set against StarCraft II's Zergling and Hellion), applied on the branch
`balance-raptor-horseman` (version 0.38.3). No AI code was changed (the Crown coaching jobs run at the same time).

## What changed

| | before | after |
|---|---|---|
| Raptor health | 36 | **38** |
| Raptor speed | 96 | **92** |
| PACK HUNT (Tyrant Sire), the Raptor's bonus | +18 (114) | **+22 (114)**; the Tyrant Challenger (+14) and the Tyrant Sire (+11) unchanged |
| Horseman (`cuirassier`) health | 140 | **100** |
| Horseman cost | 115 (+40 for his horse when no spare one stands ready) | **100** (+40 the same) |
| Cuirassier (armoured Horseman, +30) | 170 | **130** |
| KEEN SABRES (new, at the HORSE BREEDER) | | **75 gold, 30 s**: +6 sabre damage against LIGHT units for Horsemen and Cuirassiers (18 -> 24) |

- Only with Pack Hunt does a Raptor outrun horses now (92 < a Horseman's 112 < 114).
- KEEN SABRES (`Defs.RESEARCH["keen_sabres"]`, a drill: every rider has it at once, like the Cavalry Charge). The +6
  is added in the saddle only (the `_:` blow in `Unit._strike`), before the charge, the Pikeman-style kind bonuses and
  veterancy multiply it (veterancy and the band's pipes scale it too). Light = the "light" tag: Raptors, Spitters, Grubs,
  Musketeers, Officers, Horsemen, Clock Soldiers, Winders and the rest; armoured units (Brutes, Guardsmen, Cuirassiers,
  machines) and buildings take nothing more. The Officer's sabre on foot and the pistol shot are unchanged. Price and
  time are Claude's (the Cavalry Charge is 60 gold, 25 s). Icon: a stand-in (the Charge's icon mirrored and tinted
  steel blue, `assets/icons/research_keen_sabres.png`; noted in docs/art_style_inconsistency.md).
- The Cavalry Charge stays at the Armoury (undecided).
- Health across the saddle: mounting and dismounting keep the health SHARE (`Unit.morph`), so nothing is created or
  lost: a full Officer (80) rides as a full Horseman (100), a half-health Horseman gets off as a half-health Officer
  (40 of 80); the Armoured Officer 110 <-> the Cuirassier 130. The Dragoon (90) and the Musketeer (70) are untouched
  (tools/test_keen_sabres.gd checks all of it).
- Texts: the Horseman's and the Horse Breeder's "about" and tooltip, the Raptor's tooltip, Pack Hunt's text (92 to
  114), the Help page (the Horse Breeder researches KEEN SABRES), the new research's texts, all in en/pt/es
  (tools/i18n/71_balance_raptor_horseman.txt and the edited entries). No card line, help page or tutorial text stated
  140, 115, 36 or 96, so nothing else needed a number changed. Two code comments (defs.gd) now say 38.
- Side effects of the health numbers: a Horseman's body is smaller (100 + his horse's 60 = 160, was 200): it rots a
  little sooner and the Brood's grubs harvest it in 1.81 s (was 2.03) for fewer spoils; a Raptor's body (38) a little
  longer.
- Tests updated for the numbers: test_horses (the prices), test_ground_attack (bodies and harvest times),
  test_brood_new (the speeds), test_brood_rush_riders (its "of N" health). New: tools/test_keen_sabres.gd,
  tools/test_unit_duel.gd (any N v M stand-up fight, `set:` numbers and `tech0:/tech1:` research). Measuring only:
  `Game.death_log` (null in a normal game) and tools/qa_match.gd's riders' trades (`riders_seen`, `deaths`).

(RESULTS FOLLOW: being measured.)
