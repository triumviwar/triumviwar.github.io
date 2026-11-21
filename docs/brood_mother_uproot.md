# The Brood Mother gets up: the lingering swamp

Job brood-mother-uproot, branch brood-mother-uproot. The owner's answer on 2026-11-21 at 15:43 to finding 6 of the Brood
skirmish playtest (docs/playtest_2026_11_21_skirmish_brood.md): "a bit of everything" of the three proposals.

## What was wrong

The Brood Mother cannot attack while she is rooted. So when an enemy reaches her nest, she has to get up to fight. Until
now her swamp started to shrink the moment she got up, one ring of tiles a second, and every Rootmaw on it lost its swamp
and uprooted within about fourteen seconds. When she rooted again, the Rootmaws stayed up: the player had to find each
one, pick it and root it again by hand, and not too soon, because the swamp grows back at a walk. In the playtest, getting
the Mother up once took the whole economy down, and a player who got her up and down a few times earned almost nothing
for eight minutes.

## What changed

There are three parts, all for every Brood side, the player's and the computer's.

1. **The swamp lingers.** When the Mother gets up, her swamp stays where she was rooted for 45 seconds. It is drawn a
   little fainter as soon as she is up, and it fades and dries to a browner colour as the time runs out. When the time is
   up, it recedes a ring a second as before. A message tells the player: "The Brood Mother is up: her swamp lingers 45 s.
   The Rootmaws on it wait (no food) until she roots on it again."

