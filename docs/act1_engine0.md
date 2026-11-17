# Act 1's engine step 0 (job act1-engine0, 0.38.49)

The first step of Act 1's build order (docs/campaign_act1_plan.md, "Proposed BUILD ORDER" 1, and the owner's answers of
2026-11-17 22:04). It adds to the mission engine the small things the seven Act 1 missions need before any of them is
built, and the CAMPAIGN DIFFICULTY the owner said yes to (question 10). No mission of Act 1 is built here; the three
prologues only got their difficulty values. The table of keys is in docs/campaign_engine.md, "Added by Act 1's engine
step 0"; this page says what each one is for and how a mission uses it.

Code: scripts/campaign/campaign.gd (Campaign: the side pick, the difficulty, the data checks),
scripts/campaign/mission_run.gd (MissionRun: everything that runs in the match), scripts/campaign/campaign_menu.gd
(the briefing's two new rows), scripts/unit.gd (one line: a unit's sight asks the mission about the mist). Texts:
tools/i18n/75_act1_engine0.txt. Test: tools/test_campaign.gd ("engine0:" checks, on a copy of the test mission that is
never written to a file).

## What a mission can now say

### Units and buildings that depend on something: `"if"`

Any entry in `units` or `buildings`, and any `spawn` or `build` action, may carry `"if": <condition>`. It is placed only
when the condition holds. At the start that means a flag a mission before left (`{"past": {"c01_thirteenth.jakob":
"saved"}}`: Jakob is at Fürth only if he got out of Nuremberg), the difficulty (`{"difficulty": "easy"}`: two more
guns on EASY) or the side being played (`{"playing": "nest"}`). This is how Act 1 carries the prologues' choices into
the starting forces.

### The CAMPAIGN DIFFICULTY

EASY / NORMAL / HARD, picked on the BRIEFING (a row under the objectives) and kept in the progress file
(user://campaign.json), so it stays for the next mission. Online the host's setting counts (the host runs the mission).

A mission uses it in three ways:

- Conditions: `{"difficulty": "easy"}` or `{"difficulty": ["easy", "normal"]}` in any trigger, unit, line or debrief.
- The COUNTDOWNS the player races: a `clock` started with `secs` is multiplied by the difficulty's `clocks` when a
  `countdown` objective shows that clock (the canoes leaving, the city striking thirteen). The mission's own timers
  (how long a part lasts) are not, unless the clock says `"scale": true`.
- The FOE's numbers: every `units` entry and `spawn` of 2 or more units for a team of a side NO PERSON PLAYS is
  multiplied by the difficulty's `spawns` (rounded, never under 1). The player's own side, its scripted allies, single
  heroes and entries marked `"fixed": true` are never changed. In versus nothing is scaled (both sides are played).

The multipliers are the mission's own `"difficulty": {"easy": {"clocks": 1.25, "spawns": 0.75}, "hard": {...}}`, or
the defaults (EASY 1.25 / 0.75, HARD 0.85 / 1.25) for what it doesn't say. NORMAL is always the mission as written.

The three prologues: p01_leaf EASY 0.75 of the rebels, HARD 1.2 (it has no countdown); c01_thirteenth and b01_specimen
EASY the countdown 25% longer (Part 3's 9:00 becomes 11:15, the canoes' 8:40 becomes 10:50) and 0.75 of the foe, HARD
the countdown 10% shorter and 1.2 of the foe. For b01 only the `difficulty` key was added (in the JSON and in
tools/campaign/make_b01_mission.py), so the brood-prologue-flip job's rebuild merges easily; its new teams get the same
rule by side.

### The SOLO SIDE PICK

`"solo_sides": ["guild", "machine"]` lets a solo player lead either side: the briefing shows YOU PLAY: with a button per
side, and the briefing's text, still and objectives follow the pick. In the match:

- The seats: by default the teams of the picked side that a person plays in VERSUS become yours, the teams the player
  has by default become the mission's foe (`"foe"` in their `control`, else `script`), every other team keeps its solo
  control. A team can say it outright: `"control": {"solo": "p1", "solo:machine": "ai:hard:balanced", ...}`.
- The OPENING may be per side (`"opening": {"guild": [...], "machine": [...]}`), lines with `"to": side` are shown only
  to that side's player (as in versus), objectives are by side (as before), and the ENDING is the winning side's.
- `{"playing": side}` tells the triggers which side a person leads, so scripted orders and narrator lines can be for
  the side nobody plays (the Machine has no voice: its player gets objectives and sounds only).

### STAY

`{"stay": {"tag": "tomasz", "area": "square", "secs": 20}}`: that many (`count`, 1) of a tag, team or side (and a
`kind`) have stood in the area for `secs` without a break: Tomasz speaking to the crowd in Lyon's square, the
inspection in Ferrer's workshops. A `reach` objective with `"secs"` is the same in the objectives panel.

### NEAR and SEEN

`{"near": {"tag": "party", "to_side": "nest", "within": 6}}`: one of them within that many tiles of the others.
`{"seen": {"tag": "winder", "by": "guild"}}`: the walker is in the guild's sight now (a04's night shift: shadow it but
keep it in view).

### ROUTE and FOLLOW (scripted units)

`{"order": {"tag": "party", "do": "route", "route": ["stair", "split", "top"], "name": "climb"}}`: the waypoints in
turn; the group moves on when half of it stands at the waypoint and the stragglers are sent on every few seconds;
`{"route_done": "climb"}` once the last is reached. `"loop": true` walks it again and again (a patrol); `"attack": true`
attack-moves. a03's party when the player is the nest, a05's carts down the trail.

