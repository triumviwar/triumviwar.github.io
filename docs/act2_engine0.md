# Act 2's engine step 0 (job act2-engine0, patch note under 0.38.999)

The first step of Act 2's build order (docs/campaign_act2_plan.md, "Proposed BUILD ORDER" 1, and "The engine work Act 2
needs"). It adds to the mission engine the pieces the eleven Act 2 missions need before any of them is built: cargo
carts and TAKE A CART, HIDDEN / FOUND / TRACKS, THE LEASH and its breaking, BUILDINGS THAT CONVERT, the spreading ground,
the BRAKE, the LURE POST, SAPPING, the granary, the two versions (FRESH / GROWN) and the frame's choice (the named or
unseen heir). No mission of Act 2 is built here. Every piece is data in a mission's JSON, like Act 1's; the table of
keys is in docs/campaign_engine.md, "Added by Act 2's engine step 0". This page says what each piece is for, how a
mission uses it, and how it follows the owner's three rules.

Code: scripts/campaign/mission_act2.gd (MissionAct2, new: all of Act 2's pieces in one place, so MissionRun only grew by
a few lines), scripts/campaign/mission_run.gd (it asks MissionAct2 for the conditions, actions and orders it doesn't
know; its state `act2` is saved with the mission; exits take a cart's load), scripts/campaign/campaign.gd (the data
checks, THE HEIR, the hub's answers, the versions' texts), scripts/campaign/campaign_menu.gd (the briefing's version
line, the hub talk's choice and its `heir` / `hub_flag` entries), scripts/campaign/rebels.gd (the two cargo cart roles
and a role's `speed`), scripts/game.gd (two hooks: the mission's swamp, and hidden units kept off the screen),
campaign/campaign.json (`"heir": "unseen"`). Texts: tools/i18n/82_act2_engine0.txt. Test: tools/test_act2_engine0.gd.
Pictures: tools/shot_act2_engine0.gd, docs/shots/act2_engine0/.

What was already there and is reused, not rebuilt: a05's cage carts and cargo exits (the new cargo rides the same exits),
a04's `convert` (the leash's breaking uses its stars and change of side), b01 / a03's SLEEP (the hidden pens sleep with
it), a03's ROUTE (a lure post's pull is a route through the post), a07's spreading fire (the same "nearest next" rule
as the buildings that convert), the Brood's own swamp (the swamp ground is real swamp), the `if` key on units and
waves (the versions are read by it).

## The pieces, and how a mission uses them

### CARGO CARTS (d01's gold road, d02's families)

`{"spawn": {"team": "guild", "kind": "powder_wagon", "as": "family_cart", "count": 5, "at": "barns", "tag": "carts"}}`
makes the carts (role `family_cart` or `gold_cart`: a cart that never blows up, at 58, a Musketeer's walk is 62, so the
escort never waits for it). `{"load": {"cart": "carts", "cargo": "families", "amount": 3, "lost": "families_lost"}}` puts
three families on each empty one (d02's PART 1: each cart loaded after a STAY at its barn: `"first": true` loads one
at a time). A bundle (families) or a chest (gold) is drawn beside the cart with "x3". The carts go down the road on a
ROUTE; an exit with `"cargo": true, "cargo_counter": "families_out"` counts the families that reached the barges; a cart
broken loses its families into `families_lost`. `{"loaded": {"tag": "carts", "cargo": "families", "at_least": 6}}` asks
how many are still on the road.

### TAKE A CART (d02: the commission's horsemen; its mirror)

Mission `"take_carts": [{"tag": "carts", "by": "crown", "secs": 5, "counter": "carts_taken"}]`. Armed men of the Crown
round a cart (2 tiles) with none of the guild's armed men by it (3 tiles) fill a bar under it, TAKING THE CART; at 5 s
it is the Crown's (TAKEN!), families and all, and leaves its route. The bar empties twice as fast as it filled once
they are driven off, so a counter-attack saves the cart. `{"taken": "carts"}` for the triggers. On the mirror (the
commission played) the same rule is the player's way to win.

### HIDDEN and FOUND (d03: the pens in the forest)

