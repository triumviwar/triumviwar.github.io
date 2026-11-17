# crown-mirror-coach: the Crown mirror, coached again (0.38.38 -> 0.38.39)

The owner (2026-11-16 23:25: "start all coaching jobs needed"; 2026-11-11: draws should end, "a side with no
workers/army/means for 60 s is BEATEN and the winner hunts"). The problem: Hard OPTIMAL v Hard OPTIMAL Crown mirrors end in
a draw almost every game (35 of 38 at 15:00 in the 2026-11-12 study). Since then the Crown changed a lot (0.38.38: Farm
first, labourers first, halls on time, the screen, guns first).

Rules followed: docs/design_principles.md 2 (the defender's advantage must fade so a winner can finish; a lead must not be
a win button either) and 1 (a mirror is decided by play). **No unit, price or rule number changed. Everything is gated to
the mirror** (`AICrown.mirror()`, scripts/ai_crown_mirror.gd `AICrownMirror`) and switched off with `-- cmc:off` (the mirror
as 0.38.38 plays it), each rule also on its own: `cmcpress:off`, `cmctarget:off`, `cmcguns:off`.

**In short: the four rules below do what they say in the films, but on the 38-game measure they do not end more games.
Decided 2 of 38 before and 2 of 38 after.** The side ahead now goes out again more often after 10:00 and goes for the
enemy's open halls, but halls lost per game (1.71) and the leads at 12:00 and 15:00 are the same. The draws are not mainly
a "won't attack" problem: they are a 15-minute problem (see "Why the games still do not end").

## Tools

- `tools/study/crown_mirror_coach.py`: the 38 games of the QA design (`qa_matches.base()`, the Crown mirror rows: 19 maps x
  round 0/1, Hard OPTIMAL v Hard OPTIMAL, to 15:00), each played with `tools/film_coach.gd` so it keeps its log, story,
  coach lines (every 15 s) and a map picture a minute. `--extra cmc:off` etc.
- Data: `docs/crown_mirror_coach/before|after/<game>/` (result.json, story.txt, log.txt.gz).
- `tools/study/crown_mirror_report.py`: the table below (`DIR [DIR2]`) or a line per game (`--games DIR`).
- Filmed with `xvfb-run godot --rendering-driver opengl3 ... tools/film_coach.gd ... shots:1` (camera pictures of the
  armies, the halls and the fights).

## Step 1: the measure on 0.38.38 (before)

38 games (run from a checkout of main 0.38.38, `eaab153ae`): **2 decided, 36 draws.**

- Who leads: by score (income + 2 x army) the leader is ahead 1.09 at 8:00, 1.19 at 12:00, 1.36 at 15:00 (medians). 29 of
  the 38 games end with one side 10% ahead, but the leads are small and they grow slowly.
- **The side ahead holds back.** Both sides together send 2.8 waves a game (the Siege push counted). Of the 29 sides that
  led at 15:00, **17 sent no wave at all after 10:00** (0.41 a leader). Mirewood 1121: P2 (Siege push) 4,090 of army and 72
  labourers against 1,740 and 29 at 14:00, 1,682 gold in the bank, its push out once at 8:43-12:37 and again only at
  14:32 ([map at 12:00](shots/crown_mirror_coach/before_mirewood_r0_map_1200.jpg): P2's army, yellow, at home in the
  south-east). Dune Sea 1109: P2's Timing took two halls by 10:19, pulled back from the main's gate at 10:32 and sat at
  home for 4.5 minutes, 1,200-2,000 against 650-1,150. Why: the wave's supply bar (`AI._attack_at`: the plan's wave size,
  then + its step after each wave, and x1.4 of the wave after a pull-back: "it comes back only with a bigger army") while
  the army grows about 300 a minute (the economy rules take most of the gold).
- **It attacks walls head-on and pulls back.** 43 of the 115 waves ended "pulls back from the gate / palisade" (a third:
  the siege race weighed up as lost), most at the natural's palisade or the main's ramp gate under the cliff line.
- **It goes for the nearest hall, not the open one.** The shared target is the enemy hall nearest our own base: the walled
  natural under the main's cliff, then the main's gate; halls laid out in the open stood (Dune Sea 1109 10:21-10:32).
