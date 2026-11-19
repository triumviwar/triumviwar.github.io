# Labourers stacked on a site (crown-build-stack, 2026-11-18)

The owner, 10:59: "One of the strongest advantages of the Crown is stacking multiple labourers to build certain buildings
quickly. This compensates for the delayed economy of having to wait for Farms." Every Labourer on a Crown site adds his
full build speed (Unit._build calls site.add_progress for each builder), so four labourers build a Farm in a quarter of
the time. The computer did not use it: AI._construct sends one labourer to every building; only its new Town Halls got
three.

This job taught the Crown computer to stack (scripts/ai_crown_stack.gd, AICrownStack), looked for why its labourers stall
at 34 at 8:00 against the Clockwork's 47, and measured both. No number of the game changed, no other faction's computer
changed.

## In short

1. **Stacking works as a mechanic, but it did not help the computer.** With it the Crown computer's Barracks, Foundries,
   Mills and Armouries stood in about half the time (Barracks 42 -> 25 s, Foundry 47 -> 18 s from placed to done) and its
   Town Halls had 4-5 builders. Its economy did not gain anything in any version measured, and two versions made it
   worse:
   - variant A (every listed building stacked): in the Crown mirror the side that stacked won or led 4 games, the side
     without 15 (p 0.019), with 4% less income at 8:00 and 5% less at 12:00;
   - variant C (only where the building holds the economy or the defence up, and during pushes): against the Clockwork
     the income ratio at 12:00 was lower in 15 of 19 paired games (p 0.019), 5 fewer labourers at 12:00 (p 0.031), the
     third hall 70 s later;
   - variant D (as C, but no labourer walks to a site during a push except to the palisade): <<D>>.
   **So the stacking is OFF by default** (switch `buildstack:on`). The code, its test and its counters stay for the owner
   to try in his own games and for a later job.
2. **Why it does not help the computer: the Crown computer waits for gold, not for buildings.** Its bank sits at a
   median 50 gold from 2:00 to 8:00; every building is laid the moment its gold is there, and what comes after it waits
   for the next harvest, not for the building. A Barracks done 20 s sooner trains nothing sooner when the Musketeer's 60
   gold is not there. A helper costs his walk there and back, and the Farm he left works slower meanwhile (Farm work fell
   from 14.5 to 13.7 labourers on average in variant C against the Clockwork). A human player who banks gold and lays
   three buildings at once gains from stacking; this computer spends as it earns, so it has nothing to gain.
