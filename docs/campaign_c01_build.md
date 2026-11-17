# The Clockwork prologue, "The Thirteenth Hour": what was built (clockwork-prologue-build, 0.38.43)

The outline and the owner's answers (docs/campaign_clockwork_prologue.md) as a playable mission on the campaign engine
(docs/campaign_engine.md, its new parts in "Added by the Clockwork prologue"). It is the Clockwork storyline's first
mission (campaign/campaign.json "clockmaker"), open after the Crown's prologue. A LOSING mission: Parts 1 and 2 are won in
their own terms, Part 3 is a retreat on a clock, and the story's loss counts like a win (NUREMBERG IS LOST).

EVERY LINE OF TEXT IS A PLACEHOLDER for the owner to rewrite (kept short and plain on purpose). The stills are stand-ins.

## Files

| what | where |
| --- | --- |
| the mission | `campaign/missions/c01_thirteenth.json`, written by `tools/campaign/make_c01_mission.py` (edit the script, run it) |
| the map | `campaign/maps/nuremberg_advent.json` (`campaign:nuremberg_advent`), written by `tools/campaign/make_nuremberg_map.py`; opens in the MAP EDITOR |
| the stills (stand-ins) | `campaign/stills/c01_01.jpg` .. `c01_07.jpg`, drawn by `tools/campaign/make_c01_stills.py` |
| the sounds | `assets/audio/campaign/bell_toll.wav`, `off_beat.wav`, cut from the owner's clock recordings by `tools/campaign/make_c01_sounds.sh` |
| texts pt / es | `tools/i18n/campaign/c01_thirteenth.txt` (then `python3 tools/i18n_build.py`) |
| the engine | `scripts/campaign/mission_run.gd`, `campaign.gd`, `campaign_menu.gd`, `hub_scene.gd`, `rebels.gd` (now the campaign's roles in general), `mission_ui.gd`; two lines in `scripts/game.gd` (the roster) |
| test | `tools/test_campaign_c01.gd` (`godot --headless --fixed-fps 30 --script res://tools/test_campaign_c01.gd`) |
| balance and pictures | `tools/sim_campaign_c01.gd` (`-- active bells=rung|quiet gate=people|pattern`; `shots=<dir>` with a window: `xvfb-run`) |
| pictures | `docs/shots/campaign_c01/` (captions.md) |

## How to play it

CAMPAIGN, the tab THE CLOCKMAKER (open once the Crown's prologue is done), the BRASS MAP, the mission, START. The opening's
three stills (the King in Rome, Nuremberg in Advent, the Perpetual's heart: the King opens, Hollweg tells it), then:

- PART 1, THE PERPETUAL WAKES (a winter day, snow falling). The guild (BLUE): the Perpetual (the Clocktower, tagged
  `perpetual`), its two Cog Presses and Winders, 4 Clock Soldiers, MEISTER HOLLWEG (a Missionary stand-in, unarmed, 200
  health) and JAKOB (a Labourer stand-in); 400 cogs. The City Watch (PURPLE, scripted) at the three bridges and the west
  gate (with two Field Cannons there), its captain at the market; Father Ferrer (a Missionary, the town's). No flyers,
  Heavy Works, Pendulum, Ballista, Great Winder or Serpent for the guild (the roster). Objective: the Crown's order, 6 Clock
  Soldiers to the wagons at the market across the river: build a Light Works, train. The six are handed over to the Watch
  (they turn purple) and the Crown pays 300 cogs. THE GIFT at 4:00: the Perpetual raises 2 Winders, then a Winder and a
  Clock Soldier every 15 s three times, free (tag `children`); Jakob notices one facing the river.
- PART 2, THE MILL ISLAND (dusk; once the order is filled and the gift given, or at 9:00 whatever happened): a red seed
  (a machine Clocktower) and a press on the mill island, another seed at the old bath houses, regulators on the three
  bridges (the LINKS); a Netter for the guild. "Go with Jakob to the bank by the mill" (optional; the island found also by
  any guild unit on it, or by itself 2:30 into the part). FOUND: the reveal, the mill seed to destroy (primary), "catch one
  in a net" (optional). 8 s later THE TURN: the 8 children stutter 5 s (stunned, the stars, the off-beat tick) and go red,
  then march on the workshop. 24 s after the find THE BELLS (90 s, default KEEP IT QUIET):
  - RING THE BELLS: 11 more musketeers at the bridges; Part 3 starts with 20 townsfolk on the road and bigger, sooner groups.
  - KEEP IT QUIET: 500 cogs, 150 Tension and the Pendulum for the guild; the townsfolk come out only as the machine
    reaches their streets.
  The seeds grow (2 Clock Soldiers every 45 s at the mill, every 60 s at the baths, while they live, up to 26 machines).
  Night falls 3 s after the mill seed burns, or 7 minutes into the part.
- PART 3, THE THIRTEENTH HOUR (night): new seeds at the market and by the east gate. The objectives change on screen:
  "The city cannot be held. Save who you can. The great clock strikes thirteen in 9:00" (a countdown). Primary: Hollweg
  must live and be at the west gate at the stroke. Optional: the townsfolk out of the west gate ("13 saved of 20": they
  come out of four quarters in groups and walk to the gate by themselves; the machine HUNTS them in the streets but leaves
  them alone under the gate's guns), cut the three links (90 s more), Jakob lives, Jakob fetches the master drawings from
  the Guild House north of the river. Every seed burnt in Part 3 puts the stroke back a minute (the mill too if it still
  stands). With 5:00 left the machine sends a Pendulum. With 2:00 left Ferrer warns. With 1:15 left, if Jakob carries the
  drawings, THE GATE (50 s, default THE PATTERN): THE PEOPLE (6 more townsfolk on the last cart; the drawings burn) or
  THE PATTERN (the drawings ride out). Without the drawings the gate is THE PEOPLE.
- THE STROKE: with Hollweg at the gate the bells toll thirteen (13 strokes), the counts become flags, and 17 s later the
  mission ends: the ending's stills (Hollweg's lines by the flags, the crates for Lisbon, the King's truth) and the end
  screen: NUREMBERG IS LOST, the debrief's lines by the flags (how many reached Fürth, the bells, the links, Jakob, the
  drawings). It counts: the progress, the flags, the hub after it.
- THE REAL DEFEATS: Hollweg killed (DEFEAT, retry), or Hollweg inside the walls at the stroke.

The flags kept (`Campaign.flag("c01_thirteenth", ...)`; a later mission reads them with `{"past": {"c01_thirteenth.<flag>": value}}`):
`bells` rung / quiet, `saved` few / some / many (0-24, 25-59, 60+; the number in `saved_n`), `jakob` alive / lost,
`cut` yes / no, `gate` people / pattern, `drawings` taken (if fetched).

THE HUB AFTER THE FALL: the clockmaker hub becomes "Nuremberg, the Machine's City" (the painting without Hollweg, tinted
red; HOLLWEG'S LETTER on the bench in his place; the great clock and the automaton say new things). In the King's study
MEISTER HOLLWEG is listed (in exile in the palace) and the King has new lines.

Co-op: the friend commands the Watch (purple: the musketeers and the gate's guns). Versus: the friend is the machine (the
seeds' spawns are his units; he wins by killing Hollweg). Neither was played on two devices (as for the whole engine).

## The engine (docs/campaign_engine.md lists every key)

Items 1-13 and 15 of the outline's list (14, the war map, is later):

| the outline's need | built |
| --- | --- |
| 1 a story loss that counts | debrief `"banner"` (the end screen's title instead of VICTORY, in a loss's colour), the mission ended by `win` for the guild; `"manual_end"` so meeting the objectives never ends it early |
| 2 counters, exits, counter text, flags from a counter | `"counters"`, `counter` action and condition, `"exits"` (Game.consume_unit: gone, not a loss), `{name}` in objective and debrief words, `tally` |
| 3 a countdown | `clock` action, `clock_out` / `clock_left` conditions, objective kind `countdown`, `{clock:name}` |
| 4 convert | `convert` (by tag, or by place: the order handed over), with the warning stutter |
| 5 general campaign roles | Rebels.ROLES now holds `citizen`, `hollweg`, `jakob`, `ferrer` (and a role's `hp`); their art folders named, used once drawn |
| 6 a sound action | `sound` (and the two sounds) |
| 7 repeating triggers | `"every"`, `"times"`, `"while"` |
| 8 roster limit and unlock | team `"roster": {"deny"}`, `deny` / `unlock` actions; Game.can_train and Game.requirement_text say "Not in this mission." |
| 9 a winter look | the map in the snow biome, `winter_day` / `winter_dusk` / `winter_night` lights, `"weather": "snow"` |
| 10 the carried pattern | Jakob carries it: `name` action ("Jakob (the drawings)"), a flag, a `reach`-by-count trigger |
| 11 the machine on the Clockwork computer | NOT used: scripted growth (below) |
| 12 the Nuremberg map | the generator |
| 13 the hub after the fall | hub `"after"`, hotspot `"requires"` / `"until"`, HubScene.hidden_layers, `tint` |
| 15 if-lines in the debrief | ending page lines `{"id", "if"}` (MissionRun.pages_now), debrief `"text_if"` |

Also: the `hunt` order (`spare`: an area left alone), the `netted` condition, reach objectives by `unit_kind`, `give`
takes `tension`, a settled objective can be taken off the panel (`hidden`).

### Item 11: why the machine is scripted, not the Clockwork computer

The skirmish computer (AIClockwork) plans from a start (a hall, Winders, its economy, its timings and build orders by the
clock) and expands to map spots; a team that starts with no workers and gets Clocktowers dropped on it by triggers is not
what it was built for, and its timing would fight the story's (the seeds must unfold where and when the story says, the
spread must be capped and visible, and a seed killed must really slow it). So the machine is SCRIPTED: each seed is a
Clocktower tagged `seed_*`, and a repeating trigger per seed spawns its constructs while it lives and the machine has fewer
than its cap (26 in Part 2, 32 in Part 3), sending them at a place (the bank, a bridge, a quarter); the `hunt` order sends
the near ones after the townsfolk. The game's own rule still applies to the spawned constructs: they wind down off their
gear ground (about 80 s), so the ones lured far from the seeds run down. Trying the computer remains possible: a team's
control `ai:normal:balanced` (not measured here; Claude's choice 3).

## Balance (tools/sim_campaign_c01.gd)

BALANCE_PLACEHOLDER

## Stills: the prompts for the owner (ChatGPT, one request each, at most 3 reference images)

House style as the Crown's prologue (campaign/stills/p01_*.jpg): an oil painting in the manner of an 18th-century history
painting, warm lantern and firelight against deep night blues, visible brushwork, 3:2 landscape (cut to 1280 x 853), no
text or lettering anywhere. References: p01_05 (the style); where Hollweg appears campaign/hub/nuremberg_hollweg.png (grey
curly hair, moustache, leather apron, red-brown coat); for the King p01_01. The Crown's men in PURPLE coats; the loyal
guild's machines brass with BLUE enamel; the runaway machines brass with RED enamel. Save each as
`art/campaign/stills/c01_0N.png` and cut it to 1280 x 853 into `campaign/stills/c01_0N.jpg` (nothing else changes).

STILLS_PLACEHOLDER

## The voice lines (for the owner's Chatterbox recordings)

Recorded lines go in `campaign/voice/c01/<line id>.ogg` (or .wav / .mp3); the game plays them when present (CampaignVoice).
The King's lines in the King's voice (tools/voice_clone, refs king_ref.wav). MEISTER HOLLWEG, FATHER FERRER, JAKOB, THE
CAPTAIN OF THE WATCH and the NARRATOR ("Nuremberg") need DESIGNED voices first (a 10-20 s sample each, the owner's rule:
ElevenLabs only to design, then Chatterbox for all the lines; tools/voice_clone/refs/ has 5 designed voices: one may fit
Hollweg). "The Machine" (versus only) can stay text, or the off-beat tick.

VOICE_PLACEHOLDER

## What is placeholder

- Every line, every objective's words, the briefing and the debrief (the owner rewrites the dialogue himself).
- The stills (simple drawings, two of them made from existing paintings: the King's study, Hollweg's workshop).
- Hollweg, Jakob, Ferrer and the townsfolk are stand-ins: a Missionary (Hollweg, Ferrer: the Crown's priest in the
  guild's blue / the town's yellow), a Labourer (Jakob, the townsfolk). Their art folders are named in Rebels.ROLES
  (`c_hollweg`, `c_jakob`, `c_ferrer`, `c_citizen`): drop the strips in (as for the rebels: docs/campaign_m1_build.md).
- The bells are the clock bell pitched down; the off-beat tick is the alarm clock slowed.
- The Nuremberg map: walls of rock and ruined-wall pieces, houses of cottage and shed props; the mills on the island are
  windmills (no waterwheel prop).

## Claude's choices for the owner

1. THE MACHINE IS SCRIPTED, not the Clockwork computer (above).
2. THE STORY'S LOSS IS A WIN IN THE ENGINE: the guild "wins" when Hollweg is out at the stroke (the mission counts, the
   flags are kept), and the end screen says NUREMBERG IS LOST. The only DEFEATS: Hollweg killed, or inside the walls at
   the stroke (retry).
3. THE ORDER'S SIX ARE HANDED OVER to the Watch (they turn purple and guard the market): the guild serves the Crown, and
   those six fight beside the townsfolk in Part 3.
4. THE GIFT gives 8 children (4 Winders, 2 at once and then with 2 Clock Soldiers); all 8 turn. The player's own units never
   turn.
5. NO TIMER IN PARTS 1-2 shown to the player; Part 2 ends 7 minutes in at the latest, and the mill island is "found" by
   itself 2:30 into the part if the player never goes to look (so the story cannot stall).
6. THE COUNTDOWN is 9:00, +60 s for each seed burnt in Part 3 (the mill too if it still stands), +90 s for the three links
   cut; it can only move later, never sooner (the outline: "never cheap").
7. THE TOWNSFOLK: quiet bells, groups of 3 from four quarters every 70-90 s (about 70 in all); rung bells, 20 on the road at
   once and groups of 5 every 60-75 s (about 140). "Saved N of M" counts only those who came out (an honest number).
   The machine hunts them within 13 tiles, never under the gate's guns.
8. THE DRAWINGS are in the Guild House north of the river (not the workshop: Jakob stands there at the start, and the
   errand should cost something). Without them there is no gate choice: they burn.
9. HOLLWEG has 200 health (a Missionary has 60) and Jakob 120: heroes of the story, still killable.
10. EASY / HARD: the campaign has no difficulty setting yet; the outline's "Easy gives two more minutes" is not built.
11. THE KING'S STUDY gets Hollweg as a listed person (no layer in the painting): a painting of him in exile is for later.
12. THE WAR MAP (item 14) is not built.

## Tests run

TESTS_PLACEHOLDER