2. **The Rootmaws wait instead of uprooting.** While only the lingering swamp is under a Rootmaw (not her rooted swamp
   and not a Mound Turtle's), it stays rooted but drinks nothing from its ground. A yellow word "waiting" shows over it,
   and its card shows WAITING: THE MOTHER IS UP with the seconds left and a bar. The Mother's own card shows HER SWAMP
   LINGERS with the seconds left. The food already inside a waiting Rootmaw can still be carried to the Mother by its
   grubs: only the drinking stops.

   When the Mother roots again on her lingering swamp, her own swamp takes over from what lies there, and the Rootmaws
   feed again as soon as her swamp covers them (at once, if she rooted where she was). If she roots somewhere else, the
   old swamp lingers on its time and then recedes.

3. **The Rootmaws root again by themselves.** If she stays up longer than the linger and a Rootmaw does lose its swamp
   and uproot, it remembers its spot. When swamp is back under that spot (the Mother rooted again there, or a Mound
   Turtle's swamp reaches it) and the spot is free, it roots there again by itself, with a message "A Rootmaw roots again
   on its own spot." If the player gives it any order in between (move it, hold it, send it anywhere), it forgets the spot
   and does what it is told.

### The Brood computer

The computer's Mother used to get up only for a big attack at her nest (worth 250 or more that her army there did not
match), or when she was hurt and alone, because getting up cost the economy. Now that it costs only a pause:

- she also gets up for a smaller fight at her nest (worth 150 or more) that her army there does not clearly win (it has
  less than 1.3 times the enemy's worth);
- once the fight is over she roots again after 5 calm seconds instead of 9;
- if her lingering swamp is about to run out (her rooting time plus 8 seconds left) and nobody is striking at her, she
  goes home and roots even with enemies still about, so her Rootmaws only wait and are not lost.

### What did not change (the owner's other answers)

- The food bank piling up at supply 200/200: no change, as the owner wanted.
- Research at a Sire stopping his eggs: no change, as the owner wanted.

## The switch

Every part is behind one match switch for measuring: `-- broodlinger:off` plays the game as before (no lingering, no
waiting, no rooting back, and the computer's old rules). `-- broodlinger:30` or `-- broodlinger:60` sets another
linger time in seconds.

## The numbers

60 computer games (Hard OPTIMAL against Hard OPTIMAL), to 15 minutes, on 5 maps with 2 rounds each (the start spots
swapped), the same 10 games with the switch on and off: Brood against the Crown, against the Clockwork, and the Brood
mirror (both Broods with the switch). Tool: `tools/study/brood_mother_uproot.py`, data in `docs/brood_mother_uproot/data/`.
The score g is the usual one of the coaching jobs: the natural log of (income earned plus twice the army) of the Brood
over the enemy's at the bell or the defeat; above zero, the Brood is ahead. "v off" is the difference game by game with
its t value, and how many games came out better or worse.

### Brood v the Crown

| arm | games | won | won or led | lost | mean g | v off: diff g (t), better/worse | income 8:00 | income 12:00 (ratio) | Rootmaws 12:00 | Mother up | Rootmaws lost swamp | waited (Rootmaw-s) | rooted back |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| off | 10 | 0 | 5 | 3 | +0.19 | - | 0.71 | 0.98 | 7.4 | 0.0 | 0.2 | 0 | 0.0 |
| on | 10 | 0 | 3 | 2 | +0.10 | -0.09 (t -0.5), 4/5 | 0.73 | 1.00 | 6.9 | 0.0 | 0.3 | 0 | 0.0 |

### Brood v the Clockwork

| arm | games | won | won or led | lost | mean g | v off: diff g (t), better/worse | income 8:00 | income 12:00 (ratio) | Rootmaws 12:00 | Mother up | Rootmaws lost swamp | waited (Rootmaw-s) | rooted back |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| off | 10 | 0 | 3 | 7 | -0.78 | - | 0.73 | 0.79 | 7.5 | 0.4 | 0.5 | 0 | 0.0 |
| on | 10 | 0 | 1 | 7 | -0.63 | +0.14 (t 0.6), 6/3 | 0.79 | 0.89 | 7.9 | 0.3 | 0.3 | 0 | 0.0 |

### Brood v the Brood (mirror, side 0)

| arm | games | won | won or led | lost | mean g | v off: diff g (t), better/worse | income 8:00 | income 12:00 (ratio) | Rootmaws 12:00 | Mother up | Rootmaws lost swamp | waited (Rootmaw-s) | rooted back |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| off | 10 | 2 | 2 | 1 | +0.21 | - | 1.01 | 1.00 | 8.4 | 0.2 | 0.3 | 0 | 0.0 |
| on | 10 | 2 | 5 | 2 | +0.17 | -0.04 (t -0.1), 5/5 | 1.01 | 1.00 | 8.7 | 0.7 | 0.5 | 0 | 0.0 |

What this says, in plain words:

- **No swing.** Against every faction the switch moved the score by less than the noise: -0.09 against the Crown
  (t -0.5), +0.14 against the Clockwork (t 0.6), -0.04 in the mirror (t -0.1). Wins and losses are within a game or
  two (the mirror's "won or led" went 2 to 5, but side 0 lost as often as before, and its score did not move); the income
  ratios at 8:00 and 12:00 are within about a tenth (against the Clockwork 0.79 to 0.89 at 12:00, in the Brood's favour,
  inside the noise of 10 games). The Brood's economy did not get stronger or
  weaker on the whole, which is what the design principles ask for (fairness, no snowball): it only stops punishing one
  move far harder than the mistake.
- **The computers seldom get the Mother up before 15:00.** Against the Crown never (0 in 10 games, with the switch on);
  against the Clockwork about once in three games; in the mirror 0.7 times a game with the switch on against 0.2 off
  (the new "help" reason). When they do, it is mostly late in a game that is already being lost, when the Mother's own
  three Rootmaws have most likely already drunk their ground and moved to turtle ground: no computer Rootmaw was ever
  counted waiting in these games. (The counter of her get-ups with the switch off was added after the games against the
  Crown had run, so that cell shows 0.)
- **So the change matters most to a human player** who gets the Mother up early to fight, as in the playtest. The
  scripted test `tools/test_brood_mother_uproot_ai.gd` shows the computer using it: a raid of three Clock Soldiers
  (worth 210) at its rooted Mother. With the switch off she stays rooted and takes the hits (the old rule gets her up only
  for 250 or more). With it on she gets up and fights, her Rootmaw waits on the lingering swamp, she roots again as soon
  as the raid is dead, and no Rootmaw loses its swamp.
- The playtest drivers (below) show the whole cycle by hand: two Rootmaws stay rooted and waiting for 37 seconds while
  she is up, feed again the moment she roots, uproot only when she stays away past the linger, and root back by
  themselves when she returns.

## How it was tested

- `tools/test_brood_mother_uproot.gd` (new, all pass): she gets up and her swamp lingers; the Rootmaw stays rooted,
  waits, drinks nothing from its ground; both cards show their lines; the swamp is drawn fading; she roots again on it
  and the Rootmaw feeds again; up past the linger, the Rootmaw uproots and keeps its spot; she roots again and it roots
  back by itself on its exact spot; moved by the player, it does not root back; with the switch off, the old behaviour.
- `tools/playtest/brood_linger.gd` (new): a person's play by real mouse and touch input in the sandbox, at 1280 by 720
  and on a phone size (844 by 390, in Portuguese). Every probe passed both times. Pictures in
  `docs/shots/brood_mother_uproot/`: the Mother's card while up, a waiting Rootmaw's card, the fading swamp, rooted again,
  the swamp gone, and the Rootmaws rooted back by themselves.
- `tools/test_brood_mother_uproot_ai.gd` (new, passes with the switch on; with it off its first check fails on purpose:
  the old computer does not get up for that raid).
- Existing tests run after the change: test_brood_new (one check updated for the lingering swamp; the VENOM SIRE price
  check fails with the switch off too, so it is older than this job), test_brood_ai_defend (it now removes a Sire the
  computer made by itself before laying the one it tests: with the change the computer had made its own, which the test
  did not expect), test_brood_new_defence (its rooted-muskets case fails, as it does on main), test_brood_regen_calm,
  test_brood_fix3, test_brood_controls, test_bars_audit, test_i18n: all pass otherwise.

## Claude's choices for the owner

1. **45 seconds.** The owner said 30 to 60. 45 is long enough for a typical fight at the nest and to walk home and root
   (her rooting takes several seconds), short enough that a Mother who leaves her nest for good still loses it.
2. **Only the Mother's swamp lingers**, not a Mound Turtle's. A turtle that gets up is usually moving to new ground; the
   owner's answer was about the Mother getting up to fight. Easy to extend if wanted.
3. **The grubs still carry what is inside a waiting Rootmaw.** "No food from them" was read as "they stop drinking": the
   food already drunk is not lost. A Rootmaw holds little, so the pause still shows within seconds.
4. **Rooting her back inside the lingering swamp keeps it until her own swamp has grown over it**, so nothing recedes in
   between. Rooting her far away does not keep the old swamp: it lingers on its time and then goes.
5. **Rooting back by itself only to its own spot, only if free and on swamp,** and only for Rootmaws that lost their
   swamp; any order from the player cancels it. It never picks a new spot by itself.
6. **The computer gets up more readily** (150 instead of 250, and "not clearly winning" instead of "losing") only while
   the switch is on. It does not get up for riders alone, scouts or flyers, as before.
7. **The linger starts fresh each time she gets up.** Getting up and down quickly does not stack it, but each new get-up
   gives a new 45 seconds. Rooting takes time, so this is no exploit: the Rootmaws are paused while she is up anyway.
