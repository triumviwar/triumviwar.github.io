# The Clockwork's late game: why it stopped spending, and the fix

Job clockwork-late-macro, 27 November 2026. The owner asked: "Why does the Clockwork stop expanding?" This page says what was wrong, what was changed, and what the games showed. It changes no number of the game: only what the Clockwork computer chooses to build.

## The question

In the thirty Crown against Clockwork games of 26 November (Hard, OPTIMAL, to twenty minutes), the Clockwork built its halls as fast as the Crown, then lost most of them between fifteen and nineteen minutes, after it lost the big mid-game fight. While it lost them, its bank grew: about 430 cogs at twelve minutes, 2,800 at sixteen, 6,500 at twenty. Its supply stayed far under its limit, and the limit itself rarely reached 200. So it was not remaking its army after a lost fight.

## The cause

Two of those games were played again with a trace every five seconds (tools/cw_trace.gd, which now also prints why each Works cannot train). Nothing was holding the cogs back on purpose: the computer was not saving for a hall, not waiting on a plan, not saving for tech. Three plain limits were in the way.

First, it never had more than five Light Works. The shared computer rule stops building Works at five. In the late game all five stood with full queues, three Clock Soldiers each, and every think the bank had nowhere to go. After a lost fight it could only rebuild at five Works' pace.

Second, it kept two Mainsprings on five to seven Clocktowers. A new Mainspring only came once the old ones were worn out. So its Tension sat between zero and about eighty all the late game, and its Heavy Works waited on Tension most of the time ("Not enough Tension" in almost every trace line). The army it remade was nearly all Clock Soldiers: no Ballistas, few Pendulums and Springers, the units the battle tests found it needs against the Crown.

Third, one Heavy Works only, and Regulators laid just in time, so it was often short of supply in the minutes it had cogs.

## What was changed

All of it is in scripts/ai_cw_late.gd, called from the Clockwork computer's build step once its opening is over, from six minutes on, on Normal and Hard. Every part has its own switch, and they are all on.

1. More Light Works, switch cwlateworks. When every Light Works is busy (two or more in its queue), the bank holds 450 cogs beyond what the hall plan keeps back, and supply is not full, it lays one more, up to nine.

2. A Mainspring at every Clocktower, switch cwlatesprings. Any standing Clocktower with at least a third of its spring life left and no Mainspring drawing on it gets one, one at a time, when the cogs are there, and not with enemies beside it. Against the Brood an older rule did this already; now it is against every enemy.

3. A second Heavy Works, switch cwlateheavy. From nine minutes, once three Mainsprings wind and the first Heavy Works is busy, with 600 cogs to spare.

4. Supply ahead of need, switch cwlatesupply. With 500 cogs to spare, a Regulator goes up whenever fewer than 24 supply are free. With 1,200 cogs or more, two at once, up to the 200 limit.

`-- cwlate:off` turns all four off and plays as before. `-- cwlateworks:off`, `cwlatesprings:off`, `cwlateheavy:off` and `cwlatesupply:off` turn one off.

## How it was measured

The same games as the 26 November study: game number i has seed 1126001 plus i, the map is the i-th of the six parity maps in turn, and the start spot changes every six games. That study's data is the "before". Each block is ten games, numbers one to ten, five on each start spot and every parity map. Against the Crown two blocks were played, games one to twenty, and games one to ten once more with the final code (the doc calls the two versions v1 and v2). Against the Brood one block. In the mirror two blocks, with both sides running the new rules. "Won or led" means won outright, or ahead by a tenth at the bell, by income earned plus twice the army.

## What happened against the Crown

Twenty games.

The bank is spent now. In the games both versions survived, the bank at sixteen minutes went from 889 cogs to 101, at eighteen from 1,520 to 229. The supply used went up: at sixteen minutes from 106 to 128, at twenty from 110 to 143. The supply limit reached 174 at fourteen minutes where it was 154.

It built what it lacked: on average 6.2 Light Works instead of 5.7, 5.3 Mainsprings instead of 2.5, 1.9 Heavy Works instead of 1.1.

It holds its halls longer. Halls standing at eighteen minutes, 4.1 instead of 3.3; at twenty, 3.4 instead of 2.7. Buildings lost by sixteen minutes, 5.5 instead of 9.8. Its army at sixteen minutes was 3,000 against the Crown's 3,000, where it was 2,300 against 3,400.

The results moved a little, inside the noise. The Clockwork won or led 3 of 20, before 2. It was beaten outright 6 times, before 8. Game by game on the same seeds, the score difference moved in its favour by 0.21, better in 12 games and worse in 7, a t of 0.9. The Crown still wins this matchup: the battle tests found it wins the fights, and remaking an army faster does not change who wins the next fight. What changed is that the Clockwork no longer sits on its cogs while it loses.

