# The Pendulum hits flyers (pendulum-air, 0.38.3)

The owner's decision (2026-11-15, 00:46-00:53): the Clockwork's PENDULUM attacks FLYERS too, with the same area swing
it uses on the ground, at 3/4 of its damage against flyers, with NO research. "Pendulum being antiair is just fair,
Clockwork only has Springers and Swifts as antiair, the other factions have more... research is too much, it already
is ground melee vs flying units on a slow unit."

## What changed

- **Every swing cuts flyers in the arc.** The swing's arc is unchanged (62 px from its feet, 60 degrees either side of
  the way it swings). Every enemy unit in it takes the blow, on the ground or in the air; a flyer takes
  `Defs.PENDULUM_SWING["vs_air"]` = **0.75** of it (`Pendulum.blow_k`). Its own side is never hit, flyers included.
- **It can target flyers.** `Defs.UNITS["pendulum"]` lost `"ground_only"` and got `"anti_air": true`, so `Unit.can_hit`
  lets it pick a flyer. Attack-move, standing guard and the computers pick the NEAREST enemy, ground or air, by the same
  rule as every other unit (`Game.find_target`; workers and units that cannot fight back count 60 px further away). So
  a nearer ground fighter is cut first, and a flyer is walked to when nothing on the ground is nearer.
