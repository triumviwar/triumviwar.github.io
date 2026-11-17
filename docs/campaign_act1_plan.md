# Act 1, "The Age of Revolutions": the mission plan (2767-2770)

PLAN by Claude (job campaign-act1-plan, 2026-11-17, after the owner's "Do it all" of 14:39) for the owner to change
freely, written the way the three prologues were planned (docs/campaign_mission1.md, docs/campaign_clockwork_prologue.md,
docs/campaign_brood_prologue.md). It replaces the first outline (docs/campaign_act1.md, 2026-11-11), which was written
BEFORE the Clockwork and Brood prologues existed: three of its missions no longer fit (see "What changed from the first
outline"). Plot, places, play and choices only: EVERY LINE OF DIALOGUE IS A PLACEHOLDER (the owner writes it). Names
marked (proposed) are Claude's. The OWNER QUESTIONS near the end each carry Claude's recommendation; the plan is written
as if the owner takes them.

The rules it follows (CLAUDE.md, CAMPAIGN STORY; docs/campaign_structure.md): Catholic and monarchist, the Crown and the
Church are the good guys, no twist on that; the King narrates truthfully, the other sides' narrators may be mistaken or
deceived (Hollweg, Lindqvist), the Crown's never are; acts in time order AND braided storylines AND a global war map;
the Brood and Clockwork lines cross three times (the first: the Council of Rome, at this act's end); Act 1's choice is
spare or execute Varenne; every battle CAN be played from both sides; solo, co-op and co-op versus; no naval play (sea
only in stills); about one real choice per three missions; a lost battle returns as a reclaim mission.

## Where the prologues left the story

| prologue | built | left behind | flags |
| --- | --- | --- | --- |
| p01_leaf, Virginia, summer 2767 (the Crown) | 0.31.0 | the rising crushed with canister; VARENNE ESCAPED in the smoke | `families` save / leave |
| c01_thirteenth, Nuremberg, Advent 2767 (THE CLOCKMAKER) | 0.38.43 | NUREMBERG IS LOST: the city is the MACHINE's (the Clockwork faction's hub); Hollweg, the guild's survivors and the townsfolk at the Crown's camp at FÜRTH; two crates of the guild's best work left for Lisbon "for the mines in Brazil" a week before; Hollweg narrates from exile in the King's palace (in 2795) | `bells` rung / quiet, `saved` few / some / many (`saved_n`), `jakob` alive / lost, `cut` yes / no, `gate` people / pattern, `drawings` taken |
| b01_specimen, the Rio Negro, June 2767 (THE NATURALIST) | 0.38.45 | THE STATION IS LOST: Linnea (a young Brood Mother, never said) gone into the forest with the Tyrant Sire; VALADARES TURNED NORTH after her at first light; Lindqvist's hub moved to the warehouse at the Barra do Rio Negro; Lindqvist tells it ARRESTED, before the King (2795) | `teles` told / quiet, `clutch` saved / burned (`fire`), `saved` few / some / many (`saved_n`), `pieter` alive / lost, `turtle` early / late, `gun` kept / lost |

Three prologues in one year (June, summer, Advent 2767): three first fires. Act 1 is the three years after them,
2767-2770, ending at the COUNCIL OF ROME (spring 2770), the first crossing.

## What changed from the first outline (docs/campaign_act1.md)

1. "The First Automata" in NUREMBERG cannot happen: Nuremberg is the machine's since Advent 2767. The Clockwork line's
   Act 1 becomes THE GUILD IN EXILE AT FÜRTH, a few miles from the lost city, working for the Crown to hold the line
   against its own creation (the Clockwork prologue's own proposal: "the guild in exile working for the Crown with what
   it saved").
2. "Father Ferrer's Visit" moves to Fürth with it, a year later, and finds the same flaw again.
3. "The Lost Plateau" gains its reason from the Brood prologue: Valadares goes north after LINNEA (the Sire led her up
   the creek; Benedito knows the cloud mountain). It stays the first time the player COMMANDS the Brood (its mirrored
   side), as the owner decided.
4. "The Specimens" is Lindqvist's: a breeding stock if the clutch was saved, a fresh start if it was burned.
5. The volunteers from the saved families go to PARIS (Fairleigh's own men), not Lyon.
6. Mission ids: `a01`..`a07` in the order of the first outline (the Brood build already names `a05_specimens` in the
   Naturalist hub's `requires`).

## Act 1 as a whole

### The three lines and the order

| id | title (working) | line | when | place | narrator | mirrored (the other side playable) |
| --- | --- | --- | --- | --- | --- | --- |
| a01_presses | The Printing Houses | the Crown | spring 2768 | Lyon | Tomasz (a young missionary priest) | versus only: the Assembly hides its presses (as p01) |
| a02_furth | The Fürth Line | the Clockmaker | March 2768 | Fürth, before Nuremberg | Hollweg (from exile, 2795) | YES: the Machine (red) |
| a03_plateau | The Lost Plateau | the Naturalist | September 2767 | the cloud mountain north of the Rio Negro (a tepui) | Valadares (his report) | YES: the nest, the FIRST Brood play |
| a04_visit | Father Ferrer's Visit | the Clockmaker | autumn 2769 | Fürth, the guild's new works | Ferrer | versus only: the Machine |
| a05_specimens | The Specimens | the Naturalist | the dry season 2769 | the plateau's foot to the river | Lindqvist (arrested, before the King) | YES: the creatures free the cages |
| a06_barricades | The Barricades of Paris | the Crown | July 2769 | Paris | Fairleigh (now a field marshal) | versus only: the Assembly |
| a07_council | The Council of Rome (1st crossing) | all three | Lent 2770 | Rome | the King himself (young, in 2770) | three sides: the Crown, the escaped creatures, the runaway automata |

Gating (the war map's pins, or the war tables' lists until the map exists):

```
p01_leaf --+-- a01_presses ------------------------ a06_barricades --+
           +-- c01_thirteenth -- a02_furth -------- a04_visit -------+-- a07_council
           +-- b01_specimen ---- a03_plateau ------ a05_specimens ---+
```

Each line goes on in order; the three lines are free of each other until Rome, which needs a04, a05 and a06. A player
can play a whole line first or weave them (the war map shows the dates, so weaving in time order is the natural way).
The order the player picks changes nothing in the story: the lines touch only at Rome (and in hints: below).

Seven missions, about fourteen with the prologues, the frame and the heir's practice (question 13).

### Where the lines touch

- THE CROSSING (the owner's three crossings: this is the first): THE COUNCIL OF ROME, a07. Everyone comes to one city:
  Ferrer and Valadares to testify, Hollweg and Lindqvist to be heard (and to defy the verdict), the guild's broken
  automata and the Academy's caged specimens as evidence, the Assembly's last cell to burn it all.
- HINTS, not crossings (one line each, no fight):
  - a01 and a04: the pamphlets in the Fürth workshop are printed on the Lyon presses' type (Tomasz's mission found the
    presses; Ferrer recognises the type from his report). The Free Assembly's ideas live on in the guild (the
    structure doc).
  - a05 and the crates: at the river landing the Academy's convoy shares the quay with two crates from Lisbon "for the
    mines in the south", stamped with a gear seal (c01's ending). A ping and a line, no more: their waking is Act 2's
    (question 12).
  - a03 and b01: Valadares sees LINNEA among her own on the plateau; the player who met her in the pen knows her.
  - a06 and a01: the man taken at the last press in Lyon names Paris; Varenne is there.

### How each prologue flag changes Act 1

| flag | value | Act 1 |
| --- | --- | --- |
| p01 `families` | save | a06: Fairleigh's VIRGINIA VOLUNTEERS, the Hollins farm's sons, six Musketeers named over their bars, join at the start; a01: Tomasz's lines remember them as alive. War map: a loyal village in Virginia |
| | leave | a01: Tomasz's narration carries it (a line by the flag); a06: no volunteers. War map: Virginia's interior marked UNREST (the Assembly's green and black) |
| c01 `bells` | rung | a02: the Crown trusts the guild: the Franconian army is bigger (more Musketeers, two Field Cannons) and the guild may build a Light Works at once; at a07 Hollweg comes as a witness |
| | quiet | a02: a Crown commissary watches the guild (Ferrer's letter got there first): fewer Crown troops, the guild's roster tighter until Part 2; at a07 Hollweg comes as one accused |
| c01 `saved` | few / some / many | a02: Fürth's size (refugee cottages, labourers on the earthworks: 0 / 4 / 8) and, with many, A LOYAL QUARTER inside Nuremberg that lights a signal (a reveal of the machine's first sortie). War map: with some or many, a purple dot inside red Franconia |
| c01 `jakob` | alive | Jakob is a hero in a02 (he reads the machine's ticking) and in a04 (he finds the stop-works taken out: he tells Ferrer, not Hollweg) |
| | lost | his LOG is Hollweg's: in a04 Ferrer reads it and finds the same signs written down two years before |
| c01 `cut` | yes / no | a02: the machine's sorties come only along the south bank (yes) or along both banks (no) |
| c01 `gate` | pattern | a02: Hollweg builds from his drawings: the Heavy Works and a Pendulum open in Part 3; a04: the new automata ARE the Perpetual's pattern with a stop-work bolted on, and they take it out themselves (the flaw is the pattern's). At a07 the drawings are the evidence |
| | people | a02: he builds from memory: no Heavy Works in Act 1, more of the people's labourers; a04: the flaw comes from machine parts the guild salvaged from the Fürth line and fitted "to save time" (the flaw is in the machine, whatever the drawings). At a07 Ferrer's report is the evidence |
| b01 `teles` | told | a03: Teles sends six soldiers north with Valadares (the Crown knew); at a07 the Crown knew of the station |
| | quiet | a03: Valadares goes with only the commission's men and Benedito; at a07 the station's secret comes out under questioning |
| b01 `saved` | few / some / many | a03: guides from Nazaré (0 / 1 / 2) who show the plateau's paths (each guide reveals a path at the start); a05: the paddlers at the landing (more canoes: more cages fit). War map: the village of Nazaré on the Rio Negro |
| b01 `clutch` | saved | a05 is a BREEDING STOCK: the eggs hatched downriver in secret; the Academy, shown what they are, pays for males and more eggs; the hub's crate "grows". At a07 the eggs are Lindqvist's secret (with `teles` quiet) or known (with `teles` told) |
| | burned | a05 is a FRESH START: he has only his notes and his word; he goes north himself; the Academy pays less (fewer porters, fewer guns). At a07 the eggs are ashes and Lindqvist says so |
| b01 `pieter` | alive / lost | a05: Pieter keeps the specimen book on the convoy (a hero who counts the cages); lost: a line in Lindqvist's journal |
| b01 `turtle`, `gun` | | small: lines only (Lindqvist's report to Rome "a swamp that walked"; the fort's gun) |

New Act 1 flags (below): a03 `map` drawn / withheld, a04 `broken` melted / kept, a05 `cages` (few / some / all, the
number in `cages_n`), a06 `varenne` spared / executed, a07 `rome` (what stood: below).

### The choices of the act

About one per three missions:

1. a03, THE MAP: Valadares draws the route up the plateau for the Crown, or withholds it (he tells only the Church,
   sealed). It decides how the Academy finds the plateau in a05.
2. a04, THE BROKEN ONES: the automata that took their own stop-works out are melted (Ferrer) or kept for study
   (Hollweg). Kept ones are the guild's "demonstration" at the Council, and they go wrong there.
3. a06, VARENNE (THE ACT'S CHOICE, owner): spare him (exile) or execute him.

a01, a02, a05 and a07 have none: the counts and the heroes carry (Rome's verdict is canon and not the player's).

### The Varenne choice

Taken by the player at the end of a06 (FAIRLEIGH gives the order: the player's two buttons are his). Tomasz is there
(question 7). What it carries:

| | SPARED (exile) | EXECUTED |
| --- | --- | --- |
| a07 | the Assembly's last cell is small and divided (some of them disown the fire); Varenne's letter from exile, read at the Council, condemns it | the last cell burns Rome "for Varenne": more torch-bearers, two fires more, militia at the bridges |
| war map | Paris purple; Varenne's pin moves into exile (a ship's line to the south: Act 2) | Paris purple but marked; small risings flare (two UNREST regions) |
| Act 2 (timeline) | he sits in the Clockwork city's council in Brazil as its secular voice; at the 3rd crossing he chooses a side | a martyr: the Assembly hardens, more risings, rebels join the scientists earlier |
| Tomasz | (question 7) | (question 7) |

The canon is the owner's (docs/campaign_timeline.md, "the ledger").

### The war map's first use

Act 1 is when the WAR MAP (the engine's item 14, not built: its own section below) comes into the game. After the
three prologues the King's study's war table opens on the world map for the first time: almost all purple (the Crown at
its height), and three new marks: Virginia (held; loyal or uneasy by `families`), FRANCONIA RED (the machine's, always,
with a purple dot by `saved`), and on the upper Rio Negro a burnt station and a question mark north of it. The seven
Act 1 pins stand on it with their dates. Each mission won changes a region (Lyon calmed, Fürth held, the plateau drawn
in or left blank by `map`, Paris taken, Rome burned or saved), and Act 2 opens on the map as Act 1 left it.

## The missions

Sizes as the prologues (about the Virginia map, 20-30 minutes, three parts). Every mission has an opening and an
ending of stills with the King's frame (he opens and closes, truthfully; the mission's narrator tells it in between),
a voice folder `campaign/voice/a0N/`, texts in `tools/i18n/campaign/a0N_*.txt`, a generator script
`tools/campaign/make_a0N_mission.py` and a map script, as the prologues have.

### a01_presses: THE PRINTING HOUSES (Lyon, spring 2768; the Crown)

The year after Virginia the Free Assembly's pamphlets are everywhere, and Lyon's presses print them. TOMASZ, ordained
and sent to a Lyon parish before his mission abroad (proposed), tells how the Crown's garrison and the city's clergy
found the presses before the city turned. A fog hunt in streets, not a battle of lines: the Assembly hides in plain
sight among the silk-weavers.

- NARRATOR: Tomasz (young, the scene's voice; old Tomasz, the cardinal, says one line in the King's frame).
- SIDES: the GARRISON (Crown, PURPLE, p1): a captain (proposed: Captain Armand Delorme), 12 Musketeers, 4 Horsemen (the
  only cavalry in a city: fast messengers between quarters), Tomasz (a Missionary, named, a hero), no base but the
  garrison's barracks and a Powder Mill; the CITY WATCH (purple, co-op p2): 8 Musketeers at the bridges. The FREE
  ASSEMBLY (green and black, the p01 roles: militia, torch, pikeman; script, versus p2): runners, the presses, a mob.
  The TOWNSFOLK (`citizen`, yellow) in the streets.
- MAP (campaign:lyon_presses, a CITY GENERATOR shared with Paris and Rome): the two rivers (the Saône and the Rhône)
  with bridges; the old town and the cathedral on the west bank; the PRESQU'ÎLE between the rivers (the squares); the
  CROIX-ROUSSE hill of the silk-weavers to the north, its stairs and the TRABOULES (covered passages through the house
  blocks: narrow shortcuts the Assembly's runners use and the garrison can learn).
- PART 1, THE PAMPHLETS: runners carry pamphlets from hidden presses to the squares; each that reaches a square raises
  THE CITY'S TEMPER (a counter on the panel: at its top the city rises and the mission is lost). Catch the runners,
  follow them back: SIX houses are presses, they look like any other until a unit stands by them (the engine's
  DISGUISED BUILDING, below). Close four.
- PART 2, THE WEAVERS' HILL: the Assembly calls the weavers up the Croix-Rousse; a riot round the hall at the top. Tomasz
  speaks to the crowd (a hero standing in an area for some seconds: the STAY condition) while the garrison holds the
  stairs: every citizen who hears him goes home (a `convert` to neutral and an exit), the rest are the mob.
- PART 3, THE LAST PRESS: the great press under the hill, found by the traboules; take it and the man who runs it ALIVE
  (the capture: built from `floor`, `hp` and `cage`). He names Paris (the a06 hint).
- CHOICE: none. CARRIES: the temper at the end (a `tally`: `lyon` calm / sullen), shown on the war map (Lyon purple or
  uneasy) and as a line in a06 (more or fewer Lyon men at the barricades).
- `families`: Tomasz's opening line by the flag.
- VERSUS: the second player is the Assembly: he chooses which houses print (six of twelve), moves the runners, raises
  the riot; he wins at the temper's top or if Tomasz falls.
- ENGINE beyond what's built: the CITY generator; DISGUISED buildings (a building drawn and listed as a prop until a
  unit of the other side comes within n tiles); the STAY condition; a NEUTRAL team / a "go home" for citizens (or an
  exit); `units` with an `if` (flag starts, a convenience).

### a02_furth: THE FÜRTH LINE (Fürth, March 2768; the Clockmaker)

Three months after the fall the machine comes out of Nuremberg's gates. The guild in exile, with what it saved, builds
its new works at Fürth beside the Crown's Franconian army, swearing every machine has a stop-work fitted. Hollweg tells
it from his exile, sure even now that the Fürth machines were honest (he may be deceived: the tone rule).

- NARRATOR: Hollweg (old, in 2795); the King frames.
- SIDES: the GUILD (Clockwork, BLUE, p1): Hollweg (the `hollweg` role), Jakob if alive, a new Clocktower to raise
  ("the Honest One", proposed), Winders, Clock Soldiers, Netters, Springers; no flyers, no Serpent, no Great Winder; the
  Heavy Works and a Pendulum only with `gate` = pattern. The FRANCONIAN ARMY (Crown, PURPLE, co-op p2, else scripted):
  a colonel (proposed), Musketeers, Field Cannons, an earthwork line, the refugees' cottages. THE MACHINE (Clockwork,
  RED; scripted seeds as in c01, versus or solo-mirror p2).
- MAP (campaign:furth_line, snow melting): Fürth on the west at the meeting of the Rednitz and the Pegnitz; the water
  meadows; the old road to Nuremberg; the machine's gear ground creeping out of the city along the river; NUREMBERG'S
  WALLS on the east edge (red, unwalkable, the seeds' source); the Rednitz mill (a forward seed in Part 3).
- PART 1, THE HONEST ONE: raise the new Clocktower, the presses, the Light Works; fit the STOP-WORK (a scripted
  research at the Clocktower, a story beat, not a new rule: the guild's units are blue and stay blue). The army digs
  the earthworks. `saved` sets Fürth's size; with many, the loyal quarter's signal shows where the first sortie forms.
- PART 2, THE SORTIE: three waves from the gates (along one bank with `cut` yes, both with no); hold the earthworks.
  Jakob (alive) warns of each wave by its ticking.
- PART 3, THE MILL: the machine has seeded the Rednitz mill, half way to Fürth: burn it, and the line holds (a WIN: the
  Clockwork line needs one after its loss). Hollweg: "Safe this time." (placeholder; the King's closing line puts it
  in doubt without saying more).
- CHOICE: none. CARRIES: the line held (always, to win), `furth` strong / thin (how many of the Crown's men stand at the
  end: a04's escort).
- MIRROR (solo pick or versus): THE MACHINE grows out of Nuremberg with the seeds' timetable as income and must burn
  the Honest One or Hollweg before 18:00. No narrator on the machine side (it has no voice: c01): objectives, its tick,
  the King's frame.
- ENGINE: the SOLO SIDE PICK (below); `units` with `if`. Everything else c01 built (seeds, roster, convert, winter
  lights, roles).

### a03_plateau: THE LOST PLATEAU (the cloud mountain, September 2767; the Naturalist)

Valadares turned his canoe north the morning the station burned. Three months later, with Benedito, the commission's
men and (by the flags) Teles' soldiers and Nazaré's guides, he climbs the tepui the flood came down from, maps it,
finds the creatures in their nest, and among them LINNEA. A hero mission: no base, fog, a climb and a flight. Its
mirror is the FIRST TIME A PLAYER COMMANDS THE BROOD as a faction: the nest's Mother, her grubs, her Rootmaws, her eggs.

- NARRATOR: Valadares, from his report to the Crown (question 3); the King frames (he holds that report; b01's frame
  held the first letter). Lindqvist is NOT the teller here (he was not there): at the Naturalist hub he reads the
  report afterwards.
- SIDES: THE COMMISSION (Crown, YELLOW as the station's, p1): Valadares (the `valadares` role, 320 hp), Benedito, 4 of
  the commission's men, 0-2 Nazaré guides (`saved`), 6 of Teles' Musketeers (`teles` told); no buildings, no income;
  a supply cache at the foot (powder). THE NEST (Brood, GREEN; solo-mirror or versus p2, else the Brood computer
  `ai:normal` held back by script until Part 3, or scripted): a BROOD MOTHER rooted at the nest, grubs, three Rootmaws,
  a Mound Turtle, Raptors, a Spitter or two, a Tyrant Sire who comes home in Part 3; LINNEA (the `linnea` role, now at
  0.5 scale: she has grown) among them, spared.
- MAP (campaign:cloud_plateau): the forest at the foot and Benedito's landing (south); the CLIFF, climbed by two ways (a
  waterfall stair and a split in the rock: ramps); the TOP in mist, sandstone towers and black pools; the NEST in a
  hollow in the north, swamp round it; four SURVEY MARKS (a cairn, a lookout, the river's source, the nest's rim).
- PART 1, THE CLIMB: up the cliff in mist (a MIST weather that also shortens everyone's sight); the guides each light a
  path at the start; small Raptor patrols.
- PART 2, THE SURVEY: reach the four marks with Valadares (any order: a counter); at each a line and a reveal; at the
  rim he SEES the nest: the Mother, the grubs, the rooted creatures he takes for "a swamp that grows", and Linnea. The
  nest is asleep: walk softly (units within n tiles of the nest wake it: the part's tension).
- PART 3, THE NEST WAKES: the Sire comes home up the cliff path behind them; the nest wakes; down the other way to the
  landing with everyone the player can bring (an EXIT counter, on a countdown as b01's canoes).
- CHOICE, THE MAP (on the cliff top, before the descent): VALADARES: draw it for the Crown (his duty: the Crown must
  know what is here) or WITHHOLD it (only a sealed letter to the Church: no man should come here for profit).
  - DRAWN (flag `map` drawn): the war map shows the plateau; in a05 the Academy has a copy (bought from a commission
    clerk): the convoy comes up the short way, more of it.
  - WITHHELD (`map` withheld): the plateau stays blank on the war map; in a05 Lindqvist follows Benedito's memory: the
    long way, through the forest, harder.
  - Canon proposed: DRAWN (a Crown mapmaker does his duty; the Crown's servants are right to; others misuse it).
- CARRIES: `map`, `party` (how many came down, few / some / all), Valadares' sight of Linnea (always: a line at a07).
- MIRROR: the nest. The Brood player starts rooted, with the economy the faction has (grubs, Rootmaws, eggs) but
  ASLEEP for Part 1-2 (its units do nothing while the party is not seen: the ambush is the point); from Part 3 he hunts
  the party down: he wins by killing Valadares or by keeping the party under half. Lines: none on the creatures' side
  but sounds and objectives (no creature speaks: b01). This is the first Brood play: a short TEACHING strip in its
  objectives (root, lay, hatch, call the Sire home).
- ENGINE: the SOLO SIDE PICK; MIST (weather + a sight multiplier on a team or the map); a SLEEP state for a side
  (scripted or player: units hold until woken; a "wake" condition by proximity); a scripted party's ROUTE order (when
  the player is the nest); the Brood computer held by a script (`ai:` control exists; a "hold until" wrapper is new).

### a04_visit: FATHER FERRER'S VISIT (Fürth, autumn 2769; the Clockmaker)

Eighteen months on, the Fürth works are a small town of gears holding the line. The Roman College sends Father Ferrer
to inspect them before the Church decides what to do about Nuremberg. He finds automata winding each other in the
night, Assembly pamphlets in the journeymen's lockers, and stop-works taken out. A scouting mission that turns into a
riot. Ferrer tells it truthfully: he is the Clockwork line's Crown-side narrator (owner answer 3, c01).

- NARRATOR: Ferrer (in 2770, before the Council, proposed; or in 2795: question 3's twin, kept to his report).
- SIDES: FERRER'S PARTY (Crown, PURPLE, p1): Ferrer (the `ferrer` role), two lay brothers, an escort of Musketeers
  (by `furth` from a02). THE GUILD (Clockwork, BLUE, allied; co-op p2, else scripted at work): Hollweg, Jakob if alive,
  the Fürth works as a02 left them. THE MACHINE (red, across the meadow; versus p2).
- MAP: a02's map, eighteen months on (the same script with the works built up and the earthworks grown; the gear
  ground has crept further from Nuremberg).
- PART 1, THE INSPECTION: visit six workshops with Ferrer (STAY in each for a few seconds); four show nothing, two show
  the signs (a Winder winding another; pamphlets, the Lyon type). Jakob (alive) brings Ferrer the stop-works he found in
  a bin; or (lost) Ferrer reads his old log and finds the same signs.
- PART 2, THE NIGHT SHIFT: at night the works run by themselves: follow a Winder (a scripted walker) to the river where
  the guild's automata MESH with gear ground nobody laid: the same pattern as Nuremberg (`gate` pattern) or a salvaged
  red part in each of them (`gate` people).
- PART 3, THE RIOT: those automata `convert` (red, the c01 stutter) and march for the meadow to join the machine, which
  sends a sortie to meet them. Stop them before they mesh: if they reach the machine's ground, they are its (a counter;
  more lost = a stronger machine on the war map).
- CHOICE, THE BROKEN ONES: the stopped automata lie in the yard. FERRER: melt them; HOLLWEG: keep them, to learn what
  went wrong. MELTED (`broken` melted): at a07 there are no automata from Fürth; KEPT (`broken` kept): Hollweg takes them
  to Rome as his demonstration that he has mended them, and they go wrong at the Council. Canon proposed: KEPT (pride,
  again).
- CARRIES: `broken`, `lost_to_machine` (a count: Franconia's red spreads on the war map by it).
- ENGINE: the STAY condition (a01); a FOLLOW order (the player shadows a scripted walker, and a "seen" condition: the
  walker within a unit's sight); everything else built.

### a05_specimens: THE SPECIMENS (the plateau to the river, the dry season 2769; the Naturalist)

Lindqvist's second chance. The Academy pays for an expedition to the plateau to take a breeding stock (`clutch` saved)
or eggs to start again (`clutch` burned). Lindqvist tells it, arrested, before the King: to him it was his finest
expedition. Escort the cages down to the river while the creatures hunt the convoy.

- NARRATOR: Lindqvist (old, a prisoner, 2795); the King frames and corrects (truthfully).
- SIDES: THE EXPEDITION (Crown stand-in, YELLOW, p1): Lindqvist (320 hp), Pieter if alive, hired guns (Musketeers),
  porters (labourers), CAGE CARTS (a carried cage: below), Benedito's canoes at the landing (more with Nazaré's paddlers
  by `saved`). THE CREATURES (Brood, GREEN; solo-mirror or versus p2, else scripted): the nest's Raptors, Spitters, the
  Mound Turtle, the Sire; the Mother does not leave her nest.
- MAP (campaign:plateau_descent): the nest's edge at the top (north), the descent (the short way if `map` drawn, the
  long way through the forest if withheld: two maps or one map with a gate), the forest trail, the river landing
  (south) with the Lisbon crates on the quay (the hint).
- PART 1, THE TAKING: at night, at the nest's edge: take eggs from the swamp's edge (picked up as the b01 crate) and
  cage two young creatures netted asleep (with `clutch` saved, a young Sire among them: Lindqvist wants a father).
  Quiet: the nest's SLEEP state from a03.
- PART 2, THE TRAIL: the convoy down the trail (a ROUTE order for the carts; the player escorts); every few minutes the
  pack comes for the cages; a cage broken frees its creature.
- PART 3, THE LANDING: load the cages into the canoes (an exit counting CAGES); the Sire comes down for the last cart.
  The canoes leave on a countdown.
- CHOICE: none (counts carry). CARRIES: `cages` (few / some / all, `cages_n`): the size of the escaped creatures' side
  at a07; `pieter` again; Lindqvist's line about what he did with the eggs.
- MIRROR: the creatures free the cages: the Brood player wins by freeing half the cages or killing Lindqvist.
- ENGINE: CAGE CARTS (a cage that moves: a creature `cage`d to a cart and carried with it; freed when the cart dies);
  the ROUTE order (a03); the SLEEP state (a03); the SOLO SIDE PICK.

### a06_barricades: THE BARRICADES OF PARIS (July 2769; the Crown)

The Assembly's great rising: Paris behind barricades, Varenne in the Assembly's hall. FAIRLEIGH, now a field marshal,
tells how the Crown took the city street by street; Tomasz, sent for as the King's chaplain to the army (proposed), is
at his side. The act's choice: Varenne.

- NARRATOR: Fairleigh (in his own words, truthful: a Crown narrator).
- SIDES: THE ARMY (Crown, PURPLE, p1): a base outside the walls (Barracks, Foundry, Horse Breeder), lines of Musketeers,
  Field Cannons, a Mortar for the barricades; Ruggieri's guns (co-op p2, as in p01); Fairleigh (the Officer, named);
  Tomasz; the VIRGINIA VOLUNTEERS with `families` save. THE ASSEMBLY (green and black: militia, pikemen, torch-bearers,
  a captured gun or two; script, versus p2); Varenne in his hall.
- MAP (campaign:paris_barricades, the city generator): the faubourgs of the east (Saint-Antoine) with their barricades;
  the Seine and its bridges; the Île de la Cité and Notre-Dame; the Assembly's hall (proposed: the old Hôtel de Ville on
  the right bank).
- PART 1, THE FAUBOURG: three barricades across the streets (wall pieces the Assembly holds): take them with lines and
  guns, not by walking in (canister on the streets behind, the Mortar on the barricades).
- PART 2, THE BRIDGES: the Assembly holds two bridges; the Lyon men are there by `lyon` (sullen: more). Notre-Dame
  must not burn (a protect objective: the torch-bearers go for it).
- PART 3, THE HALL: storm the hall and take VARENNE ALIVE (the capture). Then the choice.
- CHOICE, VARENNE (the act's): SPARE (exile) / EXECUTE; Fairleigh's order, the player's buttons; Tomasz speaks first
  (question 7). Ending lines by the flag.
- CARRIES: `varenne` (above), `paris` (Notre-Dame stood: always to win).
- VERSUS: the second player is the Assembly (as p01): he holds the barricades and wins if Notre-Dame burns or Fairleigh
  falls, or if Varenne gets out by the river (an exit).
- ENGINE: the city generator; capture (built from existing keys; a `capture` objective kind would tidy it); otherwise
  built.

### a07_council: THE COUNCIL OF ROME (Lent 2770; all three lines: the first crossing)

The Church sits in council on the new machines and the new creatures. The King, young and newly crowned three years
before, tells it himself: this is his own city. Ferrer and Valadares testify; Hollweg and Lindqvist are heard and defy
the verdict (no machine may govern itself; the specimens are to be destroyed). On the night of the verdict the
Assembly's last cell fires the city, the caged specimens break loose and (by `broken`) the guild's demonstration
automata go wrong: the King holds Rome against fire, creatures and machines at once, and the creatures and the machines
fight each other too.

- NARRATOR: the King (young, in 2770; the old King frames the frame: he is telling his own story now).
- OPENING (a still show, longer than most): the council in session; Ferrer's testimony (by `gate`: the drawings or his
  report); Valadares' (Linnea, the map by `map`); Hollweg (as witness or accused by `bells`); Lindqvist (by `clutch`
  and `teles`: the eggs secret, known or ashes); the verdict. Mid-mission still shows for the testimony are optional
  (a MID-MATCH SHOW: below).
- SIDES: THE CROWN (PURPLE, p1): the King's guard, Rome's garrison, a small base at the Castel Sant'Angelo; Tomasz;
  the Swiss Guard at Saint Peter's (proposed). THE CREATURES (GREEN, from the cages: their number by `cages`; p2 in
  co-op versus, else scripted). THE AUTOMATA (Clockwork, RED: Hollweg's kept demonstration pieces by `broken`; melted:
  only two pieces Hollweg brought to show the stop-work, which fail anyway; p2 in co-op versus, else scripted). THE
  ASSEMBLY'S CELL (green and black, scripted torch-bearers; bigger by `varenne` executed).
- MAP (campaign:rome_council, the city generator): the Tiber and its bridges; Saint Peter's and the council's hall
  (proposed: the Vatican palace) on the west bank; the Castel Sant'Angelo; the city's quarters on the east bank where
  the fires start; the stables where the specimens were kept (east) and the exhibition hall where the automata stood.
- PART 1, THE VERDICT (short): the session as a scene in the hall (heroes standing, lines), then the first fire.
- PART 2, THE NIGHT OF FIRE: three fires (more with `varenne` executed) spreading among house blocks (a SPREADING FIRE:
  below); the creatures loose in the east; the automata meshing round the exhibition hall. The creatures and the
  machines fight each other where they meet.
- PART 3, HOLD THE BRIDGES: keep both from crossing to Saint Peter's until dawn (a survive objective); Tomasz leads
  the people to the basilica (an exit counter: the people saved).
- CHOICE: none; the verdict is canon. CARRIES: `rome` (the quarters that stood, a tally), the people saved; Hollweg's
  and Lindqvist's defiance (always): Act 2 opens with both gone (the guild to Brazil after its crates; Lindqvist to
  breed in secret).
- MODES: SOLO as the Crown (the two others scripted). CO-OP: the second player commands the garrison's east bank.
  CO-OP VERSUS: the second player picks the creatures or the automata; the other is scripted (three seats online: later,
  question 8). The winner by side: the Crown holds the bridges; the creatures or the automata win by crossing.
- ENGINE: MORE THAN TWO SIDES in one mission (the end logic; docs/campaign_engine.md "Open"); a SPREADING FIRE (`burn`
  passed to neighbouring tagged buildings); a MID-MATCH SHOW (optional); the city generator.

## THE WAR MAP (the engine's item 14)

### What it is

The world map as each hub's table (owner, 2026-11-11: option 2 rooms + option 4 the war map as the table, different per
faction). It replaces the war table's LIST as the way to pick a mission (the list stays: on a narrow screen, and as
the accessible view). It shows:

- REGIONS (Virginia, Lyon, Paris, Franconia, Rome and the Papal States, Lisbon, the upper Rio Negro, the plateau, the
  Barra, the south of Brazil, ... and the rest of the empire as plain purple): each held by someone (the Crown purple,
  the Machine red, the Brood green, the Assembly green and black UNREST, unknown), changed by missions won and flags.
- PINS: one per mission, with its date and line (Crown, Clockmaker, Naturalist), locked / open / done; a done pin keeps
  its result (a little seal, a gear, a pin through a specimen card).
- THE LEDGER: a fold-out panel with the flags so far in plain words ("The Hollins families were saved", "Nuremberg: 34
  townsfolk reached Fürth") and the act's dates.
- ACT BY ACT: Act 1 shows the empire whole; Act 2 grows the red and the green; Act 3 is three-way (the Clockwork and
  the Brood fight each other too).

### How it looks per hub

| hub | the map | pins | regions |
| --- | --- | --- | --- |
| the King's study (Crown) | a parchment map on the King's desk, ink and watercolour | wax seals (purple; a broken seal for a lost place) | washes of colour; unrest as hatching |
| the Clockmaker's (the guild in exile; question 2) | a BRASS MAP: engraved plates on turning rings, the regions as enamel | small gears set into the plates, turning when open | enamel colours; red spreads as a creeping gear ground |
| the Naturalist's (the warehouse at the Barra) | Lindqvist's SPECIMEN CHART: a naturalist's map of the rivers with labels and sketches | pins through specimen cards | inked outlines; unknown land blank paper |
| (later, the Brood side's) | a map SCRATCHED INTO THE NEST FLOOR (Act 2) | claw marks | patches of swamp |
| (later, the Machine's) | Nuremberg's great clock face as a map | the clock's hands | red gears |

One map projection and one data file under three skins: only the base painting and the pins' and regions' drawing
change per hub.

### What it needs to build

1. DATA: `campaign/warmap.json`: regions (id, name, outline as a polygon over the base picture, holder at the act's
   start), pins (mission id, point, line, date), and RULES ({"after": mission, "if": flag condition, "region": id,
   "to": holder or "unrest" or "known"}); read with the progress (Campaign.flag, finished missions).
2. DRAWING (a WarMap control in scripts/campaign/): the hub's base painting, the region washes (polygons drawn over
   it, in the hub's style), the pins (by state), pan and zoom for phones (the robot game's city map is a model:
   pinch, wheel, a "fit" button), a tap on a pin = the mission's briefing card (today's war table card).
3. THE HUB: the `war_table` hotspot opens the map (or the list on a small screen or by a toggle).
4. ART: three base paintings (the parchment, the brass plates, the specimen chart) in the same projection, ChatGPT
   prompts to be written with the build; until then a plain drawn world map (StillView-style placeholder).
5. ONLINE: co-op and versus read the host's progress (as missions do now); co-op versus will need each player's own
   faction's map (one data file, two skins).
6. TESTS: every rule's region and pin exists; every mission is pinned; the map of each act draws with every flag
   combination of the act (a headless check like test_campaign's data checks).

## The engine work Act 1 needs (beyond the three prologues' builds)

| need | missions | size |
| --- | --- | --- |
| SOLO SIDE PICK: solo play of a mirrored mission's second side (the first side scripted or the computer); a "pick a side" on the briefing; the side's own opening/ending lines | a02, a03, a05 (a04, a06, a01 versus only) | medium: Campaign.make_cfg seats, MissionRun's "control" per pick |
| MORE THAN TWO SIDES: the end logic per side (a side loses when its primaries fail; the mission ends when the scripted end or the last side standing) | a07 | medium |
| a CITY GENERATOR (streets, house blocks as props, squares, bridges, walls; one script for Lyon, Paris, Rome) | a01, a06, a07 | medium (map work) |
| DISGUISED buildings (a prop until seen up close) | a01 | small |
| STAY condition (a tag in an area for n seconds) | a01, a04 | small |
| `units` / `buildings` with `"if"` (flag starts) | all | small |
| ROUTE order (waypoints in turn) and FOLLOW (a unit or tag) | a03, a04, a05 | small |
| SLEEP / WAKE for a side (hold until an enemy comes within n tiles or a trigger) | a03, a05 | small |
| MIST (weather + a sight multiplier) | a03 | small |
| CAGE CARTS (a caged creature carried with a cart; freed when the cart dies) | a05 | small-medium |
| SPREADING FIRE (`burn` reaching neighbouring tagged buildings) | a07 | small |
| MID-MATCH SHOW (stills with lines during a match; solo pauses) | a07 (optional) | small |
| CAPTURE objective (sugar over `floor` + `hp` + `cage`) | a01, a06 | small |
| THREE SEATS online (co-op versus with three players) | a07 (later) | large: question 8 |
| a CAMPAIGN DIFFICULTY setting (both prologue builds noted it is missing) | all | small-medium: question 10 |
| SAVING A MISSION halfway (CONTINUE; engine "Open") | all (longer missions) | medium |
| THE WAR MAP | the act | large (above) |

Built already and reused: stills and endings with if-lines, story losses, counters, exits, tallies, countdowns,
repeating triggers, `convert`, roster deny/unlock, sounds, names, hunt, roles (rebels, citizens, the prologues'
people), cage / spare / pin / carry / floor / heal / hp, root / uproot, `to_if`, `burn`, building sites, rain and snow,
the winter and jungle lights, role scale, hub `after` and flag gating, `past` flags.

## OWNER ANSWERS (2026-11-17 22:04: "Yes to all your suggestions")

Every recommendation below is TAKEN (1-14), and with them a change the owner asked for at 22:00: THE NATURALIST'S
PROLOGUE IS PLAYED AS THE BROOD ("we can see the naturalist spying on the brood and we play the brood fighting maybe
brood vs brood"). So b01_specimen becomes THE FIRST BROOD PLAY (not a03): the player is the TYRANT SIRE'S PACK coming
for Linnea (A), a RIVAL PACK holds the ground round the station (Brood v Brood), the station is a scripted third side
to raid or avoid; the station still FALLS and the scientists escape by the canoes; the player wins by taking Linnea
out of the pen, the fire is what the scientists do as the pack breaks in (B); the scientists' choices (BURN THE EGGS /
SAVE THE RESEARCH, the Teles choice) stay theirs, made by the script, and the player gets ONE creature choice (C);
Lindqvist still narrates (what he saw from the station). a03_plateau stays VALADARES' CLIMB played as the Crown party
(its nest mirror kept for versus / solo side pick, no longer "the first Brood play"). Canon: the map DRAWN (4), the
broken ones KEPT (6), Tomasz asks for mercy and VARENNE SPARED into exile (7).

## OWNER QUESTIONS

Each with Claude's recommended answer (the plan above is written as if it is taken) and what changes either way.

1. THE CLOCKWORK LINE IN ACT 1: FÜRTH? The guild in exile at Fürth, a few miles from the lost city, holding the line
   for the Crown (a02) and inspected there (a04). RECOMMENDED: yes: the machine stays in sight (the Clockwork faction
   is played as the Machine in the mirror), the c01 flags all have somewhere to land, and Act 2's "the guild leaves the
   Crown" starts from a place the player knows. OTHERWISE: a Crown arsenal far away (Turin, Vienna): the guild builds
   in peace and the machine is only on the map; a02 becomes a building mission with no mirror and a04 the riot alone.

2. THE CLOCKMAKER'S HUB IN ACT 1. Since c01 it shows "Nuremberg, the Machine's City" (no Hollweg; his letter on the
   bench). RECOMMENDED: the Clockmaker line's hub MOVES to THE GUILD IN EXILE AT FÜRTH (a barn workshop, Nuremberg's
   red towers through the window; Hollweg and Jakob by the flag; a new painting later, the c01 painting tinted until
   then), and the Machine's City becomes the hub of a player who plays the Machine side (versus, solo mirror). This is
   the Naturalist's pattern (the station moved to the Barra). OTHERWISE: keep the Machine's City for the whole line:
   a guild player sits in the enemy's room between missions (odd), but one painting less.

3. WHO TELLS THE LOST PLATEAU? RECOMMENDED: VALADARES, in his own voice, from his REPORT to the Crown (the sequel to his
   letter of June 2767), the King framing with the report in front of him: he is a Crown servant and tells it truthfully, and his
   voice (designed once for b01) is already planned. He need not be alive in 2795 (open). OTHERWISE: the King reads
   it (one voice fewer; flatter), or Lindqvist tells it second-hand from the report (keeps the Naturalist line's one
   teller, but he was not there and would be "corrected" all through). Ferrer for a04: the same question; recommended
   his own voice too.

4. THE LOST PLATEAU'S CHOICE: THE MAP. RECOMMENDED: yes, Valadares draws it for the Crown or withholds it; canon DRAWN.
   It is the mapmaker's own choice and it moves a05 (the short way or the long way) and the war map (the plateau shown or
   blank). OTHERWISE: no choice in a03 (the counts carry; Act 1 has two choices); or a different one (take an egg as
   proof for Rome: then the Council has a third piece of evidence, and the egg is a carried object down the cliff).

5. WHICH MISSIONS GET A SOLO MIRROR? RECOMMENDED: a02 (play the Machine), a03 (play the nest: the first Brood play, the
   owner's decision), a05 (the creatures free the cages); a01, a04 and a06 VERSUS ONLY (the Assembly is not a faction
   and the riot is short); a07 three-way (solo as the Crown). The creature and machine sides have NO narrator (no
   creature speaks; the machine has no voice): the King's frame, objectives, sounds. This needs the SOLO SIDE PICK
   (engine). OTHERWISE: versus only everywhere (no engine work, but a solo player never plays the Brood in Act 1); or
   every mission mirrored (the Assembly as a solo side: more work, and it puts the player behind the barricades
   against the Crown).

6. a04, THE BROKEN ONES. RECOMMENDED: the choice as written (melt them: Ferrer; keep them: Hollweg), canon KEPT, and the
   kept ones are what goes wrong at Rome. OTHERWISE: no choice: the automata at Rome are always there (Hollweg brings his
   "mended" ones whatever happens) and Act 1 has two choices.

7. VARENNE: TOMASZ AT THE MOMENT, AND THE CANON. RECOMMENDED: Tomasz ASKS FOR MERCY (it echoes his prayer for the
   rebels in p01 and keeps him the Crown's conscience, not its judge); Fairleigh hears him and leaves the order to the
   player; the CANON is the owner's: Claude leans to SPARED (exile), because it keeps Varenne for Act 2's Clockwork
   council and the 3rd crossing, and mercy from a victorious Crown is still the Crown in the right. OTHERWISE: Tomasz
   stays silent (the choice is the player's alone, colder); canon EXECUTED (a martyr: Act 2's risings harden, more
   unrest on the war map; Varenne's Act 2 role goes to someone else).

8. ROME IN CO-OP VERSUS. RECOMMENDED: two players now (the Crown and ONE of the creatures or the automata, the other
   scripted); THREE SEATS (one player per faction, the true three-way) later, with Act 3's three-way war map, where it
   is needed most. OTHERWISE: build three seats for a07: online lobby, snapshots and the mission's seats all change
   (large work for one mission).

9. THE ORDER OF BUILDING: WAR MAP FIRST OR MISSIONS FIRST? RECOMMENDED: the first two missions (a02, a03) on today's
   list war table, then the WAR MAP (v1: the King's study's parchment only, drawn placeholder art, all Act 1 pins and
   rules), then the rest; the brass map and the specimen chart skins with their paintings. OTHERWISE: the war map
   first (it shows the act's shape from the first mission; nothing playable for longer).

10. A CAMPAIGN DIFFICULTY SETTING BEFORE ACT 1. Both prologue builds noted it is missing ("Easy gives two minutes more"
   was not built). RECOMMENDED: yes, small: EASY / NORMAL / HARD on the briefing, read by a mission as `{"difficulty":
   ...}` conditions and a multiplier on countdowns and spawn counts; the three prologues get it too. OTHERWISE: one
   difficulty (tuned for a careful player, as now).

11. THE DATES. RECOMMENDED as in the table: the Lost Plateau in SEPTEMBER 2767 (Valadares turned north the morning the
   station burned, b01's ending), the Fürth Line March 2768, Lyon spring 2768, the Specimens and Paris 2769, Ferrer's
   visit autumn 2769, the Council in Lent 2770 (the timeline's 2770). OTHERWISE: any dates within 2767-2770; only the
   war map's labels and a few lines change.

12. THE CRATES TO BRAZIL IN ACT 1. RECOMMENDED: one HINT only, in a05 (the gear-stamped crates on the river quay "for the
   mines in the south": a ping, a line, no fight); their waking is Act 2's, with the 2nd crossing in Brazil. OTHERWISE:
   nothing until Act 2 (the player forgets them), or a short Act 1 mission at the mines (the first red in the New
   World: earlier, but it crowds the act and spends Act 2's surprise).

13. THE HEIR'S PRACTICE AFTER THE PROLOGUES (docs/campaign_act1.md's optional skirmish: the heir holds a line until dawn).
   RECOMMENDED: LATER, as one heir mission at Act 1's END (after Rome), when the frame has a lesson to put into
   practice and the heir's name and look are decided. OTHERWISE: now, after the prologues (the heir is still unnamed:
   docs/campaign_timeline.md).

14. HOLLWEG AND LINDQVIST AT THE COUNCIL. RECOMMENDED: both present and heard (as accused or witness by the flags), both
   DEFY the verdict (the timeline), and the King meets them both for the first time there: the start of the two
   tellers' long road to his palace (Hollweg in exile, Lindqvist arrested). OTHERWISE: only their letters are read at
   Rome (they stay away; the defiance is told, not seen).

## Proposed BUILD ORDER

Each step a job on its own branch, merged on its DONE as the prologues were; the owner's answers first.

1. ENGINE STEP 0 (small, one job): `units` / `buildings` with `"if"`; the STAY condition; the ROUTE and FOLLOW orders;
   SLEEP / WAKE; MIST; the CAPTURE objective; a CAMPAIGN DIFFICULTY setting (question 10); the SOLO SIDE PICK. Each with
   its line in docs/campaign_engine.md ("Added by Act 1's engine step 0") and a check in tools/test_campaign.gd.
2. a02_furth, THE FÜRTH LINE: the cheapest mission (c01's seeds, roster, lights and roles all reused) and the first to
   read prologue flags across missions; it proves the carry and the solo mirror (the Machine).
3. a03_plateau, THE LOST PLATEAU: the first Brood play (the owner's anchor); uses SLEEP, MIST, ROUTE and the side pick.
4. THE WAR MAP v1 (the King's study's parchment, placeholder art, Act 1's regions, pins and rules; the list kept).
5. THE CITY GENERATOR, then a01_presses (DISGUISED buildings).
6. a06_barricades (the act's choice; reuses the city generator and the capture).
7. a04_visit (reuses a02's map and STAY / FOLLOW).
8. a05_specimens (CAGE CARTS; reuses a03's nest and SLEEP).
9. MORE THAN TWO SIDES and the SPREADING FIRE, then a07_council (the crossing).
10. The war map's other skins (the brass map, the specimen chart) with the owner's paintings; the Clockmaker's hub at
    Fürth (question 2); the heir's mission (question 13).

Also with step 2: campaign.json's Crown line ("prologue", titled "Prologue: The Leaf and the Fire") gets Act 1's Crown
missions; its title becomes THE CROWN (the id kept, so saved progress stays).
