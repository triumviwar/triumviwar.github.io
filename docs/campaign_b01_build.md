# The Naturalist's prologue, "Specimen One", PLAYED AS THE BROOD (brood-prologue-flip, 0.38.49)

The owner's decision of 2026-11-17 22:00-22:04 (docs/campaign_act1_plan.md, "OWNER ANSWERS"): "we can see the naturalist
spying on the brood and we play the brood fighting, maybe brood vs brood". The prologue first built in 0.38.45 (the
station played, a losing mission; in git history before 0.38.49) is rebuilt: THE PLAYER IS THE TYRANT SIRE'S PACK. It is
now THE FIRST BROOD PLAY of the campaign, so its objectives are a short teaching strip. The station's story still happens,
by the script, and LINDQVIST still tells it (what he saw from his window); the King frames it as before.

EVERY LINE OF TEXT IS A PLACEHOLDER for the owner to rewrite. The stills are stand-ins.

## Files

| what | where |
| --- | --- |
| the mission | `campaign/missions/b01_specimen.json`, written by `tools/campaign/make_b01_mission.py` (edit the script, run it) |
| the map | `campaign/maps/rio_negro_station.json`, written by `tools/campaign/make_rio_negro_map.py` (now with the two dens) |
| the stills (stand-ins) | `campaign/stills/b01_01.jpg` .. `b01_08.jpg` (unchanged) |
| the sounds | `assets/audio/campaign/linnea_call.wav`, `forest_answer.wav`, `sire_roar.wav` (unchanged) |
| texts pt / es | `tools/i18n/campaign/b01_specimen.txt` (then `python3 tools/i18n_build.py`); the Brood is a Ninhada / la Nidada, her clutch a ninhada / la puesta |
| the engine | `scripts/campaign/mission_run.gd` (`nest_free`, `heel`, `ai_foe`, `hall_tag` on a Brood team), `campaign.gd` (their checks), `scripts/ai.gd` (`_foe`), `scripts/game.gd` (`max_supply`: `supply_cap`); docs/campaign_engine.md "Added by the Brood prologue flip" |
| test | `tools/test_campaign_b01.gd` (`godot --headless --fixed-fps 30 --script res://tools/test_campaign_b01.gd`) |
| balance and pictures | `tools/sim_campaign_b01.gd` (`-- active [eggs=left|taken] [rival=easy|normal] [rush] [raid]`; `shots=<dir>` with a window: `xvfb-run`) |

## The map

The Rio Negro station's map as before (the river, the station on its rise, the village of Nazaré to the west, the fort
on its rocky point to the east, the igapó, the creek), with two big clearings cut in the deep forest:

- THE SIRE'S DEN, north-west (the player): the Old Mother's nest at cell [16, 14], a Brood standard start (her, a
  Rootmaw, five grubs). The north-west trail runs through it, a back way goes down to the village's side, and a forest
  path leads east to:
- THE RIVAL'S DEN, north-centre, right above the station (the Brood computer): its Mother at [58, 18]; a trail runs from
  it down to the forest's edge above the station's north ramp.

The map has seven starts now (one per team; the mission places them).

## How to play it

CAMPAIGN, THE NATURALIST (open once the Crown's prologue is done), the specimen chart, the mission, START (SOLO, or
VERSUS online: the friend is the rival pack). The opening's stills (the King with the mapmaker's letter; Lindqvist in
chains before the King; the station; Specimen One: "That week, Majesty, the forest watched back"), then:

