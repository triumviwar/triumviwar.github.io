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

## The computer

Only the OPTIMAL plan of the Clockwork computer uses it, and only after its opening. It keeps two Serpents against the
Crown and the Clockwork and one against the Brood (where its Pendulums do the work). It builds gears into the store
while a Serpent has room (big ones once it has more than 80 Tension and 400 spare cogs), sends a Winder to carry a gear
out (or the Serpent collects them itself when it is idle near home), and after 12 minutes links two Serpents with 16
or more gears between them into a Hydra when they are close together. The switch `-- serpent:off` turns it off.

## What is drawn now, and the art to come

For now the Serpent is drawn in code: each gear is the gear field's own painted ring (the small or the big band),
shrunk to the gear's size, squashed a little as the field is, turning as it crawls (each gear the other way from the
next, as meshed gears do). The head is a brass skull drawn in code with red eyes, the team's colour on its brow and a
jaw that opens on every bite. Broken gears lie as dimmed rings. The card icons are stand-ins made by
tools/serpent/make_icons.py. All of it is listed in docs/art_style_inconsistency.md, to be replaced by ChatGPT art.

### ChatGPT prompts

One request per image. Each names at most three reference pictures, with their paths in this repository.

1. The head, facing south (toward the viewer). References: assets/units/great_winder/idle_se.png (the Clockwork's
   brass and red), assets/units/pendulum/idle_se.png (the size and the outline), assets/icons/brass_serpent.png (the
   idea). Prompt: "Pixel art game sprite, three-quarter top-down view like the reference units, transparent
   background. The head of a mechanical serpent made of brass and dark iron: a wedge-shaped brass skull with riveted
   plates, two glowing red glass eyes, a hinged lower jaw with short steel teeth, a red enamel band across the brow,
   and a stub of brass neck at the back where gears attach. It faces straight down toward the viewer, mouth closed.
   About 40 pixels wide. Same lighting from the upper left, same dark outline and palette as the references."
2. The head facing south-east. The same three references and the same prompt, but "it faces down and to the right".
3. The head facing east. The same, "it faces right, seen from the side".
4. The head facing north-east. The same, "it faces up and to the right, the back of the skull toward us".
5. The head facing north. The same, "it faces straight up, away from the viewer: we see the top and back of the skull".
6. The head facing south-west. The same, "it faces down and to the left" (the game can mirror south-east instead).
7. The head facing west. The same, "it faces left" (the game can mirror east instead).
8. The head facing north-west. The same, "it faces up and to the left" (the game can mirror north-east instead).
9. A small gear segment. References: art/clockwork/gear/band_small.png (the painted band), art/clockwork/gear/tooth.png
   (the teeth), assets/units/great_winder/idle_se.png (the brass). Prompt: "Pixel art game sprite, transparent
   background, seen from above at a slight angle like the reference: one brass gear wheel with 8 teeth, about 18 pixels
   across, a dark iron hub with a pin through it and a short iron link on each side where it joins the next gear.
   Same palette, outline and light from the upper left."
10. A big gear segment. References: art/clockwork/gear/band_big.png, art/clockwork/gear/tooth.png,
    assets/units/great_winder/idle_se.png. Prompt: the same as 9, but "a bigger, heavier brass gear with 10 teeth, about
    26 pixels across, thicker spokes and a riveted iron rim".
11. The bite animation, facing south-east. References: the south-east head from request 2 (once drawn),
    assets/units/clock_soldier/idle_se.png (how attack strips are laid out in this game), assets/units/pendulum/idle_se.png.
    Prompt: "A horizontal strip of 6 frames, each the same size, of the brass serpent head biting: frame 1 at rest,
    frame 2 the jaw drops open and the head pulls back, frame 3 the head lunges forward with the jaw wide, frame 4 the
    jaw snaps shut (the moment of the bite), frame 5 it pulls back, frame 6 at rest. Transparent background, the same
    size and position in every frame."
12. The Hydra's joint, where several heads meet one body. References: the south-east head from request 2, the big gear
    from request 10, assets/units/great_winder/idle_se.png. Prompt: "Pixel art game sprite, transparent background: a
    heavy brass yoke shaped like a three-way gearbox, riveted, from which three short brass necks rise, each ending in
    an empty socket where a serpent head attaches; a big gear sits under it where the body continues. Seen from above
    at a slight angle, about 48 pixels across."

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
  test_clock_charge and the AI tests listed in the last commit. test_great_winder, test_ballista and test_cw_tier3 fail
  their online checks on main too (the guest is an enemy side, so the fog keeps those units out of its snapshots), and
  test_gear_turn and test_clock_charge fail the same checks on main.

## Sounds

It has none of its own yet. It answers with the Pendulum's voice (Sfx.VOICE_AS), and its bite, a gear breaking off, a
gear going on and a link try "combat/serpent_bite", "combat/serpent_gear_break", "combat/serpent_gear_on" and
"combat/serpent_link" first and fall back to the Clock Soldier's blow, the crank and the ratchet. Recording or making
those four sounds (tools/audio/make_clockwork_sounds.py has the owner's clockwork recordings) is left to do.
