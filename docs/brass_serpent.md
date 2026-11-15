# The Brass Serpent

The owner's new Clockwork unit (decided 2026-11-14, 20:07 to 20:09). Built by the cloud job brass-serpent on its own
branch. The code is in scripts/brass_serpent.gd, the numbers in Defs.SERPENT and the Defs.UNITS entries brass_serpent,
serpent_gear_s and serpent_gear_b, the test is tools/test_brass_serpent.gd.

## What it does, in plain words

The Brass Serpent is a long snake made of brass gears linked one behind the other, with a biting head at the front. It
is made at the Heavy Works, like the Pendulum, the Spring Ballista and the Great Winder, once an Escapement works.

Its gears are its body, and they decide everything about it. A Serpent with few gears, or small ones, is fast, has
little health, and bites quickly but lightly. A Serpent with many gears, or big ones, is tough and bites hard, but it
crawls and its bites come slowly. There are two sizes of gear: small and big. A big gear counts for a little more than
two small ones. Every time a gear is added or lost, its speed, its health, its bite and its bite rate change at once.

A new Serpent comes out with six small gears. New gears go on its tail and broken ones come off its tail, so those
first six stay behind its head until the very end.

Damage breaks gears off its tail, one at a time. When its health falls past what the last gear is worth, that gear
drops off. So a wounded Serpent gets shorter, faster and weaker. The broken gear lies on the ground as a Clockwork
wreck, and a Great Winder can sweep it up for cogs, the same as any wreck. Winders repair a Serpent like any other
machine, but only the damage that has not yet cost it a gear: a lost gear only comes back as a new gear.

The Heavy Works also builds gears, small and big, as items it keeps in a store. There are two ways to put them on a
Serpent. COLLECT GEARS sends the Serpent back to the Heavy Works, where it takes everything that fits, big gears first.
Or GROW sends the nearest free Winder to the store; he picks up a gear and carries it out to the Serpent wherever it is,
and puts it on its tail. A Winder's right-click on a Serpent at full health does the same as GROW. A Winder shot while
carrying a gear drops it as a wreck.

Its body is moving gear ground. Your own Clockwork units standing on it wind up just as they do on the gear field near
home, about a third of their spring a second. The Serpent itself never runs down. When the Turning Gears experiment is
on, units standing on it are also carried along with it. Enemy ground units crossing its body are slowed to three
quarters of their speed.

Serpents can link into a Hydra: one body with a head for each Serpent that joined. Select two or more and press LINK,
or right-click one of your Serpents with others selected. The others crawl to it and join when they touch. The Hydra
has all their gears and all their health, every head bites on its own (a head picks an enemy beside it, or bites the
same one as the first head), and its speed comes from all its gears together, so a big Hydra is slow. UNLINK splits it
back into Serpents of one head each, the gears shared out between them.

Blasts, shells, round shot, canister, a Pendulum's swing and a Ballista's bolt hit the Serpent wherever its body is,
gear by gear, not only at its head. A shot that catches several gears hurts a little more. Melee blows and single
musket shots go to the head, which is the part that bites back.

## The numbers

These are Claude's first guesses, written down to be tuned (Defs.SERPENT).

| gears | health | bite | one bite every | bites a second | speed | supply | price |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 2 small (badly hurt) | 130 | 6.6 | 0.74 s | 8.9 | 90 | 2 | |
| 6 small (new) | 230 | 11.8 | 1.02 s | 11.6 | 77 | 4 | 165 cogs + 25 Tension |
| 10 small | 330 | 17 | 1.30 s | 13.1 | 64 | 6 | 225 cogs + 25 Tension |
| 16 small (full) | 480 | 24.8 | 1.72 s | 14.4 | 45 | 9 | 315 cogs + 25 Tension |
| 6 small + 4 big | 450 | 23.2 | 1.64 s | 14.2 | 49 | 8 | 305 cogs + 65 Tension |
| 6 small + 10 big (full) | 780 | 40.4 | 2.56 s | 15.8 | 30 | 14 | 515 cogs + 125 Tension |
| Hydra, 3 heads, 48 small | 1,440 | 24.8 a head | 1.72 s | 43 (three heads) | 30 | 27 | 945 cogs + 75 Tension |

How they are worked out (one "weight" is a small gear, a big gear weighs 2.2):

