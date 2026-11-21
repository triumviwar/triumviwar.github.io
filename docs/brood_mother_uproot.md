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

NUMBERS

## How it was tested

- `tools/test_brood_mother_uproot.gd` (new, all pass): she gets up and her swamp lingers; the Rootmaw stays rooted,
  waits, drinks nothing from its ground; both cards show their lines; the swamp is drawn fading; she roots again on it
  and the Rootmaw feeds again; up past the linger, the Rootmaw uproots and keeps its spot; she roots again and it roots
  back by itself on its exact spot; moved by the player, it does not root back; with the switch off, the old behaviour.
- `tools/playtest/brood_linger.gd` (new): a person's play by real mouse and touch input in the sandbox, at 1280 by 720
  and on a phone size (844 by 390, in Portuguese). Every probe passed both times. Pictures in
  `docs/shots/brood_mother_uproot/`: the Mother's card while up, a waiting Rootmaw's card, the fading swamp, rooted again,
  the swamp gone, and the Rootmaws rooted back by themselves.
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
