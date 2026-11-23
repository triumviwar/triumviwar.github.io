# The hubs that grow (job hubs-grow)

The owner, 2026-11-22 22:40 and 22:45: "As missions pass it would be interesting if more people are in the hubs and also
more rooms added. Starting in Act 1 and forward." and "It would be interesting if the rooms have interesting things that
act on the games, like SC2 campaigns."

What this job built, in short:

- PEOPLE JOIN. After each mission, the people the story met (and who are still alive and free, by the flags) stand in
  the hubs, each with a talk. A green NEW line under the hub's title says who joined and why; a NEW badge sits on their
  button until you talk to them.
- ROOMS OPEN. Each hub grows rooms beyond its painting: tabs over the picture move between them, and a door button in the
  list does the same. A room opens by progress and flags, with its own NEW line and badge.
- ROOMS ACT ON THE GAME, like StarCraft II's ship: each line earns its own purse by winning its missions and their
  optional objectives, and spends it in its rooms on lasting UPGRADES (the Armory), EITHER-OR CHOICES switched freely
  between missions (the Laboratory and Kerrigan's evolutions), a BLESSING in the Crown's chapel, and a COMPANY of
  someone met, called into every mission until changed (the Cantina's mercenaries). The briefing lists what is on.
- Everything new is a STAND-IN picture (a plain room, a silhouette with the person's mission portrait for a face) until
  the owner's ChatGPT paintings come. The prompts are at the end of this page, Act 1 first.

ALL TEXT IS PLACEHOLDER: the owner rewrites the dialogue himself. Every line is in English, Portuguese and Spanish
(tools/i18n/campaign/hubs_grow.txt).

## How the hubs grow, hub by hub

Who stands where, in Act 1, by the missions finished. "Room" is where they stand. Flags in brackets: a person is there
only when the flag is as written.

### The King's Study, Rome (the Crown line: p01, a01, a06, a07)

The study is in the present (2795): the old King tells the story. The people who join are the witnesses he sends for, and
the rooms are the palace's, opened as the telling reaches them.

| after | who joins (room) | who is absent | new rooms | things to look at |
| --- | --- | --- | --- | --- |
| (start) | the King, Tomasz (study) | | | the war table, Fairleigh's letter |
| p01 The Leaf and the Fire | GENERAL RUGGIERI, the old captain of the guns (armoury) | | THE ARMOURY, THE CHAPEL | the votive candles (one more of thanks if the families were saved: `families` save) |
| a01 The Printing Houses | CAPTAIN DELORME of the Lyon garrison (armoury) | Delorme if Lyon rose (`lyon` risen: only when the Assembly won) | | |
| a06 The Barricades of Paris | FIELD MARSHAL FAIRLEIGH, old (study, behind the desk beside the King) | | THE GALLERY OF FLAGS | the Assembly's flag (Virginia), Rouvière's type case (`printer` taken), the Bastille's key, VARENNE'S LETTER from exile (`varenne` spared) or THE SENTENCE (`varenne` executed), a stone from Notre-Dame (chapel) |
| a07 The Council of Rome | THE SWISS CAPTAIN (armoury) | | | the Council's decree (a second line when Hollweg and Lindqvist walked out: `hollweg` defied) |

Act 2 (sketch, not built): RUGGIERI'S DISPATCH from Brazil after d09 (the plan's own hotspot); Tomasz's letters from
São Rafael after d05 in the chapel (by THE FIELDS); FATHER INÁCIO LOURENÇO, the balloonist, joins after d10 with A
BALLOON LOFT room (his company: an Observation Balloon that lifts the fog at a mission's start); the war map's Brazil
view. Fairleigh leaves for the Americas in Act 3 (his last ride).

### Hollweg's Workshop / the Guild in Exile at Fürth (the Clockmaker line: c01, a02, a04, a07)

The main painting is Hollweg's workshop; after c01 it is tinted as the barn at Fürth. A player who won a02 as the
Machine keeps the Machine's City: no guild people and no guild rooms there (Claude's choice 7).

| after | who joins (room) | who is absent | new rooms | things to look at |
| --- | --- | --- | --- | --- |
| (start) | Hollweg (workshop) | | | brass map, great clock, automaton |
| c01 The Thirteenth Hour | JAKOB, the apprentice (barn, `jakob` alive); MASTER ULRICH, the guild's old master Winder (yard) | Jakob if lost at c01 | THE GUILD'S YARD | Jakob's drawings (the choices' counter) |
| a02 The Fürth Line | COLONEL VON RAUCH of the Crown's camp (yard; not when `furth` fell) | Jakob if lost at a02 | | THE HONEST ONE, the automaton with the stop-work (`stopwork` fitted) |
| a04 Father Ferrer's Visit | FATHER FERRER (barn), BROTHER ANSELM (yard) | Jakob if lost at a04 | | THE BROKEN ONES under a tarpaulin (`broken` kept) or THE MELTED BRASS, an ingot (`broken` melted) |
| a07 The Council of Rome | | | | (Hollweg's own talk already follows a07) |

Act 2 (sketch): after d02 the barge cabin (one painting); after d04 CONCÓRDIA'S COUNCIL HALL takes the main painting
(the brass map on the council table, Hollweg at its head, VARENNE by the flag only if `varenne` spared, the guild's
masters); its rooms: THE CITY'S FOUNDRY (the upgrades move there, the Pendulum's line joins: K3's piece), THE
DRAWING LOFT (Jakob's choices for the Springer and the Pendulum). After d07 with `spring` stopped, a fisherman's house
at the coast: Hollweg with the honest masters, fewer rooms (the city is lost: the purse stays, the counters move).

### Lindqvist's Station / the Warehouse at the Barra (the Naturalist line: b01, a03, a05, a07)

The Brood is never a person (docs/campaign_timeline.md): no creature joins a hub, talks or has a room of its own. The
store's cages and jars are spoken of as animals and remains. The rooms' offers go to the expedition's men (the side the
hub's people stand with), never to a Brood side (Claude's choice 3).

| after | who joins (room) | who is absent | new rooms | things to look at |
| --- | --- | --- | --- | --- |
| (start) | Lindqvist (station) | | | specimen chart, her crate |
| b01 Specimen One | PIETER, the assistant (warehouse, behind the table; `pieter` alive) | | THE SPECIMEN STORE | the jars, the crate in the cellar or the singed notebook (already built) |
| a03 The Lost Plateau | BENEDITO the canoe-man (store); DUARTE VALADARES (chart room, only with `map` drawn) | Valadares stays away if the map was withheld | THE CHART ROOM (`map` drawn) | the plateau map (the choices' and company's counter) |
| a05 The Specimens | | Pieter if lost at a05 | | THE CAGES (their line by `cages` all / some / few), THE LISBON CRATE (`crates` seen: the one crate hint) |

Act 2 (sketch, by the plan): after d03 THE FAZENDA'S STUDY becomes the main painting (Lindqvist, the jars, a window on
the pens: the pens are a view, not a room of creatures); after d06 VALADARES' QUARTERS AT THE BARRA (the teller changes
hands: Lindqvist's chair empty, Valadares holds the chart). The store's kit follows the line to whichever hub it is in.

## The rooms that act on the game

### The purses

Each line has its own: the Crown's ROYAL FAVOUR, the Clockmaker's GUILD MARKS, the Naturalist's FIELD NOTES.

- A mission of the line, WON on its own side (never a mirror, never a versus side): 2, plus 1 for each optional
  objective of that side done (campaign/hubs_grow.json "earn"). The mission end panel says it in green: "+3 ROYAL
  FAVOUR (best run of this mission: 3)".
- The BEST run of each mission counts: playing a mission again only pays the difference when it is done better. No
  farming, and IRONMAN changes nothing (nothing is loaded back; the purse is in the campaign's progress file).
- What a line can earn in Act 1: the Crown p01 3, a01 3, a06 3, a07 5 (14 in all); the Clockmaker c01 up to 9 (seven
  optional objectives), a02 3, a04 up to 7; the Naturalist b01 4, a03 3, a05 4.
- Choices open by what the line has EARNED in all (spending does not close them): what is brought back from the field
  unlocks them, like StarCraft II's research points.

### Where it reaches

ONLY the line's own later missions ("reach"), played SOLO, on the mission's own side. Never skirmish, online (co-op or
versus) or a mirror side, never a tutorial. The first mission of each line gets nothing (there is nothing to spend yet).
The ladder (docs/campaign_roster_ladder.md) stays as it is: the rooms only IMPROVE pieces the ladder has already given,
and a company only comes into a mission that lets that kind in (a mission's roster deny wins: the company stays home and
the match log says so). The upgrades touch only the player's own team's units; the other teams and the Defs are
untouched.

The briefing lists everything that is on for the mission, in plain words, under FROM THE HUB (solo).

### The offers (numbers)

THE CROWN (the King's palace)

| where | kind | name | what it does | cost / opens |
| --- | --- | --- | --- | --- |
| armoury, THE RACKS | upgrade | PAPER CARTRIDGES | Musketeers hit 10% harder | 3 |
| | upgrade | GOOD BOOTS | Musketeers and Pikemen march 8% faster | 2 |
| | upgrade | HORSE BREASTPLATES | Horsemen (Cuirassiers) +12% health | 3, after a01 |
| | upgrade | PROOFED BARRELS | Field Cannons and Mortars +15% health | 3 |
| | choice | THE DRILL BOOK: THE LINE | THE STEADY LINE: Musketeers +12% health, or THE QUICK MARCH: +10% speed | 4 earned |
| | choice | THE DRILL BOOK: THE GUNS | HEAVY SHOT: guns +12% damage, or LIGHT CARRIAGES: guns +15% speed | 8 earned |
| armoury, THE MUSTER BOOK | company | DELORME'S RIDERS | 2 Horsemen at the start | after a01 (not if Lyon rose) |
| | company | RUGGIERI'S GUN CREW | 1 Field Cannon at the start | after a06 |
| | company | THE SWISS GUARD | 3 Pikemen at the start, where a mission lets them in | after a07 (Act 2) |
| chapel, THE ALTAR | blessing | SAINT BARBARA | guns +8% damage | after p01, free, one at a time |
| | blessing | SAINT MICHAEL | Musketeers, Horsemen and Pikemen +6% health | |
| | blessing | SAINT ISIDORE | +150 gold at the start | |

THE CLOCKMAKER (the guild's yard at Fürth)

| where | kind | name | what it does | cost / opens |
| --- | --- | --- | --- | --- |
| yard, THE MASTERS' BENCH | upgrade | TEMPERED MAINSPRINGS | Clock Soldiers run down 15% slower | 3 |
| | upgrade | DOUBLE RIVETS | Clock Soldiers +10% health | 3 |
| | upgrade | WINDERS' OIL | Winders +15% speed | 2 |
| | upgrade | HARDENED SCREWS | Springers +10% damage | 3, after a02 |
| | upgrade | VON RAUCH'S DRILL | Musketeers +10% health (Ferrer's escort in a04) | 2, after a02 (not if Fürth fell) |
| yard, JAKOB'S DRAWINGS | choice | THE CLOCK SOLDIER | LONG WIND: run down 20% slower, or HEAVY PLATE: +15% health, 5% slower | 3 earned |
| | choice | THE SPRINGER | SHARP SCREWS: +12% damage, or LIGHT FRAME: +12% speed | 6 earned, after a02 |
| yard, WHO CAN COME | company | MASTER ULRICH'S WINDERS | 2 Winders at the start (a02) | after c01 |
| | company | VON RAUCH'S MUSKETEERS | 3 Musketeers join Ferrer's party (a04) | after a02 |

A company only joins a team of its own faction: Ulrich's Winders in a02 (the guild), von Rauch's men in a04 (Ferrer's
party). Calling the wrong one for the next mission is told plainly by the briefing listing it; in the match it simply
does not come (Claude's choice 9).

THE NATURALIST (the Academy's store and Valadares' chart room)

| where | kind | name | what it does | cost / opens |
| --- | --- | --- | --- | --- |
| store, THE EXPEDITION KIT | upgrade | HIRED GUNS' KIT | Musketeers +10% health | 3 |
| | upgrade | LIGHT PACKS | Labourers (porters, guides) +15% speed | 2 |
| | upgrade | DRY POWDER | Musketeers +8% damage | 3, after a03 |
| chart room, THE PLATEAU MAP | choice | THE MAP'S LESSON | THE SHORT WAY: Musketeers +10% speed, or THE WATCHFUL CAMP: Musketeers see 1 tile further | 3 earned |
| | company | VALADARES' HUNTERS | 3 Musketeers join the expedition (a05) | after a03, `map` drawn |

Modest on purpose: at most about +10-15% on one kind each, and the whole Act 1 purse of a line buys three or four of them.
Hero roles keep their own health (Rebels.apply sets it after the upgrade), so Valadares, Ferrer, Lindqvist and the King
are never changed by the rooms.

### What a SC2 player will recognise

| StarCraft II | here |
| --- | --- |
| the Armory's upgrades, bought with credits | the RACKS / MASTERS' BENCH / EXPEDITION KIT, bought with the line's purse |
| the Laboratory's research points and its either-or picks | the CHOICES: opened by what the line has earned in all, one of two, switched any time between missions |
| Kerrigan's evolution pit (pick one, switch later) | the same choices, and the chapel's BLESSING (one at a time) |
| the Cantina's mercenaries | the COMPANY called: someone met in an earlier mission comes into every mission of the line until changed |
| the crew who join the Hyperion | the PEOPLE who join the hubs, by the flags |

## The engine

Kept in its own files (another job, act2-engine0, was changing the mission engine at the same time):

- campaign/hubs_grow.json: "lines" (main room id, purse name, the missions that earn and that are reached), "earn",
  "rooms", "people", "upgrades", "choices", "blessings", "helpers", "talks".
- scripts/campaign/hub_grow.gd (HubGrow): the conditions, the rooms and people now, the NEW marks, the purse, buying /
  choosing / picking, the loadout of a mission, the two match hooks, the award at a mission's end, the texts for the
  translation check, and a test switch.
- scripts/campaign/hub_rooms_ui.gd (HubRoomsUi): what the hub page shows (view), the room tabs and the NEW line
  (add_tabs), the people's layers, the NEW badges, the counters' panel (shop), the briefing's list and the end panel's
  line.
- Small hooks elsewhere: CampaignMenu.show (the view, the tabs, the layers, the act), CampaignMenu.briefing (one line),
  CampaignMenu._end_panel (one line), HubScene.add_person (a person's layer: "before" a layer, cut off "behind" a
  table), Game._add_unit (HubGrow.on_unit) and Game._start_positions (HubGrow.on_start). campaign/campaign.json lost its
  three ARMOURY stubs (the list-only placeholder hotspots); its "rooms" entry stays unused.

### Conditions

Rooms, people, hotspots, offers and talk entries all take: "requires" (a mission or a list, all finished), "until" (none
of them finished), "flag" {"<mission>.<flag>": value or [values]} (all as left), "not_flag" (none as left), "sides" /
"not_sides" (as the hubs already had), "any" [conditions] (one holds). A talk entry also has "after": the last entry that
holds is said, as the hubs' talks already did.

### A person

{"id", "line", "room", "name", "image" (res://campaign/hub/people/<id>.png, keyed out like the hub's own people), "pos"
and "size" in the room's pixels (1672 x 941), "shadow" [x, y, rx, ry], "before": a layer to be drawn under (Rome's
desk), "behind": the room's y of a table top (only what shows above it is drawn), the conditions, "joined" (the NEW
line), "talk", "portrait" (else campaign/portraits/<id>.png)}. The hotspot is made from "pos" and "size".

### A room

{"id", "line", "title", "scene" (a HubScene json, like campaign/hub/rome.json), the conditions, "joined", "hotspots"
(rects as fractions of the picture; kind "talk" with "talk", or "shop" with "shop": the kinds of offers it shows)}.

### The state (the progress file, user://campaign.json)

"hub": {"earned": {mission: best}, "spent": {line: n}, "bought": [ids], "choices": {id: "a"/"b"}, "bless": {line: id},
"helper": {line: id}}; "hub_seen": {"room:<line>:<id>" / "person:<line>:<id>" / "offer:<id>": true}.

### In the match

The loadout is worked out once (Game meta "hub_loadout") from the mission, the side played and the progress: solo only,
not online, not a lesson. Each unit of the player's team made by Game._add_unit gets its kind's changes on its own copy
of its numbers ("hp", "damage", "speed", "wind_drain" multiply; "sight", "armor" add). After the mission's start the
blessing's gold is added and the company comes in among the team's men (their middle), named after the company. A
mission loaded from a save gets the upgrades again on every unit (they are made by Game._add_unit), and its company and
gold come from the save itself.

## Checks

- tools/test_hubs_grow.gd (new): the data (every room's painting, every cut-out, every talk, every kind real, every text
  in pt and es), made-up progress (rooms, people and hotspots by missions and flags for all three lines, the Machine's
  City), the NEW marks, the purse (earned once, best run, no loss, no other side, no mirror), buying, choosing, picking,
  the loadouts, a real a01 start with and without the upgrades (a musketeer's damage and health, Delorme's two riders,
  the other teams and the Defs untouched), and through the real menu: the tabs, the NEW line, a room's people and
  layers, buying at the racks, a talk, the briefing's list. 112 checks, all pass.
- tools/hubs_grow_checks.sh: every campaign test, then every mission's sim at NORMAL with the active bot, without the
  hub's things and with all of them on each choice's side (the test switch `-- hubgrow:a` / `hubgrow:b`: every upgrade
  of the line open then, each choice on that side, the first blessing, the latest company). Results below.
- Boot: godot --headless --path . --quit-after 120: no SCRIPT ERROR or Parse Error (the abort at quit happens on main
  too).
- Pictures: docs/shots/hubs_grow/ (tools/shot_hubs_grow.gd: every hub at several points of the story, the new rooms,
  two counters open, a briefing).

RESULTS: see "The checks' results" at the end of this page.

## The stand-ins

tools/make_hub_standins.py writes them from the json: campaign/hub/rooms/<room>.jpg + .json (a plain room in the hub's
size: walls, a floor, its light, simple shapes where its hotspots' things are, "STAND-IN" at the top) and
campaign/hub/people/<id>.png (a silhouette at the person's size in the room, the mission's portrait for a face, the
side's colour on the coat, the name on a plate at the knees). An existing file is kept unless `--force`. When the owner's
painting comes: key it out like the other hub people (tools/hub_key.py), save it over the stand-in's file (same name),
and fit "pos" and "size" in the json; a room's painting goes over the room's jpg (and its json may get "fx" from its
importer).

### Looked at (CHECK THE FEEL)

- Rome: Fairleigh stands behind the desk between the candles and the King, the desk drawn over his legs; he is a little
  smaller than Tomasz (he is further back). Fine at 1280 x 720.
- The barn: Jakob and Ferrer stand on the floor left of the brass map, in front of the automaton, larger than the seated
  Hollweg (they are in front). The scale reads; the painted figures should keep feet at y about 900-920.
- The warehouse: Pieter behind the table between the lamp and the egg's bell jar, only his upper body drawn (the
  "behind" cut at y 596). His first place stood him on the table: fixed.
- The new rooms: people stand on the stand-in floor with soft shadows; sizes chosen so a standing man is about two thirds
  of the room's height in the foreground (as Tomasz in Rome).
- Long hub titles pushed the storyline buttons off the screen in a room ("The Guild in Exile at Fürth · The Guild's
  Yard"): the room's name now shows only on its tab.
- The briefing's FROM THE HUB list is under the objectives, in the part that scrolls.

## The paintings are in (2026-11-23)

Claude made all 18 requests below in ChatGPT (one request a picture, the references named) and put them in with
`tools/import_hubs_grow.py`: the six rooms (cropped to 1672 x 941, saved over the stand-ins, "stand_in" dropped) and the
twelve people (keyed out of the magenta with tools/hub_key.py, scaled to the stand-in's height, toned into the room's
light, feet and middle kept where the stand-in stood). The rooms' hotspots were moved onto the painted things, and in
the guild's yard Anselm, Ulrich and von Rauch stand a little further left (clear of the crates by the door). The
sources are in art/campaign/hub/grow/<name>_chatgpt.png; run the importer again after replacing one. Pictures of the
hubs with them in: docs/shots/hubs_grow/painted/. Small differences from the requests: Valadares and Delorme came in
Crown purple, the gallery picked up a pew and votive candles from the chapel request.

## ChatGPT requests for the owner (Act 1 first, most needed first)

Each request stands alone. Attach at most the three images named, from the repo. Oil-painting style matching the hub
art: candle or lantern light, rich dark colours, painterly brushwork, no text, no borders. People on FLAT MAGENTA
#FF00FF (to be keyed out), full body, feet visible, nothing else in the picture. Answers go to
art/campaign/hub/grow/<name>_chatgpt.png.

ROOMS (3:2 or 16:9 landscape, empty of people, the camera at standing eye height, a clear stretch of floor in the
middle and right for people to stand on):

1. THE ARMOURY (Rome). "An oil painting of an 18th-century royal palace armoury at night in Rome, lit by two oil lamps:
   tall wooden racks of muskets along the left wall, a bronze field cannon on its carriage in front of them, a
   quartermaster's desk with an open muster book in the middle, purple Crown banners, a window with Saint Peter's dome
   at night. The right half of the floor is clear. No people, no text." References: campaign/hub/rome_room.jpg (the
   style and the palace), campaign/stills/p01_02.jpg, campaign/hub/rooms/armoury.jpg (the layout).
2. THE CHAPEL (Rome). "An oil painting of a small baroque palace chapel in Rome at night: a marble altar with a gilded
   crucifix and six candles in the middle, a rack of votive candles on the right, a carved stone fragment on a stand on
   the left, dark wooden pews, warm candlelight. No people, no text." References: campaign/hub/rome_room.jpg,
   campaign/stills/a07_01.jpg, campaign/hub/rooms/chapel.jpg.
3. THE GALLERY OF FLAGS (Rome). "An oil painting of a long palace gallery hung with captured flags: a scorched green and
   black rebel flag, framed letters and a printer's type case on small tables, a large iron key on a velvet cushion, a
   parchment decree with red seals on the far wall, candlelight. No people, no text." References:
   campaign/hub/rome_room.jpg, campaign/hub/rooms/gallery.jpg, campaign/portraits/varenne.png (the rebels' colours).
4. THE GUILD'S YARD (Fürth). "An oil painting of the inside of a large timber barn used as a clockmakers' workshop in
   18th-century Franconia, grey winter daylight through the open barn door on the right: a long workbench with brass
   gears and springs, three half-built brass automatons standing in a row on the left, a drawing table with technical
   drawings, a lantern. No people, no text." References: campaign/hub/nuremberg_room.jpg, campaign/stills/a02_01.jpg,
   campaign/hub/rooms/yard.jpg.
5. THE SPECIMEN STORE (the Barra). "An oil painting of a riverside warehouse in the 18th-century Amazon used by a
   naturalists' academy: shelves of glass jars with pale specimens, iron animal cages with straw on the right, crates
   stamped with ports, an expedition kit (packs, powder horns, rope) on a trestle on the left, a lamp, rain on the river
   through a window. No people, no creatures shown clearly, no text." References: campaign/hub/station_room.jpg,
   campaign/stills/a05_01.jpg, campaign/hub/rooms/store.jpg.
6. THE CHART ROOM (the Barra). "An oil painting of a mapmaker's room in an 18th-century Portuguese river town in Brazil:
   a large table with a hand-drawn map of a misty table mountain, survey instruments, three framed maps on the wall, a
   lamp, a window on rain. No people, no text." References: campaign/hub/station_room.jpg, campaign/stills/a03_01.jpg,
   campaign/hub/rooms/chart.jpg.

PEOPLE (full body, standing, three-quarter view, on flat magenta #FF00FF):

7. GENERAL RUGGIERI, old (about 60), Italian artillery general of the Crown, purple and gold coat, grey moustache,
   standing at ease with a hand on his sword hilt. References: campaign/portraits/ruggieri.png, campaign/hub/rome_tomasz.png
   (the style and the light), campaign/stills/p01_02.jpg.
8. FIELD MARSHAL FAIRLEIGH, old (about 70), English governor turned field marshal, purple coat, white hair tied back,
   a cane, standing (he will stand behind the King's desk: the legs may be plain). References:
   campaign/portraits/fairleigh.png, campaign/hub/rome_king.png, campaign/hub/rome_tomasz.png.
9. JAKOB, the apprentice, about 18, leather apron over a brown work coat, a roll of drawings under his arm.
   References: campaign/portraits/jakob.png, campaign/hub/nuremberg_hollweg.png.
10. PIETER, Lindqvist's young assistant, light linen coat, spectacles, a notebook in his hands (he will stand behind a
    table: from the waist up matters most). References: campaign/portraits/pieter.png, campaign/hub/station_lindqvist.png.
11. DUARTE VALADARES, Portuguese-Brazilian explorer and mapmaker, wide hat, a rolled map, boots, a musket slung.
    References: campaign/portraits/valadares.png, campaign/hub/station_lindqvist.png, campaign/stills/a03_01.jpg.
12. CAPTAIN DELORME of the Lyon garrison, cavalry captain, helmet under his arm. References: campaign/portraits/delorme.png,
    campaign/hub/rome_tomasz.png.
13. FATHER FERRER, S.J., Jesuit astronomer, black cassock, a small brass instrument in hand. References:
    campaign/portraits/ferrer.png, campaign/hub/nuremberg_hollweg.png.
14. MASTER ULRICH, the guild's old master Winder, grey beard, a big winding key over his shoulder, leather apron.
    References: campaign/hub/nuremberg_hollweg.png, campaign/stills/c01_01.jpg.
15. COLONEL VON RAUCH, Crown colonel at Fürth, purple coat, tricorne, gloves. References: campaign/portraits/colonel.png,
    campaign/hub/nuremberg_hollweg.png.
16. BROTHER ANSELM, lay brother, brown habit, a ledger under his arm. References: campaign/portraits/brother.png,
    campaign/hub/nuremberg_hollweg.png.
17. BENEDITO, the canoe-man, barefoot, rolled trousers, a paddle. References: campaign/portraits/benedito.png,
    campaign/hub/station_lindqvist.png.
18. THE SWISS CAPTAIN, Swiss Guard captain in the striped uniform with a halberd (Act 2 first). References:
    campaign/stills/a07_04.jpg, campaign/hub/rome_tomasz.png.

(Check that each still named exists before sending: they are the missions' stand-in or painted stills.)

## Claude's choices (for the owner to confirm or change)

1. The hubs are in the present (the King old), so the people who join are the WITNESSES each teller sends for (old
   General Ruggieri, old Field Marshal Fairleigh) and the palace's rooms; the young people of the missions are seen
   only in the stills.
2. ONE PURSE PER LINE (Royal Favour, Guild Marks, Field Notes), not one for the whole campaign: each line's rooms stay
   its own, as the owner's three hubs are.
3. The Naturalist's rooms improve the EXPEDITION (the Crown party, the hired guns), never a Brood side: the Brood is not
   a person and has no hub. b01 (played as the Brood) still earns Field Notes for the line ("the notes Pieter saved").
4. The best run of each mission counts; replays pay only the difference. Ironman needs nothing special.
5. Choices open by what was EARNED in all (not spent), so buying never closes a choice.
6. SOLO ONLY, on the mission's own side: co-op and versus stay as written (fair for the friend), mirrors too.
7. The Machine's City (a02 won as the Machine) has no guild rooms or people.
8. Companies spawn among the player's men at the start, and only when the mission lets that kind in; heroes keep their
   own health.
9. A company called that cannot come (the wrong faction for that mission, or a denied kind) simply stays home; the
   match log notes it. Better later: the briefing could grey it out.
10. Invented people, marked (proposed): MASTER ULRICH (the master Winder), THE SWISS CAPTAIN. The others are the
    missions' own (Ruggieri, Delorme, Fairleigh, Jakob, Ferrer, von Rauch, Brother Anselm, Pieter, Benedito,
    Valadares).
11. Fairleigh joins only after a06 (he tells Paris); his letter stays on the desk from the start as before.
12. The old ARMOURY stub in campaign.json (a list-only placeholder) is removed; the real armoury is the Crown's room,
    and each line has its own counter room.
13. The test switch `hubgrow:a` / `hubgrow:b` (command line only) lets the sims play with everything on; it never
    appears in the game.
14. The NEW line shows at most three news at once ("(+n)" for the rest); entering a room or talking to a person clears it.

## The checks' results (2026-11-22, on the branch against main 0.38.179)

TESTS (each run alone, one user folder each): the same on main and on the branch. Every test passes on both except
test_campaign_m1's "no recording yet for Tomasz: the voice hook stays silent" (1 failure on main too: a recording
exists now). test_campaign, _a01-_a07, _b01, _c01, _heroes, _ironman, _save, test_war_map, test_roster_ladder: 0
failures. test_hubs_grow: 0 failures. Boot: no SCRIPT ERROR or Parse Error.

SIMS at NORMAL with the active bot (the end clock in game seconds; "a" / "b": every hub thing on, choices a / b):

| mission | main | branch, none | branch, a | branch, b |
| --- | --- | --- | --- | --- |
| a01 Lyon | won 718 | won 495 | won 617 | won 314 |
| a02 Fürth | won 776 | won 528 | won 510 | won 512 |
| a03 the plateau | won 344 | won 343 | won 342 | won 344 |
| a04 the visit | won 333 | won 344 | won 335 | won 322 |
| a05 the specimens | won 342 | won 343 | won 388 | won 343 |
| a06 Paris | won 316 | won 290 | won 298 | won 264 |
| a07 Rome | won 768 | won 768 | won 768 | won 768 |
| b01 Specimen One | LOST 970 (the rival won) | won 501 | lost 1466 | won 572 |
| c01 Nuremberg | won 1044 | won 1044 | (no hub thing reaches it) | |
| p01 the Prologue (sim_m1) | 490, not over (the night sim) | | (no hub thing reaches it) | |

Read plainly: every mission the hub reaches is still won at NORMAL with the hub's things off and with all of them on,
in about the same time (Lyon's and Fürth's times move with the town's layout and the seed, on main too). b01's bot is
flaky on main as well (it lost there) and nothing from the hub reaches b01, the first mission of its line. a07 ends at
dawn (a clock) whatever the army. HARD plays the same code as main when nothing is bought (the hub's things are all
off on a new campaign), so it stays as winnable as before.

The companies were checked to come in (a06: Ruggieri's cannon, a04: von Rauch's 3 musketeers, a05: Valadares' 3
hunters, a07: Ruggieri's cannon; a02 takes Ulrich's Winders: a Crown company called for a02 stays home).