- health: 80 a head, plus 25 a small gear, plus 55 a big one. Armour 1, tagged armoured.
- bite: 4 plus 1.3 for each weight per head.
- time between bites: 0.6 s plus 0.07 s for each weight per head.
- speed: 96 less 3.2 for each weight of the whole body, never under 30.
- supply: one a head, plus half a supply a small gear, plus one a big gear, rounded up.
- the Serpent costs 165 cogs and 25 Tension and takes 30 s; the head alone is worth 75 cogs.
- a small gear: 15 cogs, 6 s at the Heavy Works. A big gear: 35 cogs and 10 Tension, 10 s.
- a Heavy Works stores at most 10 gears of both sizes together.
- at most 16 gears a head, at most 3 heads.

For comparison: a Clock Soldier has 75 health, about 5 damage a second, costs 70 cogs and 1 supply, speed 68. A
Pendulum has 340 health and 2 armour, about 8.6 damage a second to every enemy in its arc, 200 cogs and 75 Tension, 4
supply, speed 46. A Spring Ballista has 210 health and 300 range, 150 cogs and 50 Tension, 3 supply.

## How it is kept fair (design principles)

- A new Serpent is a quick biter for about two Clock Soldiers' price: a little more health than two, about the same
  bite, but 4 supply instead of 2. It does not beat a Clock Soldier line for its supply; it is a fast flanker that
  grows (principle 1: fairness, a soft counter).
- Growing costs cogs, Tension for big gears, supply for every gear, and a trip to the Heavy Works or a Winder's walk.
  A huge Serpent fills the army: a full one with 10 big gears is 14 supply for one body (principle 2: the supply cap brakes it).
- The bigger it gets the slower it gets, down to 30, slower than anything but a Great Winder: kiting shooters,
  cavalry and spreading out answer it. Its long body is a long target for every area weapon: canister, round shot,
  shells and the Pendulum (principle 1: telegraphed, soft counters).
- Losses come back only a little: a broken gear is a wreck worth 30% of its price to a Great Winder, like every
  Clockwork wreck. The loser gets something back; the winner gets nothing extra (principle 2: anti-snowball).
- It is ground only and bites only ground units: flyers answer it.
- Its winding body is small: only what stands on it winds up. It helps an army off the gear field without making the
  Great Winder useless (the Great Winder winds everything in a ring of 200 px around it).

## Claude's choices for the owner to confirm

1. The starting length: 6 small gears.
2. At most 16 gears a head (a Hydra of 3 heads: 48).
3. At most 3 heads to a Hydra.
4. Linking is an order on two or more Serpents (LINK, or a right-click on one of your Serpents with others selected);
   they join when they touch.
5. A Hydra's speed comes from its total gears; each head bites with the damage and rate of its share of the gears.
6. Supply: one a head, half a supply a small gear, one a big gear, rounded up.
7. Prices: a small gear 15 cogs, a big gear 35 cogs and 10 Tension; the Serpent 165 cogs and 25 Tension with its 6
   small gears.
8. A Heavy Works stores at most 10 gears.
9. Clockwork units are carried along the body only while the Turning Gears experiment is on; otherwise they are only
   wound.
10. Enemy ground units on its body move at 75% of their speed.
11. It is armoured, ground only, and cannot hit flyers.
12. A blast or shot that catches several gears does 25% more for each extra gear caught, at most 50% more.
13. Melee blows and single musket shots hit the head only; area weapons hit the whole body.
14. When a Serpent dies every gear on it falls as a wreck; the head's own wreck is worth the head's price.
15. A Winder carrying a gear when a game is loaded puts it back into the nearest Heavy Works' store.
16. GROW sends the nearest free Winder; COLLECT goes to the nearest Heavy Works that has gears.
17. The fog hides or shows the whole Serpent by where its head is.

The art (job serpent-art, 0.38.2):

18. The sections' side cogs do not turn (the 0.38.0 code gears did): each painted section is a tube with a cog on its side,
    so the picture can't spin; a 1 px ripple runs down the body while it crawls instead. Turning cogs would need small cog
    pictures to lay over each section, or turning strips per view.
19. A Hydra's side heads are drawn spread wider than the points they bite from, so the three heads read apart.
20. The red enamel follows the side's colour (like every Clockwork unit's red); the brass and the glowing eyes stay.
21. Sizes: the head about 40 px long side on, a small section 27 x 13, a big one 36 x 18 (the old gears were 22 and 32 px
    across); one number per piece in tools/serpent/import_art.py SIZE to change.

## The computer