- **The Siege push waits for its kit.** Cinder Steps 1151: P2's push sat at home to 10:45 (1.46 ahead at 12:00) and went
  out with no gun at all (its 3 guns never came).
- **A beaten side lives on.** The two decided games (Greenhold 1140 at 14:21, Thornwood 1173 at 14:14) needed 4-5 halls
  taken and a hunt; a side down to its main with a few labourers has a hall and gold, so the 60 s rule (no worker, no
  army, nothing it can pay to train) does not reach it before 15:00.
- The P1 spot: won or led 11, P2 20 (p 0.15, a sign test): no edge to act on.

## Step 2: the fixes (all in `scripts/ai_crown_mirror.gd`, the mirror only)

8. **THE SIDE AHEAD PRESSES** (`press`, from `AICrown._army` before the shared think; `cmcpress:off`). From 8:00, an army
   ready (raiders, errands, harassers, a new hall's guards left out) worth 1.3 times the enemy army it reckons and 900 or
   more goes out whatever the bar, 25 s after its last wave ended, while the enemy has a hall it was not just beaten at
   (or it has 2 guns to shell a walled one, rule 7). The bar comes down to 85% of that army (the shared rule counts fewer
   men than the press does). The reckoning (`foe_army`): what was seen lately, never under 70% of the Crown's reckoning
   table (AICrown.foe_reckon, the table less half of what we killed); not seen for 60 s, 80% of it. The first versions
   reckoned on a scout's glimpse ("770 against 120") and both sides pressed at once at 6:00 with 600 of army: early
   even trades; hence the floor, 8:00 and 900. A held press says why in the log (`'s pressed wave is held: ...`).
   The **Siege push** presses the same way (`press_siege`, from `AICrownSiege._maybe_go`): it goes without its full kit
   (3 guns, 10 muskets) with one gun or 30 supply while ahead.
9. **THE OUTLYING HALLS FIRST** (`wave_target`, from `AICrown._enemy_base` while a wave is out, and the Siege push's march;
   `cmctarget:off`). The wave goes for the cheapest enemy hall: near our base, away from the enemy's main (its army and
   its cliff), few walls or gates within 9 tiles, few enemy soldiers seen at it, not on the main's plateau (+25); a hall
   going up is cheaper; a hall the wave was just beaten at is left. Kept while it stands unless another is much cheaper.
10. **GUNS FOR THE WALLED HALL** (`siege_guns`, from the Crown's think stage 2; `cmcguns:off`). Ahead, from 8:00, while the
    enemy's halls left are its main or walled halls it was beaten at, an idle Foundry trains Field Cannons until the army
    has 3 (Dune Sea after the press: P1 1,455-2,700 against 780-1,080 before P2's main gate with one gun: "it can't get
    through under 55 dps of fire" twice; the bombardment of 0.33 wants 2 guns).

The rules of crown-v-crown-coach (0.33.17: the raid answer, farms before Mills, the guns shell the hall, the line holds
off and shells, the hunt over a token army) are unchanged.

## The films (the final code, shots:1)

- **Dune Sea 1109** (P1 Dragoon raids v P2 Timing). 6:58 P2's wave "goes for the enemy hall at (3, 26) (18 tiles from its
  main, 0 walls by it)" and at 7:49 for the hall P1 is putting up at its ramp's foot; the line breaks it with its guns at
  8:16 ([7:55](shots/crown_mirror_coach/after_dune_sea_0755_open_hall_first.jpg): P2's red line at the scaffolding below
  P1's ramp, P1's riders coming down). On 0.38.38 the same seed's P2 went for P1's natural and then its main gate. 13:56
  P2 "presses its lead: 1,080 of army against the 240 it reckons" and takes P1's hall at 14:48
  ([13:26](shots/crown_mirror_coach/after_dune_sea_1326_line_at_the_hall.jpg)). A draw at 15:00, P2 ahead.
- **Greenhold 1103** (P1 Timing v P2 Dragoon raids). 6:27 P1's wave goes for P2's hall at the foot of P2's ramp (18 tiles
  out, no walls), its guns come up (7:38) and the hall falls at 8:28; then the guns stand at P2's ramp gate with P2's
  musket line massed on the plateau above it ([8:45](shots/crown_mirror_coach/after_greenhold_0845_guns_at_the_main_gate.jpg)):
  the main is out of reach. 9:38 P2 presses (1,020 against 321), takes P1's hall below its cliff at 12:16 while P1's whole
  army stands on its plateau by its gate ([12:27](shots/crown_mirror_coach/after_greenhold_1227_hall_below_the_cliff.jpg)).
  A draw at 15:00.