`{"sleep": {"tag": "stock", "name": "pens", "within": 0}}` then `{"hide": {"tag": "stock", "from": "commission",
"within": 3, "name": "pens", "counter": "pens_found"}}`. The commission's player does not see them and none of its men
aims at them. A pen is FOUND for good (seen, pinged, FOUND!, counted) when a searcher comes within 3 tiles of a
sleeping creature, sees an awake one in his own sight (the plan's rule), or when one is hurt or goes for a searcher.
`{"found": {"name": "pens", "at_least": 3}}`. The flag `hidden` all / some / few comes from the counter with a `tally`.

### TRACKS (d03: Valadares reads them)

`{"tracks": {"tag": "stock", "for": "commission", "secs": 60}}`: claw prints where the creatures walk, fading over a
minute, seen only by the commission (on the mirror its player reads them; solo the Brood player never sees his own
tracks, as the commission's). A trigger with `"every": 10` and `{"order": {"tag": "patrol", "do": "track"}}` sends the
scripted patrols after the freshest prints within 14 tiles ("on hunches").

### THE LEASH and its BREAKING (d03, d06)

`{"leash": {"side": "stock", "lure": "lure", "within": 8, "loose": "wander", "name": "stock"}}`: the stock obeys only
within 8 tiles of something tagged `lure` (Lindqvist, a keeper with a lure, a lure post). A green ring shows each
lure's reach to the stock's player. Out of every ring a creature is LOOSE (LOOSE over it) and goes its own way every
3 s whatever it is told: wanders round where it is (`hunt`: goes for the nearest foe; `root`: roots where it stands;
`to`: walks to an area: d06's "turn towards the river"); walked back under a lure it stops and waits for orders (HELD).
A leash on a side takes its new creatures too (the Storm Sire's Hatchlings). `{"loose": "stock"}` asks if any is loose
now (d03 Part 3: the young Mother away for the goats).

d06's BREAKING: `"breaks": {"near": "linnea", "within": 5, "to": "brood", "counter": "brood_n"}` on the same leash:
a creature that comes within 5 tiles of her stars for 2 s and is hers for good (THE LEASH BREAKS), counted
(`brood_n` few / some / all by a tally).

### LURE POSTS (d03's decoy, d08 / d10's drowned wave)

`{"lure_post": {"tag": "lure", "at": "clearing_4"}}` sets a post (a pole with a jar, LURE POST over it): a lure for the
leash above, so a pen can be walked deeper into the forest. d08's choice USE IT ONCE: `{"lure_post": {"tag": "far_bank",
"at": "far_bank", "pull": {"side": "swarm", "within": 25, "then": "flooded_forest", "name": "drowned"}}}`: the
swarm's scripted wave within 25 tiles turns off its road to the post, then into the flooded forest; `{"lured":
"far_bank"}` and `{"route_done": "drowned"}` for the triggers. A person's units are never pulled.

### BUILDINGS THAT CONVERT (d07: the city turns; d04's plates)

`{"spread_convert": {"name": "city", "from": "great_spring", "tag": "meshed", "to": "machine", "every": 25, "warn": 8,
"units": "meshed_men", "counter": "turned"}}`: every 25 s the meshed building nearest to the Great Spring (or to one
already turned) gets a red ring and TURNING 8, 7, ... over it; after 8 s it is the machine's, with the meshed men
working there. The player sees where it goes next and can get there first (and a trigger can `stop` it when the
Nuremberg quarter holds). `{"turned": {"name": "city", "at_least": 6}}`.

### THE SPREADING GROUND (d04's gear plates, d08's swamp)

`{"ground": {"name": "plates", "from": "crates", "kind": "gear", "team": "machine", "r": 2, "every": 20, "max": 9}}`:
brass plates that grow by a tile every 20 s; the team's Clockwork units on them are wound up (the "portable wind" d02
needs: a ground under the guild's march, `wind` a second). `{"ground": {"name": "forward", "from": "forward_mother",
"kind": "swamp", "team": "swarm", "every": 6, "max": 12}}`: real Brood swamp (its creatures root and drink on it)
spreading faster than a skirmish's (d08: "every forward Mother rooted nearer is a wave more"). `{"ground": {"name",
"at_least": 8}}`, `{"ground": {"name", "on": "barra_gate"}}`.

### THE BRAKE (d07's choice STOP IT)

`{"brake": {"faction": "clockwork", "name": "great_spring"}}`: every Clockwork machine on the map runs down at once and
stays run down (new ones too), honest and meshed alike: the choice's price. `{"brake": {"name": "great_spring", "on":
false}}` lets it go (Act 3's empty city waking). It takes a team, a side or a tag as well.

### SAPPING (d11: the old galleries)

`{"sap": {"tag": "sappers", "to": "tower_foot", "secs": 45, "name": "mine", "blast": {"tag": "spring_tower", "amount":
2500, "within": 3}}}`: the sappers go under the ground (their own side sees the gallery dug as a trench and a mound
moving along it, the way still to dig dashed; nobody else sees them or can hit them; walls and the river don't stop
them), come up at the tower's foot after 45 s, and the mine goes off. `{"sapped": "mine"}`. It is an action, not an
order, so it works on the player's own sappers (the mission sends them when he gives the word: a STAY at the gallery's
mouth).

### GRANARIES (d05: THE FIELDS)

Mission `"granaries": [{"tag": "granary", "gold": 12, "every": 10, "hold_within": 4, "counter": "swarm_fed"}]`: the
granary feeds the mission's people (its own team) every 10 s while it stands; when the swarm's creatures stand round it
with no villager or soldier by it, it feeds the swarm instead ("+12" over it for that player). BURN (the choice) ends
it; LEAVE keeps it feeding whoever holds it. `{"fed": {"team": "swarm", "at_least": 100}}`.

### TWO VERSIONS (d10, d11: FRESH or GROWN)

Mission `"versions": {"pick": [{"if": {"past": {"d09_crossroads.first": "brood"}}, "id": "fresh"}], "default": "grown",
"labels": {"fresh": "FRESH: you came here first: ...", "grown": "GROWN: you fought the other front first: ..."}}`. The
version is picked once before anything is placed and kept in the flag `version`; every unit, building, spawn and line
reads it with `"if": {"version": "grown"}`. The BRIEFING shows the label under the objectives (SAY IT PLAINLY: the
player knows why the city has walls this time).

### THE HEIR and THE FRAME AT THE CHOICE (d09)

campaign/campaign.json `"heir": "unseen"` is the one value the owner changes ("named" for the prince). Missions and
pages read it with `{"heir": "named"}`; a hub talk entry with `"heir": "named"` is said only then. A hub talk entry may end
with a CHOICE: `"choice": {"flag": "frame_first", "options": [{"id": "brood", "label": "THE SWARM FIRST", "lines":
["..."]}, {"id": "clock", "label": "THE CITY FIRST", "lines": ["..."]}]}`: after its lines the buttons are the
listener's (the player's) answer, kept in the progress file; the option's lines follow (the King says what Ruggieri
chose and whether you agreed). Later entries and missions read it with `"hub_flag": {"frame_first": "brood"}`. Inside a
mission the frame's question is the existing `choice` action (its answer is a mission flag).

### THE IDLE METER (rule 2: NO WAITING)

`game.mission.longest_idle()` gives the longest stretch so far (and when it began) with nothing for the player to do: no
line said, no objective or counter changed, no choice open, none of his men fighting or hurt, nothing new made. Every
mission writes it into the match log at its end ("(mission) longest idle stretch 23 s (from 312 s)"), so each
mission's sim can print it and fail over 45 s.

## How the three rules are kept

1. SAY IT PLAINLY. Every piece shows its words on the map in the three languages: TAKING THE CART (a bar), TAKEN!,
   FOUND!, LOOSE / LOOSE! / HELD, THE LEASH BREAKS, LURE POST, TURNING n / TURNED, "+12", the cargo's "x3", and the
   briefing's version line. A mission still writes its own objective line for each (the engine can't know the story).
2. NO WAITING. Cargo carts walk at the column's pace; a cart being taken can be saved meanwhile; the spread and the
   ground give warning and time to act; the leash's loose creatures can be walked back; sappers go while the army
   fights; the idle meter measures it for the sims.
3. CHECK THE FEEL. Pictures of every piece on screen: docs/shots/act2_engine0/ (below). Orders: a FOLLOW, ROUTE or
   escort keeps working; only the pieces that must (a taken cart, a sapper, a broken leash) take a unit off its route,
   and the leash overrides orders only while a creature is out of reach (that is its lesson).

## The pictures (docs/shots/act2_engine0/)

Made with `xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --script res://tools/shot_act2_engine0.gd
-- <dir>`, on a copy of the engine's test map, the clock held still. What they showed, and what was changed after
looking at them: 1 the cargo marks were hidden in the cart's canopy (moved beside the cart, a dark disc behind them)
and TAKING THE CART sat on the cart's name (moved under the cart); 3 the lures' ring was too faint on grass (a dark
under-line and a stronger green); 4 the tracks did not read on dark grass (a pale scuff under each print); 7 a Brood
team past the first two had no swamp on screen at all (the Game paints two teams' swamp: the mission's ground now
paints its own); 8 the gallery was a thin faint line (a trench, a brighter dashed way ahead, the mound bigger).
The pictures hold the game's clock still, so words that fade in play ("LOOSE!", "FOUND!") pile up a little there.

## Claude's choices (for the owner to confirm)

1. All of Act 2's engine is ONE new file (MissionAct2) beside MissionRun, its state one dictionary saved with the
   mission (CONTINUE and checkpoints keep a cart's load, a leash, a spread, a sapper under the ground).
2. CARGO is a number on the cart (families are not units aboard): the cart's load, drawn beside it as a bundle or a
   chest with "x3". A broken cart loses it; a taken cart keeps it (the families go with the cart).
3. The cargo carts walk at 58 (a Musketeer 62, the old powder wagon 38) and never blow up.
4. TAKE A CART counts ARMED men only (a labourer can neither take nor guard one); defaults 5 s, 2 tiles to take, 3
   tiles of guard; the bar empties twice as fast as it fills. A taken cart goes to the taking side's scripted team.
5. A HIDDEN unit is untouchable for EVERY side while hidden (not only the searchers: a third side's patrols would
   otherwise give it away), and hidden only from the side named.
6. FOUND by the plan's rule: 3 tiles from a sleeper, in a searcher's sight for one awake; a wound or an attack also
   gives it away. Found is for good.
7. TRACKS are seen only by the side that reads them, are not saved (they fade within a minute anyway), a print every 2 s
   while a creature moves; the "track" order looks 14 tiles round.
8. THE LEASH overrides the player's orders while a creature is out of reach (re-issued every 3 s), and only then; the
   lures' ring and LOOSE are shown to the leashed side's player only (the commission doesn't see Lindqvist's control).
9. The BREAKING uses a04's convert (2 s of stars, then for good); it is checked before the leash, so a creature by her
   breaks even under a lure.
10. A LURE POST is a marker, not a building (nothing can destroy it); its pull is once, on scripted units only.
11. BUILDINGS THAT CONVERT warn (default 5 s, the ring and TURNING with the seconds) before each turn; the building's
    queue is dropped; the `units`-tagged men within 4 tiles go with it. Turned buildings keep their art (only their
    team colour changes): d07's city is Clockwork on both sides anyway.
12. The SWAMP ground is the Brood's real swamp (rooting, drinking); the GEAR ground winds the team's machines (the
    portable wind d02 needs) and is drawn as brass plates (stand-in art, docs/art_style_inconsistency.md).
13. THE BRAKE keeps the wind at zero every tick, Winders and fields included, until it is let go.
14. SAPPING goes in a straight line over its seconds, under anything; the sappers are off the field (nothing hits them)
    and only their own side sees them; it is an action so it works on a person's men.
15. A GRANARY's holder is its own team unless enemies stand round it (4 tiles of its edge) and none of its own; it pays
    gold (the Brood's food) and powder if asked.
16. The VERSION is decided before the match from what can be known then (`past`, `difficulty`, `playing`, `heir`,
    `hub_flag`), and the briefing says it.
17. THE HEIR is "unseen" by default (the owner's answers: unseen until the finale), one value in campaign.json.
18. A hub CHOICE's answer is kept for the whole campaign (progress `hub_flags`); answering again changes it.
19. The IDLE METER counts as "something to do": a line, an objective or counter changing, a choice, a fight of the
    player's men (a target within 10 tiles, or hurt), something new made. Walking alone does not count (a long escort
    with nothing happening is waiting).
20. Online, the guest sees what the pieces do (sides changed, units, pings) but not the overlays (rings, bars, tracks,
    the gallery): only the host's MissionAct2 runs. To add when a co-op Act 2 mission needs it.

## What is left for the mission jobs

- The rest of the plan's engine table, not in this step: VÁRZEA (flooded forest terrain), the sertão and highlands art,
  THE FOG OF THE UNMAPPED (d04), the city generator in hills (d01), RECLAIM PARTS (owner question 6), the war map's
  Act 2 view and the diamond's "first" clock (build order step 4), three seats online.
- Each mission writes its own objective lines and first-time character lines for the pieces it uses (rule 1), and
  prints `longest_idle()` from its sim (rule 2).
- Art for the stand-ins (the carts' sprites, cargo, lure post, tracks, gear plates, the gallery).
- The overlays for an online guest (choice 20); a "LOOSE: out of the lure's reach" line on a leashed creature's card.
- Rebels.ROLES needs the people of Act 2 (Lindqvist's keepers, the commission, the sappers) when their missions are built.

## Tests run (Godot 4.7, headless)

- tools/test_act2_engine0.gd (new): every piece above, the data checks good and bad, the version, the heir, the hub
  choice and the briefing's version line, the save keeping the state: RESULT_NEW.
- Before and after (the same machine; "before" on origin/main 0.38.178): RESULT_TABLE
- Boot: `godot --headless --path . --quit-after 120`: no SCRIPT ERROR / Parse Error.
- (On this cloud machine every headless Godot run ends with "Aborted", exit 134, after its last line: the engine's
  shutdown here, as Act 1's step 0 noted.)