Only the OPTIMAL plan of the Clockwork computer uses it, and only after its opening. It keeps two Serpents against the
Crown and the Clockwork and one against the Brood (where its Pendulums do the work). It builds gears into the store
while a Serpent has room (big ones once it has more than 80 Tension and 400 spare cogs), sends a Winder to carry a gear
out (or the Serpent collects them itself when it is idle near home), and after 12 minutes links two Serpents with 16
or more gears between them into a Hydra when they are close together. The switch `-- serpent:off` turns it off.

## What is drawn now (the owner's art since 0.38.2, job serpent-art)

The Serpent is drawn from the owner's ChatGPT pictures (art/redraws/brass_serpent/, its README.md). tools/serpent/import_art.py
cuts them out of their grey backgrounds, scales them to game size (beside a Clock Soldier: the head about 40 px long seen
from the side, a small section about 27 x 13 px, a big one 36 x 18), turns the red enamel into the two team keys (so it takes
the side's colour, as every Clockwork unit's red does) and writes assets/units/brass_serpent/ and their sizes and anchors to
scripts/serpent_art.gd (generated: do not edit). scripts/brass_serpent.gd draws them on a child node of the unit that wears
the unit's team material (the hit flash too); the shadows are drawn on the unit itself.

- THE HEAD: head_s, se, e, ne, n; W, SW and NW are E, SE and NE mirrored (8 ways by its facing).
- THE BITE: a 4-frame strip in each of the five painted ways (closed, opening, wide open with a lunge, snapped shut with
  sparks), 0.08 s a frame, on one box so the head stays put; frame 0 is fitted onto the idle head. Mirrored for W, SW,
  NW. The north bite's wide-open frame is its opening frame pushed up 10 px (both ChatGPT north bites showed the mouth from
  the front, as the README says).
- THE BODY: each gear is one section (small or big), laid along the body at that point: of its three pictures (lying across,
  up-down, and upper left to lower right) and their mirrors the nearest is picked and turned the rest of the way (at most
  about 22 degrees). The sections overlap like a jointed tube; they are drawn back to front by height on the screen, the
  head and the tail among them. While it crawls each section bobs a pixel, one after the other (a ripple down the body).
- THE TAIL: beyond the last gear, pointing away; its across (tip right), up-down (tip down) and diagonal (tip up-left)
  pictures, mirrored and turned as the sections.
