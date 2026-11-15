# Crown coaching: the Balloon harass (crown-coach-balloon, 0.38.2)

AI only: no unit, building or economy number changed. Branch `crown-coach-balloon` from 0.38.1. Switches: `blfix:off`
plays the harass as before (scripts/ai_crown_balloon.gd), `blshare:off` keeps OPTIMAL's old share for the balloons
(scripts/ai_optimal.gd). Study switch (no effect without it): `normalclock:<plan>` makes OPTIMAL's pick on a NORMAL read of
the Clockwork that plan (with the old `greedyclock:<plan>` for the GREEDY read), to measure plans against each other.

## The complaint

The owner's watched game (2026-11-15 00:21, Hollowfen, seed 4287366311, Hard OPTIMAL v Hard OPTIMAL, 0.38.1; log on branch
playtest-logs, docs/playtests/2026-11-15_0021_crown_v_clockwork_hollowfen.txt): "Crown made a balloon but didn't load
musketeers on it. Sent the balloon out without anyone, and then, scouted an attack from clockwork, sent musketeers on move
command to die to the attack." In the log: OPTIMAL read the Clockwork NORMAL at 1:34 and picked Balloon harass; the first
balloon at 4:07; `party 1 forms: a balloon and 3 Musketeers` at 4:57; the Clockwork's push (8 Clock Soldiers) at the ramp
from 5:30; `party 1 is over (too few aboard)` at 5:37; 4 Crown units lost by 6:00. And his view: "I actually suspect
balloon like that game is good vs clockwork, but the execution was pitiful... it shouldn't be 100% the choice all the
time, but I think it is a viable choice."

## What was wrong, in plain words

Reproduced on Hollowfen (the same seed; a match does not replay exactly, so the plan was forced with the new study
switch, `normalclock:balloon greedyclock:balloon`) with a trace of every balloon every 3 s (`bltrace:1`), and on Greenhold:

1. **An empty balloon went out alone.** With fewer than 3 Musketeers free, the harass sent the balloon to "look at the
   enemy's land": it floated 60-80 tiles out toward the Clockwork and hovered there. In the old code's 12 measuring games
   every game had it, a third of an empty balloon's time spent more than 30 tiles from home (449 of 1,415 looks).
   In one traced game (Hollowfen) a balloon called home from 80 tiles out to load was netted on the way and shot to 19
   of 180 health.
2. **The men were sent to a balloon that was not there.** A party formed as soon as 3 Musketeers were free, wherever the
   balloon was (60-80 tiles out, see 1). After 20 s the men were ordered aboard anyway: a boarding order makes a man walk
   to the balloon, so they walked out of the base toward it, on a plain move (they do not shoot on the way), into the
   Clockwork's push coming the other way. That is the "move command to die". After 40 s the party gave up ("too few
   aboard": 10 times in 12 games) and the balloon went back to floating out alone.
3. **Nothing kept a party from forming with the enemy at the door**, and a loaded party near home took up the "defence
   from the air" while it was still loading, so a balloon with 1 man aboard flew off and left 2 walking.
4. **A hurt balloon flew on.** A balloon hit on the way kept going until under 45% health, and it was never mended (the
   computer never sends a labourer to a machine): in one game a party arrived at its target with 21 of 180 health and
   was shot down with its 4 men. At 46 px a second the way home is long.
5. **The Clock Aviary was not feared**, and the enemy's army was rated only where it was in sight at that moment.

Films (docs/crown-coach-balloon/films/): `before_army_0_0702.jpg` and `before_army_0_0722.jpg` (old code, Hollowfen):
the balloon out over the Clockwork army below the ramp, netted, while the men are at the gate; `after_base_0_0632.jpg`:
both balloons wait behind the hall, away from the Clockwork army razing the natural; `after_base_0_0642.jpg`: the
party loads there, the Musketeers on the high ground; the `after_strike_*` pictures: a coached party over a Cog Press.

## What changed (scripts/ai_crown_balloon.gd; the Balloon harass plan only)

