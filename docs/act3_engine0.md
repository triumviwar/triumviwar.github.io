# Act 3's engine step 0 (job act3-engine0, patch note under 0.38.999)

The first step of Act 3's build order (docs/campaign_act3_plan.md, "Proposed BUILD ORDER" 1, and "The engine work Act 3
needs"), built after the owner's answers of 2026-11-28 ("Do all": every question as recommended). It adds to the
mission engine the pieces Act 3's twenty missions and the finale need before any of them is built: THE CLIMATE and its
FROST LINE, THE STOP-WORK, THE MADE CALL, WARMTH, THE FLIGHT PART, THE NIGHT's ORDER, THE LADDER IN ANY ORDER, THE
LEDGER, THE FINAL CHOICE and THE CREDITS. No mission of Act 3 is built here. Every piece is data in a mission's JSON or in
campaign.json, like Acts 1 and 2; the table of keys is in docs/campaign_engine.md, "Added by Act 3's engine step 0". This
page says what each piece is for, how a mission uses it, and how it keeps the owner's three rules.

Code: scripts/campaign/mission_act3.gd (MissionAct3, new: the mission pieces in one place, beside MissionAct2, so
MissionRun grew only by its hooks), scripts/campaign/campaign_credits.gd (CampaignCredits, new), scripts/campaign/
campaign.gd (the ledger, the night's order, the ladder in any order, the ending, `past` with a list, the data checks
handed to MissionAct3), scripts/campaign/mission_run.gd (the hooks: Act 3's state `act3` saved with the mission, the
final choice with no timer, `climate_pace`), scripts/campaign/campaign_menu.gd (the credits after the last mission, THE
CREDITS on the war table, the briefing's asking mission), scripts/campaign/mission_act2.gd (one line: the version's
asking mission), scripts/unit.gd (one line: the heat's pace), campaign/campaign.json (`nights`, `ledger`, `credits`),
tools/campaign/roster_ladder.py (ANY_ORDER, Act 3's rungs given their missions), docs/campaign_roster_ladder.md (the
CHECKED TABLE printed again, a note). Texts: tools/i18n/84_act3_engine0.txt and tools/i18n/campaign/campaign.txt (the
ledger's marks, the King's words, the credits' headings). Test: tools/test_act3_engine0.gd.

What was already there and is reused, not rebuilt: d07's BRAKE (the stop-work is the brake with a ring and an end),
d08's LURE POST (the made call is its pull with a time), a03's ROUTE and the flyers' own sight (the flight), the
`choice` action and its panel (the final choice is a choice with `final`), the mission's ENDING pages and their `if`
lines (the endings and their variations are compiled by them from the flags), StillShow, WarMap and HubScene (the
credits), Campaign.cond_before (the ledger's marks and the night's order are decided by it before any match).

## The pieces, and how a mission uses them

### THE CLIMATE (e02 Potosí's thin air, e04 Kongo's dry season, e07's highlands, e08 Goa's monsoon, e10, e15, e20)

The worldwide plan's rule (owner, 2026-11-22): the Brood can't live in the cold, the Clockwork rusts in the wet. A
mission rule only, never the skirmish's. The mission's key (or the action, to change it when the rains come):

`"climate": {"cold": {"hatch": 0.5, "frost": {"row": 40, "side": "north", "kill": 20}}, "wet": {"wind": 1.6}, "heat":
{"pace": 0.9}}`

- COLD: every Brood egg hatches at half its pace (its father's breath is not slowed: only its time to hatch).
- THE FROST LINE: a row of cells. On its frozen side an egg dies after `kill` seconds (FROZEN over it; FROST and the
  seconds left while it lies there). The frozen side is drawn as a pale field with a ticked edge, so the player sees
  where the swarm can't lay (SAY IT PLAINLY). With `"night_row": 60, "period": 240` the line comes down to row 60 at
  midnight and goes back up to row 40 at noon: e07's Ethiopian highlands, where the Brood stops at the foot of the cold
  nights (the plan's "the frost line moves with the day and the night"). `"counter"` counts the frozen eggs; condition
  `{"frozen": {"at_least": n}}`.
- WET: every Clockwork machine's wind runs down 1.6 times as fast; fields and Winders wind it as ever, so in the monsoon
  the Machine has to stay near its plates (e08's lesson: the guild's last hands win by mending, the Great Winder K8).
- HEAT: the Brood walks at 0.9 (`"faction"` for another side). A small push, not a wall (Claude's choice 3).

### THE STOP-WORK (e09 Nagasaki's choice, e17 Goa's bell, e20 Rome's bells)

`{"stop_work": {"at": "basilica", "within": 14, "secs": 60, "spare": "guild", "name": "goa_bell", "counter": "stopped"}}`:
Hollweg's pattern rung on a bell. Every Clockwork machine within the ring (the red Machine's; the `spare` side, the
guild's last hands, goes on) runs down to nothing and stays so for 60 seconds; one that walks into the ring stops too.
Its rings go out from the bell and STOP-WORK with the seconds left stands over it. Conditions `{"stopped": {"name",
"at_least"}}` and `{"stopping": name}`. Owner question 8 / Claude's choice 14: kept, it is rung twice, small at Goa and
great at Rome (all the bells: a bigger ring); rung at Nagasaki, it is used there.

### THE MADE CALL (e20, the ruin opened)

`{"made_call": {"at": "marsh_edge", "within": 25, "secs": 90, "to": "pontine_marsh", "name": "call"}}`: Lindqvist's call
from the opened records. For 90 seconds every SCRIPTED creature that comes within reach turns off its road and goes to
the marsh, once each: the ledger's "the Brood's next two waves turn off to the marsh". A person's creatures are never
pulled (the call is for waves, as d08's lure post). Conditions `{"called": ...}`, `{"calling": name}`. The creatures have
no reason to go: the call is a made thing, the lab's engineering, and they answer it as an animal answers a lure (the
rule: the Brood is not a person).

### WARMTH (e15, the Cold Forge)

`{"warmth": {"side": "crown", "fires": "brazier", "within": 5, "loss": 1.0, "counter": "cold_dead"}}`: out of every
fire's ring a man loses 1% of his health a second; by a fire he stops losing. A fire is any living thing with the tag:
a brazier (a building), a man carrying a torch, a burning wreck. COLD over those out, warm rings round the fires, for
that side's player. `"floor": 0.5` keeps the cold from killing (a mission that wants it as a pressure only).
`{"cold": {"name", "at_least"}}` counts who is out now (a line from the sergeant when too many are).

### THE FLIGHT PART (e05: Father Inácio's flight up the Congo)

`{"flight": {"tag": "inacio", "route": ["bend_1", "bend_2", "nest_bank"], "speed": 60, "mark": "nests", "within": 8,
"name": "flight", "counter": "marked"}}`: the balloon goes along its route by itself (the story's flight: the player
watches the land open under it and reads what it finds), and every nest of the `nests` tag that comes within eight
tiles is MARKED for good: pinged, a ring round it, counted, and kept on the player's screen after the balloon has gone
(`"reveal": false` not). The way still to fly is drawn dashed. `{"flown": "flight"}` when it reaches the end;
`{"marked": {"name", "at_least"}}`. The flyer's own sight lifts the fog as any flyer's does. Part 1 of e05 then hands
the marks to Part 2's column.

### THE NIGHT's ORDER (e16 Lisbon, e17 Goa, e18 the Atlantic port)

campaign.json `"nights": {"the_night": ["e16_lisbon", "e17_goa", "e18_port"]}`. The night's three ports are played in
any order; the first is FRESH, the second NORMAL, the last GROWN (owner question 10). Condition `{"night": "grown"}`
(or a list), in a mission's `versions` pick (the usual way: `"versions": {"pick": [{"if": {"night": "fresh"}, "id":
"fresh"}, {"if": {"night": "grown"}, "id": "grown"}], "default": "normal", "labels": {...}}`: the briefing then says it
plainly, as d10's and d11's do) or on units and waves. The rank is how many of the group were won before this one;
once won, the rank it was won at is kept in the progress (`night_rank`), so a replay plays the same night.

### THE LADDER IN ANY ORDER (Act 3's rungs: C10-C12, K8-K9, B8-B9)

The theatres are free, so a line's Act 3 rungs come in any order (the plan's Claude's choice 6). Act 3's rungs now
name their missions in tools/campaign/roster_ladder.py (C10 e01_brazil, C11 e03_virginia, C12 e12_exiles, K8
e08_arsenal, K9 e13_gold, B8 e05_river, B9 e11_spice). From C10 / K8 / B8 on, `apply()` writes a mission's allow-list
as the line's whole Act 2 kit + its OWN rung, and every other Act 3 rung of the line as `"if_won": {"e03_virginia":
["band_fifer", "band_piper"], ...}`; in the game those pieces join the kit once that mission is won
(Campaign.roster_denied). The mission jobs only need to add their BOUND / SIDE / CARD_AT lines as before. The doc's
CHECKED TABLE was printed again (Act 3's rows now show their mission and the base + own allow-list);
tools/test_roster_ladder.gd checks those rows against the line's last Act 2 row and, once a mission is built, its
`if_won`; tools/test_act3_engine0.gd plays every order of every line's rungs.

### THE LEDGER (e20)

campaign.json `"ledger"`: the 17 marks of the plan's table, each a condition decided from the progress (`{"past":
{"e16_lisbon.lisbon": "held"}}`; the Virginia Volunteers need p01's `families` save AND e03's `virginia` some or many:
`past` now takes a list of values, any of which will do), the bands (10 or more STRONG, 5 to 9 MIDDLE, 4 or fewer WEAK)
and the King's words for each. In e20, before the choice: `{"ledger": {"counter": "ledger", "show": true}}` counts it,
keeps the count and the band in the mission's flags (`ledger`, `ledger_band`) and shows THE LEDGER's card: every mark,
held (bright, ticked) or not (dim), the count and the band, the King's words (SAY IT PLAINLY: "The heir sees the real
stakes. Nothing is hidden."). Solo it holds the match until CLOSE. Every relief wave, ship and banner then reads
`{"ledger": {"mark": "lisbon"}}` or `{"ledger": {"band": "strong"}}` in its `if` (in the match and before it, so a
version or a briefing line can too). THE COLONIES mark reads the war clock's colonies (`{"colonies": {"share": 0.5}}`):
the clock is build step 2, so until it writes progress `colonies` that mark is never held (Claude's choice 7).

### THE FINAL CHOICE (e20)

A `choice` with `"final": true`: no timer (the only choice in the game without one: the plan's Claude's choice 15),
and solo it holds the match while it is open (the heir is given time; a save loaded with it open holds it again),
letting go as it was when answered. `"time": 0` on any other choice: no timer, the match goes on. The two buttons are
HOLD ROME and SAVE THE FLOCK (their words are e20's to write; the engine adds no button). What follows is e20's own
data: HOLD won sets `{"ending": "rome_holds"}`; HOLD lost (a story loss that counts, as c01's) sets `hard_way`; SAVE
THE FLOCK sets `rome_falls`. The endings' stills and lines, and the minor variations, are the mission's `ending` pages
with `if` lines by the flags (Fairleigh, Lindqvist, Varenne, the King on the bridge...), as every mission's ending is.

### THE ENDING and THE CREDITS

`{"ending": "rome_holds"}` keeps the ending in the mission's flags and Campaign.record writes it into the progress
(Campaign.ending(): the hub and the war map's last state can read it). A mission with `"credits": true` (e20) rolls
THE CREDITS after its ending pages, before its end screen: campaign.json `"credits"`' names (placeholder sections)
over THE WAR MAP as the campaign left it, then THE KING'S STUDY (the Rome hub's painting, his pipe smoking) with the
ending's last line under it, then "The King knocks out his pipe.", a fade, and the end screen (owner question 15). A
first tap quickens the roll four times, a second goes to the study, one there ends it; Esc ends it. Once the campaign
has an ending, the war table has THE CREDITS to roll them again.

## How the three rules are kept

1. SAY IT PLAINLY. Every piece shows its words on the map in the three languages: STOP-WORK and its seconds, THE MADE
   CALL, COLD, FROST and its seconds, FROZEN, MARKED; the frozen field and the warm rings are drawn; THE LEDGER is a
   card with every mark and the King's words for the band. A mission still writes its own objective line and first
   character line for each piece it uses (the engine can't know the story).
2. NO WAITING. The flight moves on its own at a set pace and the mission chooses it (a 60 px/s balloon over a short
   route is under a minute; a sim should print `longest_idle()` as Act 2's do); the stop-work and the call have an end
   the player can count down; the ledger's card and the final choice are the only things that stop the clock, and only
   because the player is reading the stakes.
3. CHECK THE FEEL. Pictures are left to the first mission that uses each piece (no map of Act 3 exists yet to show them
   on); the overlays follow Act 2's look (rings with a dark outline under the words). The stop-work, the call and the
   flight never take a person's unit off its orders except the flyer of a flight (that is its lesson).

## Claude's choices (for the owner to confirm)

1. All of Act 3's mission engine is ONE new file (MissionAct3) beside MissionAct2, its state one dictionary saved with
   the mission; the campaign-wide pieces (ledger, night, ladder, ending) live in Campaign, the credits in their own
   CampaignCredits.
2. THE COLD slows only an egg's time to hatch (not the father's fertilising, not the Mother's laying); the frost kills
   only EGGS (grown creatures on the frozen side live: the plan's "kills eggs below a line"). Default 20 s to freeze.
3. THE HEAT is a plain walking pace for the faction (0.9 proposed), everywhere on the map; the WET's extra drain is on
   every Clockwork machine (Winders too), so fields matter more, not less.
4. THE FROST LINE is a ROW (straight east to west) with a frozen north or south, and its night is a smooth day-and-night
   swing over `period` seconds (not tied to the mission's light). A mountain's outline would need the map's heights;
   a row is enough for e07's plateau edge.
5. THE STOP-WORK's ring stops a machine that walks INTO it while it rings, and stops no `spare` side's (the guild's);
   default 12 tiles, 60 s. Its count is of machines, each once.
6. THE MADE CALL turns only scripted creatures (a person's never), each once, with a plain move to its place; what they
   do there is the mission's (e20 lets the marsh keep them).
7. THE LEDGER's marks are written into campaign.json now, from the plan's table, with flag names the missions must keep
   (e16 `lisbon` held, e17 `goa_night` held, e18 `atlantic` held, e04 `kongo` stood, e07 `ethiopia` held, e03
   `virginia` some/many and `fairleigh` rode_with, e09 `stopwork` kept, e06 `ruin` opened, e12 `exiles` pardon, e15
   `forge` broken, e01 `colonists` some/many, d11 `jakob` alive (built), d10 `inacio` joined (built), e19 `deserters`
   spared and `campagna` some/many). THE COLONIES mark is false until the war clock (build step 2) writes progress
   `colonies`. The band on the card: STRONG / MIDDLING / WEAK ("MIDDLE" already meant a place in the editor's
   translations).
8. THE LEDGER's card holds a solo match until CLOSE (the stakes are read with the clock stopped), and only shows the
   marks, the count, the band and the King's words; the plan's real things (waves, ships, banners) are e20's data.
9. THE NIGHT's rank is kept as the mission was WON (a replay plays the same night); a lost try does not count.
10. THE LADDER IN ANY ORDER: Act 3's rungs were given the plan's missions in the ladder file now (the CHECKED TABLE shows
    them), so each Act 3 mission job only binds its teams.
11. THE FINAL CHOICE has no default and no timer, and holds a solo match (the only choice that does). Online the match
    goes on (the other player can't be paused by it), the choice still waits.
12. THE ENDINGS are three ids: rome_holds, rome_falls, hard_way (HOLD chosen and lost: the plan's "the hard way"); the
    mission sets one, the engine keeps it.
13. THE CREDITS: names in placeholder sections (the owner writes the real list: campaign.json "credits"), rolled at 46
    px a second over the parchment war map dimmed, then 11 s in the King's study with the pipe's smoke (the Rome hub's
    own painting and life), the ending's last line, then "The King knocks out his pipe." (placeholder). The hard way
    uses Ending 2's last line. A tap quickens and then skips; Esc ends.
14. THE CREDITS come again from the war table's THE CREDITS once the campaign has an ending (in every storyline's hub).
15. A flight's flyer is moved by the flight itself (its own orders don't count while it flies); with no flyer left the
    flight just ends unflown.

## What is left for the mission jobs and later steps

- The war map's Act 3 (build step 2): the world view, the theatres, THE CLOCK (it should write progress `colonies` for
  the ledger's last mark), the clock sim.
- Art (step 3): savanna, monsoon, mangrove, ice; the frost and the warm rings are drawn in code and may want art
  (docs/art_style_inconsistency.md lists them: the frost field's ticked edge, the warm rings).
- Each mission: its objectives' lines for the pieces it uses, its sim with `longest_idle()`, its pictures, its BOUND /
  SIDE / CARD_AT lines in roster_ladder.py, its flags with the names the ledger reads.
- THREE SEATS ONLINE (step 13). Online, as Act 2's pieces: the guest sees what the pieces do (wind gone, units turned,
  pings) but not the overlays (rings, words) and not the ledger's card; to add when a co-op Act 3 mission needs it.
- The heir as a hero unit (`heir` seen at e19) and the voyages' stills on the war map: the plan's table, not this step.

## Tests run (Godot 4.7, headless)

- tools/test_act3_engine0.gd (new): every piece above, the data checks good and bad, the campaign's ledger, night group
  and credits, every order of every line's Act 3 rungs, the save keeping the state, the credits after the last
  mission and on the war table: 0 failures.
- After the change, 0 failures each: test_campaign (its one failure was a stale check, not this job's: the Governor's
  talk after p01 was rewritten by the hubs' writing pass to "It is done...", the test still looked for "Done. See the
  men fed"; the check now reads the new line), test_campaign_a01 to a07, b01, c01, d01 to d11, heroes, ironman, m1,
  save, test_act2_engine0, test_roster_ladder (with the any-order rows), test_war_map, test_tutorial, test_i18n (PASS,
  0 of 428 data texts untranslated in pt and es).
- (Every headless Godot run here ends with "Aborted", exit 134, after its last line: the engine's shutdown on this
  machine, as Acts 1 and 2's steps noted.)
- Boot: `godot --headless --path . --quit-after 120`: no SCRIPT ERROR / Parse Error.