- A HYDRA: the joint (joint_e, se, s; facing W, SW mirrored; facing N, NE, NW the S and SE pictures upside down, so its
  necks point at the heads) sits 12 px behind the heads; the second and third heads are drawn fanned out 0.7 rad either
  side, 26 px from the joint, each in the view of its own turned way. (They bite from head_points, a few px nearer the
  middle: the drawing is spread so the heads don't sit on one another.)
- WRECKS: a broken gear lies as wreck_small / wreck_big, a fallen head as wreck_head (dented, cracked, the smoke cut away),
  mirrored by the wreck's serial so a line of them isn't all alike.
- A WINDER CARRYING A GEAR: the section's across picture at 0.75 size over his head.
- CARD ICONS: assets/icons/brass_serpent.png, brass_hydra.png (shown for a Serpent with two or three heads),
  serpent_gear_s.png, serpent_gear_b.png, cut from the owner's icons_chatgpt.png.
- THE FALLBACK: if any picture is missing (SerpentArt.P names them all) the whole Serpent is drawn in code as in 0.38.0
  (BrassSerpent.art_off forces it for a test).

Still drawn in code or not from the owner's art (also in docs/art_style_inconsistency.md): the shadows (ellipses, as every
unit's); the side cogwheels on the sections do not turn (each section is a tube with a cog on its side, not a wheel: turning
the picture would roll the whole tube; separate cog pictures would be needed, or a 2-4 frame turning strip per view); the
Hydra joint facing north (upside-down pictures); the carried gear (no carry picture); the 1 px crawl ripple; the command
icons (COLLECT, GROW, LINK, UNLINK: tools/serpent/make_icons.py's stand-ins); the Winder-carry and wreck smoke not animated.
The 0.38.0 prompts for the pictures are kept in git history (all drawn now).

## Pictures

In docs/shots/brass_serpent/, made by tools/shot_brass_serpent.gd in the Clockwork lab
(`xvfb-run -a godot --rendering-driver opengl3 --resolution 1600x900 --fixed-fps 30 --script res://tools/shot_brass_serpent.gd -- <outdir>`):

- sizes_2s_6s_6s4b_6s10b.jpg: four Serpents, top to bottom 2 small gears, 6 small (a new one), 6 small and 4 big, and a
  full one (6 small and 10 big); closeup_6s4b.jpg the same closer.
- crawling_a_curve.jpg: the body following the head's path round two turns.
- clock_soldiers_winding_on_its_body.jpg: three Clock Soldiers standing on its body, winding up.
- hydra_3_heads.jpg and hydra_card.jpg: three Serpents linked into a Hydra, and its card ("HYDRA of 3 heads: ...").
- fight_vs_musketeers.jpg / .gif and fight_after.jpg: a Serpent of 6 small and 4 big gears bites into six Crown
  Musketeers holding a line. Their volleys break its gears off one by one (the wrecks lie where they fell); alone it
  kills one of them and dies, its last gears and its head lying in a line. Six Musketeers (6 supply) beat one Serpent of
  8 supply alone: it is a tank and a flanker to go with an army, not a unit to send in by itself (a first measurement
  for the tuning: the owner may want more bite).
- fight_card.jpg: the card after the fight.

With the owner's art (0.38.2), in docs/shots/brass_serpent/art/ (the same tool; LOOK at these):
- sizes_2s_6s_6s4b_6s10b.jpg and closeup_6s4b.jpg (the closeup beside three Clock Soldiers and a Pendulum, for the scale).
- eight_ways.jpg: eight Serpents, each facing one of the eight ways.
- bite_frames_x2.png: the bite's four frames (left to right) facing E, SE, S, NE and W (mirrored), twice size.
- crawling_a_curve.jpg, clock_soldiers_winding_on_its_body.jpg.
- hydra_3_heads.jpg, hydra_joint_x3.jpg (its joint and fanned heads, three times size), hydra_card.jpg (the Hydra icon).
- fight_vs_musketeers.jpg, fight_after.jpg (the wrecks in a line, the fallen head at the front), fight_card.jpg.

## Tests

- tools/test_brass_serpent.gd (all pass): the numbers per gear count and size; training at the Heavy Works; gears into
  the store and the store's limit; the tail breaking (shorter, faster, weaker; wrecks the Great Winder can sweep; not a
  loss in the stats); a Winder's repair up to its gears' worth; the body following the head; winding on the body;
  carried along it with Turning Gears; enemies slowed on it; shells, lines and blasts hitting the body; COLLECT GEARS;
  GROW with a Winder carrying a gear (and dropping it if shot; the right-click); LINK into a Hydra (health, gears, speed,
  the second head biting, at most 3 heads) and UNLINK; save and load (gears, heads, health, body, the store); online
  (the guest gets gears and heads, the stats follow, a new gear arrives); the OPTIMAL computer making two against the
  Crown, feeding them gears and linking a Hydra late.
- Run after the change, no new failures: test_files, test_unit_stats, test_card_text, test_card_keys, test_i18n,
  test_content_all (the gear items checked as items), test_great_winder, test_ballista, test_pendulum_v2,
  test_gear_rules, test_cog_scatter, test_gear_turn, test_cw_tier3, test_aoe_show, test_vet_chevrons, test_sound_pool,
  test_clock_charge, test_ai_optimal, test_ballista_ai, test_cw_tier3_ai, test_clockwork_builds_b,
  test_clockwork_army, test_cw_army, test_cw_air_ai, test_clock_ai_swarm, test_clockwork_home. All pass except checks
  that fail the same way on main (run there for comparison): the online checks of test_great_winder, test_ballista and
  test_cw_tier3 (the guest is an enemy side, so the fog keeps those units out of its snapshots), test_gear_turn's
  "stays on it, riding round", test_clock_charge's "1.6x its old size" and test_ballista_ai's "its escort Winders crew
  it". test_vet_chevrons' timing check failed once with two tests running side by side and passes alone. The game boots
  headless with no SCRIPT ERROR.

## Sounds

It has none of its own yet. It answers with the Pendulum's voice (Sfx.VOICE_AS), and its bite, a gear breaking off, a
gear going on and a link try "combat/serpent_bite", "combat/serpent_gear_break", "combat/serpent_gear_on" and
"combat/serpent_link" first and fall back to the Clock Soldier's blow, the crank and the ratchet. Recording or making
those four sounds (tools/audio/make_clockwork_sounds.py has the owner's clockwork recordings) is left to do.