3. **Why the labourers stall at 34 at 8:00 against the Clockwork: the gold, then the posts.** Traced second by second in
   19 games (tools/crown_econ_trace.gd, variant A's "off" arm): from 3:00 to 8:00 a Crown hall stands idle with Farm posts
   free for a median **133 s** of the 300, with under 50 gold in 120 of them; in about half of that time the army clock
   (AICrownArmy, "soldiers before more labourers" against the Clockwork's usual army until 6:30) has the gold, and in a
   quarter the coach's LABOURERS FIRST wants a labourer but the harvest has not come. The posts themselves are full only
   a median 35 s; at 8:00 the Crown has 34 labourers for 42 posts. After 8:00 "an army the size of the economy" holds the
   halls (64% of the idle time). The second hall (median 4:35) and the third (8:49) come when their gold does; the owner's
   rule for the third hall (40 labourers and an army of 0.7 per labourer, AICrown.owner_hall_ok) holds it too.
   Against the Brood it is the other way round: the posts are full a median 189 s of the 300 (the Rush plan's second hall
   comes at ~5:00) and the army floor holds the rest.
   **Nothing here is the computer doing something plainly wrong**: each hold is a rule an earlier coaching job measured
   (the army on time, the army floor, the owner's third hall). The gap is the income: the Crown earns 0.67 of the
   Clockwork's at 8:00 with 0.75 of its workers. The one wrong thing found and fixed is below (3).
3. **A bug found on the way, fixed (ON, switch `keeppending:off`)**: when OPTIMAL picked its build at ~1:30, the common
   opening's step still waiting for its gold was cut with the old steps (AICrown.opt_switch slices the plan at the step
   it is on). The Rush's own steps (bo_opt) take the Barracks as laid, so when the Barracks was 20 gold short at the pick
   it was never built: no Horseman came, the army was 0-60 at 5:00 and the Crown lost to the Brood (Dune Sea r0, and 3
   more of 14 games in the first batch, where stacking had moved the gold by a second). Now the waiting step is kept at
   the front of the new plan unless the new plan builds that kind itself. It did not fire in the 115 measured games of
   variant C (the opening's gold no longer moves); it guards a timing that any small change can hit.
4. **The hall step keeps its gold** (switch `hallkeep:on`, OFF): while the opening's Town Hall step waits and the main's
   Farm posts are full, the army clock may not take the step's gold. Measured with the stacking, it fired a median 0 s
   and at most 20 s a game: the step is usually paid before the posts fill. Off with the stacking.

## What the stacking does (when switched on)

Every think (AICrown stage 1, after _finish_sites) each unfinished Crown site of the list gets helpers:

| site | helpers (all builders) | when a working labourer may go |
|---|---|---|
| Town Hall | 4 (5 when behind the coach's HALLS ON TIME) | always: its Farm posts are what the labourers wait for |
| Farm | 3 (4 for the opening's second Farm and a new hall's first) | while the free Farm posts are one or none, and for the urgent ones |
| Cottage | 1 (3 when the supply is blocked) | only while the supply is blocked (used >= cap - 1) |
| Barracks, Gate | 3 (4 under a rush) | only under a rush our scout read (before 7:00) |
| Foundry, Horse Breeder, Mill, Armoury, Church | 2-3 | never: idle labourers only |
| palisade pieces | 4 more along the ring | under a rush read, a push seen coming or a fight at home |

- **Who goes**: an idle labourer (or one whose Farm is barren) goes if he arrives 2 s before the site would be done
  without him. A working Farm hand (or a Mill hand that is not its last) goes only if his walk is under 0.34 of the
  work he will do there (0.75 at an urgent site), and while fewer than a quarter of the labourers are building. Never the
  scout, the escort, a crew of any other building, a labourer leading a horse or on an errand.
- **Not to**: a site in danger (AI._unsafe), a site not begun yet (a ghost: helpers standing on its footprint kept it
  from starting until it was swept), and during a push seen coming or a fight at home anything but the palisade.
- **The first minutes**: below 14 labourers only idle labourers help (a working hand only at a site a rush makes urgent),
  against the Brood and against anyone before our scout's read. The owner's extreme rush (test_ai_wall_vs_rush): one Farm
  hand pulled to the second Farm at 0:46 put the next harvest a few seconds late, the Barracks missed its gold at 58 s by
  20 and waited for the next harvest: Barracks at 98 s, no Musketeer by 2:40, 13 labourers lost.
- **After**: a helper goes on to the next unworked site near him or back to a free post (Unit._build: Game.next_site,
  free_site).
- Switches: `buildstack:on` (both sides), `buildstack:on0` / `on1` (one team), `buildstack:all` (variant A: working hands
  to every kind), `buildstack:push` (variant C: to the Barracks and Cottages during a push too). Counters in result.json
  crown_ai "stack" (helpers by kind, every watched site's placed / done clock and most builders).

## How it was measured

- The win-rate design (docs/winrate_2026_11_17.md): tools/qa_match.gd through tools/crown_econ_trace.gd (the same game
  plus a second-by-second trace of the Crown's economy), Hard OPTIMAL v Hard OPTIMAL, the 19 two-player maps of
  qa_matches.base(), round 0 (map, seed and sides as the win-rate studies), **to 12:00**. Crown v Brood and v Clockwork:
  each game twice, "on" and "off". The Crown mirror: each game twice, team 0 with the change (arm a) and team 1 with it
  (arm b), so every mirror game is the change against its absence and the spots swap. Runner
  tools/study/crown_build_stack.py, tables tools/study/crown_build_stack_report.py, two games at a time on a 2-core
  machine (about 2 minutes a game).
- Paired sign tests game by game (the same map and seed: the match is not deterministic, so a pair shares the start,
  not the game). "Won or led" = won, or led a draw by 10% on income + 2 x army (the win-rate rule).
- Round 1 and the 20:00 sample were not run: every version measured worse or no better at 12:00 in round 0, and the
  machine time went to the next version instead (see Claude's choices).
- Data: docs/crown_build_stack/data (variant C), data_variantA, data_variantD; tables.md, tables_variantA.md,
  tables_variantD.md. Films: docs/crown_build_stack/films (tools/study/crown_build_stack_film.sh, buildstack:on).

## The numbers

<<NUMBERS>>

## The films

- **Greenhold v the Clockwork (r0, variant C)**: Timing plan; the Crown's sites had 1-5 builders (coach.txt "build" 1 in
  24 looks, 2-5 in 26); 40 labourers and 4 halls at 12:00 against 54 Winders on 5; income 11,780 v 21,869. The film
  shows what the tables say: the buildings come fast, the gold does not.
- **Kestrel Rise v the Brood (r0, variant D)**: Economy plan; 43 labourers and 3 halls at 12:00 against 50 grubs;
  income 11,780 v 13,726, army 1,905 v 2,215; no hall lost.

## Claude's choices (for the owner)

1. **Off by default.** The task said to keep it only if it helps; it did not, so the stacking (and the hall step's keep)
   ship off, with the switch for anyone who wants to look again. The OPTIMAL pick's bug fix ships on.
2. **What to stack**: the "binding" list (a hall, a Farm when labourers wait for posts, a blocked Cottage, a rush's
   Barracks/Gate, the palisade under a push). Variant A (everything) measured worst.
3. **The walk rule** (a working hand goes if his walk is under a third of the work he will do there) and BUSY_SHARE 25%.
4. **No helpers in the first minutes** below 14 labourers except idle ones (the owner's extreme rush test).
5. **No helpers during a push** except to the palisade (variant D), because variant C's push-time helpers went with the
   worse numbers against the Clockwork.
6. **Only Farm and Mill hands are pulled**, never a Foundry's or a Church's crew.
7. **The hall step's keep** was the one fix aimed at the stall; it hardly fires, so it is off too.
8. **The third hall's army condition** (the owner's rule from his own game) and **the army clock** were left alone: they
   are what holds the labourers, but each was measured by its own job; changing them is the owner's call (below).
9. **12:00, round 0 only**, three versions instead of one version twice (rounds 0 and 1) and a 20:00 sample.

## What could make stacking pay (proposals, nothing applied)

1. **Bank, then stack**: the computer could save for two or three buildings at once at fixed moments (the second hall
   with its two Farms; the Foundry with a Horse Breeder) and stack them, as a player does. That trades a little time in
   the bank for a burst; it needs its own measure.
2. **The stall is income**: a Crown labourer earns less than a Clockwork worker (the win-rate studies: 34 v 57 gold a
   minute per worker at 10:00 in the 11-12 coaching). Against the Clockwork the army clock takes half the halls' idle
   time; a lower SHARE (0.6 now) or an earlier UNTIL (6:30 now) would give the labourers more gold and the army less:
   measured before at 0.75 -> 0.6 (crown-coach-army). The owner's call.