- **Buildings**: unchanged (x1.25).
- **A netted flyer** (a Netter's catch) is on the ground while caught: it takes the FULL blow then, as before.

### The "light" tag on flyers

The light bonus (x1.5, `PENDULUM_SWING["vs_light"]`) applies to flyers exactly as on the ground, on top of the 3/4:

| Target | Tag | Share of the 12 blow | Damage a blow (before armour) |
|---|---|---|---|
| Labourer, Raptor, Musketeer (ground, light) | light | x1.5 | 18 |
| Clock Soldier, Brute (ground) | armored | x1 | 12 |
| Observation Balloon, Hatchlings, Storm Challenger, Swift (flyers) | light | x0.75 x1.5 = **x1.125** | 13.5 |
| Ticking Owl, Storm Sire (flyers) | armored | x0.75 | 9 (8 on 1 armour) |

So a light flyer still takes a little MORE than the plain blow (13.5 against 12). Most flyers in the game are light
(the Balloon, Hatchlings, the Storm Challenger, the Swift); only the Ticking Owl and the Storm Sire are not.
That is the owner's rule as written ("light bonus as on the ground"); see Claude's choices for the other way.

## Texts (en, pt, es)

- The card "about" no longer says "at ankle height" and "It cannot reach flyers": "...they sweep in turn, like scythes,
  and every blow cuts EVERY enemy in the wide arc in front of it (never your own units), light units hardest. The blades
  reach up for flyers in the arc too, for three quarters of the blow."
- The short card line: "Slow and tough: its blades cut every enemy in its arc, flyers too." (pt/es shortened to fit
  the 80-character card line: test_card_text).
- The selection card's line (hud.gd), the attack chip ("on the ground or in the air"), the SWEEP chip ("flyers take
  75%"), a new chip "Against flyers 75%", and the "hits flyers" icon in its stats (UnitStats._hits).
- Translations: tools/i18n/71_pendulum_air.txt; patch notes 0.38.3 in tools/i18n/patch/notes.txt.

## Art

At first (0.38.3) the swing was drawn LOW at flyers too (the blade passed under the flyer it hit; pictures:
docs/shots/pendulum_air/, tools/shot_pendulum_air.gd).

### The HIGH SWING (pendulum-high-swing, 0.38.16)

At a flyer the Pendulum now plays its own HIGH SWING strips, attack_hi_r / attack_hi_l (assets/units/pendulum/, 6
frames, views S SE E NE N, the W ones mirrored like every strip): the arm swings back (frames 1-2, the telegraph), up and
forward (3), the blade at its HIGHEST over its head on frame 4 (index 3), THE HIT, the same frame the low sweep's blow
lands on (same 6 frames at 9 fps: the timing is unchanged), then it settles back (5-6). Ground targets keep the low sweep.

- ART: the owner's ChatGPT sheets art/redraws/pendulum_high_swing_<view>_chatgpt.png (S, SE, NE, N: 2 rows of 6) and
  pendulum_high_swing_e_v2_chatgpt.png (E: one row of 6 in side profile, his redo of a hallucinated first E sheet),
  imported by tools/pendulum_guide/import_high_swing.py: magenta keyed (magenta-ness min(R,B) - G under 60, ChatGPT's
  pink motion smears left out) and despilled on the rim (R and B lose their excess over G: no pink fringe), every frame
  aligned on the BODY (its legs' red matched to the row's first frame, so the body stands still and only the arm moves;
  checked at game size: the legs move 0 px between frames, once 1 px), each row scaled so its first frame's body is as
  tall as the low sweep's first frame of that view (80/74/78/76/80 px), feet on the same line, the red case over the same
  x (within 0.6 px), the Clockwork palette (tools/cw_palette.py: team reds, the blue joints player colour, steel blade).
  Preview: art/redraws/pendulum_high_swing.png / .gif (the old low sweep beside the new high swing, x3).
- THE TALLER CELL: the raised blade goes far over the 91-px cell, so the hi strips are 130 x 136 a frame (the same width,
  so the frame count still reads from the kind's cell width), with the feet 7 px over the strip's bottom as in the 91-px
  strips. No offset code was needed: Unit._set_anim already keeps a taller strip's feet in place (offset -anchor -
  (texture height - cell height), the way the Springer's attack_up does).
- CODE: scripts/pendulum.gd: Pendulum.HIGH (2) is added to Unit.arm when the blow's target is an enemy flyer as the
  wind-up starts (Pendulum.high_at, off with `pendair:off`); attack_anim then returns attack_hi_<arm> (the low sweep when
  the hi strips are missing). Kept for the whole blow (a flyer dying or drifting off mid-swing does not switch the
  strip) and streamed to online guests with the unit's arm. The arc on the ground is still laid for a high swing, but
  not the blade's smear along the ground (the blade went over its head). scripts/cw_art.gd ANIMS and unit.gd's pose
  lists (fps 9, no loop) know the two new strips.
- Pictures in game: docs/shots/pendulum_air/high_swing/ (tools/shot_pendulum_high_swing.gd: a Balloon, a Swift, a
  Pterodactyl or a Skywing at each of its 8 sides, frames 2, 4 (the hit) and 5; all_hits.png = every view's hit frame;
  then the low sweep at a soldier on the ground).
- Tests: tools/test_pendulum_air.gd gained 4 checks (the hi strips load with 6 frames; at the Balloon it plays
  attack_hi_r only; the blow lands on frame index 3; at a soldier on the ground the low sweep): ALL PASS.
  test_pendulum_v2 ALL PASS, test_unit_stats 0 failures, test_card_text PASS. test_cw_tier3's 3 online checks fail as on
  main before (CLAUDE.md); test_cw_tier3_ai's Netter check (the Cuirassier netted first) fails with different numbers
  run to run: the Netter, not the Pendulum's art.

Choices made at the import (for the owner):
- **S**: the bottom row's 2nd frame swings the wrong arm (attack_r's): attack_hi_l takes the top row's 2nd frame mirrored
  there (S is symmetric).
- **SE**: the bottom row's 3rd frame reaches out with the wrong arm and SE is not symmetric: its 2nd frame (the
  telegraph) is held one frame longer instead.
- **NE**: both rows swing the viewer's RIGHT arm (attack_r's). Mirroring would show the NW body for the length of the
  blow, so the bottom row is kept as drawn: in NE both high swings are on the same arm. A ChatGPT redo of the NE LEFT arm
  (the viewer's left) would fix it (same prompt, art/redraws/pendulum_high_swing_ne_chatgpt.png's top row as reference).
