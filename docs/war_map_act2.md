# THE WAR MAP's ACT 2 (job act2-warmap, step 4 of Act 2's build order)

Step 4 of docs/campaign_act2_plan.md's build order: the war map grows into Act 2. A new BRAZIL view, Act 2's regions,
marks, pins and rules, and the two skins the plan asked for: the Clockmaker's BRASS MAP and the Naturalist's SPECIMEN
CHART. Same data file, same code; the skins are drawn in code with slots for the owner's paintings. ALL TEXT IS A
PLACEHOLDER. There is NO Brood skin and no Brood war map (owner 2026-11-22: the Naturalist always tells the Brood's story;
the chart is Lindqvist's, then Valadares', never the creatures').

## What the player sees

- After THE COUNCIL OF ROME (a07) is won, the war map opens on BRAZIL, not THE WORLD, and its heading says "Act 2"
  (the ledger and the cartouche say "Act 2: 2771-2780"). Before Rome nothing changes.
- THE BRAZIL VIEW (a button beside THE WORLD): the whole colony from the Amazon to the Rio Uruguai, drawn in the old-map
  style of the parchment (Natural Earth's coasts, engraved coast lines, the mountains as inked peaks: the Andes, the
  Serra do Mar, the Mantiqueira, the Espinhaço, the Serra Geral, the Guiana highlands) with Brazil's rivers now drawn
  (the Tapajós, São Francisco, Madeira, Xingu, Tocantins, Araguaia, Paraná, Uruguay and others: Natural Earth, public
  domain). It has no painting yet: a slot is ready (`painted_brazil.jpg`, see the prompt below); until then the code
  draws it.
- ACT 2's SEALS: one for every Act 2 mission, d01 to d13, on its place. The two built ones (d02 The Exodus, d03 The
  Island) open after Rome; the others show the empty dashed ring of a mission not written yet. Every pin's card says
  WHAT (the title), WHERE and WHEN (place and date), WHY (one line of what it is about, for missions not open yet) and
  WHAT OPENS IT ("Opens after: ..."): the rule SAY IT PLAINLY.
- THE DIAMOND'S CLOCK: after d09 (Between Two Fires) the front NOT chosen first wears a small ticking clock on its seal,
  and its card says in red "Waits: the army is in the north, and the city grows while it waits." (or the swarm spreads).
  Once that front is fought, the clock goes.
- The map changes with Act 2's flags (below): Minas uneasy, Concórdia the free city's (blue), the Tapajós green or
  uneasy, Lindqvist's island green and the Queen's mark, the Barra held or burned, the sertão and its fort, the lower
  Amazon held or lost, Concórdia red and besieged, Luanda and Goa.
- THE HUBS: the King's study's war table opens the King's PARCHMENT (as before); the Clockmaker's hub's war table (the
  "BRASS MAP" hotspot) now opens THE BRASS MAP; the Naturalist's hub's ("SPECIMEN CHART") opens THE SPECIMEN CHART. A
  war table's WAR MAP button opens its own line's skin too.
- On the drawn map, places' names (the station, Nazaré, the fazenda) and the chart's notes show once the map is zoomed
  in past a whole country, so the Brazil view stays readable; the pin's own place and date always show.

### THE BRASS MAP (the Clockmaker's)

