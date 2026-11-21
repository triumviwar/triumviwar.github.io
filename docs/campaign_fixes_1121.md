# Campaign fixes, 21 November 2026 (job campaign-fixes-1121)

The owner answered the three campaign playtests (docs/playtest_2026_11_21_campaign_crown.md, _campaign_clock.md and
_campaign_brood.md) at 15:43 with five things to build. This job built them. Every mission text is still a placeholder
for the owner to rewrite. Branch campaign-fixes-1121, made from main at 0.38.113; no version bump on the branch, the
patch note is under the placeholder version 0.38.999.

In short:

1. Father Ferrer's Visit: the riot can now be stopped by good play.
2. The Thirteenth Hour: burning the mill seed now matters, and Jakob can be kept alive by care.
3. The Prologue: SAVE THE FAMILIES has time, and the raiders are seen marching.
4. The story's people who must live are wounded, not killed.
5. The mirror sides are harder, and the campaign's difficulty is chosen on the hub.

The numbers below come from the missions' simulation bots (tools/sim_campaign_*.gd). They are simple players, so read
them as a direction, not as how a person will do. Several runs went at the same time on a two-core machine.

## 1. Father Ferrer's Visit: the riot can be stopped

What was wrong: when the broken automata turned red, all of them walked at once for the machine's ground, about 45
seconds after the reveal, and the player had no idea where to wait. In the playtest 12 to 20 of them reached the machine
every time. The owner: not intended.

What changed:

- A WARNING first. Six seconds after the reveal at the river, Brother Anselm says the broken ones are gathering on the bank
  and will cross the bridge and go out by the gap in the line. A countdown objective says "The broken ones march in 0:35:
  over the bridge and out of the meadow gap. Hold the gap." The bridge, the gap and the colonel's gate men are pinged, and
  the gap is revealed. The countdown is 35 seconds on Normal, about 44 on Easy and 30 on Hard.
- THE GATE MEN CAN GET THERE IN TIME. Ferrer's answer names them ("the escort and the colonel's gate men too"), and the
  35 seconds are enough to walk them down from the road gate.
- THE GUILD COMES TO HELP the player who stands at the gap. In solo the guild is scripted, so the player can't move its
  Pendulum; now, once eight of the Father's men stand at the gap, Hollweg sends the guild's Pendulum and its line down to
  them ("Your men are at the gap, Father..."). A player who leaves the gap to the four men already posted there gets no help.
- THREE WAVES. The bank's Clock Soldiers go first, then its Springers and Winders (with the two salvaged ones when c01's
  gate was "people"), then the press-house shift, 20 seconds apart. Each wave is announced by the brother.
- THE OBJECTIVE TELLS THE TRUTH. "Stop the broken automata" is done when at most half of them reached the machine, and
  failed when more did. It is now optional (it was never a defeat: the count goes on to Rome as before). In versus the
  Machine still wins by bringing six home.
- Two old softlocks found on the way: a wave's straggler could stop short of the machine's ground for good (the route
  ended when half the wave was in), and one stuck on the earthworks' corner kept the riot from ever ending. Now whoever is
  left walks on into the meadow, and two minutes after the last wave the riot is over whatever is left.

What I tried and left out: slowing the broken ones down and making them unarmed while they march. It made the riot a
walkover: even a player who did nothing lost almost none, because the waiting waves walked into his men.

The numbers (broken automata that reached the machine, of how many; the sim's careful player holds the gap from the
warning; "late" waits in the town and moves only when they march, as the playtest's players did; "passive" gives no order
in the riot):

| Difficulty | Careful | Late | Passive | Before (careful, main) |
|---|---|---|---|---|
| Easy | 0 of 10 | | 7 of 10 | |
| Normal | 1 of 15 | 6 of 15 | 9 to 10 of 15 | 6 of 15 (the playtest: 12 to 14) |
| Hard | 3 to 4 of 19 | 8 of 19 | 10 to 12 of 19 | (the playtest: 20 of 21) |

So a careful player keeps most of them, a passive one loses most, as the owner asked.

## 2. The Thirteenth Hour: the mill seed matters, Jakob can live