## The final code, against the Crown again

The tests showed one thing to mend: the new rules could spend cogs the computer had put by for its Heavy Works or other tech. They now leave those cogs alone. Games one to ten against the Crown were played once more with this final code. The bank is still spent: in the games both versions survived, 727 cogs at sixteen minutes before, 125 now; at eighteen, 2,412 before, 77 now. The results are the same as before the change: won or led 2 of 10 (before 1), beaten 4 (before 4), score difference 0.00 game by game.

Put together, thirty games against the Crown with the new rules, each against the same game before: better in 17, worse in 11, a mean of 0.14 in the Clockwork's favour, a t of 0.8. That is inside the noise. The fix does what was asked, the cogs are spent and the halls last longer, but it does not turn the matchup.

## Side effects: against the Brood

Ten games. The Clockwork won or led 4 of 10 both before and after. It was beaten outright twice, before five times. Game by game, 0.34 in its favour, better in 6 and worse in 4, a t of 0.4: no clear change. Against the Brood it already had a Mainspring at every Clocktower and it was not short of Works, so the new rules matter less there.

## Side effects: the mirror

Twenty games, both sides on the new rules, "us" being the side on start spot A. More games are decided before the bell: 15 of 20, before 13. The side on spot A won or led 12, spot B 5; before it was 9 and 8. Twelve to five on twenty games is not a clear spot edge (about one chance in seven by luck alone), but it is worth watching. The 26 November study found no spot edge in this mirror. A winner now reaches 200 supply and then banks 5,000 to 12,000 cogs, because there is nothing more it may build at the cap; the owner decided the cap stays and there is no cog sink.

## The tests

Run after the change (each line: the test, then the result with the new rules, then with `-- cwlate:off` where a failure needed a check):

- test_cw_ai: passes.
- test_cw_tier2: passes.
- test_cw_tier3_ai: passes.
- test_clockwork_eco: passes.
- test_clockwork_home: passes.
- test_clockwork_owls: passes.
- test_cw_written_openings: passes.
- test_ai_optimal: passes.
- test_econ_limit_local: passes.
- test_clockwork_army: passed, then failed its "no combat unit sent alone" check in two runs out of three. With the new rules off it fails too: it is flaky, not from this job.
- test_clock_ai_swarm: fails now and then on "the Heavy Works is laid by 6:30" and "the first Pendulum is out by 9:00". With the new rules off it fails the same way (Heavy Works laid at 7:07 and 7:29 in two runs). It was already listed as unsteady. One fix came out of it: the new rules now leave alone the cogs the computer has put by for its tech and heavy machines.
- test_cw_heavy: fails its "will not set up too far from the Line" check, with the new rules on or off; it fails on main too (listed in CLAUDE.md).

## Claude's choices

1. All four parts are kept together and on by default, although they did not move the results beyond the noise: they do what the owner asked (the bank is spent, the supply fills, fewer halls are lost) and harm nothing measured. They were measured as one package, not one by one: a block takes over an hour, and the four parts feed each other (the second Heavy Works needs the Mainsprings, the Works need the supply). The switches let any one be measured alone later.
2. Nothing starts before six minutes. The written openings and the timing attacks keep their own pace; the problem was in the late game.
3. Nine Light Works at most, as the Crown computer stops at nine Barracks. Two Heavy Works at most.
4. The Mainspring rule now runs against every enemy, not only the Brood, and it does not hold the army's cogs back to save for one: a Mainspring only goes up when the cogs are already there.
5. Supply is built ahead only while the bank floats (500 cogs and more), so the opening's tight economy is untouched.
6. No change to which units it trains. The army's mix follows from the Tension it now has; the ai-lessons job already sets the mix against the Crown.
7. Retaking lost halls was not added. With the bank spent, the hall plan's own rule already lays new Clocktowers; the Clockwork now loses fewer of them.
8. The Brood and mirror blocks were played with the first version (before the saved-cogs guard); the guard only makes the new rules wait more, so they were not played again.
9. The mirror's lean to spot A is reported, not fixed: twenty games are too few to call it, and both sides run the same rules.

## Files

- scripts/ai_cw_late.gd: the four parts and their switches.
- scripts/ai_clockwork.gd: one call to it in the build step.
- tools/cw_trace.gd: the trace now prints the training gates and each Works' answer.
- tools/study/clockwork_late_macro.py: the runner and the tables.
- docs/clockwork_late_macro/tables.md: every table; docs/clockwork_late_macro/data/v1/: each game's result, story, trace, and the match log's cwlate lines.