`{"order": {"tag": "guard", "do": "follow", "leader": "winder", "within": 3}}`: they keep within 3 tiles of the leader
and stop when it is gone. Any new order ends a route or a follow.

### SLEEP and WAKE

`{"sleep": {"team": "nest", "name": "nest", "within": 6, "then": {"do": "attack", "to": "camp"}}}`: the units hold where
they are and don't fight, a person's own too (the nest asleep while the party climbs), until a unit of another side
(or of `"by"`) comes within `within` tiles of any of them, or one of them is hurt; then the whole group wakes and
carries out `then`. `{"wake": {"name": "nest"}}` wakes them by a trigger; `{"asleep": "nest"}` and `{"awake": "nest"}`
ask after them. `"within": 0`: only a wound or a trigger wakes them.

### MIST

`"mist": {"sight": 0.5}` on the mission, or `{"mist": {"sight": 0.5, "side": "party"}}` as an action: units' sight is
multiplied (never under 2 tiles), for everyone or one team or side; a grey veil drifts over the screen (not drawn on a
headless machine). `{"mist": {"sight": 1}}` clears it. `"weather": false` changes the sight without the veil;
`{"weather": "mist"}` is the veil without the sight. The Lost Plateau's climb.

### CAPTURE

`{"id": "varenne", "side": "crown", "kind": "capture", "tag": "varenne", "share": 0.25, "within": 3}`: Varenne can't be
brought under a quarter of his health; beaten down to it with a Crown unit within 3 tiles, he is TAKEN (held where he
stands and spared: nothing hurts him any more); the objective is done when everyone with the tag is taken, failed if
they die (only possible once a `floor` action has set his floor to 0). `{"captured": "varenne"}` for the triggers. The floor
is set as soon as the man is placed, before the objective is shown. a01's printer and a06's Varenne.

## Claude's choices (for the owner to confirm)

1. The difficulty is ONE setting for the whole campaign (kept between missions), picked on each briefing; not per
   mission. Online, the host's.
2. Only the countdown the player RACES is scaled by default (the one shown in the objectives); a mission's own part
   timers (c01's dusk, b01's eve) and SURVIVE objectives are not, so a part doesn't drag on or end early.
3. EASY / HARD change only the numbers of the side nobody plays and the raced clock, never the player's own forces, the
   computer's level (a team's `ai:<level>` stays as written) or the heroes (a single unit stays one).
4. The prologues' HARD is milder than the default (countdown x0.9, foe x1.2 instead of x0.85 / x1.25): they are tuned
   for a careful player already and are the first missions anyone plays.
5. The side pick's default seating follows VERSUS (who sits where when two friends play), so a mirrored mission needs
   no extra data unless the other side must be the normal computer (`"solo:<side>": "ai:..."`).
6. Sleeping units can't move or fight even when they are the player's; the WHOLE group wakes at once (one foe near
   one of them, or one of them hurt). There is no "Zz" over them yet (art).
7. A ROUTE moves on when HALF its living units reach the waypoint (a column strung out on a cliff path would otherwise
   wait for its last man); the rest are sent on every 4 seconds.
8. FOLLOW looks once a second and walks (never attack-moves) after the leader.
9. The MIST shortens the sight of UNITS, not buildings (a tower's lookout in the mist is still a tower), never under 2
   tiles.
10. A man CAPTURED stays on his own team (held and spared, not converted); the mission decides what then (a trigger
    on `captured`). Default: a quarter of his health, a captor within 3 tiles.
11. STAY counts while the trigger that asks it is waiting (each check, four a second); a pause in the asking starts it
    again. In practice the same as "stood there for n seconds".
12. SEEN reads the fog grid (updated several times a second), so it is the side's real sight, mist included.

## Tests run (0.38.49, Godot 4.7, headless)

- tools/test_campaign.gd: every mission's data, the translations, the old checks, and the new "engine0:" checks (the
  data checks catch bad new keys; the side pick's seats; the difficulty kept and carried; the prologues' values;
  "if" units; the foe scaled on EASY and the player's side not; a spawned wave scaled; the raced countdown longer and a
  plain timer not; the difficulty and playing conditions; STAY after 5 s and not 4; NEAR; SLEEP holds and WAKE by a
  foe near and by a wound, with its order; ROUTE on to each waypoint and done; FOLLOW; CAPTURE floor, taken, done; MIST
  halves the foe's sight and the unit's own sight follows, cleared again; solo as the rebels: your team, the Crown
  scaled as the foe, the rebels' objectives and lines; the briefing's side and difficulty buttons).
- tools/test_campaign_m1.gd, tools/test_campaign_c01.gd, tools/test_campaign_b01.gd, tools/test_tutorial.gd: as before.
- Boot: `godot --headless --quit-after 300`, no SCRIPT ERROR.

Results: test_campaign 0 failures (120 checks), test_campaign_m1 0, test_campaign_c01 0, test_campaign_b01 0,
test_tutorial 0; the boot prints no SCRIPT ERROR. (On this cloud machine every headless Godot run ends with "Aborted",
exit 134, AFTER its last line: main 0.38.48 does the same, it is the engine's shutdown here, not a test.)

Test note: the "engine0:" checks tick a unit by hand for the mist (`_tick_unit`): right after a match starts its 3-2-1
holds the tree paused, so awaiting physics frames there does nothing.