What was wrong: the mission could be "won" (the story's loss that counts) without ever burning the mill seed, a primary
objective, and the end screen then listed it unticked under "NUREMBERG IS LOST". And Jakob died in 4 of 6 careful games,
sent alone through the streets for the master drawings.

The owner asked "what is more fun?" and left it to me. My choice: make the seed a real reward, not a requirement, and make
Jakob's errand dangerous but fair.

- THE MILL SEED. Burnt before night, the city's last hour is 1:30 longer (the captain says so at the start of Part 3) and
  the machine has one seed fewer spawning into the streets. That means more townsfolk saved, so the better ending
  (the "saved" band) comes from it. The objective now reads "Burn the seed on the mill island before night: the city's
  last hour will be longer and the machine slower." It is optional, because the night still falls whatever you do: that
  is the story. Burnt later, in Part 3, it still puts the stroke back a minute, as before. At the stroke it is failed if
  it still stands, so the end screen is honest. A new story flag, "mill" burnt or standing, is kept; Hollweg's ending has
  a line for each ("It bought the city an hour it would not have had." / "I hear it at night.") and so does the debrief.
  Before, burning it early gave nothing at all: it only started Part 3 sooner.
- JAKOB. When Part 3 starts, three men of the City Watch go with him wherever he goes (the captain says so and Jakob is
  pinged). He has 180 health instead of 120 (in every mission, as he is the same man). When he is under half health he
  shouts that he is hit and coming back. He can still die: losing him still costs the drawings and carries on to Fürth.
  In co-op the friend leads the Watch, so the escort is his to send.

The numbers (the sim's careful player, who sends Jakob straight for the drawings): Jakob lived in 3 of 3 games (bells kept
quiet twice, rung once), the mill seed burnt in all three, 63 to 64 townsfolk saved with the bells quiet and 122 with them
rung, all with the drawings out.

## 3. The Prologue: the raiders march on Hollins Farm

What was wrong: SAVE THE FAMILIES failed about ten seconds after it was picked on Normal: the raiders were spawned at the
farm itself.

What changed (tools/campaign/patch_p01_1121.py; the Prologue's generator is older than its file, so the file is patched,
the same way the roster ladder does it):

- The band (four militia and a torch) now comes out of the east woods and marches down the north road toward the farm in
  three stages, pinged on the map at each stage and every 15 seconds, so it shows on the minimap too.
- Tomasz says so at once: "Riders saw a band on the north road, my lord... They will be at the farm within the hour."
  and again when it is close ("They are almost at the farm!").
- The families' objective shows the time: "Save the families at Hollins Farm. The raiders reach it in 1:40." That is 1:40 on
  Normal, about 2:05 on Easy and 1:25 on Hard. The army's walk from the first camp to the farm takes the Musketeers about
  15 seconds, so there is time, but not to dawdle.
- The choice now waits a minute for an answer (it was two; past the raiders' arrival the answer would make no sense).
- MARCH ON: the farm burns when the band gets there (it burnt after 40 seconds before).

## 4. The story's people who must live are wounded, not killed

New file scripts/campaign/mission_heroes.gd, called from MissionRun with three lines (the job player-comforts changes
MissionRun at the same time; this keeps the merge easy).

- WHO: every unit a mission's primary "Must live" objective names (Tomasz in Lyon, Paris and Rome; Hollweg; Ferrer;
  Lindqvist; Valadares; the young King; Fairleigh in Paris...), plus a mission's own "heroes" list. The Prologue lists Lord
  Fairleigh and Tomasz there, as nothing in it said they must live. A mission whose story needs a death lists the tag in
  "mortal". Jakob and Pieter are not heroes: their deaths are part of the story's flags.
- WHAT: they can't drop below a fifth of their health. At a fifth they are WOUNDED: nothing hurts them and nothing aims at
  them, they walk back to their side's nearest building with no enemy near it (else to where they started), the name over
  their head says "(wounded)" and the player sees "Father Tomasz is wounded and falls back." They heal 1% of their health a
  second and come back at 60%, about 40 seconds later.
- NOT PROTECTED: the Brood's creatures (the Mothers and Sires are the Brood's buildings and army, not people), and a hero
  that an enemy person hunts: played as a mirror side, or in versus, Valadares, Lindqvist and Hollweg are the prey, as
  written, and can still die.
- ARMY (F2) leaves them out, so the first attack-move no longer walks them in with the army.
- Father Tomasz (and any must-live priest) now tends only the wounded within 3 tiles, instead of 9. He walked alone into
  the fight in Paris to bandage a soldier. He still follows orders anywhere.

Tested by tools/test_campaign_heroes.gd: a deadly blow leaves Fairleigh wounded and untouchable, he heals and comes back,
ARMY leaves him and Tomasz out; played as the Nest, Valadares dies to a deadly blow; played as the party, he is protected.

## 5. The mirror sides are harder; the difficulty is on the hub

What was wrong: played as the Nest (a03), the creatures (a05) or the Machine (a02), the mission was short and easy: the
Nest won in 4:42 and the creatures in 3:52 in the playtest, the Machine in about 7 minutes.

THE DIFFICULTY ON THE HUB: every hub's GO TO list now ends with "DIFFICULTY: NORMAL", the three buttons EASY / NORMAL / HARD
and one line on what it does, above BACK. It is the same setting as the briefing's. The list scrolls now: on a phone the
extra row pushed BACK under the bottom edge.

The engine learned three small things for it:

- A team's supply cap can be set per difficulty ({"easy": 28, "normal": 36, "hard": 50}).
- A computer team can play stronger per difficulty ("ai_by_difficulty": {"hard": "normal"}).
- An escort ("follow" with "fight": tiles) now fights what comes near its leader and then follows on. The old way (a
  follow and a hunt in the same tick) ended the following: the scripted guards stood where their last quarry fell.