- **An empty balloon waits at home**, over its boarding spot: open ground by the main hall on the side away from the
  enemy, on the hall's level. It is never sent out alone. (The old look-out is what `blfix:off` brings back.)
- **A party forms only when home is quiet and its balloon is home**: no armed enemy at the main's buildings and no enemy
  army (150+) seen within 20 tiles of the main in the last 50 s, for 20 s in a row; the balloon within 12 tiles of the
  boarding spot. An enemy army at the natural does not stop it (its own base is emptiest then: the time to raid; the
  main's ramp post holds the main).
- **Loading**: the balloon goes over the spot first; the men walk there on ATTACK-MOVE; they board only once it is there.
  An attack on the main while it loads calls the party off ("trouble at home: the men stay with the army"); the balloon
  stays home. It leaves with 2 or more aboard and never with a man walking after it. No air defence while loading.
- **On the way**: a balloon that loses 20% of its health since it set out, or falls under 45%, turns back. Over a target,
  dropping or waiting for its men: under fire and under 70% health, it pulls back home (the men on the ground are lifted
  first, never left behind). The way home goes round the anti-air it knows (one waypoint, as its flights out do). It
  does not set out again under 60%, and a labourer MENDS a hurt balloon at home (the Crown's machines are labourers'
  work). Anti-air worth 60% of the party sends it off (was 100%).
- **The enemy army is remembered** where it was seen (50 s): targets near it rate down (it strikes where the army is not,
  e.g. while the army is out pushing), and no drop beside it. **The Clock Aviary counts as anti-air** (10 tiles: its
  Swifts).
- **The defence from the air** only near home (a raid far out keeps raiding), over an attack with next to no anti-air (a
  hovering balloon over Springers and Netters was shot down), and not again within 25 s of leaving one.

OPTIMAL (scripts/ai_optimal.gd): the Balloon harass's weight against the Clockwork, on a NORMAL and on a GREEDY read, goes
from 1 to 2: Timing 3, Economy 1, Balloon 2, so a third of the picks (was a fifth; the riders' early roll on a greedy
read, 15%, is unchanged).

## The numbers

All the data (result.json, the AI story, the harass's lines and its minute counts per game) is in
docs/crown-coach-balloon/data/<variant>/<game>/, the tables in docs/crown-coach-balloon/report.txt.

Hard OPTIMAL Crown v Hard OPTIMAL Clockwork, 12 maps (Greenhold, Highmoor, Dune Sea, Frostfang, Twin Fords, Ashfall, Red
Coast, Ashford Crossing, Kestrel Rise, Redrock Canyon, Cinder Steps, Hollowfen), the win-rate study's tags and seeds (one
round per map, both start spots), to 15:00, `tools/qa_match.gd` headless; the Crown's plan forced with the study switches.
"Score" = the Crown's (income earned + 2 x army) over the Clockwork's at the end, the mean of the games.

### The harass, before and after (all forced to Balloon harass)

Two runs of the coached harass: "after 1" is the code of this doc without the flight home round the anti-air, "after 2"
the code with it (both runs of the same 12 games).

| | before (`blfix:off`) | after 1 | after 2 |
|---|---|---|---|
| W-D-L (the Crown) | 0-8-4 | 0-8-4 | 0-9-3 |
| score at the end | 0.34 | 0.40 | 0.35 |
| "too few aboard" (a party that never left) | 10 | 0 | 0 |
| games with an empty balloon out alone (30+ tiles from home) | 12 of 12 | 0 of 12 | 0 of 12 |
| games with no strike at all | 3 | 2 | 0 |
| strikes (hover or drop at a target) | 19 | 35 | 41 |
| Clockwork workers killed by the harass | 75 | 185 | 162 |
| value killed by the harass (all 12 games) | 12,765 | 12,235 | 10,675 |
| balloons lost | 16 | 8 | 10 |
| Musketeers lost from the baskets | 20 | 12 | 20 (9 in one game) |
| Crown units lost, a game | 80 | 60 | 76 |
| the first party / the first strike (mean) | 6:08 / 8:05 | 5:53 / 8:17 | 6:17 / 8:20 |
| army at 8:00 / 10:00 / 15:00, Crown (Clockwork) | 914 (1,932) / 1,284 (3,103) / 798 (5,891) | 977 (1,788) / 1,372 (2,848) / 1,294 (5,858) | 991 (1,770) / 1,486 (3,099) / 1,069 (6,407) |
| Crown income at 5:00 / 8:00 / 10:00 (Clockwork) | 2,470 (4,163) / 5,700 (10,108) / 8,202 (15,688) | 2,565 (4,090) / 5,795 (9,751) / 8,392 (14,900) | 2,502 (4,137) / 5,668 (9,942) / 8,297 (15,433) |
| Crown halls lost / Clockwork halls lost, a game | 2 / 0 | 2 / 0 | 2 / 0 |

The faults the owner saw are gone: no party ever ended "too few aboard", no empty balloon went out, no man walked out
to a balloon. The harass now strikes twice as often and kills about two and a half times the workers (24 games: 347
against 75 in 12), for about half the balloons (0.75 a game against 1.33) and fewer men (1.3 a game against 1.7); the
value it kills is about the same (the old code's kills were more soldiers, often from a balloon over a fight at home).
The results do not change: the Crown wins none of these games whatever it plays (below). The two "after" runs differ
by 0.05 in score, which is the noise of 12 games (the scores of single games run from 0.2 to 0.8).

In "after 2" one party dropped its men and pulled home under fire with them on the ground (the 9 men lost on Kestrel
Rise). Fixed after the run (men on the ground are always lifted out first; tests pass), not measured again.

One more variant was measured and NOT kept ("bl_evade" in the data): a party under fire but still above 60% health
flying off and picking the next target instead of going home. It struck more (42 strikes, 203 workers, 13,520 killed)
but lost 14 balloons and 20 men and ended at a score of 0.28: the old losses back. The pull-back home stays.

### The Balloon harass against the other Crown plans (the owner's question: one of OPTIMAL's options?)

The same 12 games, the Crown's plan forced on both reads:

| | Balloon harass (coached, 24 games) | Timing attack | Economy race | Balloon (uncoached) |
|---|---|---|---|---|
| W-D-L | 0-17-7 | 0-9-3 | 0-8-4 | 0-8-4 |
| won or led (draw ahead by 10%+) | 0 | 0 | 1 | 0 |
| score at the end | 0.38 | 0.36 | 0.43 | 0.34 |
| decided games, mean length | 12:51 | 13:40 | 12:00 | 12:30 |
| Crown income at 8:00 / 10:00 | 5,730 / 8,345 | 5,510 / 8,107 | 6,808 / 9,880 | 5,700 / 8,202 |
| Crown army at 8:00 / 10:00 / 15:00 | 984 / 1,429 / 1,182 | 1,208 / 1,633 / 415 | 847 / 1,185 / 718 | 914 / 1,284 / 798 |
| Crown units lost / Clockwork units lost, a game | 68 / 107 | 80 / 109 | 93 / 92 | 80 / 104 |
| labourers at 8:00 | 29 | 26 | 39 | 29 |

Noise: a score moves about +-0.05 and a W-D-L column about +-2 between two runs of the same 12 (the two "after" runs
above, and docs/winrate_2026_11_12.md). So the three plans are close: no plan wins against Hard Clockwork
OPTIMAL. The coached balloons sit between the Timing attack and the Economy race on the end score, lose the fewest units,
and are the only plan that takes the Clockwork's workers (14 a game) while its army is out.

**Share set by the data: one third of OPTIMAL's picks against the Clockwork** (Timing 3, Economy 1, Balloon 2, on a
NORMAL and on a GREEDY read; was one fifth). Not more: it is no better than the Economy race by these numbers, and the
Timing attack is the only plan that has taken Clockwork halls in the bigger study (docs/crown_v_cw_plan_study.md).

## Tests

- New: `tools/test_crown_balloon_coach.gd` (Hollowfen, the Clockwork standing still): [wait] an empty balloon with too few
  men comes home and waits over its boarding spot; [mend] a labourer mends a hurt balloon at home; [spot] the boarding
  spot is behind the hall, away from the enemy; [load] no party forms with its balloon away, no man walks out more
  than 22 tiles while it loads (11), 3 board, none walks after a balloon that left; [calloff] Clock Soldiers at the main
  call a loading party off and the balloon stays home; [aviary] the Clock Aviary counts as anti-air; [hit] hit on the way,
  it turns back; [switch] with `blfix:off` the empty balloon floats out as before. ALL PASS.
- `tools/test_crown_balloon.gd` (the harass against a standing Brood): ALL PASS. test_i18n (the patch notes in pt/es): PASS.
- Run on the branch (with the harass of "after 1" plus the evade variant; the balloon tests again on the final code): test_ai_optimal, test_cinder_crown, test_crown_build_order, test_crown_ammo, test_crown_farms,
  test_crown_gate, test_crown_ghosts, test_crown_hold, test_crown_line, test_crown_lost_hall, test_crown_owner_eco,
  test_crown_rider_screen, test_crown_siege, test_crown_stall, test_crown_v_brood: ALL PASS. Failing, and listed as failing
  on main before this job (CLAUDE.md): test_crown_dragoon_raid [plan] and test_crown_mirror "a Musketeer is queued for the
  raider (12.0 s)". Neither touches the balloons (the harass exists only on the Balloon harass plan).
- The other test_ai_*.gd were not run: no code they use changed (the harass module is made only on its plan; the OPTIMAL
  change is the Crown's pick against the Clockwork).

## Claude's choices for the owner

1. **The empty balloon no longer scouts.** The old harass used it as the Crown's eyes (14 tiles of sight) between
   parties; now it waits at home, as you asked ("never sent alone"). The Crown keeps its labourer scout.
2. **No party while an enemy army is at the main** (within 20 tiles, seen in the last 50 s), but yes while it is at the
   natural. A raid during the enemy's push is the best time in principle, but 3-4 Musketeers fewer at the ramp is a risk
   with the Crown's army already behind; if you would rather raid during every push, the 20 tiles (QUIET_R) is the knob.
3. **Pull home under fire** rather than fly on to the next target: measured both ways (above); flying on struck more and
   lost the balloons again.
4. **A labourer mends the balloons.** The computer never mended its machines; one hand per hurt balloon at home, sent
   back when it is whole or the balloon leaves. Cannons and mortars are not touched (other jobs' area).
5. **OPTIMAL's share: a third** against the Clockwork, on both reads. Say if you want it higher; by these numbers the
   Economy race is at least as good on the scoreboard.
6. Left as they were: HOME_KEEP (2 Musketeers at home at least against the Clockwork), the party size (3-4), the
   targets' scoring apart from the army memory, the drop rules.

## What is still wrong (not this job's area)

- The Crown loses or trails every game against Hard Clockwork OPTIMAL whatever it plays (0 of 72 won here): its
  income is 0.55-0.65 of the Clockwork's at 10:00 and its army a fifth or less by 15:00 (the economy and army-size jobs).
- The Clockwork answers the first balloon it sees with a Clock Aviary "at once" and Swifts; by 7:00 most flights meet
  anti-air on the way (the "backs off: anti-air on the way" lines). The harass's window is the first strike.
- The balloons are slow (46): a strike on a far Cog Press is a 70-75 s flight each way.

## How to run

- A game: `godot --headless --fixed-fps 30 --script res://tools/qa_match.gd -- map:hollowfen seed:4287366311 end:900
  out:DIR slots:crown/optimal/0,clockwork/optimal/1 normalclock:balloon greedyclock:balloon bltrace:1` (`blfix:off` for
  the old harass; `bltrace:1` prints BLTRACE lines every 3 s and a BLSUM line every minute: strikes, kills, losses).
- Filmed: `tools/shot_ai_match.gd` with `a:crown b:clockwork pa:optimal pb:optimal every:10` and the same switches.
- The measuring batch of this doc: 12 games a variant, `GODOT=... python3 tools/study/crown_coach_balloon.py run DATA
  bl_new` (variants bl_old, bl_new, timing, economy, default), `... report DATA bl_old bl_new` for the tables.