An engraved brass plate: a brushed sheen and lathe rings, the coasts cut into the brass (a dark line with the light
catching its lower lip), the grid engraved, the regions as ENAMEL with brass rims (the Crown purple, the creatures green,
the free city blue), the machine's land a CREEPING GROUND OF SMALL GEARS that turn, the pins small brass gears with the
line's enamel in their middle (the open ones turning), a riveted rim and a turning dial in the corner for a compass, and
words engraved on the plate ("Nuremberg, Advent 2767.", "Landed, 2771.", "CONCORDIA. Founded 2773."). It never shows the
King's Catholic paintings (they are the King's). It never shows Concórdia red: Hollweg's map shows the city he believes
in (Claude's choice 3).

### THE SPECIMEN CHART (the Naturalist's)

A field chart in ink and pencil: cream paper with faint stains, a fine pencil grid every 5 degrees, the coasts in thin
sepia ink, the RIVERS IN BLUE INK, thicker than anything else (a naturalist's river map), light watercolour washes, the
creatures' land STIPPLED IN GREEN INK by a careful hand, the pins SPECIMEN LABELS pinned to the paper (a coloured pin
head, a paper tag with the line's sign, a tick when done, torn when lost), margin NOTES in blue-black ink ("The station.
Burnt, Saint John's Eve 2767.", "The pens, kept against Rome's verdict.", "Something roots here. No one has gone to
look.", "Their ground creeps in the flood: a mile a week (V.)."), a pencil scale of a hundred leagues and a plain north
arrow. It does not show the King's paintings either.

## The data (campaign/warmap.json, written by tools/campaign/warmap_act2.py)

Act 2's part is written by `python3 tools/campaign/warmap_act2.py` (it can run again: every item it writes carries
`"act2": true` and is taken out first). New keys in the file:
- `views`: `brazil` `[-74, -34, -33, 6]`, second after THE WORLD.
- `holders`: `guild`: "The free city (the guild's)" (blue; on the brass map blue enamel).
- `acts`: `[{"if": {"done": "a07_council"}, "act": 2, "act_title": "Act 2: 2771-2780", "view": "brazil"}]`: the act the
  progress has reached and the view the map opens on (WarMapData.act).
- `skins`: each skin's title (THE WAR MAP, THE BRASS MAP, THE SPECIMEN CHART).
- `notes`: `{skins, if, point, text}`: the chart's margin notes and the brass map's engraved words (WarMapData.state
  `notes`, by the skin).
- In rules: `skins` (the rule runs only for those skins: Concórdia's red is the parchment's and the chart's), `clock`
  with `pin` (the diamond's clock: the words on the waiting pin's card).
- In pins: `about` (one plain line for a planned mission's card).
- New mark kinds: `route` (a dashed line by sea or land, `points`), `gear`, `queen`, `church`, `church_burnt`, `fort`,
  `siege`.
- campaign/warmap_mountains.json: five new ranges in Brazil (one range a line, as the file was).
- campaign/warmap_land.json: Brazil's rivers added (tools/campaign/make_warmap_land.py's RIVERS; the land and lakes are
  unchanged, checked).

### The pins

| pin | line | place, date | after | state today |
| --- | --- | --- | --- | --- |
| d01_minas | Crown | Vila Rica, 2772 | a07 | planned: "The Gold of Vila Rica" |
| d02_exodus | Clockmaker | The Main, February 2771 | a07 | BUILT (its own pin, unchanged) |
| d03_fazenda | Naturalist | The island, dry season 2772 | a07 | BUILT (its own pin, unchanged) |
| d04_concordia | Clockmaker | The southern highlands, 2773 | d02 | planned: "The City of Gears" |
| d05_aldeia | Crown | São Rafael, on the Tapajós, wet season 2776 | d01 | planned |
| d06_queen | Naturalist | The island, wet season 2775 | d03 | planned: "The Queen" |
| d07_spring | Clockmaker | Concórdia, 2777 | d04 | planned: "The Council of Gears" |
| d08_rivers | Naturalist | The Barra do Rio Negro, 2778 | d06 | planned: "Down the Rivers" |
| d09_crossroads | all three | The São Francisco, dry season 2780 | d05, d07, d08 | planned: "Between Two Fires" |
| d10_jungle | all three | Óbidos, 2780 | d09 | planned: the clock when the city was chosen first |
| d11_siege | all three | Concórdia's outer works, 2780 | d09 | planned: the clock when the swarm was chosen first |
| d12_luanda | Naturalist | Luanda, 2777 | d06 | planned, OPTIONAL: "The Hold" |
| d13_goa | Clockmaker | Goa, 2779 | d04 | planned, OPTIONAL: "The Mining Machines" |

Three pins stand at Concórdia (d04, d07, d11) and two at the island (d03, d06): nudged side by side with a thin line back
to the true point (Act 1's way).

### The rules (by the plan's flag names; checked against each mission's JSON once it is built)

| mission | flags | the map |
| --- | --- | --- |
| a07 done | | Brazil unrolled: Salvador on the map, the map opens on BRAZIL |
| d02 won by the guild | | the guild's ships: a dashed line by sea from Hamburg to the coast below the highlands |
| d01 | `minas` quiet / restless, `gold` few / some / all, `conspirator` taken / fled; won by `conspiracy` | Minas purple; restless = uneasy; fled = a dashed road from Vila Rica to Concórdia; the conspiracy's win = unrest, the seal broken |
| d04 | `colonists` parley / fought, `crates` opened; won by `guild` / `valley` | Concórdia the free city's (blue), its gear and the old mine; fought = the valley uneasy; with a06 Varenne spared his ship's line ends at Concórdia; the valley's win = the seal broken |
| d05 | `fields` burned / left, `aldeia` few / some / many; won by `swarm` | the São Rafael church; left = the Tapajós the creatures'; burned = uneasy and the church burnt; the swarm's win = the seal broken |
| d06 | `brood_n` few / some / all, `pieter` alive / lost | the island the creatures', the fazenda fallen, the Queen's mark in the forest north of the river ("where nobody has been"), the lower Amazon uneasy |
| d07 | `spring` stopped / running, `honest` few / some / many; won by `machine` | stopped = Concórdia red at once (parchment and chart) and the honest masters at the coast; running = blue until d09 |
| d08 | `lure` burned / used, `barra` held / burned, `nazare` few / some / all; won by `swarm` | the upper Rio Negro the creatures' (the swarm came down), Nazaré gone; held = the Barra purple; burned = uneasy; the swarm's win = the creatures', the seal broken |
| d09 | `first` brood / clockwork, `sertao` few / some / many | the fort, the sertão purple; with `spring` running Concórdia red now (parchment and chart); THE CLOCK on the front not chosen |
| d10 | `jungle` held / thin; won by `swarm` | held = the lower Amazon uneasy; thin (or the swarm's win) = the creatures' |
| d11 | `siege` close / held_off, `jakob` alive / lost; won by `city` | Concórdia red (parchment and chart); close = the siege ring; held off = the valley uneasy |
| d12 | `luanda` clean / escaped | clean = Luanda purple; escaped = uneasy |
| d13 | `goa_seed` smashed / shipped | smashed = Goa purple; shipped = uneasy |

The ledger's lines say each in plain words ("Ruggieri chose the swarm first: the army went up the rivers.").

## Code

- `scripts/campaign/war_map_data.gd`: HOLDERS + `guild`; SKINS (parchment, brass, chart); MARK_KINDS;
  `state(p, skin)` (rules with `skins`, `clock`, the skin's `notes`); `act(p)`; `skin_title(skin)`; `problems()` checks
  marks' kinds and routes, views, acts, notes and rules' skins and clocks; `strings()` has the new texts.
- `scripts/campaign/war_map.gd`: SKINS `brass` and `chart` (colours, `style`, `paintings`, `paper_art`, `hill_art`);
  the map opens on the act's view; the brass plate and the chart paper (`_draw_sheet`), the creeping gears and the
  stipple (each region's `dots`), engraved coasts, the notes (`_draw_notes`), the frames (`_draw_frame`), the gear pins
  and the specimen-label pins (`_draw_gear_pin`, `_draw_tag_pin`), the clock (`_draw_clock`), the new marks. Camera
  fixes found by the pictures: a pin's card opened with the page (or before it was laid out) no longer sends the map out
  to the whole world; a glide still running stops when a newer move comes (`_stop_glide`); the card's side is kept as a
  side (`card_right`, `card_top`), not a rectangle measured too early; on the drawn map the sheet's edge may go under the
  card so a pin near the bottom (Concórdia on a phone) still comes out beside it.
- `scripts/campaign/campaign_menu.gd`: `skin_for(line)`; the page's heading is the skin's title and "Act 2"; a planned
  pin's card shows its `about` line (`CardAbout`) and a waiting pin its clock (`CardClock`); a test's progress that
  "finishes" an unwritten mission no longer offers a BRIEFING for it.
- `campaign/campaign.json`: the Clockmaker's and the Naturalist's war table hotspots have `"map": "brass"` / `"chart"`.
- Texts: tools/i18n/campaign/warmap_act2.txt (en, pt, es).

## Pictures (docs/shots/war_map/act2/, by tools/shot_war_map_act2.gd)

`xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --script res://tools/shot_war_map_act2.gd -- <dir> pc`
(and `--resolution 1600x720 ... mobile` for a phone held sideways). Each comes as pc_ and mobile_:
a2_1 the parchment on BRAZIL at the act's start (d02, d03 played); a2_2 late in the act, the siege's card with the clock;
a2_3 a planned pin's card (d01: what, where, when, why); a2_4 the act finished, the ledger open; a2_5 the world painting
with Act 2's seals; a2_6 THE BRASS MAP on Brazil; a2_7 the brass map zoomed on Concórdia (three gears, the engraved
words); a2_8 the brass map on Europe (Franconia's creeping gears); a2_9 THE SPECIMEN CHART on Brazil; a2_10 the chart on
the Amazon (stipple, specimen labels, margin notes); a2_11 the chart in Act 1 (the Naturalist's line before Rome).
Checked for scale and overlaps: on the Brazil view the marks' names and the notes wait for a zoom (they crowded the
Amazon); the heading shows "Act 2" only (the dates were cut by the view buttons); the legend's swatches on the brass
map; the chart's scale bar moved from under the legend to the bottom middle.

## ChatGPT prompts for the owner (one request each, standing alone, at most 3 reference images)

1. THE BRAZIL SHEET (for the King's parchment: the BRAZIL view's painting, `art/campaign/warmap_brazil_chatgpt.png`,
   fitted by tools/campaign/fit_warmap_paintings.py; references: (a) docs/shots/war_map/act2/pc_a2_1_parchment_brazil_start.png
   for the coasts and rivers, (b) art/campaign/warmap_amazon_chatgpt.png for the style, (c)
   art/campaign/warmap_world_chatgpt.png for the frame and the saints):
   "An antique hand-painted map of Brazil in the style of an 18th-century Catholic royal cartographer, landscape format,
   1536 x 1024 pixels. The land painted by its landscape as in a satellite picture, never by countries: the Amazon
   rainforest dark green, the dry backlands of the north-east (the sertão) in ochre with scrub, the southern highlands
   with dark umbrella-shaped araucaria pines and red earth, the mountains along the coast (Serra do Mar) as small inked
   peaks, the great rivers in blue (the Amazon, the Rio Negro, the Tapajós, the São Francisco, the Paraná, the
   Uruguay). Follow the first reference image's coasts and rivers as closely as you can; do not add islands or seas. The
   Atlantic in pale blue-green with fine wave hatching, one Portuguese ship with a red cross on its sail. In the top
   left corner a small Byzantine icon of Our Lady of the Conception with a gold halo; bottom centre an empty crowned
   cartouche with laurel. No text, no letters, no labels, no borders between regions, no compass. Soft even light."
2. THE BRASS PLATE (the Clockmaker's map's sheet, `campaign/warmap_art/brass_plate.jpg`, drawn under the code's map;
   references: (a) docs/shots/war_map/act2/pc_a2_6_brass_brazil.png for the look, (b) the Clockmaker's hub painting for
   the brass and the light):
   "A large engraved brass plate seen from straight above, filling the whole picture, 1920 x 1080 pixels: warm
   polished brass with fine brushed lines and faint concentric lathe rings, a darker riveted rim all round with eight
   round rivets, a thin engraved double border inside the rim, small scratches and a little green patina in the corners.
   Completely empty in the middle: no map, no land, no text, no gears drawn on it. Soft lamplight from the top left, no
   reflections of objects."
3. THE CHART PAPER (the Naturalist's chart's sheet, `campaign/warmap_art/chart_paper.jpg`; references: (a)
   docs/shots/war_map/act2/pc_a2_10_chart_amazon_notes.png for the look, (b) the Naturalist's hub painting for the
   field-station mood):
   "A sheet of a naturalist's field chart paper seen from straight above, filling the whole picture, 1920 x 1080
   pixels: cream rag paper, a faint pencil border, light water stains, a coffee ring in one corner, a pressed fern leaf
   and a pin hole near an edge, slight fold creases. Completely empty in the middle: no map, no land, no drawings, no
   writing. Soft daylight."
With the plate or the paper in place the code draws the map over it as it does over the parchment; the land itself
stays drawn by the code (exact coasts at every zoom, as the parchment decided in v1).

## Claude's choices (for the owner)

1. BRAZIL'S REGIONS START AS THE EMPIRE'S (the faint purple of the empire, not the stronger purple of a region won):
   the plan says "all purple"; a strong wash over the whole colony would hide the changes.
2. THE ACT 2 MAP OPENS ON BRAZIL once Rome is won, on every skin (the act's frame: "Brazil unrolled for the first
   time"); the parchment's other views keep their paintings.
3. THE BRASS MAP NEVER SHOWS CONCÓRDIA RED, whatever happens (the plan's choice 12 says it for `spring` running; I kept it
   for `stopped` and the siege too: the plate is the city's own and Hollweg's pride). The King's parchment and the
   Naturalist's chart show it red after d09 (running) or at once (stopped).
4. THE CHART SHOWS THE SAME HOLDERS AS THE PARCHMENT (the Naturalist knows what the Crown knows by then); only its notes
   are its own. THE BRASS MAP'S WORDS are engraved notes, not ledger lines.
5. THE QUEEN'S MARK stands in the forest north of the lower Amazon (lon -57.4, lat 0.6), "where nobody has been": the
   plan says beyond the map; on a map the King can read it has to stand somewhere. Its words never give it a mind.
6. d06's WORDS follow the owner's rework (the Mothers fight; the strongest grows into the Queen; no name), not the plan's
   older Linnea text.
7. THE LOWER AMAZON GOES UNEASY AFTER d06 (the swarm born on the river) and d10 decides it (held = uneasy, thin =
   the creatures').
8. FORT CONSTANTINE stands where the Rio Grande meets the São Francisco (Barra, Bahia): the crossroads of the plan;
   SÃO RAFAEL a week up the Tapajós (lon -55.7, lat -4.6); CONCÓRDIA on the plateau above the Rio Uruguai (lon -51.6,
   lat -27.3, by today's Concórdia in Santa Catarina); the VALLEY to its south-west. All proposals, as the plan's.
9. d10's and d11's MIRROR WINS DO NOT BREAK SEALS (the plan says nothing): the swarm holding the river reads like
   `jungle` thin, the city breaking the batteries like `siege` held off. d01's conspiracy, d04's valley, d05's swarm and
   d08's swarm (the plan's own) do break them.
10. d12 AND d13 ARE PINNED WITH THEIR FLAGS NAMED `luanda` clean / escaped and `goa_seed` smashed / shipped (the
   worldwide plan's words, "some got away" and "shipped on", made into single words). Their lines are the Naturalist's
   and the Clockmaker's; they open after d06 and d04.
11. THE ACT'S TITLE stays "Act 2: 2771-2780" (the plan's dates) in the ledger and the cartouche; the page's heading
   says "Act 2" so the six view buttons fit.
12. THE GUILD'S SHIPS' LINE starts at Hamburg (owner answer 4) and lands below the highlands (São Francisco do Sul);
   Varenne's ship of exile (a06 spared) goes on to Concórdia only once d04 is played.
13. ON THE DRAWN MAP, MARK NAMES AND NOTES SHOW ONLY ZOOMED IN (14 pixels a degree): the Brazil view is too crowded
   for them at its first size. The pins' place and date always show where there is room.
14. THE OLD MAP's ORNAMENTS (ships, serpent, cartouche) STAY THE PARCHMENT'S; the brass map has its rim and dial, the
   chart its scale and north arrow.
15. "100 leagues" on the chart's scale is five degrees (near enough at the equator for a field chart).
16. The Machine's City hub (a Machine player's Nuremberg) reads the brass map too (it is the Clockmaker's line).

## What is left

- The owner's paintings (the three prompts above); with the Brazil sheet, its landmarks in tools/campaign/fit_warmap_paintings.py
  (the list of places is written there).
- The missions d01, d04-d13 themselves: each build checks its flags against these rules (WarMapData.problems fails on
  a flag a built mission never sets) and may rename them.
- Locking the second front until the first is won (owner answer 9) is the campaign's gating, for d09's build; the map
  only shows the clock.
- The hubs' Act 2 rooms (Concórdia's council hall with the brass map on its table, Valadares' quarters with the chart)
  are their own build steps.

## Tests run (on 0.38.186 + this branch)

- `tools/test_war_map.gd`: 0 failures (Act 1's checks and Act 2's: the view and the act, every skin's holders and title,
  no Brood skin, each line's skin, every Act 2 pin and mark on land, the states after Rome, d01-d13's rules, what each
  skin knows of Concórdia, the clock and when it stops, the notes, 384 combinations of Act 2's flags in three skins, the
  Clockmaker's hub opening the brass map on Brazil, a planned card's words, the Naturalist's war table opening the
  chart, the clock on the card, every skin drawing Act 2).
- `tools/test_campaign.gd`, `tools/test_hubs_grow.gd`, `tools/test_campaign_d02.gd`, `tools/test_campaign_d03.gd`: 0
  failures.
- Boot `godot --headless --path . --quit-after 120`: no SCRIPT ERROR or Parse Error.
- `python3 tools/i18n_build.py` (no errors), `python3 tools/i18n_patch_build.py` reports [].
- (As before on this cloud machine every headless Godot run ends with "Aborted", exit 134, after its last line.)
