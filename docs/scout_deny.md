# Deny the scout (job scout-deny)

The owner, 2026-11-18 11:42, watching Crown OPTIMAL v Brood OPTIMAL: "Why is the Brood not killing the labourer scouting?
Denying scouting should also be a priority for all factions." In his game the Crown's scouting Labourer (sent at 0:02) walked
the Brood's base, read it GREEDY at 1:30, and came back for a second look at 4:00, and nothing went after it.

## Why nothing went after it

- **The Brood computer** only ever counted ARMED enemies as a threat at home (every check has `has_attack() and not
  is_worker()`), so a Labourer, a Winder or a Messenger walking round its Mother was invisible to its defence.
- **The Crown and Clockwork computers** had two answers already, both partial: their sized defence (`AI._defend`) sends a
  "lone raider" detachment at anything by their buildings, but only from units at least as quick as the intruder and only
  when it walks within 330 px of a building; and their worker safety sends two workers at an unarmed intruder, but only
  while their army is under 3 units.

## What changed (AI play only, no number of the game changed)

One new part shared by the three computers, `scripts/ai_scout_deny.gd` (`AIScoutDeny`), Normal and up. Switch:
**`scoutdeny:off`** plays as 0.38.61.

1. **It looks for scouts.** Twice a second it looks for an enemy SCOUT in or near its base: within 11 tiles of one of its
   buildings, rooted creatures or its Mother, and in sight (no cheating: what its own side sees). A scout is what it
   looks like from outside:
   - a worker (Labourer, Winder, grub) or an unarmed unit (Messenger, balloon, Missionary) with no armed friend within
     9 tiles (a Winder walking with an army is its escort, not a scout);
   - a quick soldier or a flyer of little worth (speed 88+ or flying, worth 180 or less: a Horseman, a Raptor, a Swift)
     with no armed friend within 16 tiles, and only while no other enemy fighter is in or by its base (the first Raptors
     of a wave, strung out, are the wave's).
   The Brood leaves riders to its own doctrine (no chase: `_nb_defend_riders`). Slow unarmed machines (the Great Winder)
   are no scouts.
2. **It sends the nearest fit hunters.** At most 2 for one scout and 4 in all, never a whole army: units that can hit it
   (a flyer needs anti-air) and catch it (85% of its pace or more, the defence's own rule, or a shooter already in reach),
   at least 50 quick (no Spring Ballista, no Pendulum), and free: not on a wave, in a defence, a harass, a raid, on an
   errand (screen, picket, refill), rooted, moulting, the computer's own scout. Early (before 7:00), when no soldier can,
   1-2 workers within 9 tiles go at a scout on foot (Labourers, Winders, grubs).
3. **It keeps it short.** A hunter gives up when the scout is 6 tiles past the base, after 30 s (10 s for workers), when it
   has been out of sight 3 s, or when enemy fighters worth 60% of the hunters are near the scout. Then it goes back:
   soldiers to where they were taken from (the army's code takes them from there), workers back to work. A scout that got
   away is left alone 20 s.
4. **The army is not held at home for it.** An UNARMED scout the hunters are after no longer counts as a threat
   (`AI._threat`): the army's waves and the workers carry on. An armed one still counts, so the defence's own answer still
   comes if the hunters are not enough.
5. **It tells the story.** The match log and the AI STORY: "P2 Brood sends 2 Raptors after the Crown's scouting
   Labourer", "P2 Brood killed the Crown's scouting Labourer at 4:50", "P1 Crown lets the Brood's scouting Grub go (the chase
   took too long)" (en/pt/es: `tools/i18n/58_scout_deny.txt`).

The hunters are left out of the rest of the computer while they hunt (`AI._on_errand`; the Brood's army, defence, waves and
sacrifices).

## The scout's side (part 3 of the job)

Checked, not changed:
- **A killed scout reads UNKNOWN, not a wrong read.** AIScout (the Crown and the Clockwork) ends a killed trip "killed",
  and a trip that saw too little of the base reads UNKNOWN ("the scout was killed before it saw the base"); the next look
  goes 35 s later, a fast soldier from the second denied trip on. Its GREEDY-by-absence read needs the base seen with no
  army at all, and hunters are army seen, so a scout killed by soldiers can't call the base empty.
- **The Brood reads all the time** from what any of its creatures sees: a dead grub leaves its read where it was (no read
  yet = OPTIMAL's normal game at its deadline). Nothing to change there.
- **Chased scouts still read something:** AIScout backs out of reach of soldiers and stands off where it can still see
  (`_avoid`, the stand-off spot); the Clockwork's flees from workers too. The Brood's watching grub backs off and comes back.

## HIDING TECH (part 2): not built

Claude's choice: skipped. Keeping tech out of a scout's sight means moving or not building buildings while it looks, and the
computers' building placement is shared by many coached rules; denying the scout gives most of the same and is simple.

## The numbers

**The study** (`tools/study/scout_deny.py`, report `tools/study/scout_deny_report.py`, all tables in
[scout_deny/tables.md](scout_deny/tables.md), data in `docs/scout_deny/data/`): the six pairings (Crown v Brood, Crown v
Clockwork, Brood v Clockwork and the three mirrors) on Greenhold, Dune Sea, Ashford Crossing and Hollowfen, two seeds each
(the base rounds' tags, seeds and sides), Hard OPTIMAL v Hard OPTIMAL to 12:00: 48 games with the rule ON and the same 48
with it OFF. (A first ON run, "ON_V1", had the workers' chase cut at 10 s; its numbers are in the tables too. The rule as
built is "ON": workers chase while the scout is in the base, 30 s at most.)

### What it did (ON, per player a game)

| denier | hunts sent | scouts killed | chases given up | workers sent | workers lost | hunters lost | first kill (median) |
|---|---|---|---|---|---|---|---|
| Crown | 4.0 | 2.0 | 2.0 | 0.9 | 0.00 | 0.06 | 4:26 |
| Clockwork | 4.1 | 1.8 | 2.3 | 2.4 | 0.00 | 0.06 | 5:19 |
| Brood | 4.1 | 1.4 | 2.6 | 2.5 | 0.06 | 0.06 | 5:21 |

Scouts killed (48 ON games): the Crown 30 Labourers, 26 Winders, 3 Horsemen, 2 Raptors, 2 Dragoons, a grub; the Clockwork
35 Winders, 14 Labourers, 4 grubs, 2 Raptors, a Missionary; the Brood 20 grubs, 17 Labourers, 7 Winders, a Raptor. Almost
nothing is lost doing it: 3 workers and 6 hunters in 96 player-games.

### The first scout

**The first scout is rarely denied: it comes before there is anything to deny it with.** Every computer's first scout
reaches the enemy's main at 1:10-1:45. By then the Brood has 0-6 Raptors (army worth 0-150 at 2:00 in the Crown v Brood
games), the Clockwork no soldier, the Crown a Musketeer or two behind its walled ramp. So only the workers can go at it, and
a worker is no quicker than a worker (Labourer and Winder 74, grub 68).

| scouter -> denier | first scouts brought a read, OFF / ON | killed, OFF / ON | GREEDY read by 5:00, OFF / ON |
|---|---|---|---|
| Crown -> Brood (the owner's game) | 8/8 / 8/8 | 0/8 / 4/8 (median 1:21) | 8/8 / 8/8 |
| Crown -> Clockwork | 8/8 / 8/8 | 6/8 / 3/8 | 8/8 / 8/8 |
| Crown -> Crown | 0/16 / 0/16 | 16/16 / 16/16 | 2/16 / 0/16 |
| Clockwork -> Brood | 8/8 / 6/8 | 0/8 / 0/8 | **8/8 / 0/8** |
| Clockwork -> Crown | 0/8 / 0/8 | 0/8 / 0/8 | 0/8 / 0/8 |
| Clockwork -> Clockwork | 15/16 / 13/16 | 0/16 / 0/16 | 7/16 / 13/16 |
| Brood -> Crown | 8/8 / 8/8 | 2/8 / 3/8 | 1/8 / 0/8 |
| Brood -> Clockwork | 8/8 / 8/8 | 0/8 / 2/8 | 8/8 / 8/8 |
| Brood -> Brood | 16/16 / 16/16 | 1/16 / 4/16 | 0/16 / 0/16 |

- **The owner's case, the Crown's Labourer at the Brood:** with the rule the Brood's grubs go at it at ~1:10-1:20 and
  kill it in 4 of 8 games, but the first look reads the Brood GREEDY in 7 of 8 all the same (3 of the 4 killed had read
  it as they fell) (1:15-1:45: "a second base and little
  army", the Mother and her far turtle, 0 Sires). That read is not wrong at that moment: the Brood's common opening HAS no
  army then. The Brood can't deny that first look; what it can change is the read (proposal P2 below).
- **The Clockwork's Winder at the Brood:** the Brood's grubs drive it back (the Clockwork's scout flees from workers after
  it) and it finishes its look only at 2:20-2:40, having seen less of the main (37-76% of it, OFF 93-100%): it reads
  NORMAL in 6 games and UNKNOWN in 2, GREEDY in none (OFF: GREEDY in 8 of 8). The Clockwork then plays a normal game (2 of 8 picked Owl raids, 1 Pendulums) instead of its "economy goes on"
  answer to a greedy Brood.

### The later looks: denied

From the second trip on, the hunters are there. The Crown's second look at the Brood (sent at 4:00, there at 4:45) is
killed in 6 of 8 ON games (4:48-5:24, by two Raptors or two grubs, mostly within 5 s of the hunt starting); OFF it finished
its loop in 8 of 8 (5:45-6:15) and read NORMAL in 6. The scouts each side loses in a
game go up (Crown at the Brood 1.25 -> 3.1, Clockwork at the Brood 1.25 -> 1.9, Clockwork at the Crown 2.1 -> 2.8, Brood
mirror 1.6 -> 1.8): a killed trip reads UNKNOWN and the next goes 35 s later.

**GREEDY reads that set off a plan:** 41 OPTIMAL picks on a GREEDY read OFF, 25 ON. The ones that went: the Clockwork's
"its first ground is its usual opening" picks against the Brood (8 -> 0), the Brood's "middle GREEDY -> timing" (4 -> 2),
the Crown mirror's middle picks (5 -> 0). The Clockwork mirror has a few more (7 -> 9: each side's Winder is chased, its
read comes at ~2:50 instead of ~2:25 and is GREEDY more often). The Brood's own opening rush on reading the Clockwork GREEDY at 1:41-1:51 stays
(8 of 8 both ways): its watching grub sees the Clockwork's second Clocktower before any Clockwork soldier exists.

### Income and outcomes

| pairing (first-named side) | income 8:00 OFF -> ON (it / foe) | won or led / trailed / even, OFF -> ON | paired better / worse |
|---|---|---|---|
| Crown v Brood | 6,365 / 6,737 -> 6,412 / 6,640 | 0/6/2 -> 0/6/2 | 0 / 0 |
| Crown v Clockwork | 7,077 / 9,801 -> 6,982 / 9,518 | 0/7/1 -> 0/8/0 | 0 / 1 |
| Brood v Clockwork | 7,080 / 8,442 -> 6,057 / 8,320 | 1/7/0 -> 1/7/0 (W-D-L 0-8-0 -> 0-6-2) | 1 / 1 |
| Crown mirror (P1) | 7,505 / 7,505 -> 7,552 / 7,172 | 4/3/1 -> 3/4/1 | 1 / 2 |
| Brood mirror (P1) | 8,886 / 8,765 -> 8,828 / 8,756 | 4/3/1 -> 2/5/1 | 1 / 4 (p 0.38) |
| Clockwork mirror (P1) | 10,070 / 9,875 -> 10,452 / 10,171 | 4/2/2 -> 2/2/4 | 1 / 3 (p 0.62) |

- **No outcome changed beyond noise** (every paired test p 0.38 or more; 8-16 games a pairing).
- **Income is the same within 3% everywhere but one place: the Brood against the Clockwork, -15% at 8:00, lower in 8 of 8
  games (p 0.008).** Not the grubs' chase (2 grubs for under 30 s): it is the reads. Denied its GREEDY read, the Clockwork
  plays a normal game, which meets the Brood's opening rush (picked from its own GREEDY read of the Clockwork) much better:
  the Brood lost 44-64 units by 8:00 in 3 games (OFF 24-28), and its rush plan keeps fewer grubs; the Clockwork also kills
  its watching grub now, so its second GREEDY read (the switch to a Timing attack and more grubs) came in 2 games, not 4.
  Two of these games ended in a Clockwork win (OFF none).
- Workers at 5:00 and 8:00 within a worker of OFF for every faction.

### Tests

- `tools/test_scout_deny.gd` (new): a Labourer walking round the base of each faction is hunted and killed (Brood ~16 s,
  Crown ~7 s, Clockwork ~20 s), by 2 hunters at most; the hunters are let go after; nothing chases past the leash (an
  unkillable Labourer that runs home: the hunters turn back inside the base); with no soldier at all the Crown's
  Labourers kill a grub inside its main and go back to work; with `scoutdeny:off` nobody is sent. `-- only:catch|leash|
  workers|off` runs one case.
- `tools/test_ai*.gd` (23), `test_brood_new*`, `test_crown_*`, `test_clockwork_*` and the Clockwork AI tests (59 in all):
  the failures are the known ones, the same with `scoutdeny:off` (test_ai_rush_followup, test_ai_wall_vs_rush's Barracks
  timing, test_brood_new's one check, test_brood_new_defence, test_crown_dragoon_raid's plan check, test_crown_line,
  test_crown_rider_screen, test_cw_heavy, test_cw_militia), plus flaky ones that passed on a rerun (test_ai_brood's banked
  food 60 s, test_ai_rush, test_crown_mirror's raider Musketeer, test_clockwork_builds_b). **One to watch:
  test_clockwork_home** ("the attack drew the army ... want 60% at the fight at once") failed in 3 of 5 ON runs and passed
  in 2 of 2 OFF runs. A first version took the first strung-out Raptors of a Brood wave for scouts and pulled 2 Clock Soldiers
  off; that is fixed (an armed scout only with no other enemy fighter in or by the base, and it stays a threat for the
  defence) and the next run passed, but the one game this test plays is changed by the denial (the reads differ), so its
  60% line is close either way.

### Films

Two games filmed to 7:00 with `tools/film_scout_deny.gd` (under xvfb), pictures in `docs/scout_deny/films/<tag>/`
(`hunt_<team>_MMSS.jpg` while a hunt goes on, `huntend_` where it ended; `hunts.txt` the hunts from the match log):
- `base_greenhold_crbr_r0` (Crown v Brood, the owner's matchup): at 1:20 a grub goes after the Crown's Labourer round the
  Mother (it read GREEDY at 1:30 all the same); at 1:36 two Crown Labourers kill the Brood's watching grub; at 4:46 two
  Raptors kill the Crown's second scout on the ramp at 4:50; at 6:40 two Musketeers chase the next watching grub off.
- `base_dune_sea_brcw_r0` (Brood v Clockwork): the Winders and the grubs chasing each other's scouts at 1:20-1:40.


## Claude's choices for the owner

Each one says what I chose and the alternative; say if you want it the other way.

1. **One shared part for all three computers** (`AIScoutDeny`), not a rule in each: the same notion of "a scout" and the same
   leash everywhere. The Brood keeps its anti-rider doctrine (no chase of riders) on top.
2. **What a scout is, from the outside only:** a worker or unarmed unit with no armed friend within 9 tiles, or a lone
   quick (88+) or flying soldier worth 180 or less with no armed friend within 16 tiles and no other enemy fighter in the
   base. No peeking at the enemy computer's "this is my scout" flag. It also hunts a human player's scouts.
3. **Hunters:** at most 2 a scout, 4 in all; at least 85% of the scout's pace (the defence's rule) or a shooter already in
   reach; never slower than 50 (no Ballista, no Pendulum). The alternative, 1 hunter a scout, lost more of the chases.
4. **The leash:** 6 tiles past the base, 30 s, out of sight 3 s, or enemy fighters worth 60% of the hunters by the scout.
   Then 20 s before that scout is chased again.
5. **Workers:** only before 7:00, only when no soldier can, only within 9 tiles of the scout, and they never leave the
   base (30 s at most). The first version gave up after 10 s (ON_V1); chasing while the scout is inside kills a little
   more for the same cost (3 workers lost in 96 player-games).
6. **An unarmed scout being hunted is no threat for the army** (`AI._threat`): no wave held home, no hands pulled. An armed
   one still is, so the defence's own answer still comes if 2 hunters are not enough.
7. **HIDING tech (part 2) not built:** placement is shared by many coached rules; denying the scout does most of it.
8. **No change to how a killed scout reads:** AIScout already reads UNKNOWN and looks again in 35 s; the Brood reads
   continuously. Checked in the data: no killed scout gave a wrong read (a scout killed after its look keeps that read,
   e.g. the Crown's GREEDY of the Brood at 1:15-1:45, which was true at that moment).
9. **The Brood's grubs go at the Clockwork's Winder scout early** even though, measured, that denial made the Brood's own
   opening rush meet a better-prepared Clockwork (Brood income -15% at 8:00 in that matchup). It is what the rule is for;
   the cause is in the reads (P1, P3).

## Proposals (not built)

- **P1. The Clockwork's answer to a GREEDY Brood.** Denied its GREEDY read, the Clockwork played a normal game and met the
  Brood's opening rush far better. Its "economy goes on" pick on a GREEDY read of the Brood leaves it thin against the rush
  the Brood picks at the same minute. Worth a coached look (clockwork-v-brood).
- **P2. The Crown's first read of the Brood.** "A second base and little army" at 1:15-1:45 is the Brood's standard
  opening (its far turtle and no Raptors yet), read GREEDY on the first look in 14 of 16 games here and answered by the Horseman rush. The
  switch `truegreed:on` (AIOptimal: GREEDY only on 3+ grounds or 5+ Rootmaws) exists; measuring it is the next step if the
  owner wants the Crown's first read of the Brood to stop calling its normal opening greed. (No denial can stop that look:
  there is no Brood army at 1:20.)
- **P3. A computer could scout with a soldier sooner** once its worker scout was killed (today: from the second denied trip).
  Now that every computer kills worker scouts from ~4:30, the Crown loses ~3 Labourers a game at the Brood.
- **P4. Early anti-scout guard:** the Brood could keep its first Raptor (from ~2:00) home near the Mother as a scout
  catcher; the Crown and Clockwork's first soldiers likewise. Not built: the first look comes before any of them.