Coach's notes: the waves now go for the right thing and take it; what follows is the same every time: the loser's army is
on its main's plateau behind its ramp gate, the winner's guns stand below, and the 15 minutes run out. Before
([Mirewood 14:00](shots/crown_mirror_coach/before_mirewood_r0_map_1400.jpg), [Dune Sea 12:00](shots/crown_mirror_coach/before_dune_sea_r0_map_1200.jpg))
the leader's army stood at home; after, it stands at the enemy's ramp.

## Measured: the 38 games, before (0.38.38) and after (this branch)

`python3 tools/study/crown_mirror_report.py before after` (the "before" batch is 0.38.38 itself, which is what
`-- cmc:off` plays: every rule here is behind `AICrown.mirror()` and the switch):

| batch | games | decided | W-D-L (P1) | P1 won or led - P2 | spot p | mean length | halls lost / game | waves / game | score lead 8:00 / 12:00 / 15:00 (median) | leader at 8:00 still ahead at 15:00 | idle-ahead min / game | dominant min -> hall in 3 min |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| before (0.38.38) | 38 | 2 | 1-36-1 | 11 - 20 | 0.150 | 14:57 | 1.71 | 2.8 | 1.09 / 1.19 / 1.36 | 8 of 13 | 1.4 | 128 -> 61 |
| after | 38 | 2 | 2-36-0 | 18 - 14 | 0.597 | 14:53 | 1.71 | 3.0 | 1.08 / 1.22 / 1.34 | 4 of 7 | 1.5 | 117 -> 61 |

Behaviour (`python3 tools/study/crown_mirror_diag.py before after`):

| | before | after |
|---|---|---|
| waves (with Siege pushes), 38 games | 115 | 128 |
| sides ahead at 15:00: waves after 10:00 (mean), sent none | 0.41, 17 of 29 | 0.63, 13 of 30 |
| sides ahead at 15:00: enemy halls taken (mean), none | 1.45, 7 of 29 | 1.37, 6 of 30 |
| pulled back from a gate or palisade | 43 | 40 |
| "presses its lead" / "goes for the enemy hall" / guns trained for a walled hall | - | 57 / 161 / 11 |
| the hunt began | 10 | 9 |
| army / income at 15:00 (mean of both sides) | 1,986 / 18,865 | 1,873 / 18,617 |

- Decided: 2 and 2 (after: Kestrel Rise 1133 P1 at 12:51, Highmoor 1143 P1 at 13:18; before at 14:14 and 14:21).
- Won or led by spot: 11-20 before, 18-14 after; neither is an edge (p 0.15, 0.60). The flip is noise.
- No harm seen either: the leads, the armies, the incomes and the halls lost are the same within noise.

## Why the games still do not end

1. **15 minutes is short for this mirror.** Both Crowns saturate 40-70 labourers on 4-6 halls and keep 1,500-2,500 of army
   at 12:00; the median lead at 12:00 is 1.2 and a lead of 1.8 (the "dominant" minutes) turns into an enemy hall within 3
   minutes half the time (61 of 117-128) in both batches. The decided games end at 12:51-14:21: a side has to lose 4-5
   halls first. Most of the films' draws were going to end by 17-20 minutes (Greenhold 1103's P1 in the dev runs: 6
   labourers and 310 of army at 13:00, the hunt on at 13:16, gone just after 15:00).
2. **The main holds.** The loser's army stands on its plateau behind its ramp gate (the owner's doctrine: hold the ramp's
   top, AICrownHold), the cliff line covers the gate, and the winner's guns below have no spot out of the line's reach to
   shell the main hall from (rule 7 checks that and pulls back as before). This is the defender's advantage of the design
   principles that should fade by mid-game; in the mirror it does not.
3. **The shared bar and the guards.** A pressed wave still waits for the shared rule's other gates (a new hall's guards
   take two thirds of the army while it goes up, the screen riders, the defence's "a push is coming"); in the after batch
   the press fired 57 times and the waves rose by 13.