Per mission:

- THE NEST (a03): the Crown's party brings an escort of Musketeers, 2 on Easy, 6 on Normal, 10 and two officers on Hard,
  and its men fight what comes at Valadares on the way down. Valadares, the prey, has 450 / 800 / 1,100 health (320
  before). Also fixed: the scripted mapmaker could stand at the edge of a survey mark for good, the survey never taken
  (playtest-campaign-brood finding 13, the Nest "won" when the rains came); he walks on into the mark now.
- THE CREATURES (a05): the Academy hires 4 more guns on Normal and 8 on Hard, and the guns escort properly (see above).
- THE MACHINE (a02): the guild's own defence has 4 more Clock Soldiers and a Pendulum on Normal, 4 more Clock Soldiers and
  2 Springers again on Hard, and it keeps building: 2 Clock Soldiers every 1:30 on Normal, 2 and a Springer on Hard.
- SPECIMEN ONE (b01, the pack against the rival pack): the rival pack's cap is 28 on Easy, 36 on Normal (as before) and 50
  on Hard, where it also plays as the Normal computer.
- Every scripted side the player does not lead already had more or fewer units by the difficulty (EASY three quarters,
  HARD a fifth more); these come on top of it.

The numbers (the sims' mirror bots; time to win, or who won):

| Mirror (the bot leads) | Before, Normal (main) | Easy | Normal | Hard |
|---|---|---|---|---|
| The Nest (a03) | won 4:45 | won 5:13 | lost: the party got away, 11 of 13, at 5:44 | lost: the party got away, 18 of 20, at 5:44 |
| The creatures (a05) | won 4:03 | won 4:04 | lost: the carts got away at 6:12 | lost: the carts got away at 6:26 |
| The Machine (a02) | lost to the clock (18:00) | won 9:53 | lost to the clock (18:00) | won 10:50 |
| Specimen One (b01, the pack) | lost (the rival, 13:28) | won 10:46 | won 9:34 | lost (the rival, 8:21) |

Read this with care. The mirror bots are very simple: the Nest's and the creatures' bots wait, then send everything at
once, and never GROW, MATURE or lay more. So the bot losing on Normal now says the scripted side holds against that, not
that a person can't win: a person has four and a half minutes of sleep to grow the nest first, which the bot never does.
The a02 and b01 bots are noisy (one game each: the Machine's bot won on Hard and lost on Normal); the b01 result moves a
lot from game to game (the same Normal lost on main and won here). The playtest's people won the Nest in 4:42, the creatures
in 3:52 and the Machine in about 7:10; the bots' "before" times agree with the first two.

## Claude's choices for the owner

1. The riot: the waves and the warning, not a slower march. Slowing them made it a walkover (above).
2. The guild's Pendulum comes to the gap only when the Father's own men are there (eight of them), so that holding the gap
   is the player's act and a passive player is not saved by the script.
3. The riot objective is now optional: done if at most half reached the machine, failed if more. It was never a defeat.
4. c01: the mill seed is a reward, not a requirement (optional, 1:30 more for the city, a flag and ending lines). Making it
   required would stop the story's night from falling, and the mission is a loss that counts by design.
5. Jakob stays mortal (with an escort and 180 health), because his death is a story flag carried on to Fürth and Rome.
   Pieter the same. Jakob's 180 health counts in a02 and a04 too.
6. Heroes: "must live" means a primary protect objective, plus a mission's "heroes" list (the Prologue's Fairleigh and
   Tomasz). The hunted hero of a mirror or versus game is not protected.
7. A wounded hero heals 1% a second and comes back at 60%; he can't be ordered back into the fight while wounded (the fall
   back order comes again every two seconds).
8. b01's Normal stays as it was: the playtest and the sim both found Specimen One a hard fight already for a pack that goes
   out early, and the owner said no to lowering Normal. Easy is easier, Hard harder.
9. The Prologue's raiders take 1:40 on Normal. The choice now waits one minute (was two).
10. The hub's difficulty row sits above BACK in the GO TO list.

## Tests

Run before and after on this branch: tools/test_campaign_m1.gd (the Prologue, new checks for the march), test_campaign_c01
(the mill's 1:30, the flag, Jakob's escort, the ending line), test_campaign_a04 (the warning, the countdown, the guild at
the gap, the three waves, the half rule), the new tools/test_campaign_heroes.gd (the heroes and the mirrors by difficulty),
test_campaign, test_campaign_a02, a03, a05, b01, a01, a06, a07, test_roster_ladder, test_war_map and test_i18n.

TEST_RESULTS

The sims gained a few switches: sim_campaign_a04.gd idle3 (plays to the riot, then nothing) and late3 (the party waits in
the town, moves only when they march); sim_campaign_b01.gd diff=easy|normal|hard (the campaign's difficulty for the run).