THE SIDES. The Sire's pack (GREEN, the player: the Old Mother, the Tyrant Sire, two Raptors, the standard start). The
rival pack (RED: the Brood computer, Easy, its supply capped at 36, its foe the Sire's pack; four Raptors and a Spitter
watching the forest's edge above the station; and its HUNTERS, a scripted team of the same side and colour). The station
(YELLOW: Lindqvist, Pieter, six hands, four guards; the garrison PURPLE: Teles and ten Musketeers at the fort, Frei
Joaquim and fourteen villagers at Nazaré, Benedito at his canoes) and LINNEA in her pen (her own team, the station's,
caged and untouchable). Three sides, all against each other.

THE TEACHING STRIP (the objectives, one after another; no creature speaks: objectives and sounds only):

1. ROOT: select the Tyrant Sire, ROOT, set him down in the ring round the Old Mother (her father range). Rooted, he is the
   nest her warrior eggs hatch in.
2. LAY AND HATCH: lay two Raptor eggs at the Old Mother; they roll into his nest, he breathes on them, they hatch (6
   Raptors in all; after 10:00 four will do). More creatures need more supply: a grub turns into a Mound Turtle (BUILD).
3. THE SIRE'S ROAR: uproot him and walk him anywhere along the forest's edge above the station (a long band from the
   west jar's clearing to the creek). He roars, she answers (her call, her pen shown for 40 s), the dusk comes, and from
   now on he may nest by her pen (`nest_free`). From here the rival pack's hunters come: four Raptors and a Spitter
   down the creek trail to her pen 25 s after the roar; and once the laying is done and the Sire is out of the den, six
   of them at the Old Mother (a raid to show that the den needs guarding).
4. LINNEA: root the Sire beside her pen. While he lies there she lays her clutch, an egg every 16 s, five in all (the
   count pauses whenever he gets up or leaves). Rooted he cannot bite: keep the pack round him. The station's guards
   shoot at whatever comes onto its rise.
5. Break her pen's gate (spared until the clutch is laid).
6. THE ONE CHOICE (30 s, default LEAVE IT): TAKE THE CLUTCH (the Sire carries the eggs home in his jaws: slower, he cannot
   bite until she is home) or LEAVE IT (canon: Lindqvist saves them from the fire). Then: TAKE HER HOME: walk the Sire
   back to the Old Mother's den; Linnea follows at his heels (`heel`, on a scripted team allied to the player). Eight
   Raptors and two Spitters of the rival's hunters come out at the west jar 4 s after the gate breaks and hunt the
   Sire. She reaches the den: the dawn, her call and his roar, and 6 s later the WIN.
- Optional all along: drive the rival pack off (kill its Mother).
- THE DEFEATS: the Tyrant Sire or the Old Mother killed (the rival pack's debrief: "The pack is broken").
- A player who does nothing: nothing happens (no den raid until the laying is done; the rival computer, held at 36
  supply, does not come for the den). Not a loss, never a win.

THE STATION'S STORY, by the script, while the player plays (Lindqvist's eyes; the canon results):

| when | what |
| --- | --- |
| 0:01 | Lindqvist: something moved in the deep forest that week |
| 1:10 | Linnea calls at sunset, nothing answers yet |
| 2:20 | Valadares comes down the river with two of the commission's men (he and Lindqvist untouchable and unarmed: they can't be killed and can't shoot the pack while untouchable); they meet |
| the pack at the ford or the forest's edge (or 7:00) | the tracks: two kinds, two packs |
| the pack at the goats | "At the goats!": the guards go there |
| the roar | the dusk, "She knows that voice"; 12 s later THE TELES DEBATE, the script's choice: KEEP IT QUIET (flag `teles` quiet) |
| 25 s later | the night and the rain; the lure explained; Pieter walks the three jars to the forest's edge (it pulls nobody: "they walked past the jars" when the pack comes onto the rise) |
| the Sire on the station's rise | the break-in: "the ground shook", the fire light; the guards go for the pen; Valadares fires the thatch (the garden at +20 s, the specimen house at +70 s, the house at +90 s); Teles comes late with three men to hold the east causeway (+60 s); Frei Joaquim sends the village to its boats |
| the Sire rooted by her pen | "He lay down beside her like a groom"; the eggs; "She is too young"; at five: "Five eggs. And he lay across the gate." |
| the gate broken | "The pen broke like kindling, and she followed him"; the station's people to the jetty, the village to its beach, Teles back to the fort; THE RESEARCH (the scientists' choice, by the script: canon SAVE IT): Lindqvist goes to the straw; left: he carries the crate (flag `clutch` saved); taken: the straw is empty, "I thought the fire had taken them" (`clutch` burned, `fire` yes); then to the jetty |
| Lindqvist and Valadares on the jetty | the canoes push off |

The people are counted from the start (the station's but Lindqvist, the commission when it comes, the village and the
friar: 28); those who reach the jetty or the beach once the gate is broken are saved. So a player who raids the station
or lets the hunters loose among the village saves fewer of them (flag `saved` few / some / many, the number in `saved_n`).

## The flags (for the missions after it)

| flag | values | set by | what later missions read (docs/campaign_act1_plan.md) |
| --- | --- | --- | --- |
| `teles` | quiet (always) | the script (the canon: Lindqvist kept it quiet) | a03: Valadares goes north with only the commission's men and Benedito; a07: the station's secret comes out under questioning |
| `clutch` | saved / burned | the player's choice: LEAVE (saved: Lindqvist carries the crate out of the fire) or TAKE (burned: the straw was empty, he believes the fire took them) | a05 breeding stock / fresh start; the hub's crate in the cellar / singed notebook |
| `fire` | yes (with TAKE) | Lindqvist's belief | the ending's line "The fire took her eggs before I reached them" |
| `eggs` | left / taken (NEW) | the player's one choice | the truth: with taken, the pack carried the clutch north (the King's line; a03 can show more young on the plateau) |
| `saved` | few / some / many (`saved_n`) | the people who reached the boats | a03 guides from Nazaré, a05 paddlers |
| `pieter` | alive / lost | Pieter alive when she is home (he walks the jars to the forest's edge and is often lost) | a05 |
| `turtle` | early / late | early if the Sire's pack had a Mound Turtle when the gate broke | lines only ("a swamp that walked") |
| `rival` | standing / driven (NEW) | the rival Mother dead or not when she is home | nothing yet (the debrief's line) |
| `gun` | not set | (the canon is quiet: the fort's gun never came to the station) | lines only |

## The engine (docs/campaign_engine.md, "Added by the Brood prologue flip")

Three sides needed nothing new (hostility by side; the second side in the list is the loser's debrief). Added: a
team's `hall_tag` works on a Brood team (her Mother); `ai_foe` (the rival computer goes for the Sire's pack, not the
station); `supply_cap`; `nest_free` (a father may root away from his Mother's range, a person's ROOT ghost too); the
`heel` order. Not built here (another job's, act1-engine0): the solo side pick (playing the station or the rival pack
alone) and the difficulty setting.

## The voice lines (for the owner's Chatterbox recordings)

Recorded lines go in `campaign/voice/b01/<line id>.ogg`. Changed since 0.38.45: NEW `l_open5`, `l_2`, `v_fire`, `l_five`,
`l_gone`, `l_end_two`, `k_end_taken`; REWORDED `l_1`, `l_weigh`, `n_canoe`, `p_tracks2`, `v_tracks`, `l_tracks`, `l_kin`,
`n_call`, `l_call`, `v_tell`, `l_one_night`, `l_lure1`, `l_lure2`, `p_sire`, `l_lost`, `v_lost`, `t_late`, `j_raid`,
`n_taken`, `n_room`, `l_pieter`, `n_leave`, `l_end_nopieter`; GONE (the station is no longer played): `l_open4`, `p_1`,
`tip_1`, `l_pen`, `p_pen`, `tip_meet`, `p_tracks`, `v_told`, `l_lure3`, `tip_lure`, `l_set`, `t_told`, `j_come`, `j_in`,
`p_island`, `v_island`, `v_turtle`, `n_quiet`, `l_quiet2`, `tip_3`, `b_bonus`, `t_steps`, `tip_rooted`, `n_nothing`,
`p_fire`, `v_lamp`, `b_here`, `p_pack_goes`, `p_fire_took`, `b_warn`, `v_hurt`, `n_behind`, `f_intro` (The Forest),
`l_end_burned`. The voices to design are as before (Lindqvist, Valadares, Pieter, Teles, Frei Joaquim, Benedito; the
Rio Negro a narrator); no creature has a voice.

| file (campaign/voice/b01/) | voice | when (trigger) | line |
| --- | --- | --- | --- |
| k_open1.ogg | The King | opening | Two letters came that year. The first came from the Amazon, from the Crown's mapmaker. |
| k_open2.ogg | The King | opening | The naturalist they brought me in chains. He knows these creatures better than any man alive. Let him tell it. |
| l_open1.ogg | Dr. Lindqvist | opening | I was the happiest man in the world that summer, Majesty. Write that down, whoever writes. |
| l_open2.ogg | Dr. Lindqvist | opening | The Academy's station at the rapids of São Gabriel. The river high, the forest standing in the water. |
| l_open3.ogg | Dr. Lindqvist | opening | She came from an egg a trader found after the flood. In forty days she had trebled. |
| l_open5.ogg | Dr. Lindqvist | opening | I watched the forest from my window every evening. That week, Majesty, the forest watched back. |
| l_1.ogg | Dr. Lindqvist | intro | Something moved in the deep forest that week. Pieter said the birds had gone quiet to the north. |
| l_2.ogg | Dr. Lindqvist | intro | I wrote it down and thought nothing of it. I had a pen to finish. |
| l_weigh.ogg | Dr. Lindqvist | call_1 | She called at sunset, as every day. Eleven pounds heavier than Monday. Nothing answered. Not yet. |
| n_canoe.ogg | The Rio Negro | valadares | A canoe came down from the boundary survey: the Crown's mapmaker, Duarte Valadares. |
| v_1.ogg | Valadares | meet | Doctor. They say at the fort you keep a lizard the size of a dog. |
| l_v1.ogg | Dr. Lindqvist | meet | Not a lizard. Something no man has named. The Crown will have a cavalry that needs no hay. |
| v_2.ogg | Valadares | meet | You mean to sell this to the army, Doctor? Then why do you whisper when you speak of her? |
| p_tracks2.ogg | Pieter | tracks_p | Three toes, deep in the mud at the creek. Too many to count. |
| v_tracks.ogg | Valadares | tracks | There are two kinds of track up there, Doctor. Two packs, and both came down from the north. |
| l_tracks.ogg | Dr. Lindqvist | tracks | Then she has a family. Two families. Splendid. |
| v_goats.ogg | Valadares | goats | At the goats! Guns, quickly! |
| l_kin.ogg | Dr. Lindqvist | goats | Did you see them hunt? Not one beast. A breed, with a breed's manners. |
| n_call.ogg | The Rio Negro | roar_heard | At dusk a roar came out of the forest, and she answered it. |
| l_call.ogg | Dr. Lindqvist | roar_heard | Listen. Listen to that. She knows that voice. |
| v_tell.ogg | Valadares | debate | Send to Teles, Doctor. Tell him what is in the forest, and bring the village in before dark. |
| l_quiet.ogg | Dr. Lindqvist | debate | If Teles sees those tracks he will shoot everything in this forest, beginning with her. One night. |
| l_one_night.ogg | Dr. Lindqvist | debate | So I kept it quiet, Majesty. One night, I said. The Crown would have its beasts tame or not at all. |
| n_eve.ogg | The Rio Negro | eve | The Eve of Saint John. Rain on the river, and the bonfires lit at Nazaré. |
| l_lure1.ogg | Dr. Lindqvist | eve | I had made a lure from the shell of her egg and her own musk. Pieter set it in three jars at the forest's edge. |
| l_lure2.ogg | Dr. Lindqvist | eve | Any of her kind that smelt it would stand at the jar sniffing like a dog, and we would be waiting with the guns. |
| v_lure.ogg | Valadares | eve | You are calling something you have never seen, Doctor, to a house full of people. |
| l_stallion.ogg | Dr. Lindqvist | eve | I am calling a stallion for my mare. By morning the Academy will have a pair. |
| p_set.ogg | Pieter | lure_set_p | All three jars are open, Doctor. I can smell it from here. |
| p_past.ogg | Pieter | walked_past_p | Doctor, they walked past the jars. |
| v_past.ogg | Valadares | walked_past | They are not after your scent. They are going to her. |
| n_ground.ogg | The Rio Negro | turn | Then the ground shook. |
| p_sire.ogg | Pieter | turn_p | Over the palisade. Doctor, it is as big as the house. |
| l_lost.ogg | Dr. Lindqvist | turn | He walked through my station as if it were reeds. He did not want us. He wanted her. |
| v_lost.ogg | Valadares | turn | We cannot hold this place. Get the people to the jetty. Benedito has his canoes. |
| v_fire.ogg | Valadares | fire_1 | Fire the thatch! They shy from fire. It buys us the jetty. |
| t_late.ogg | Lieutenant Teles | teles_late | Shots at the station! You three, with me, along the causeway. Hold the ford for them. |
| j_raid.ogg | Frei Joaquim | village_wake | The station is burning! Down to the boats, all of you, in the name of God! |
| l_groom.ogg | Dr. Lindqvist | sire_rooted | He did not want to eat her. He lay down beside her like a groom. |
| p_eggs.ogg | Pieter | eggs_seen_p | Doctor, there are eggs in her straw. |
| l_young.ogg | Dr. Lindqvist | eggs_seen | She is too young. She is far too young. |
| l_five.ogg | Dr. Lindqvist | ready | Five eggs. Five. And he lay across the gate and would not let a man near. |
| n_taken.ogg | The Rio Negro | broken | The pen broke like kindling, and she followed him. |
| l_taken.ogg | Dr. Lindqvist | broken | No. No! She is mine! Shoot him, not her! |
| v_taken.ogg | Valadares | broken | Let her go, Doctor. Your notes, your people. Now. |
| n_room.ogg | The Rio Negro | research_go | The specimen house was alight. Her eggs lay in the trampled straw. |
| v_burn.ogg | Valadares | research_go | Burn them, Doctor. Whatever she was, do not carry her children down this river. |
| l_save.ogg | Dr. Lindqvist | research_go | Ten years of work. The Crown's beasts are in that straw. I will not leave them to the fire. |
| l_crate.ogg | Dr. Lindqvist | research_saved | The crate, Pieter. The notes on top. I carry it myself. |
| l_gone.ogg | Dr. Lindqvist | research_gone | The straw was empty. I thought the fire had taken them. I believed that for thirty years. |
| l_pieter.ogg | Dr. Lindqvist | pieter_lost | Pieter. Pieter did not come back from the forest's edge. |
| n_leave.ogg | The Rio Negro | canoes | The last canoe pushed off with the station burning behind it. |
| b_leave.ogg | Benedito | canoes | Paddle! Do not look back. |
| l_end1.ogg | Dr. Lindqvist | ending | We went down the river at first light with the station burning behind us. She was gone. He took her from me as a thief takes a horse. |
| l_end_saved.ogg | Dr. Lindqvist | ending | I had the research. I told the Academy I had saved my notes. That was the first lie. |
| l_end_fire.ogg | Dr. Lindqvist | ending | The fire took her eggs before I reached them. I had nothing left but my word, and no one wanted it. |
| l_end_pieter.ogg | Dr. Lindqvist | ending | Pieter sat in the canoe with the specimen book on his knees and did not speak all day. |
| l_end_nopieter.ogg | Dr. Lindqvist | ending | Pieter went to the forest's edge with the jars. I have his specimen book still. He does not. |
| l_end_two.ogg | Dr. Lindqvist | ending | There were two packs in that forest, Majesty, and they fought over her like dogs over a bone. I saw it from my window. |
| l_end_north.ogg | Dr. Lindqvist | ending | Valadares turned his canoe round at the first island. He went north after her, up the creek, to the mountain in the cloud. |
| l_end2.ogg | Dr. Lindqvist | ending | I meant to give the Crown its beasts, Majesty. I still think I was right. |
| k_end1.ogg | The King | ending | He wrote that his lure called them. It did not. She called them, and they came for her. |
| k_end2.ogg | The King | ending | She was never stolen. She went home. |
| k_end_saved.ogg | The King | ending | And what he carried out of the fire was not research. It was her children. |
| k_end_taken.ogg | The King | ending | And the fire took nothing. The pack carried her eggs north in its jaws. He never knew. |


## Balance (tools/sim_campaign_b01.gd, 0.38.49)

The bot plays a plain Brood game: the Sire rooted by the Old Mother, grubs to 10, a second Rootmaw, Mound Turtles when
the supply runs short, Raptors with the rest; at 24 creatures (or 20:00) the whole pack goes out with the Sire, by the
west (the west jar's clearing, away from the rival's den), roars there, comes east above the station, kills the yard's
guards with the Sire held back, roots him by her pen, keeps the pack on whatever comes at him, breaks the gate, and goes
home by the west, the pack going in first if the den is being raided. When its pack is spent (under 4) before the gate,
the Sire goes home to root and rebuild.

| run (0.38.49) | result | time | the fight |
| --- | --- | --- | --- |
| active, leave the clutch, rival Easy (as written) | WIN, `saved` some (15 of 28), Pieter lost | 9:30 | 70 creatures made, 55 lost (some to morphs); 20 Raptors killed by the hunters' Raptors, 5 by the guards |
| active, rival Normal | WIN | 10:03 | 26 Raptors killed by the hunters' |
| active, TAKE the clutch | WIN (`clutch` burned, `fire` yes, `eggs` taken) | 9:44 | the slow, biteless Sire home through the hunters |
| active, rush (out at 6 creatures) | WIN after two rebuilds | 14:44 | 104 made, 95 lost: the rival's Tyrannosaur and Mother where the bot strayed |
| passive (does nothing) | nothing happens | (30:00) | the rival computer at 36 supply never comes |
| earlier tunings, for the record | | | rival not capped: 129 creatures by 13:00 and the den overrun; capped at 44-56: its first push (17-30, a Tyrannosaur and a Dilophosaurus among them) reaches the den at 7:00-8:00, just when the pack comes home: the bot won 1 in 3; six guards and Teles' five on the yard killed the rooted Sire |

Reading: a player who builds up at home and goes out with a real pack wins in about ten minutes and fights two real
Brood battles on the way (the hunters at the pen, the hunters on the way home); going out early costs a rebuild;
walking into the rival's den is costly; the den raid shows the Old Mother needs a guard. The rival computer itself only
holds its ground (capped at 36 supply it never pushes): the Brood v Brood fighting is mostly its hunters, scripted
(Claude's choice 2). The station's guns are the danger to a rooted Sire: clear the yard first.

## Stills: which prompts still fit, and new ones

The eight stand-ins and their prompts (below, unchanged from 0.38.45) still fit the story: b01 the letter, b02 the station,
b03 Specimen One, b04 eyes at the forest's edge (now also the rival's briefing and debrief, and Lindqvist's "two packs"
page), b05 the Tyrant at the pen (now the player's briefing), b06 the station burns (the player's debrief and the
ending's first page: the canoe and the crate fit LEAVE; with TAKE the crate holds only notes), b07 north, b08 the teller.
NEW stills wanted (until then the stand-ins above are used):

- b09 THE OLD MOTHER'S DEN (the player's briefing): "Oil painting, 18th-century history painting style. Dawn mist in a
  clearing of a deep Amazon forest: a huge old reptilian brood mother, crocodile- and monitor-like, olive-brown scales
  grey with age, venom-green frills, lies rooted in a nest of mud and roots; beside her a colossal tyrannosaur-like male
  with green-tipped spines lifts his head and roars toward the south; lean two-legged reptilian hunters with green crests
  crouch round them; through the trees, far below, a river and a thin line of smoke. No people. 3:2 landscape, no
  text." References: art/redraws/brood_mother_concept2_chatgpt.png, art/redraws/tyrannosaur_concept_chatgpt.png.
- b10 TWO PACKS (Lindqvist's "they fought over her like dogs over a bone"): "Oil painting, 18th-century history painting
  style. Night in the rain at the edge of a flooded Amazon forest, seen from a lamp-lit window of a timber station: two
  packs of reptilian hunters tear into each other in the mud, one crested venom-green, the other blood-red; behind
  them the dark trees and the glint of eyes. A naturalist's hand holds a spyglass at the window's edge. 3:2 landscape,
  no text." Reference: art/redraws/raptor_walk_se_chatgpt.png.
- b11 HOME (the end, optional): "Oil painting, 18th-century history painting style. Grey dawn in a forest clearing: a
  small young reptilian brood mother with a green frill comes out of the trees at the heels of a colossal tyrannosaur-like
  male and lowers her head to an old brood mother rooted in her nest; a few pale leathery eggs carried in the male's
  jaws (or none); a column of smoke far off over the trees. Tender and uncanny. No people. 3:2 landscape, no text."
  References as b09.

### The prompts of 0.38.45 (still used) (ChatGPT, one request each, at most 3 reference images)

House style as the Crown's prologue (campaign/stills/p01_*.jpg): an oil painting in the manner of an 18th-century history
painting, warm lantern and firelight against deep night blues and greens, visible brushwork, 3:2 landscape (cut to
1280 x 853), no text or lettering anywhere. The Crown's soldiers in PURPLE coats; the station's people in plain colonial
clothes with a touch of YELLOW (the station's colour); the creatures REPTILIAN (crocodile, monitor lizard, dinosaur),
olive-brown scaled with VENOM-GREEN frills and spines, never insect-like. Save each as `art/campaign/stills/b01_0N.png` and cut
it to 1280 x 853 into `campaign/stills/b01_0N.jpg` (nothing else changes).

- b01 THE MAPMAKER'S LETTER (the frame). "Oil painting, 18th-century history painting style. Night, a study in Rome by
  candlelight: an old King in a purple robe sits by a desk with a parchment map, a pipe in his hand, listening. Beside him a
  younger priest in a black cassock holds a water-stained, opened letter with a broken wax seal shaped like a compass rose,
  reading aloud. A dried jungle leaf has fallen from the letter onto the desk. Warm candlelight, deep shadows. 3:2
  landscape, no text." References: campaign/stills/p01_01.jpg (the King, the room), art/campaign/hub/rome_tomasz_chatgpt.png
  (the priest).
- b02 THE STATION AT THE RAPIDS. "Oil painting, 18th-century history painting style. Late afternoon on a wide black river in
  the Amazon at high water: on a low rise of the bank a timber research station with a palm-thatched roof, a wooden jetty
  with dugout canoes, a goat pen, a vegetable garden, a small pen of sharpened stakes beside a shed; the forest stands in
  the dark water around it (a flooded forest), white rapids downstream, and far in the north, above the jungle, a
  flat-topped mountain wrapped in cloud. Golden light, heavy humid air, birds. 3:2 landscape, no text." Reference:
  campaign/stills/p01_05.jpg (the style).
- b03 SPECIMEN ONE. "Oil painting, 18th-century history painting style. Inside a naturalist's specimen house lit by an oil
  lamp: a lean naturalist with wild sandy-grey curly hair, a monocle on a chain, a green brocade waistcoat and rolled linen
  sleeves crouches by a brass scale and holds out a scrap of meat to a hatchling reptile the size of a large dog: a young
  crocodile-like and monitor-like creature with a small frill of green spikes round its neck, olive-brown scales,
  intelligent golden eyes. A young assistant writes in a ledger. On the wall a pinned sketch of the creature grown huge with
  a saddle on its back. Jars of specimens on shelves, an empty leathery eggshell in a straw crate. Tender and uncanny. 3:2
  landscape, no text." References: art/campaign/hub/station_lindqvist_chatgpt.png (the naturalist),
  art/redraws/brood_mother_concept2_chatgpt.png (her kind, drawn as a young hatchling), campaign/stills/p01_05.jpg (the
  style).
- b04 EYES AT THE FOREST'S EDGE. "Oil painting, 18th-century history painting style. Dusk in the rain at the edge of a flooded
  Amazon forest: a broken goat pen in the foreground, a lantern on the mud; between the dark trunks standing in the water,
  many pairs of reflecting eyes low to the ground and the half-seen shapes of lean, fast, two-legged reptilian hunters with
  green crests. A tall explorer (Portuguese-Brazilian, weathered, a brass compass on his chest, a machete) raises a pistol;
  behind him the naturalist holds up a lamp, fascinated. 3:2 landscape, no text." References:
  art/redraws/raptor_walk_se_chatgpt.png (the hunters), campaign/stills/p01_05.jpg (the style).
- b05 THE TYRANT AT THE PEN. "Oil painting, 18th-century history painting style. Deep night in the rain at a jungle research
  station: a colossal tyrannosaur-like reptile with green-tipped spines has walked through a palisade of sharpened logs and
  lies down beside a small wooden pen as if nesting, its great head lowered toward a small frilled creature inside the pen,
  which calls up at it; in the straw at her feet a few pale leathery eggs. Soldiers in purple coats and station hands with
  torches and muskets hold back in terror; the thatched roof behind them has caught fire. Firelight and rain. 3:2 landscape,
  no text." References: art/redraws/tyrannosaur_concept_chatgpt.png (the Sire), art/redraws/brood_mother_concept2_chatgpt.png
  (her kind, small), campaign/stills/p01_05.jpg (the style).
- b06 THE STATION BURNS. "Oil painting, 18th-century history painting style. The grey before dawn on a black Amazon river:
  seen from a crowded dugout canoe pulling away downstream, a jungle research station burns on its low rise, the palisade
  broken, the flames doubled in the water. In the canoe, among exhausted station hands and villagers, the naturalist (wild
  sandy-grey hair, monocle, green waistcoat, soot-black and burned) clutches a small iron-banded crate to his chest and
  stares back at the fire; at the bow a river trader paddles. 3:2 landscape, no text." References:
  art/campaign/hub/station_lindqvist_chatgpt.png (the naturalist), campaign/stills/p01_05.jpg (the style). (One picture for
  both choices: the crate is small enough to read as notes alone.)
- b07 NORTH. "Oil painting, 18th-century history painting style. Morning on a narrow jungle creek: a dugout canoe with a tall
  explorer in a wide hat at the bow, a machete in his belt, and a Brazilian river trader paddling, heading upstream between
  giant trees; huge three-toed tracks in the mud of the bank, and beside them a line of much smaller ones; ahead, above the
  canopy, a sheer flat-topped mountain with a waterfall falling from the cloud. 3:2 landscape, no text." Reference:
  campaign/stills/p01_05.jpg (the style).
- b08 THE NATURALIST BEFORE THE KING (the present; the owner's answer of 10:22: he tells it as a prisoner before the King).
  "Oil painting, 18th-century history painting style. A grand study in Rome by candlelight: an old King in a purple robe sits
  in a high chair by a desk with a parchment map, a pipe in his hand, listening gravely. Before him stands an old man, thin,
  with long white curly hair and a monocle on a chain, a faded green brocade waistcoat, his wrists in iron chains, one hand
  raised as if describing something large; an old leather journal lies open on the desk. Two guards in purple coats with
  halberds stand behind the prisoner. Warm candlelight, deep shadows, the dome of Saint Peter's faint through the window.
  3:2 landscape, no text." References: campaign/stills/p01_01.jpg (the King, the room),
  art/campaign/hub/station_lindqvist_chatgpt.png (the same man, young).
- (her own art, later) LINNEA the unit: the owner's usual sprite-sheet prompt for a small hatchling of the Brood Mother's
  kind (south-east first: idle in a pen, calling with her head up, and a walk for following the Sire), reference
  art/redraws/brood_mother_concept2_chatgpt.png. The people's art folders are named in Rebels.ROLES (`b_lindqvist`,
  `b_valadares`, `b_pieter`, `b_teles`, `b_joaquim`, `b_villager`, `b_benedito`, `b_linnea`): drop the strips in as for the
  rebels (docs/campaign_m1_build.md).
- (for the hub, later) THE WAREHOUSE AT THE BARRA: a painted room for THE NATURALIST's hub after the fall (the station's
  room tinted until then): "Oil painting, 18th-century history painting style. A riverside warehouse at night lit by oil
  lamps: crates, jars, rolled charts and a long table, rain on the river through a wide door, a few tired people asleep on
  sacks; a crate under a tarpaulin by the cellar steps. 3:2 landscape, no text." Reference: campaign/hub/station_room.jpg.

Files: b01 -> b01_01, b02 -> b01_02, b03 -> b01_03, b04 -> b01_04, b05 -> b01_05 (in the stills list, shown by name in the
dialogue later), b06 -> b01_06, b07 -> b01_07, b08 -> b01_08.

## What is placeholder

- Every line, every objective's words, the briefing and the debrief (the owner rewrites the dialogue himself).
- The stills (b01-b08 stand-ins; b09-b11 not made: the stand-ins are used).
- The people are stand-ins (as before); Linnea a Brood Mother's sprite at 0.3 in the station's yellow, then the pack's green.
- The rival's colour (RED): the Clockwork's faction colour in skirmish, but here only a team colour; another (orange,
  pink) is a one-number change.

## Claude's choices for the owner

1. THE PLAYER'S PACK HAS A MOTHER (the Old Mother, a Brood standard start), so the first Brood play can teach rooting,
   laying and hatching, and the Sire comes for Linnea as a second, young mother (a new pack's queen), not as a lone male.
   Who the Old Mother is to Linnea is never said.
2. THE RIVAL PACK is the Brood computer (Easy) for its den and its own army, HELD AT 36 SUPPLY (uncapped it out-grew the
   player fivefold and overran the den), plus a SCRIPTED team of hunters of the same side and colour: four Raptors and a
   Spitter at her pen after the roar, six at the den once the Sire is out, eight Raptors and two Spitters hunting the
   Sire on the way home. The computer goes for the Sire's pack only (`ai_foe`), never the station.
3. THE ROAR is a place, not a button: the Sire walked to the forest's edge (a wide band, so the player can go round the
   rival's den by the west or through it by the creek). The Brood has no roar ability.
4. "HE MAY NEST BY HER PEN" only after the roar (`nest_free`): the first ROOT teaches the father range.
5. THE CLUTCH is laid while he lies rooted by her pen (an egg every 16 s, five), the old prologue's beat, now the
   player's to defend; the gate stays spared until then.
6. THE ONE CHOICE: TAKE THE CLUTCH (the Sire carries it: slower, cannot bite; `clutch` burned, `fire` yes: what
   Lindqvist believes; `eggs` taken: the truth, the King's line) or LEAVE IT (canon: Lindqvist saves it; `clutch` saved).
   Default LEAVE (the canon of the outline).
7. THE SCIENTISTS' CHOICES are the script's, with the canon: TELES kept QUIET (so no fort's gun, no `gun` flag), THE
   RESEARCH SAVED (when the clutch is left). Teles still comes late, but only to hold the east causeway (on the yard his
   men killed the rooted Sire in the tuning runs).
8. LINDQVIST AND VALADARES ARE UNTOUCHABLE AND UNARMED (they must live to tell it and to go north; unarmed so they can't
   shoot the pack while nothing can hurt them); the hands and Pieter carry tools, not guns. Pieter can die (he walks the
   jars to the forest's edge); the guards, the commission and the village can.
9. LINNEA once out is on a scripted team allied to the player (`kin`), untouchable, at the Sire's heels: the player never
   gets a second Brood Mother's card (two Mothers on one team would confuse the Brood's rules), and she can't be lost.
10. THE WIN is her reaching the Old Mother's den (not a map edge): "take her home". The scientists' canoes leave on their
    own when Lindqvist and Valadares reach the jetty; if she is home first, the flags are set by the canon anyway.
11. MODES: solo and versus (the friend is the rival pack, wins by killing the Sire or the Old Mother; the hunters still
    come for him). No co-op (one Brood side to play). The station is never a person's in this mission (the solo side
    pick, act1-engine0, could make the station or the rival pack a solo side later).
12. THE TEACHING STRIP lives in the objectives' words (no tip lines: no creature speaks, and Lindqvist can't teach the
    pack). The lay step asks for two eggs, not more: with five grubs and the Sire the Old Mother's 16 supply holds six
    Raptors; more needs a Mound Turtle, said in the same objective.
13. THE PEOPLE COUNTED include the village and the commission (28); the bands as before (few under 10, some 10-19, many
    20+). The bot ends with "some" (15): it kills the yard's guards, and Pieter dies at the jars.
14. EASY / HARD: not built here (the difficulty setting is act1-engine0's); the rival computer's level and the hunters'
    numbers are the knobs (`ai:easy`, `supply_cap`, the spawn counts in make_b01_mission.py).

## Tests run

- tools/test_campaign_b01.gd: 176 checks, 0 failures (the data and translations; the seats; the engine, feature by
  feature, the flip's `nest_free`, `heel`, `ai_foe`, `supply_cap`, the Brood `hall_tag` among them; two play-throughs:
  L (leave the clutch) and T (take it), every step of the strip and every beat of the station's script, the end and its
  lines, the flags kept; the two defeats; the hubs after, by the flags; the King's study).
- tools/test_campaign.gd, test_campaign_m1.gd, test_campaign_c01.gd, test_tutorial.gd: 0 failures.
- The boot (`godot --headless --quit-after 300`): no SCRIPT ERROR (every headless run here ends with "Aborted" after its
  last line, as before).
- Not run: the faction and AI tests (the AI change is one line, read only in a mission that names an `ai_foe`; the
  supply cap only in a mission that names one).

## The roster ladder (roster-ladder, 0.38.57)

What the player may build, train, research and grow to here is now the roster ladder's step for this mission (docs/campaign_roster_ladder.md; tools/campaign/roster_ladder.py), with a NEW card a few seconds in. tools/test_roster_ladder.gd checks it.