- **N**: the top row swings the viewer's LEFT arm (attack_l's in N) and the bottom row mixes both arms: attack_hi_l is the
  top row and attack_hi_r the same row mirrored (N is symmetric from behind).
- **E**: one row for both arms (the far arm is hidden behind the body).
- The ChatGPT body is a little stockier than the code-built low sweep's (the same height, a few px wider legs); the blue
  ball joints become player colour by the palette rule, as on every Clockwork unit.

## The Clockwork computer

- Pendulums count as anti-air everywhere the computers ask "can this hit a flyer" (`AI._hits_air`, the army's answer
  to an air-only attack, the Crown's Balloon parties fearing anti-air: they now fly round Pendulums too), because
  they read Defs "anti_air".
- The Swifts it wants against enemy flyers (one more than the flyers seen, up to 6): each Pendulum counts as half a
  Swift, never fewer than 2 Swifts while flyers are about (the Pendulum is slow and only reaches what comes to it).
- With 2+ enemy flyers seen, it makes its Pendulums without waiting for 3 Springers first.
- On Hard, a Pendulum walks into the thickest knot of enemies near it (`AI._pendulum_aim`): flyers count in the knot
  now (a cloud of Hatchlings over the fight).

## Measured

### Bench (tools/bench_pendulum_air.gd, scripted fights, no computers; `pendair:off` = before)

Value lost = the value of the units lost (Game.unit_value, as the match log counts it). Fights end when one side is
gone or at 90 s.

| Fight | Before (ground only) | After (flyers 3/4) |
|---|---|---|
| **Balloon harass**: 2 Pendulums + 4 Winders at work under 2 Balloons (4 Musketeers aboard each, hovering); the Pendulums attack-move under them | 18 s: both Pendulums dead, the Balloons untouched (Clockwork lost 460, Crown 0) | 18 s: both Balloons down with their 8 Musketeers (Crown lost 730), one Pendulum lost (Clockwork lost 440) |
| **3 Pendulums v 4 Storm Challengers** (attack-moving into each other) | 90 s: 2 Pendulums dead, the Challengers untouched (400 v 0) | 19 s: all 4 Challengers dead, no Pendulum lost (0 v 600) |
| **3 Pendulums v 2 Storm Sires** | 64 s: all 3 Pendulums dead, the Sires untouched (600 v 0) | 90 s: 1 Pendulum and 1 Sire dead, the other Sire at 112 of 700 hp (200 v 200) |
| **3 Pendulums + 3 Swifts v 10 Hatchlings** (Hatchlings hit only flyers: they go for the Swifts) | 90 s: all 3 Swifts dead, 9 Hatchlings left (225 v 40) | 6 s: all 10 Hatchlings dead, nothing lost (0 v 400) |

What it says: against flyers that come to it (melee and short-range flyers: Hatchlings, Challengers, a hovering
Balloon) the Pendulum is now a strong answer, as it is against light melee on the ground; the Storm Sire (700 hp, armour)
is an even trade. Its weakness stays: it is slow (46) and its reach is short (62 px), so a flyer that keeps moving or
shoots from range (a Balloon's basket fires 35% beyond a Musketeer's 190) and flies off is not caught; the bench's
Balloons hovered still on purpose. The Storm Challenger result (0 lost for 600) is the one to watch: four light flyers
diving into three Pendulums is the worst case for the flyers (see Claude's choice 1).

### Computer games (tools/shot_ai_match.gd, Hard v Hard, Greenhold, 15:00; result.txt counts what the Pendulums did
to flyers)

Eight games, each seed played with the change on and off (`pendair:off`): the Crown on its Balloon harass plan v the
Clockwork's Pendulums plan, and the Brood's Optimal v the Clockwork's Pendulums plan. The match log's last minute
(army value, kills and losses) and what the Pendulums did to flyers:

| Game | Pendulum swings | Hits on flyers (damage) | At 15:00 (or the end) |
|---|---|---|---|
| Crown Balloon v Clockwork Pendulums, seed 11, ON | 97 | 0 | Crown army 2755, Clockwork 4605; Clockwork killed 80, lost 40 |
| same, OFF | 66 | - | Crown army 4845, Clockwork 540; Clockwork killed 32, lost 121 |
| Crown Balloon v Clockwork Pendulums, seed 12, ON | 104 | 2 (26) | Crown army 4345, Clockwork 1875; Clockwork killed 28, lost 84 |
| same, OFF | 177 | - | Crown army 3945, Clockwork 3120; Clockwork killed 22, lost 67 |
| Brood Optimal v Clockwork Pendulums, seed 11, ON | 109 | 0 | the Brood far ahead (200 supply v 4) |
| same, OFF | 281 | - | the Clockwork ahead (army 3820 v 3200; killed 313, lost 72) |
| Brood Optimal v Clockwork Pendulums, seed 12, ON | 516 | 0 | the CLOCKWORK WON at 12:53 |
| same, OFF | 68 | - | the BROOD WON at 12:15 |

What it says: in computer games the Pendulums almost never meet a flyer (2 hits in 4 games): the Crown's Balloon parties
already flew round anti-air and now fly round Pendulums too ("round the anti-air" in the log from the first party), and
the Brood's Optimal plan made almost no flyers in these games (a Storm Sire, 2 Hatchlings). The results swing both ways
between ON and OFF (the Brood won one seed each way, the Clockwork did better ON in one Crown seed and worse in the other):
that is the games going their own way once one decision differs (the Balloon AI's anti-air map, the Swift count), not the
change; there is no sign here that it tips a matchup. The change shows where a player brings flyers to Pendulums (the
bench), which is what the owner asked for.

## Tests

- tools/test_pendulum_air.gd (new): Defs, the card's "hits flyers", can_hit and find_target (a flyer alone, a nearer
  ground soldier first), one swing through a Balloon, three Hatchlings, an armoured Ticking Owl and a labourer (13.5,
  13.5 x3, 8, 18), its own Swift and a Hatchling behind it untouched, a netted flyer the full blow: ALL PASS.
- test_pendulum_v2 ALL PASS; test_unit_stats 0 failures; test_card_text PASS (65 kinds); test_i18n PASS (0
  untranslated); test_content_all 0 FAIL (16 WARN, all older: voice lines, RELOAD tips); test_cw_air, test_cw_air_ai,
  test_cw_army, test_clockwork_army, test_clockwork_builds_b, test_cw_tier3_ai, test_cw_ai, test_ai_optimal pass.
- test_cw_tier3: its "it cannot reach flyers" check now says "it reaches flyers too"; its 3 online checks (the Swift's
  morph bar, the net in flight, the catch on the guest) fail as they did on main before this job (CLAUDE.md).
- Several tests exit with code 134 after printing their result (Godot's exit on quit in this build): their printed
  results are what count.

## Claude's choices (for the owner)

1. **The light bonus stacks on flyers** (x0.75 x1.5 = x1.125 on a light flyer), as the job said. If light flyers should
   take less than the plain blow, drop the light bonus in the air (`Pendulum.blow_k`): a light flyer would then take 9.
2. **Target choice is the plain nearest-enemy rule**, with no preference for ground units: a flyer and a ground unit at
   the same distance are equal. The swing cuts both anyway when they are in the arc.
3. **The same arc and reach** for flyers (62 px): no extra height check. A flyer over the arc is hit wherever it hovers.
4. **Art**: since 0.38.16 the HIGH SWING plays at flyers (see Art, with the import's own choices).
5. **The computer: a Pendulum = half a Swift**, never under 2 Swifts with flyers about; Pendulums without 3 Springers
   first once 2+ flyers are seen.
6. A **measuring switch** `-- pendair:off` (scripts/pendulum.gd) puts the old ground-only Pendulum back for benches
   and studies; players never see it.
