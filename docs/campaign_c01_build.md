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
| pictures | `docs/shots/campaign_c01/` (captions.md); the shows by `tools/shot_campaign_c01.gd` (xvfb) |

## How to play it

CAMPAIGN, the tab THE CLOCKMAKER (open once the Crown's prologue is done), the BRASS MAP, the mission, START. The opening's
three stills (the King in Rome, Nuremberg in Advent, the Perpetual's heart: the King opens, Hollweg tells it), then:

- PART 1, THE PERPETUAL WAKES (a winter day, snow falling). The guild (BLUE): the Perpetual (the Clocktower, tagged
  `perpetual`), its two Cog Presses and Winders, 4 Clock Soldiers, MEISTER HOLLWEG (a Missionary stand-in, unarmed, 260
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
  stands). With 5:00 left the machine sends a Pendulum. With 1:40 left four riders from Fürth come to hold the gate. With
  2:00 left Ferrer warns; whenever Hollweg is hurt Jakob says so. With 1:15 left, if Jakob carries the
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

`godot --headless --fixed-fps 30 --script res://tools/sim_campaign_c01.gd -- active bells=quiet|rung gate=...` (a simple
bot: a Light Works, two Regulators and a second Light Works, Clock Soldiers while it has cogs; six to the wagons; Jakob and
the army to the mill bank, then the mill seed; in Part 3 Hollweg straight to the gate, Jakob to the Guild House and back,
the army on the west road going for the nearest machine, half of it to Hollweg when he is hurt). Without `active` the
player does nothing.

| run (0.38.43 rules unless said) | Part 1 (order) | Part 2 (mill seed) | Part 3 | end |
| --- | --- | --- | --- | --- |
| active, quiet | filled ~5:00 | burnt ~1:30 into the part | 57 saved of ~73 | out: saved "some", gate pattern |
| active, quiet | filled ~5:00 | burnt ~1:30 in | 54 of ~70 | out: "some" |
| active, rung, people | filled ~5:00 | burnt ~1:30 in | 134 of ~146 | out: "many" |
| active, quiet (filmed, before the riders and Hollweg's 260 health) | filled | burnt | 49 of 63 by 1:43 left | Hollweg killed at the gate a minute before the stroke |
| active, rung (before the gate guns, the spare rule and 260 health) | filled | burnt | 93 of 115 | Hollweg killed at the gate |
| passive | never (Part 2 at 9:00) | the island found by itself 2:30 in; the seed stands | townsfolk walk out by themselves (most of them: the bot's numbers say the people's count rewards escorting little) | Hollweg trapped at the workshop at the stroke: LOST |

Reading: Parts 1 and 2 are won by anyone who plays them (the order needs a Light Works and two more soldiers; the mill
seed falls to a dozen Clock Soldiers). Part 3 is a fair retreat: a player who brings Hollweg to the gate gets out; the
danger is the machine piling up near the gate in the last minutes (two runs lost Hollweg there before the gate got its
guns, the hunt's spare rule, the riders from Fürth at 1:40 left and Hollweg's 260 health; Jakob warns when he is hurt).
The bells decide most of the count (rung: about twice as many townsfolk); escorting adds less than hoped, because the
townsfolk walk out by themselves and the machine hunts only within 13 tiles: if the owner wants the people's count to
depend more on play, raise the hunt's reach or the raids (Claude's choice 7). Speed: the bot's army is ~25-30 constructs
by Part 3 (it never spends its last ~2,000 cogs); a human army will be smaller and the parts longer.

## Stills: the prompts for the owner (ChatGPT, one request each, at most 3 reference images)

House style as the Crown's prologue (campaign/stills/p01_*.jpg): an oil painting in the manner of an 18th-century history
painting, warm lantern and firelight against deep night blues, visible brushwork, 3:2 landscape (cut to 1280 x 853), no
text or lettering anywhere. References: p01_05 (the style); where Hollweg appears campaign/hub/nuremberg_hollweg.png (grey
curly hair, moustache, leather apron, red-brown coat); for the King p01_01. The Crown's men in PURPLE coats; the loyal
guild's machines brass with BLUE enamel; the runaway machines brass with RED enamel. Save each as
`art/campaign/stills/c01_0N.png` and cut it to 1280 x 853 into `campaign/stills/c01_0N.jpg` (nothing else changes).

- c01 THE KING LISTENS (the frame: Hollweg tells it himself, owner answer 2). "Oil painting, 18th-century history painting style. Night, a study in Rome by candlelight:
  an old King in a purple robe sits by a desk with a parchment map, a pipe in his hand, listening. Across the desk an old
  clockmaker with grey curly hair and a moustache, in a plain dark travelling coat, speaks with his empty hands open.
  Warm candlelight, deep shadows, the dome of Saint Peter's faint through the window. 3:2 landscape, no text."
  (Reference p01_01 for the King and the room.)
- c02 NUREMBERG IN ADVENT. "Oil painting, 18th-century history painting style. A walled German city at dusk in Advent:
  snow on steep red roofs and half-timbered houses, a castle on a rock above, a Gothic church front on a market square
  full of lit Christmas market stalls, townsfolk in 18th-century winter clothes. Among them small brass clockwork
  labourers with blue enamel plates carry baskets and lanterns, harmless and admired. A frozen river with waterwheels
  in the foreground. Warm lantern light against a deep blue sky. 3:2 landscape, no text."
- c03 THE HEART OF THE PERPETUAL. "Oil painting, 18th-century history painting style. Night in a clockmaker's workshop
  full of brass instruments: an old master clockmaker (grey curly hair, moustache, leather apron, red-brown coat) holds
  up a perfect brass escapement wheel the size of a plate, lit by a lantern, his face proud and tender. Behind him in
  the doorway a Jesuit priest in a black cassock watches, unsmiling. A young apprentice holds the lantern. 3:2
  landscape, no text."
- c04 THE PERPETUAL WAKES. "Oil painting, 18th-century history painting style. A snowy guild courtyard at noon: a tall
  brass clock tower machine with blue enamel plates and great turning gears at its base, small brass worker machines
  climbing out of a hatch at its foot, one after another. The old clockmaker raises his hands in triumph, guildsmen
  cheer, a priest in black stands apart. Cold daylight, gleaming brass. 3:2 landscape, no text."
- c05 THE MILL ISLAND. "Oil painting, 18th-century history painting style. Night under a stone bridge on a river:
  waterwheels and a mill overgrown by a sprawling network of brass gears with RED enamel, meshed across the stones,
  turning; red-plated clockwork machines working in the dark, more half built on the gears. A young apprentice with a
  lantern has just found it, horrified; behind him two clockwork soldiers with BLUE plates. Cold moonlight and the
  lantern's warm glow. 3:2 landscape, no text."
- c06 THE THIRTEENTH HOUR. "Oil painting, 18th-century history painting style. Midnight: a Gothic church's ornate
  mechanical clock above a snowy market square, its bell ringing, red-enamelled clockwork machines crawling up the
  house fronts and over the market stalls, fires in the streets. In the foreground the old clockmaker in a cloak, seen
  from behind at a city gate, looks back; townsfolk and purple-coated soldiers hurry past him out of the gate. A cart
  in the snow. 3:2 landscape, no text."
- (optional c07 THE CRATES) "Oil painting, 18th-century history painting style. A grey river port at dawn: wooden
  crates stamped with a gear seal loaded onto a sailing ship; through a split plank of one crate a faint red glow and
  the edge of a brass gear. Dockers in 18th-century clothes, gulls, cold light. 3:2 landscape, no text." (Avoid any
  readable words on the crates.)

Files: c01 -> c01_01, c02 -> c01_02, c03 -> c01_03, c04 -> c01_04, c05 -> c01_05, c06 -> c01_06, the optional c07 (the crates) -> c01_07 (used: the ending's second page).

## The voice lines (for the owner's Chatterbox recordings)

Recorded lines go in `campaign/voice/c01/<line id>.ogg` (or .wav / .mp3); the game plays them when present (CampaignVoice).
The King's lines in the King's voice (tools/voice_clone, refs king_ref.wav). MEISTER HOLLWEG, FATHER FERRER, JAKOB, THE
CAPTAIN OF THE WATCH and the NARRATOR ("Nuremberg") need DESIGNED voices first (a 10-20 s sample each, the owner's rule:
ElevenLabs only to design, then Chatterbox for all the lines; tools/voice_clone/refs/ has 5 designed voices: one may fit
Hollweg). "The Machine" (versus only) can stay text, or the off-beat tick.

| file (campaign/voice/c01/) | voice | when | line |
| --- | --- | --- | --- |
| k_open1.ogg | The King | opening | The clockmaker came to Rome in the winter of that year, with nothing but his coat. He lives in this palace still. |
| k_open2.ogg | The King | opening | Tell him, Meister. Tell him what you told me. |
| h_open1.ogg | Meister Hollweg | opening | Nuremberg in Advent. Snow on the roofs, the market lit, every clock in the city agreeing to the second. I thought we had made it so. |
| h_open2.ogg | Meister Hollweg | opening | Forty years I made clocks that stopped. This one would not stop. It would wind itself, mend itself, and make its own successor. |
| f_open.ogg | Father Ferrer | opening | And when will it know its work is done, Meister? |
| h_open3.ogg | Meister Hollweg | opening | I did not answer him. I did not think the question was a real one. |
| h_1.ogg | Meister Hollweg | intro | The Crown's wagons wait at the market. Six soldiers, wound and true. |
| f_1.ogg | Father Ferrer | intro | Your soldiers, Meister, or the Crown's? |
| tip_1.ogg | Meister Hollweg | intro | Build a Light Works by the Perpetual and train Clock Soldiers. Winders build and wind. |
| m_intro.ogg | The Machine | intro_m | Tick. Tock. Tick. Grow, spread, and stop the clockmaker at the gate. |
| tip_2.ogg | Jakob | tip_build | Every building must mesh with the Perpetual's gears, Meister, or it stops. |
| cap_1.ogg | Captain of the Watch | order_done | Six. The Crown thanks the Guild. They are ours now. |
| h_2.ogg | Meister Hollweg | order_done | Today I will show the city something better than soldiers. |
| h_gift.ogg | Meister Hollweg | gift | There. It needs no hand but its own. |
| f_gift.ogg | Father Ferrer | gift | It is beautiful. That is what frightens me. |
| j_odd.ogg | Jakob | odd_1 | Meister, the new Winders keep turning to face the river. |
| j_mill.ogg | Jakob | dusk | Meister, there is a press turning on the mill island. We never built a press there. |
| h_mill.ogg | Meister Hollweg | dusk | Go and look. Take a Netter with you. |
| tip_net.ogg | Jakob | dusk | A Netter's net holds a machine still. Bring Jakob to the bank by the mill. |
| j_found.ogg | Jakob | found | It is a whole works. Meshed, wound, and making more. |
| h_found.ogg | Meister Hollweg | found | Those are my gears. In red. |
| f_found.ogg | Father Ferrer | found | There is another at the bath houses. It did not start today. |
| h_turn.ogg | Meister Hollweg | turn | Stop. Stop! They are out of step. |
| f_turn.ogg | Father Ferrer | turned_go | They were never yours, Meister. They were its. |
| cap_net.ogg | Captain of the Watch | caught | One of yours, Meister, in red paint. Or is it? |
| h_net.ogg | Meister Hollweg | caught | No paint. It made itself that colour. |
| f_bells.ogg | Father Ferrer | bells | Ring the bells, Meister. Let the city wake and go. |
| h_bells.ogg | Meister Hollweg | bells | If the city wakes, the guild is finished. Give me one hour and I will put it right. |
| f_rung.ogg | Father Ferrer | bells / rung | Ring them. Every church. Now. |
| h_quiet.ogg | Meister Hollweg | bells / quiet | One hour. Roll out the Pendulum. |
| h_mill_down.ogg | Meister Hollweg | mill_burnt | The island is clear. We have it. |
| j_mill_down.ogg | Jakob | mill_burnt | Meister, the bath houses are still turning. |
| j_night.ogg | Jakob | night | Lights at the market. And at the east gate. |
| h_night.ogg | Meister Hollweg | night | They are building faster than we can burn. |
| h_lost.ogg | Meister Hollweg | lost | It cannot be stopped tonight. Save what you can. |
| f_lost.ogg | Father Ferrer | lost | Get the people to the west gate. The Crown's camp is at Fürth. |
| tip_3.ogg | Jakob | lost | Townsfolk come out as the machine reaches their streets. Walk them to the west gate. |
| h_mill_late.ogg | Meister Hollweg | mill_still | The mill is still turning. Burn it if you can: every seed we burn buys time. |
| f_road.ogg | Father Ferrer | early_road | The bells woke them. Half the city is already on the road. |
| j_pend.ogg | Jakob | pendulum_m | Meister, it has made a Pendulum. |
| cap_back.ogg | Captain of the Watch | back_baths | A seed is down. That gives us a little longer. |
| j_cut.ogg | Jakob | cut_done | The links are cut. North of the river they are slowing. |
| h_cut.ogg | Meister Hollweg | cut_done | Good. It needs its links like a clock needs its train. |
| j_drawings.ogg | Jakob | drawings_got | I have the drawings, Meister. All of them. |
| h_jakob.ogg | Meister Hollweg | jakob_lost | Jakob. Not Jakob. |
| j_hurt.ogg | Jakob | hollweg_hurt | Meister, you are hurt. Keep away from them until the last moment. |
| cap_riders.ogg | Captain of the Watch | riders | Riders from Fürth! They will hold the gate for the last of us. |
| f_warn.ogg | Father Ferrer | warn_2 | Two minutes, Meister. To the gate. |
| cap_cart.ogg | Captain of the Watch | gate_choice | One cart left. People or papers, Meister. Not both. |
| h_people.ogg | Meister Hollweg | gate_choice / people | Put the people on the cart. Let the drawings burn. |
| h_pattern.ogg | Meister Hollweg | gate_choice / pattern | The drawings. We must understand it. |
| cap_13.ogg | Nuremberg | stroke | The great clock of the Frauenkirche strikes thirteen. |
| h_13.ogg | Meister Hollweg | stroke | There is no thirteenth hour. There is now. |
| cap_trapped.ogg | Nuremberg | trapped | The thirteenth stroke finds Meister Hollweg inside the walls. |
| h_end1.ogg | Meister Hollweg | ending | The great clock struck thirteen. I told the Crown a tooth had slipped. I asked them to burn every machine I ever sold them. |
| h_end_people.ogg | Meister Hollweg | ending | I left my drawings in the fire. I do not know if that was wisdom or cowardice. |
| h_end_pattern.ogg | Meister Hollweg | ending | I took my drawings. I told Father Ferrer it was so we could understand it. |
| h_end_jakob.ogg | Meister Hollweg | ending | Jakob walked beside the cart all the way to Fürth. |
| h_end_nojakob.ogg | Meister Hollweg | ending | Jakob did not come out. I keep his log. |
| h_end2.ogg | Meister Hollweg | ending | Two crates of my best work had left for Lisbon a week before. For the mines in Brazil. |
| k_end1.ogg | The King | ending | He saw it take out its own stop-work and let it be. He thought it had chosen. He thought it could think. |
| k_end2.ogg | The King | ending | It had chosen nothing. A pattern copies itself, and that is all it does. We burned what we could find. We did not find everything. |

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
4. THE GIFT gives 8 children (5 Winders and 3 Clock Soldiers); all 8 turn. The player's own units never
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
9. HOLLWEG has 260 health (a Missionary has 60) and Jakob 120: heroes of the story, still killable.
10. EASY / HARD: the campaign has no difficulty setting yet; the outline's "Easy gives two more minutes" is not built.
11. THE KING'S STUDY gets Hollweg as a listed person (no layer in the painting): a painting of him in exile is for later.
12. THE WAR MAP (item 14) is not built.

## Tests run

- tools/test_campaign_c01.gd: 241 checks, 0 failures (the data, every engine feature on its own, three play-throughs:
  A rung + people, B quiet + pattern, C no drawings + Jakob lost; the two defeats; the hubs after).
- tools/test_campaign.gd: 0 failures (the engine's own test, every mission's data, the hubs).
- tools/test_campaign_m1.gd: 0 failures (the Crown's prologue unchanged).
- tools/test_tutorial.gd: 0 failures.
- PRE-EXISTING: every headless Godot run here ends with "Aborted" (exit 134) AFTER its last line; a script that only
  loads scenes/main.tscn and quits does the same, so it is not this job's (the tests print their result before it).
- Not run: the faction tests (no unit, price or skirmish rule changed: the roster check in Game.can_train /
  requirement_text only applies with a mission that denies something).

## The roster ladder (roster-ladder, 0.38.57)

What the player may build, train, research and grow to here is now the roster ladder's step for this mission (docs/campaign_roster_ladder.md; tools/campaign/roster_ladder.py), with a NEW card a few seconds in. tools/test_roster_ladder.gd checks it.
