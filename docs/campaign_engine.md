# The campaign engine (0.30.0)

The owner's brief (2026-11-03): a campaign that two friends can play together, CO-OP (same side) and VERSUS (each one
side of the same mission; the story follows who won), and SOLO against the computer. Cutscenes are STILL SHOTS with
text, not movies. Dialogue in period words ("zounds", "knave", "by my troth"). Story (owner, later the same day): the
year 2500, technology fallen back to the 17th/18th century (background only); the FIRST MISSION is a quick revolt the
Crown puts down; then the campaign splits into storylines with their own heroes (a Catholic explorer who finds the
Brood; a clockmaker horrified by his Clockwork...). Between missions a HUB per storyline (like StarCraft II's ship):
a scene with hotspots: a war table for the missions, people to talk to, rooms (an armoury, undecided). A fourth,
campaign-only faction (human tribes, design pending) must fit the format later.

This job built the ENGINE and ONE TEST MISSION. The test text is a placeholder; the real story is being written.

## Files

| what | where |
| --- | --- |
| storylines, hubs, rooms | `campaign/campaign.json` |
| missions | `campaign/missions/<id>.json` |
| mission maps (the map editor's format) | `campaign/maps/<name>.json`, map id `campaign:<name>` |
| stills, portraits (when drawn) | e.g. `campaign/stills/<id>.png` (any res:// path a still's `image` names) |
| translations of the campaign's texts | `tools/i18n/campaign/campaign.txt`, `tools/i18n/campaign/<mission>.txt` |
| translations of the pages' own words | `tools/i18n/50_campaign.txt` |
| data, progress, checks | `scripts/campaign/campaign.gd` (Campaign) |
| the running mission | `scripts/campaign/mission_run.gd` (MissionRun, `game.mission`) |
| dialogue box, objectives panel | `scripts/campaign/mission_ui.gd` (MissionUi) |
| hub, war table, briefing, end screen | `scripts/campaign/campaign_menu.gd` (CampaignMenu) |
| placeholder stills and portraits | `scripts/campaign/still_view.gd` (StillView, StillView.Portrait) |
| the test map's generator | `tools/campaign/make_ford_map.py` |
| test | `tools/test_campaign.gd` (`godot --headless --fixed-fps 30 --script res://tools/test_campaign.gd`) |
| screenshots | `tools/shot_campaign.gd` -> `docs/shots/campaign_engine/` |

`campaign/` is exported with the game (`include_filter="campaign/*"` in the Web, Android, Windows and Linux presets:
JSON files are not resources and are left out otherwise). Progress is kept in `user://campaign.json`.

## How the campaign hangs together (campaign.json)

```json
{"title": "THE CAMPAIGN",
 "storylines": [
   {"id": "prologue", "title": "Prologue: The Revolt", "about": "...", "missions": ["p01_revolt"],
    "hub": {"title": "The Crown's Camp", "still": {"caption": "..."}, "colour": 1,
      "hotspots": [
        {"id": "war_table", "kind": "war_table", "label": "WAR TABLE", "rect": [0.08, 0.30, 0.30, 0.34]},
        {"id": "captain", "kind": "talk", "label": "CAPTAIN HALE", "talk": "captain", "rect": [0.68, 0.34, 0.18, 0.42]},
        {"id": "armoury", "kind": "room", "label": "ARMOURY", "room": "armoury", "rect": [0.84, 0.08, 0.14, 0.24]}],
      "talks": {"captain": {"name": "Captain Hale", "colour": 1, "entries": [
        {"after": "", "lines": ["...", "..."]},
        {"after": "p01_revolt", "lines": ["..."]}]}}}},
   {"id": "explorer", "title": "The Explorer", "requires": "p01_revolt", "missions": [], "hub": {...}}],
 "rooms": {"armoury": {"title": "ARMOURY", "text": "..."}}}
```

- A STORYLINE is open when its `requires` mission has been finished (none: open from the start). Its first mission is
  playable when the storyline is open; the next ones when a finished mission leads to them (`next`).
- The HUB: the still fills the scene, each hotspot is a box at `rect` (fractions of the still: x, y, w, h; never
  smaller than a thumb on a phone). The same hotspots are listed beside the scene. Kinds: `war_table` (the
  storyline's missions), `talk` (a person: the talk's `entries`, the one for the latest finished mission it names is
  said), `room` (a page from `rooms`: the ARMOURY is a stub until the owner decides on upgrades between missions).
  The tabs at the top switch storylines; locked ones show what opens them.

## A mission (campaign/missions/p01_revolt.json, shortened)

```json
{"id": "p01_revolt", "title": "The Revolt at the Ford", "summary": "...",
 "map": "campaign:ford_village",
 "modes": ["solo", "coop", "versus"],
 "sides": [{"id": "crown", "name": "The Crown"}, {"id": "rebels", "name": "The Rebels"}],
 "teams": [
   {"id": "column", "side": "crown", "faction": "crown", "colour": 1, "start": "none", "camera": "camp", "gold": 150,
    "control": {"solo": "p1", "coop": "p1", "versus": "p1"}},
   {"id": "horse", "side": "crown", "faction": "crown", "colour": 3, "start": "none",
    "control": {"solo": "script", "coop": "p2", "versus": "script"}},
   {"id": "rebels", "side": "rebels", "faction": "crown", "colour": 0, "start": "standard", "hall": [14, 28],
    "hall_tag": "rebel_hall", "control": {"solo": "script", "coop": "script", "versus": "p2"}}],
 "areas": {"ford": [52, 27, 14, 10], "village": [10, 22, 26, 18]},
 "units": [{"team": "column", "kind": "dismounted", "count": 1, "at": "camp", "tag": "captain"},
           {"team": "rebels", "kind": "musketeer", "count": 4, "at": "village", "tag": "militia", "order": "hold"}],
 "buildings": [{"team": "rebels", "kind": "barracks", "at": "village"}],
 "wiped_out": {"crown": 0, "rebels": 0},
 "objectives": [
   {"id": "burn", "side": "crown", "primary": true, "kind": "destroy", "tag": "rebel_hall", "text": "Burn the rebels' Town Hall."},
   {"id": "captain", "side": "crown", "primary": true, "kind": "protect", "tag": "captain", "text": "Captain Hale must live."},
   {"id": "hold", "side": "rebels", "primary": true, "kind": "survive", "time": 480, "text": "..."}],
 "triggers": [
   {"id": "intro", "when": {"time": 1}, "do": [{"say": ["i1", "i2"]}]},
   {"id": "militia_go", "when": {"fired": "at_ford"}, "delay": 10, "do": [{"order": {"tag": "militia", "do": "attack", "to": "ford_west"}}]},
   {"id": "horse", "when": {"time": 120}, "do": [
      {"spawn": {"team": "horse", "kind": "cuirassier", "count": 4, "at": "east_road", "tag": "relief"}},
      {"order": {"tag": "relief", "do": "attack", "to": "ford_west"}}]}],
 "speakers": {"captain": {"name": "Captain Hale", "side": "crown"}},
 "lines": {"i1": {"who": "captain", "text": "Zounds, Sergeant..."}, "tip1": {"who": "sergeant", "to": "crown", "text": "..."}},
 "stills": {"muster": {"caption": "The Crown's column musters on the east bank at dawn..."}},
 "briefing": {"crown": {"still": "muster", "text": ["...", "..."]}, "rebels": {...}},
 "debrief": {"crown": {"still": "hall_burns", "title": "The revolt is crushed", "text": "..."}, "rebels": {...}},
 "next": {"crown": "", "rebels": ""}}
```

### The parts

- `map`: `campaign:<name>` (a map editor map in `campaign/maps/`) or a built-in map id. Cells are given as [x, y].
- `sides`: the story's sides (two for now: the end logic gives the win to "the other side"). Teams on one side are
  allies.
- `teams`: one per player slot, in order. `faction` (crown / brood / clockwork, or a campaign-only one, below);
  `colour` (palette index: Blue 0, Red 1, Green 2, Yellow 3, Purple 4, Orange 5, Teal 6, Pink 7); `start`:
  `standard` (the normal hall, economy building and workers, at `hall` if given) or `none` (only what the mission
  gives); `hall_tag` tags the standard hall; `gold`, `powder`; `camera`: the area the view starts on.
  `control` per mode: `p1` (you in solo, the host online), `p2` (the friend online; offline it falls back to a
  scripted team), `script` (no computer player: the triggers move it), `ai:<level>:<plan>` (the normal computer
  player, e.g. `ai:hard:balanced`, through the AI's usual interface: Main.start makes it like a skirmish's).
- `areas`: named rectangles [x, y, w, h] in cells.
- `units`, `buildings`: `team`, `kind` (Defs.UNITS / Defs.BUILDINGS keys), `count`, `at` (an area: units spread over
  its free cells, a building takes the free spot nearest its middle; or [x, y]), `tag`, `order` (`"hold"` or an order
  as below), `modes` (only in these modes).
- `wiped_out`: {side: seconds}: after that time a side with no units and no buildings left (having had some) loses.
- `objectives`: `id`, `side`, `primary` (true: decides the mission; false: optional), `text`, `hidden` (until a
  trigger shows it), `kind`:
  - `survive` (`time` in seconds: done then; the panel counts down; an `"if"` condition must also hold then, else it
    fails: the Prologue's "until dawn, with at least three barns standing"),
  - `destroy` (`tag`: done when everything with the tag is dead),
  - `protect` (`tag`: failed when everything with the tag is dead; counts as met while it holds),
  - `reach` (`area`, `count`, and `tag`, `team` or `side_units`: done when that many stand in the area),
  - `manual` (only triggers set it).
  The END: a side whose primary objective fails loses (the other side wins); a side with all its visible primaries
  met (at least one done, not only protects) wins. In versus both sides have their own objectives.
- `triggers`: `id`, `when` (a condition), `do` (actions, in order), `delay` (seconds after the condition first held),
  `modes`. Each fires once.
- `speakers`: `name`, `side` (its colour), `portrait` (a picture; none: initials). `lines`: `who`, `text`, `to` (only
  that side sees it: versus), `still` (a still shown in the dialogue box).
- `stills`: `caption`, `image` (optional picture; none: the placeholder). `briefing` and `debrief` per side.
- `next`: {winning side: mission id} or one id (the story's branch by who won; "" = not written yet / the story goes
  on in the storylines this mission opens). Without `next`: the next mission of the same storyline.
- `factions` (optional): CAMPAIGN-ONLY FACTIONS. `{"tribes": {"name": "...", "stand_in": "crown", "campaign_only": true}}`
  lets a team say `"faction": "tribes"`. Such a faction never shows in the skirmish or online lobbies (they list only
  the playable factions, Main.FACS / NetLobby.FACTIONS). Until it exists in the game (Defs.FACTIONS, to be marked
  `"campaign_only": true` and kept out of any list built from Defs.FACTIONS), the match plays its `stand_in`. Nothing of
  the tribes is built yet.

### Conditions (`when`; several keys in one dictionary must all hold)

| key | true when |
| --- | --- |
| `{"time": s}` | the match clock has reached s seconds |
| `{"dead": tag}` | everything with the tag is dead (something had it) |
| `{"hurt": tag}` | anything with the tag has lost health (or died) |
| `{"count": {"tag" or "team" or "side": X, "area": a, "at_least": n, "below": n, "buildings": true}}` | living units (horses not counted; buildings too with `buildings`) |
| `{"done": objective}`, `{"failed": objective}` | that objective's state |
| `{"fired": trigger}` | that trigger has fired |
| `{"all": [...]}`, `{"any": [...]}`, `{"not": {...}}` | combinations |

### Actions (`do`; each one `{name: value}`)

| action | what it does |
| --- | --- |
| `{"say": [line ids]}` | the lines, one after another in the dialogue box (and the match log) |
| `{"spawn": {"team", "kind", "count", "at", "tag", "order"}}` | new units (for a person's team they are simply theirs) |
| `{"order": {"tag" or "team", "do": "attack"/"move"/"hold"/"stop"/"patrol", "to": area}}` | scripted orders; never to a team a person plays |
| `{"objective": {"id", "set": "active"/"hidden"/"done"/"failed"}}` | show or settle an objective |
| `{"reveal": {"area", "side", "secs"}}` | that side sees the area for a while |
| `{"ping": {"area"}}` | a ping on the map |
| `{"camera": {"area", "side"}}` | moves that side's view |
| `{"give": {"team", "gold", "powder"}}` | resources |
| `{"win": side}`, `{"lose": side}` | ends the mission |

`Campaign.problems(mission)` checks all of it (unknown names, kinds, areas, lines, conditions, actions);
tools/test_campaign.gd runs it on every mission.

## How to write a mission

1. Draw the map in the MAP EDITOR, save it, copy `<user folder>/maps/<name>.json` to `campaign/maps/` (the mission
   refers to it as `campaign:<name>`). The map's start spots only matter for `standard` teams without a `hall`.
2. Copy a mission file, set the sides, teams (who plays them in each mode), areas, units, objectives and triggers.
3. Put the mission's id in a storyline's `missions` in `campaign/campaign.json`.
4. Translations: add a `tools/i18n/campaign/<id>.txt` with a block per text (`> English`, `pt ...`, `es ...`), run
   `python3 tools/i18n_build.py`. Every text is its own English key, so a text used twice is translated once.
5. Run `tools/test_campaign.gd` (data checks and translations), then play it from CAMPAIGN.

## In the game

- The DIALOGUE BOX (top right, under the top bar): portrait, name in the side's colour, the line; a still above it
  when the line has one. Lines follow each other by themselves (about 4.5 s, longer for long lines); NEXT and SKIP.
  Nothing is paused, alone or online (a paused solo match holds the line's timer).
- The OBJECTIVES panel (top left, under the resources): primary first as written, `(optional)` ones dimmer; ticked
  when done, crossed when failed, the time left on a survive objective. Its title folds it.
- The END screen: VICTORY / DEFEAT (versus: "<side> WIN"), the winners' still and words, the objectives as they
  ended, where the story goes (the next mission, or the storylines it opens, or "being written"), and NEXT MISSION
  (solo), PLAY AGAIN, BATTLE REPORT (the usual report), CAMPAIGN.
- Progress (`user://campaign.json`): a mission counts when your side won it, or in versus whoever won (the story
  follows the winner on both machines).
- A campaign mission is not autosaved (no CONTINUE): its trigger and objective state is not in the save format yet.

## Co-op and versus (online)

On the war table pick CO-OP or VERSUS (versus: which side you play), then OPEN AN ONLINE ROOM: a room is hosted
(NetLobby.set_campaign) and the ONLINE page shows the campaign room (the mission, who plays which side, START). The
friend joins with the code from ONLINE as usual. The host's game runs the mission (triggers, scripted orders, the
end); the guest's MissionRun only shows what the host sends ("camp" messages through NetSession: lines, objectives,
reveals, pings, camera) and learns the end from the snapshot like any online match. Lines with `to` are shown only to
that side.

What is done and checked: the room's slots and the setups for both machines (tools/test_campaign.gd checks the host's
and the guest's setup and a guest MissionRun fed the host's messages, without a network).
NOT CHECKED: a real two-machine run through the relay (the job's rule was one Godot process at a time; tools/test_online.sh
needs two). That is the first thing to try: host a CO-OP room from CAMPAIGN on one device, join from the other.

## Two Crown sides

The two Crown sides wear their team colours (the Crown column red, the rebels blue in the test mission: the coats
take the colour, docs/shots/campaign_engine/7_mission_dialogue.jpg). That reads well; no art was redrawn. Colours that
are close (red and orange, blue and teal) would be hard to tell apart: pick distant ones.

## Open

- Real online test (above). Online, a friend who leaves is replaced by the normal computer player (as in a skirmish), which may not fit a scripted mission.
- Saving a mission halfway (CONTINUE).
- The story itself, the stills and portraits (art not decided: placeholders drawn in code, docs/art_style_inconsistency.md),
  the hub scenes' art and the ARMOURY's upgrades (stub).
- The campaign-only faction (format ready, faction not built).
- More than two sides in one mission: DONE in a07 (0.38.68, below). Three persons in one match (one a side) not yet.
- Voice lines for the dialogue (text only).
- Hotspots on the hub are boxes over the placeholder; with real art they would become invisible areas with a glow.

## The TUTORIAL (0.30.0)

The TUTORIAL button's lessons run on this engine: missions with "tutorial": true and "steps" (written out by
Campaign.expand_steps), listed in campaign/tutorial.json and never in the storylines. They add conditions on what the
player did (selected, camera_moved, built, rooted, crew, did...) and the `point` action. See docs/tutorial.md.

## Added by mission 1 (campaign-m1, 0.31.0; docs/campaign_m1_build.md)

| key / action / condition | what it does |
| --- | --- |
| `"opening": [{"still", "lines": [ids]}]` | stills full screen with their lines, before the match (StillShow: tap / NEXT / SKIP) |
| `"ending": {side: [pages]}` | the same after a win of that side, before the end screen |
| `"voice": "<folder>"` | recorded lines: `campaign/voice/<folder>/<line id>.ogg` (or .wav / .mp3), played when present (CampaignVoice), in the dialogue box and the shows |
| `"light": "night"` | the scene's light at the start (night, dusk, dawn, day): a tint on the world only |
| `"expansion_spots": false` | no gold expansion marks |
| unit / spawn `"as": "<role>"` | a role from Rebels.ROLES (its own art when drawn, a name, a torch) |
| unit / spawn `"name": "..."` | a name over the unit's bar |
| `{"choice": {"id", "side", "title", "line", "options": [{"id", "label", "about", "do": [...]}], "default", "time"}}` | a choice panel for that side's player on this machine (else the default at once); the answer becomes the flag `id` and runs the option's actions; unanswered after `time` s (90): the default |
| `{"flag": {"name": value}}` | sets this mission's flags (kept in the progress when the mission is won: Campaign.flag) |
| `{"light": {"to", "secs"}}` | the light changes over secs |
| `{"build": {"team", "kind", "at", "tag"}}` | a building appears during the mission |
| `{"hurt": {"tag", "amount"}}` | damage to everything with the tag |
| `{"point": {"ui": "card", "icon": "ab_canister"}}` | the pointer frames that one button of the command card (the card when it isn't there) |
| `{"flag": {"name": value}}` (condition) | this mission's flag |
| `{"past": {"<mission>.<flag>": value}}` (condition) | a flag a finished mission left |

## Added by the Clockwork prologue (clockwork-prologue-build, 0.38.43; docs/campaign_c01_build.md)

| key / action / condition | what it does |
| --- | --- |
| `"manual_end": true` | the mission is won only by a trigger's `win` (objectives all met do not end it); a failed primary still loses |
| debrief `"banner": "NUREMBERG IS LOST"` | a STORY LOSS: the side won the mission (it counts: progress, flags, the next storylines), but the end screen shows the banner in a loss's colour instead of VICTORY |
| debrief `"text_if": [{"if": cond, "text"}]` | lines added to the debrief when their condition holds (counters filled in) |
| ending / opening page line `{"id", "if": cond}` | a line said only when its condition holds (MissionRun.pages_now); a page left with none is skipped |
| `"counters": {name: {"start", "of"}}` | mission numbers; `{"counter": {"name", "add"/"set"}}`; condition `{"counter": {"name", "at_least", "below"}}`; in any objective's or debrief's words `{name}` (and `{name.of}`) |
| `"exits": [{"area", "tag" or "team", "counter"}]` | units walking into the area leave the map (Game.consume_unit: not a loss) and are counted |
| `{"clock": {"name", "secs"}}`, `{"name", "add": s}`, `{"name", "stop": true}` | a COUNTDOWN the triggers read: `{"clock_out": name}`, `{"clock_left": {"name", "below": s}}`; `{clock:name}` in words shows m:ss |
| objective `"kind": "countdown", "clock": name` | the clock in the panel (ticked when out, crossed when out with `"fail": true`, as Paris's King's patience; never decides the end) |
| trigger `"every": s` (`"times": n`, `"while": cond`) | a REPEATING trigger: after its first firing (its `when` and `delay`), again every s seconds while `while` (else `when`) holds |
| `{"convert": {"tag" (or "area" + "from" + "kind" + "count"), "to": team, "warn": s, "as": new tag, "sound"}}` | units stutter (stunned, the stars, a sound) for the warning, then change side (colour, selection, supply) |
| team `"roster": {"deny": [kinds]}`, `{"deny"/"unlock": {"team", "kind"}}` | what a team may not build or train in this mission (Game.can_train / requirement_text: "Not in this mission.") |
| `{"sound": {"name", "area", "vol"}}` | a sound for everyone (assets/audio/<name>), sent to the friend online |
| `{"name": {"tag", "name"}}` | the name over their bars |
| `{"tally": {"flag", "counter", "bands": [[at least, value], ...]}}` | a flag from a counter (and `<flag>_n` the number) |
| `{"order": {..., "do": "hunt", "prey": tag, "within": tiles}}` | each unit goes for the nearest living unit with that tag in reach |
| condition `{"netted": {"team"}}` | one of that team's units is in a Netter's net |
| objective `"unit_kind"` (reach) | only units of that kind count |
| `"weather": "snow"`, `{"weather": "snow"/""}` | snow falling over the screen (under the HUD; not drawn headless) |
| lights `winter_day`, `winter_dusk`, `winter_night` | the cold lights |
| `"give"` takes `"tension"` | the Clockwork's Tension |
| roles (Rebels.ROLES, now the campaign's roles in general) `citizen`, `hollweg`, `jakob`, `ferrer`; a role's `"hp"` | people as stand-ins (Labourer, Missionary) until drawn; heroes harder to kill |
| hub `"after": {mission: {"title", "about", "still", "hide_layers", "tint"}}`; hotspot `"requires"` / `"until"` | the hub as the story left it (CampaignMenu.hub_now; HubScene.hidden_layers) |
| `set_objective(..., "hidden")` on a settled one | takes it off the panel (a new part of the mission) |

## Added by the Brood prologue (brood-prologue-build, 0.38.45; docs/campaign_b01_build.md)

| key / action / condition | what it does |
| --- | --- |
| `{"cage": {"tag", "on"}}` | kept in place and harmless: can't move or attack, put back if shoved (MissionRun._tick_held); an egg caged never hatches (Linnea in her pen, her clutch) |
| `{"spare": {"tag", "on"}}` | nobody targets it and nothing hurts it (Entity.spared, read by Entity.untouchable); the fire of `burn` still takes a spared building |
| `{"pin": {"tag", "on"}}` | can't move, still fights (Unit.m_pace 0: the fort's gun with no horse) |
| `{"carry": {"tag", "on", "pace"}}` | slower (pace, 0.65) and can't attack (Unit.m_unarmed: Lindqvist with the egg crate) |
| `{"pace": {"tag", "pace"}}` | its speed times pace (b01: Linnea, a Brood Mother, walks home at 2.3x; 0.38.165) |
| `{"floor": {"tag", "share"}}`, `{"heal": {"tag", "share"}}` | health never under that share of the most (Entity.hp_floor: the Sire who cannot die tonight; 0 clears it); health back up to a share |
| condition `{"hp": {"tag", "below": share}}` | one of them has less than that share of its health |
| `{"order": {..., "do": "root", "to": area}}`, `"do": "uproot"` | a Brood creature walks there and roots (a father may nest by a Mother of another side: meta `mission_root`, BroodRoot's place rule), or gets up |
| condition `{"rooted": {"tag"}}` | one of them is rooted now (the tutorial's `rooted` by kind still works) |
| `{"order": {..., "to_if": [{"if": cond, "to": area}]}}` | the first that holds picks the place, else `to` (a wave to its lure jar while the lure works, then to the pen) |
| `{"burn": {"tag", "secs"}}` | buildings alight: they burn down in about that time, flames on them |
| building `"site": true` (in `buildings` or `build`) | a building site, paid for, that the team's workers build (labourers go on to the next site by themselves) |
| objective `"kind": "build", "tag"` | done when every building with the tag stands built |
| exit `"after": trigger`, `"except": [tags]` | the exit opens once that trigger has fired; units with those tags are never taken off (they must be there at the end) |
| `{"counter": {"name", "count": query, "plus": true}}` | a counter set (or, with plus, added to) from a count (as the `count` condition's query) |
| `"weather": "rain"` | rain over the screen (not drawn headless) |
| lights `jungle_day`, `jungle_dusk`, `jungle_night`, `fire_night`, `grey_dawn` | the Amazon's lights |
| mission `"floor": [r, g, b]` | the ground pictures tinted (Game.ground.modulate: the jungle floor darkened so the green pack reads) |
| role `"scale"` (Rebels.ROLES) | the unit drawn smaller (its own copy of its data, art_scale; BroodNew's Mother picture reads `role_scale`) and a smaller body |
| roles `lindqvist`, `valadares`, `pieter`, `teles`, `joaquim`, `villager`, `benedito`, `linnea` | the Brood prologue's people (stand-ins) and Linnea (a Brood Mother's kind at 0.4) |
| hub hotspot / talk entry `"flag": {"<mission>.<flag>": value}` | shown / said only if a finished mission left that flag (CampaignMenu.flags_ok: the crate in the cellar if the eggs were saved) |
| a Brood team with no Mother | in a mission it is never beaten for it (Game._check_end leaves the end to the mission); the pack is scripted |

## Added by Act 1's engine step 0 (act1-engine0, 0.38.49; docs/act1_engine0.md)

| key / action / condition | what it does |
| --- | --- |
| unit / building / spawn / build `"if": cond` | placed only when the condition holds (at the start: `past` flags, `difficulty`, `playing`; later: anything) |
| unit / spawn `"fixed": true` | the count is never changed by the difficulty |
| mission `"difficulty": {"easy": {"clocks", "spawns"}, "hard": {...}}` | the multipliers at each CAMPAIGN DIFFICULTY (none given: easy 1.25 / 0.75, hard 0.85 / 1.25); "spawns" scales every unit entry and `spawn` of 2+ units for a team of a side no person plays (never under 1); "clocks" scales a `clock`'s `secs` when a `countdown` objective shows that clock (or the clock says `"scale": true`; `"scale": false` keeps it) |
| condition `{"difficulty": "easy"}` (or a list) | the campaign's difficulty (EASY / NORMAL / HARD, picked on the briefing, kept in user://campaign.json: Campaign.difficulty) |
| mission `"solo_sides": [side ids]` | the SOLO SIDE PICK: the briefing lets a solo player lead any of these sides (the default side first); the briefing, its objectives, its opening (`"opening": {side: pages}`) and the lines `"to"` that side follow the pick |
| team `"control": {"solo:<side>": "p1" / "script" / "ai:..."}`, `"foe": "script" / "ai:..."` | who moves the team in solo when the player picked `<side>` (Campaign.solo_control); without it: the teams of the picked side a person plays in versus are yours, the default player's teams take their `"foe"` (else `script`), the rest keep their solo control |
| condition `{"playing": side}` | a person plays a team of that side (solo: the side picked; co-op: the friends'; versus: both) |
| condition `{"stay": {"tag" / "team" / "side", "kind", "area", "count", "secs"}}` | STAY: that many have stood in the area for secs without a break |
| objective `"kind": "reach"` with `"secs"` | the same: they must stay there that long |
| condition `{"near": {"tag" / "team" / "side", "to": tag / "to_team" / "to_side", "within": tiles}}` | one of them within that many tiles of one of the others |
| condition `{"seen": {"tag", "by": side}}` | one of them is in that side's sight now |
| `{"order": {..., "do": "route", "route": [areas], "loop", "attack", "name"}}` | ROUTE: the waypoints in turn (on when half of them stand at the waypoint; stragglers sent on); condition `{"route_done": name}` (name: the order's "name", else its tag or team) |
| `{"order": {..., "do": "follow", "leader": tag, "within": tiles}}` | FOLLOW: they walk after the first living unit of the tag when it is more than `within` (3) away; they stop when it is gone. A new order ends a route or a follow |
| `{"sleep": {"tag" / "team" / "side", "name", "within": tiles, "by": side, "hurt": true, "then": order}}` | SLEEP: the units hold where they are and don't fight (a person's own too) until a unit of another side (or of `by`) comes within `within` (6; 0: never) of one of them, or one is hurt; on waking they carry out `then` |
| `{"wake": {"name" or tag / team / side}}`; conditions `{"asleep": name}`, `{"awake": name}` | wake them by a trigger; ask after them |
| mission `"mist": {"sight", "team" / "side", "weather"}`, action `{"mist": {...}}` | MIST: units' sight times `sight` (1 clears it), on that team or side only if given; a grey veil over the screen unless `"weather": false`. Weather `"mist"` alone is the veil without the sight |
| objective `"kind": "capture", "tag", "share" (0.25), "within" (3), "by" (the objective's side)` | CAPTURE: the man can't be brought under that share of his health (a floor from the start); there, with one of the capturing side within reach, he is TAKEN (caged and spared); done when all of the tag are taken, failed if they die; condition `{"captured": tag}` |

## Added by the Brood prologue flip (brood-prologue-flip, 0.38.49; docs/campaign_b01_build.md)

The Naturalist's prologue played as the Brood (the Sire's pack v a rival pack, the station a scripted third side) needed
only these; the solo side pick and the difficulty setting are another job's (act1-engine0).

| key / action | what it does |
| --- | --- |
| three sides in a mission | nothing new was needed: teams are hostile by side (Game.hostile); a side with no objectives never ends the mission; a failed primary hands the win to the FIRST other side in `sides` (MissionRun._other_side), so the side listed second is the one whose debrief a loser sees (the rival pack's) |
| team `"hall_tag"` on a Brood team | tags (and lets the triggers name) her Brood Mother, the Brood's "hall" (the Old Mother, the Rival Mother) |
| team `"ai_foe": "<team id>"` | the computer player of that team goes for that team before any other (AI._foe asks MissionRun.ai_foe): the rival pack attacks the Sire's pack, not the station |
| team `"supply_cap": n` | the team's supply never above n (Game.max_supply asks the mission): the rival computer's army kept to a size a first Brood player can meet |
| `{"nest_free": {"tag", "on"}}` | these fathers may root away from their own Mother's father range (meta `mission_root`, the rule BroodRoot.place_problem already had for a scripted root), and so may a person's ROOT ghost: the player's Sire nests by her pen; off: the range again |
| `{"order": {..., "do": "heel", "leader": tag}}` | each unit walks after the first living unit with that tag, stopping a little behind (repeat it with a trigger's `every`): Linnea at the Sire's heels, on a scripted team allied to the player (no person orders her) |

## Added by Act 1's a02_furth (a02-furth, 0.38.53; docs/campaign_a02_build.md)

The first mission that reads a prologue's flags from another mission (`if` on units and buildings, `past`) and the first
solo mirror (`solo_sides`); it needed only these:

| key / action / condition | what it does |
| --- | --- |
| condition `{"count": {..., "buildings": true, "built": true}}` | only finished buildings count (the Light Works standing, whoever's machine runs the mission) |
| `{"order": {..., "idle": true}}` | only the units with no living target take the order (a wave pushed on at the tower is never pulled off the tower or a fight) |
| `Campaign.record` keeps `"side"` | the side this player led when the mission counted (`done[<mission>]["side"]`) |
| hub `"after"` entry, hotspot or talk entry `"sides": {"<mission>": side}`, `"not_sides": {...}` | only when (not) that mission was finished on that side (CampaignMenu.sides_ok): the Clockmaker's hub is the guild's barn at Fürth after c01, and stays the Machine's City for a player who won a02 as the Machine |

## Added by Act 1's a03_plateau (a03-plateau, 0.38.55; docs/campaign_a03_build.md)

| key / action / condition | what it does |
| --- | --- |
| `{"sleep": {..., "except_kinds": [kinds]}}` | those kinds of the group stay awake (the nest's Mother, grubs and Rootmaws work on while its hunters sleep) |
| `{"sleep": {..., "keep": true}}` | while the group sleeps, every NEW unit of it (team or side) falls asleep too (a person's nest: the hatchlings sleep with the rest) |
| `{"counter": {"name", "add_counter": other}}` | another counter's number added (the party left on the mountain plus those already down) |
| `{"tally": {..., "of": counter}}` | the bands are SHARES of that counter's number (`[[0, "few"], [0.5, "some"], [1, "all"]]`), so they hold whatever the size; `<flag>_n` is still the number |
| `{"order": {..., "kind": kind or [kinds]}}` | only the units of those kinds take the order (the nest's Raptors hunt, its Spitters keep by the Mother) |
| roles `linnea_grown` (a Brood Mother's kind at 0.5, 1,400 health), `guide` (a Labourer, Nazaré's guide) | Rebels.ROLES |

## Added by THE WAR MAP v1 (war-map-v1, 0.38.56; docs/war_map_v1.md)

- campaign/warmap.json (regions, marks, pins, rules; one file for every skin) and campaign/warmap_land.json (Natural
  Earth's coasts, by tools/campaign/make_warmap_land.py); WarMapData (scripts/campaign/war_map_data.gd: `state(progress)`,
  the ledger, `problems()`), WarMap (scripts/campaign/war_map.gd: the King's parchment skin drawn in code, pan / zoom /
  pinch, seals by state), CampaignMenu.war_map (the page: views, LEDGER, LIST, the pin card with BRIEFING / CO-OP /
  VERSUS).
- A hub's war_table hotspot with `"map": "<skin>"` opens the war map instead of the list (the King's study: "parchment");
  every war table has a WAR MAP button. A rule's conditions: done, not_done, won_by, flag, flag_at_least, any.
- A new mission needs a pin (tools/test_war_map.gd fails on a mission in campaign.json with no pin) and its rules name
  only flags it really sets (checked against its JSON).

## Added by Act 1's a01_presses (a01-presses, 0.38.57; docs/campaign_a01_build.md, docs/city_generator.md)

| key / action / condition | what it does |
| --- | --- |
| building / build `"disguise": {"as": team, "within": tiles, "by": side, "secs": s}` | a DISGUISED building: to every other side it wears team `as`'s colour (the map, the minimap, its card, the fog's memory) and nobody targets or hurts it (spared), until a unit of a side hostile to it (of `by`, if given) stands within `within` tiles (3) of its edge for `secs` seconds (0: at once): then it is UNMASKED (its own colour, open to attack, a ping). MissionRun.disguise / unmask, Entity.cloth_colour / refresh_cloth |
| `{"unmask": {"tag", "first"}}` | the story gives them away (`first`: only the first still disguised) |
| conditions `{"unmasked": tag}`, `{"disguised": tag}` | one with the tag has been unmasked (dead or alive); one still stands disguised |
| unit / building / spawn / build `"tags": [tags]` | more tags than `tag` (a press is "presses" and "press_3") |
| building / build `"name"` | the name kept on the building (meta `mission_name`) |
| spawn `"near": tag` | round the first living thing with that tag (its footprint and two cells round; `at` if there is none) |
| `{"ping": {"tag"}}` | a ping at the first living thing with the tag |
| choice `"default": "random"` | the match's seed picks an option (the same on every machine and replay) when nobody answers |
| `{"counter": {..., "min", "max"}}` | the counter kept between them |
| `{"order": {..., "only_team": team}}` | of a tag, only those still on that team (the weavers who went home, not those who turned) |
| roles `tomasz`, `delorme`, `runner`, `printer`, `weaver` | Rebels.ROLES (stand-ins: a Missionary, an Officer, Labourers) |
| THE CITY GENERATOR | tools/campaign/city_gen.py: a town as a map editor map from a seed (docs/city_generator.md) |
## Added by the roster ladder (roster-ladder, 0.38.57; docs/campaign_roster_ladder.md)

Each mission brings the line's player one or two new pieces (the owner, 2026-11-18); the data is in
tools/campaign/roster_ladder.py, which the mission generators call (`roster_ladder.apply(M, "<id>")`).

| key / action | what it does |
| --- | --- |
| team `"roster": {"allow": [pieces]}` | an ALLOW-LIST: everything of the team's faction (Campaign.roster_items: its units, buildings, researches, and the Brood's growth stages `stage2` / `stage3`) not on it is "Not in this mission." (Campaign.roster_denied; the old `deny` still adds to it: the story's refusals on top of the ladder) |
| team `"roster": {"new": [pieces]}` | the mission's NEW pieces (on the allow-list; the doc's CHECKED TABLE and tools/test_roster_ladder.gd read them); the generator adds the NEW cards: speaker `new` ("NEW"), a line per piece `to` the ladder side, said by the trigger `ladder_new` a few seconds in |
| the refusal reaches | Game.requirement_text (buildings), Game.can_train (units), Game.research_problem (Crown / Clockwork research), BroodResearch.problem, BroodRoot.morph_problem (a grub's BUILD), BroodNew.lay_problem (the Mother's eggs), BroodMature.problem (MATURE: the mature form's kind), BroodNew.grow_problem (GROW: `stage2`, `stage3`) |
| `{"unlock"/"deny": {"team", "kind"}}` | unchanged, and now also takes researches and stages; Campaign.problems checks every roster name and every unlock / deny kind (Campaign.roster_known) |

Not gated: MOUNT (a man getting on a horse is not a training) and anything a mission hands over (units, buildings).

## Added by Act 1's a06_barricades (a06-barricades, 0.38.59; docs/campaign_a06_build.md)

Nothing in the engine: Paris is the city generator's (tools/campaign/make_paris_map.py) and the mission is built from
the keys above (spare, capture, a choice with a default, stay, follow, a countdown, repeating triggers, build, `if` by
`past` flags). New roles in Rebels.ROLES: `fairleigh`, `ruggieri`, `volunteer`, `lyon_man`, `varenne_hall` (Varenne
with 260 health in his hall; his p01 role is unchanged). A way the mission does a thing the engine has no key for: a
building spared from every blow but one (Notre-Dame burns only at the torch-bearers' hands) is a repeating trigger that
lifts the spare, hurts it, and puts the spare back in the same round.

## Added by Act 1's a04_visit (a04-visit, 0.38.63; docs/campaign_a04_build.md)

| key / action | what it does |
| --- | --- |
| `{"wind": {"tag", "share"}}` | Clockwork units with the tag wound up to that share at least (Unit.wind): run down to nothing a construct stands still, so a scripted team with no ground of its own (the works' broken automata) is wound before it marches, and a scripted guild's Pendulum kept wound on its post |

Everything else in Father Ferrer's Visit is built from the keys above (stay, follow, route and `route_done`, near,
`convert`, `exits` with `after`, counters, `tally`, countdown clocks, a choice with a default, cage, spare, `if` by `past`
and `difficulty`, trigger `modes`). New roles in Rebels.ROLES: `ferrer_visit` (Ferrer with 300 health), `lay_brother`.
A `tally` whose bands are the numbers themselves (`[[0, 0], [1, 1], ...]`) leaves a numeric flag the war map's
`flag_at_least` can read (`lost_to_machine`).


## Added by Act 1's a05_specimens (a05-specimens, 0.38.64; docs/campaign_a05_build.md)

| key / action / condition | what it does |
| --- | --- |
| `{"cart": {"tag", "cart", "caged", "freed", "freed_tag"}}` | CAGE CARTS: each creature of the tag not yet on a cart is caged on the nearest free cart of the cart tag (one a cart): carried with it every frame (MissionRun._carry_cages), can't move or fight, spared, shoving nobody (its mass near nothing), the cage's bars drawn round it (MissionRun.CageBars); `caged` counts it. The cart broken (dead): the creature is FREED (on its feet, open to attack; `freed` counts it, `freed_tag` tags it) |
| condition `{"cargo": {"tag", "at_least" / "below"}}` | living carts of the tag with a cage on them (MissionRun.cargo_count) |
| exit `"cargo": true`, `"max"`, `"cargo_counter"` | only carts with a cage leave by it, the cage with them; `max` (a number or a counter's name: the canoes' room) how many may leave by it in all, with `counter` counting them |
| `{"remove": {"tag", "empty"}}` | taken off the map, not killed (the eggs lifted into Lindqvist's crate); `empty`: only those with no cage on them (the carts that caught nothing) |
| `{"sleep": {..., "except_tags": [tags]}}` | those sleep apart: not in this group (the young in the ferns never wake the nest) |
| `{"spare": {"tag", "on": false}}` on a carted creature | it stays untouchable until its cart breaks |
| mission `"mend_allies": true` | workers may repair an ally's machines and buildings (Game.mends: the right-click and Unit._repair): the porters mend the convoy's cage carts |
| role `cage_cart` (`"cart": true`) | a Powder Wagon with meta `cage_cart`: it never blows up |
| roles `porter`, `hired_gun`, `young_sire` | Rebels.ROLES (stand-ins: a Labourer, a Musketeer, a Tyrant Sire at 0.55) |

MATURE refuses a caged creature (BroodMature.problem: "It is caged.").

## Added by Act 1's a07_council (a07-council, 0.38.68; docs/campaign_a07_build.md)

| key / action / condition | what it does |
| --- | --- |
| MORE THAN TWO SIDES | a side whose primary fails, that is wiped out, or `lose` is OUT (MissionRun.side_lost, `out_sides`). Two sides: the other wins at once (as before). More: the winner is a side still in with a primary DONE; else the only side still in with primary objectives; a PERSON's side out: the other person's side (versus) or, nobody else playing, the first side still in; a SCRIPTED side out: nobody yet, the match goes on. Teams are hostile by side (the creatures and the automata fight each other) |
| condition `{"out": side}` | that side has lost (the match may go on without it) |
| `{"burn": {"tag", "secs", "spread": {"tag", "within", "every"}, "douse_side", "douse_teams", "douse_secs", "first"}}` | THE SPREADING FIRE: a burning building lights the nearest building of the spread tag within `within` tiles (6) every `every` s (12), the new fire spreading the same way; units of the dousing side (the building's own if not given; only `douse_teams` if given) within 2 tiles of its edge put it out in `douse_secs` (8) of one man's work, stop its spread and halve its burning meanwhile; `first`: only the first building of the tag |
| `{"douse": {"tag"}}`, condition `{"burning": {"tag", "at_least" / "below"}}`, MissionRun.fires_out | fires out; buildings of the tag on fire now; fires put out so far |
| `"weather": "rain"` and fires | the rain works as one man at every fire and no fire spreads in it |
| mission `"torch_fire": {<burn keys>, "tag"}` | a torch-bearer (role `torch`) at a building of that tag sets it ALIGHT (a spreading fire), spared or not, and walks on to the next not burning (Rebels.tick) |
| `{"show": {"pages": [{"still", "lines"}]}}` | a MID-MATCH SHOW: the pages (`if` lines kept) full screen over the match (StillShow); a solo match pauses while it plays (online it does not); sent to the friend; MissionRun.shows |
| mission `"versus_pick": [sides]` | THE VERSUS PICK: in versus the friend's seat (p2) leads ONE of these sides, the other p2 teams scripted (Campaign.control_of / seat_side / make_cfg take the pick; the cfg's campaign keeps `"pick"`; the war table's YOU PLAY row and NetLobby.set_campaign carry it) |
| mission `"needs": [missions]` | a CROSSING: unlocked only once every one of them is finished, whichever led to it (Campaign.unlocked); a mission in several storylines is listed once (Campaign.mission_ids) |
| mission `"auto_tags": [{"team", "kind", "tag"}]` | every unit of that team and kind (one a person trains too) gets the tag |
| roles `king_young`, `swiss`, `captain_rome`, `roman`, `roman_mob` | Rebels.ROLES (stand-ins) |