## Proposals (not built: shared code, or numbers)

- **P1, measure the mirror to 20:00** (the same 38 games): the measure, not the play, decides "draw" today; at 15:00 a game
  with one side on 6 labourers counts as a draw. A cheap check of whether the mirror ends at all.
- **P2, the guns' spot against a main** (shared fighting code: crown-guns-coach's area): let the guns shell the main hall
  from a spot within the cliff line's reach if the wave's line stands in front of them (a formed line screening its guns),
  instead of only from spots out of every shooter's reach.
- **P3, the new hall's guards** (shared, `AI._guard_new_hall`): two thirds of the army guard a hall going up; in the mirror,
  with HALLS ON TIME a hall is often going up, so the army is often two thirds home. A wave pressed by a lead could take
  the guards along (the hall's builders run, as they do from any push).
- **P4, the defender's advantage that fades** (design, numbers: for the owner): e.g. the ramp gate's hit points or the
  cliff line's reach later in the game; not this job's (no numbers changed).

## Tests

| test | result |
|---|---|
| test_crown_mirror | ALL PASS, with new checks: the side ahead presses (the bar comes down), not while behind, the Siege push goes without its full kit while ahead and keeps it while behind, `cmcpress:off`; the open hall in the field before the walled one by the main, a hall it was beaten at is left, `cmctarget:off`. Its raid-answer check is flaky (a Musketeer queued in 12.0 s once in four runs; it passes on rerun) |
| test_ai_optimal, test_crown_ammo, _balloon, _balloon_coach, _build_order, _defence, _farms, _gate, _ghosts, _hold, _line, _lost_hall, _owner_eco, _rider_screen, _siege, _stall, _v_brood | PASS |
| test_crown_dragoon_raid | 1 failure ("[plan] ... a group out by 690 s (formed true, rode false)"): known on main |

## Shared code touched (for the merges)

| file | where | change |
|---|---|---|
| scripts/ai_crown.gd | `_army` | `cm.press()` before the shared think, in the mirror |
| scripts/ai_crown.gd | `_enemy_base` | in the mirror with a wave out (not the rush wave): `cm.wave_target(...)` first |
| scripts/ai_crown.gd | `_think_stage_crown` (stage 2) | `cm.siege_guns()` after `cm.raid_answer()` |
| scripts/ai_crown_siege.gd | `_maybe_go` | `big` also when `cm.press_siege(...)` (mirror) |
| scripts/ai_crown_siege.gd | `_march` | the goal is `cm.wave_target(mid)` in the mirror (it still sets up against what is in its way) |

Nothing in ai_crown_line.gd, ai_crown_screen.gd or the gun handling (crown-guns-coach's) or in the Crown v Brood code
(crown-brood-army's).

## Claude's choices (for the owner to confirm)

1. **The rules are left ON** although they did not end more games: they do what the films show (the open halls first, the
   leader out again after 10:00 more often, guns for a walled hall), nothing measured got worse, and they are the play a
   later fix (P1-P4) builds on. `-- cmc:off` (or each switch) turns them off; tell me to default them off instead.
2. **The press's numbers**: from 8:00; 900 of army at least; 1.3 times the enemy it reckons; the reckoning never under 70%
   of the table (80% when nothing was seen for 60 s); 25 s after the last wave; the bar to 85% of the army.
3. **The target's weights**: tiles from our base, less 0.3 per tile from the enemy's main (up to 40), +3 per wall or gate
   within 9 tiles (up to 10), +25 on the main's plateau (16 tiles), -5 for a hall going up, + the enemy soldiers seen
   there / 100; a new target only 8 cheaper; looked at every 10 s.
4. **Guns for a walled hall**: up to 3 Field Cannons, an idle Foundry, from 8:00, ahead the same way, 20 powder in the bank.
5. **"Before" is 0.38.38 itself**, not this branch with `cmc:off`: every rule is behind `AICrown.mirror()` and the switch,
   so `cmc:off` plays 0.38.38's mirror; running the 38 games a third time (~2.5 hours on this machine) was left out.
6. **No balance change proposed beyond P4**; the spot edge is noise in both batches.
