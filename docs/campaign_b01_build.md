# The Brood prologue, "Specimen One": what was built (brood-prologue-build, 0.38.45)

The outline and the owner's answers (docs/campaign_brood_prologue.md, with the answers of 2026-11-17 09:18 and 10:22) as a
playable mission on the campaign engine (docs/campaign_engine.md, its new parts in "Added by the Brood prologue"). It is
the first mission of THE NATURALIST (campaign/campaign.json "naturalist", the Brood storyline renamed from "The Explorer"),
open after the Crown's prologue, as the Clockwork's is. A LOSING mission: Parts 1 and 2 are won in their own terms, Part 3 is
a retreat to the canoes on a clock, and the story's loss counts like a win (THE STATION IS LOST).

EVERY LINE OF TEXT IS A PLACEHOLDER for the owner to rewrite (kept short and plain on purpose). The stills are stand-ins.

## Files

| what | where |
| --- | --- |
| the mission | `campaign/missions/b01_specimen.json`, written by `tools/campaign/make_b01_mission.py` (edit the script, run it) |
| the map | `campaign/maps/rio_negro_station.json` (`campaign:rio_negro_station`), written by `tools/campaign/make_rio_negro_map.py`; opens in the MAP EDITOR |
| the stills (stand-ins) | `campaign/stills/b01_01.jpg` .. `b01_08.jpg`, drawn by `tools/campaign/make_b01_stills.py` |
| the sounds | `assets/audio/campaign/linnea_call.wav`, `forest_answer.wav`, `sire_roar.wav`, made from the Brood's own creature voices by `tools/campaign/make_b01_sounds.sh` |
| texts pt / es | `tools/i18n/campaign/b01_specimen.txt` (then `python3 tools/i18n_build.py`) |
| the hubs | `campaign/campaign.json`: THE NATURALIST (Lindqvist's Station; after the fall The Warehouse at the Barra), the King's study (Dr. Lindqvist held) |
| the engine | `scripts/campaign/mission_run.gd`, `campaign.gd`, `campaign_menu.gd`, `rebels.gd`; small hooks in `scripts/entity.gd` (spared, hp_floor), `scripts/unit.gd` (m_pace, m_unarmed), `scripts/brood_new.gd` (a caged egg, a role's scale), `scripts/brood_root.gd` (a scripted father's nest) |
| test | `tools/test_campaign_b01.gd` (`godot --headless --fixed-fps 30 --script res://tools/test_campaign_b01.gd`) |
| balance and pictures | `tools/sim_campaign_b01.gd` (`-- active teles=told|quiet clutch=saved|burned`; `shots=<dir>` with a window: `xvfb-run`) |
| pictures | `docs/shots/campaign_b01/` (captions.md) |

## How to play it

CAMPAIGN, the tab THE NATURALIST (open once the Crown's prologue is done), the SPECIMEN CHART, the mission, START. The
opening's four stills (the King in Rome with the mapmaker's letter; Lindqvist in chains before the King; the station; Specimen
One: the King opens, Lindqvist tells it), then:

- PART 1, SPECIMEN ONE (a humid afternoon). The station (YELLOW): the station house (a Town Hall), the specimen house (a
  Cottage), the garden (a Farm), 6 hands, 4 guards, DR. LINDQVIST (a Musketeer stand-in, 320 health) and PIETER (a
  Labourer, 110). No Horse Breeder, Foundry or Armoury (the jungle: the roster). LINNEA in her crate beside the
  specimen house (a Brood Mother's kind drawn at 0.3, of a team of her own on the station's side, YELLOW: caged and
  untouchable). 300 gold and 400 powder (250 more at nightfall). The garrison (PURPLE, scripted) at the fort: Lieutenant Teles and 10 Musketeers; Frei Joaquim and 14
  villagers at Nazaré; Benedito at his canoes. Objective: BUILD HER PEN (11 stakes and a gate, laid out as building sites:
  the hands build them). At 2:20 VALADARES comes down the river (an Officer stand-in, 320 health, with two of the
  commission's men): meet him at the jetty. Then Pieter's TRACKS at the creek's ford. At dusk Linnea CALLS, something
  answers, and two Raptors come for the goats (green). Then THE FIRST CHOICE (60 s, default KEEP IT QUIET):
  - TELL THE LIEUTENANT: the village crosses to the fort, the garrison holds the causeway, the gun goes to the station's
    landing; in Part 3 the villagers leave by the fort's steps.
  - KEEP IT QUIET: the station alone; Raptors at the bonfires; bring the village in (optional: walk the station's men to
    the village and they come up to the station); Teles comes late, with half his men.
- PART 2, THE EVE OF SAINT JOHN (night, rain). First Lindqvist EXPLAINS the lure (what it is, what it does, where it goes),
  then the objective: SET THE LURE (Pieter to the three marks at the forest's edge). The waves come from the three trail
  heads one by one (about one every 50 s, 3 Raptors, a Spitter from the north-east): the first two go to their trail's jar
  (the ambush works), from the third they walk past the jars to her pen ("they walked past the jars"). 3:40 into the part
  the MOUND TURTLE walks out of the igapó and roots at the creek's mouth; Spitters come out of its swamp every 55 s while it
  lives (optional: kill it). The part ends when the forest goes quiet: 8:00 in, once the turtle is dead and the village
  settled, or at 11:00 whatever happened.
- PART 3, THE TYRANT (night, the station alight). The TYRANT SIRE comes down the creek trail with Raptors and a Spitter. The
  objectives change on screen: "The station cannot be held. Save who you can and get to the jetty. Benedito's canoes leave
  in 8:40" (a countdown; +1:30 if the turtle died in Part 2). Primary: Lindqvist and Valadares at the jetty when the canoes
  leave. Optional: the people into the canoes ("21 saved of 33": BENEDITO'S CANOES come round from the rapids 1:40 into the
  part; from then the station's men who walk onto the jetty, and the villagers onto the jetty or the fort's steps, are
  aboard: until then hold them there), Pieter lives, the fort's gun (told). The Sire LIES DOWN beside her pen (rooted he cannot bite;
  he cannot die tonight: his health stops at a third); every 30 s he calls with her and a few Raptors answer; while he lies
  there she lays a clutch of 5 eggs in her straw. Hurt to a third he gets up roaring (two Raptors come), lies down again 30 s
  later. The garden catches fire at 0:40, the specimen house at 2:30, the station house at 2:40 (it falls last). At 5:30 HE
  TAKES HER: the pen broken, Linnea his (green), they walk up the creek trail and off the map; the pack goes with them, but
  for a few stragglers. Then "Reach the burning specimen house with Dr. Lindqvist": THE SECOND CHOICE (35 s, default SAVE
  THE RESEARCH):
  - BURN THE EGGS: the eggs and the notes burn; Lindqvist walks to the jetty free and armed.
  - SAVE THE RESEARCH: Lindqvist carries the crate (slower, he cannot shoot: "Dr. Lindqvist (the crate)").
  - Never reached (the specimen house burned down, or 0:40 left): the fire takes the eggs (as burned, said so).
- THE CANOES LEAVE: with Lindqvist and Valadares on the jetty the saved are counted, the flags kept, and 12 s later the
  mission ends: the ending's stills (Lindqvist's lines by the flags, Valadares going north, the teller before the King, the
  King's truth) and the end screen: THE STATION IS LOST, the debrief's lines by the flags. It counts: the progress, the flags,
  THE NATURALIST's hub after it, Lindqvist held in the King's study.
- THE REAL DEFEATS: Lindqvist or Valadares killed (DEFEAT, retry), or either not on the jetty when the canoes leave.

The flags kept (`Campaign.flag("b01_specimen", ...)`; a later mission reads them with `{"past": {"b01_specimen.<flag>": value}}`):
`teles` told / quiet, `clutch` saved / burned (`fire` yes when the fire took them), `saved` few / some / many (0-9, 10-19, 20+;
the number in `saved_n`), `pieter` alive / lost, `turtle` early / late, `gun` kept / lost (told only).

THE HUB AFTER THE FALL: THE NATURALIST's hub becomes "The Warehouse at the Barra" (the station painting tinted, until the
owner's painting of the warehouse; Lindqvist's new lines), with THE CRATE IN THE CELLAR (eggs saved: "It grows.") or THE
SINGED NOTEBOOK (burned) in place of HER CRATE. The plateau's egg and the specimen jar wait for the Specimens (`requires`
a05_specimens, a mission not written yet). In the King's study DR. LINDQVIST is listed (held in the palace) and the King has
new lines.

Co-op: the friend commands the garrison (purple: Teles' Musketeers, the gun, Frei Joaquim and the villagers). Versus: the
friend is the pack (the waves and the Sire are his units; he wins by killing Lindqvist or Valadares). Neither was played on
two devices (as for the whole engine).

## The engine (docs/campaign_engine.md lists every key)

The outline's 16 needs beyond the Clockwork's, and what was built:

| the outline's need | built |
| --- | --- |
| 1 a Brood team with no Mother that is not beaten | nothing to add in a mission: Game._check_end leaves the end to MissionRun, so the scripted pack (no Mother, no grubs, no economy) is never beaten for it. The pack's player in versus still sees the Brood's HUD (no Mother: its economy buttons do nothing); a "wild" team flag that hides them is not built (Claude's choice 10) |
| 2 scripted root and uproot | `order` `"do": "root"` (to an area) and `"uproot"`; a father may nest by a Mother of another side (meta `mission_root`); condition `{"rooted": {"tag"}}` |
| 3 a caged unit on another team | Linnea is on a team of her own (`pen`, the station's side, YELLOW, scripted), so she is "the station's" without the player commanding a Brood Mother; `cage` (no move, no bite, put back if shoved), `spare` (untargetable, unhurt); `convert` to the pack when the pen breaks, then she walks after the Sire and leaves by an exit |
| 4 a pen condition | the pen's 12 pieces are building SITES (`"site": true`) the hands build; objective `"kind": "build"` |
| 5 a priority target and the lure's one-time pull | `order` `"to_if"` (the jar while the first two waves come and that jar is set, else the pen) |
| 6 the Sire's call while rooted | a repeating trigger gated by `rooted` |
| 7 a unit that cannot die tonight | `floor` (and `heal`), condition `hp` |
| 8 the clutch | `brood_egg` units spawned in her pen while the Sire lies there, `cage`d (an egg caged never hatches) and `spare`d; burned or carried by the choice |
| 9 a spreading fire | `burn` (a timetable per building; flames shown); the station house last |
| 10 a carrier's price | `carry` (slower, unarmed) |
| 11 rain and bonfires | `"weather": "rain"`, the jungle lights; the bonfires are the map's campfire props (no placed light: Claude's choice 11) |
| 12 no horses | the roster denies the Horse Breeder, the Foundry and the Armoury; the gun is a Field Cannon with no horse (`pin`; a cannon with no horse already stays set up where it is) |
| 13 the pack in versus | the waves and the Sire are the friend's units (scripted orders skip a person's team); his objective: kill Lindqvist or Valadares. NOT built: choosing the trail head for each call, rooting the Sire himself (a father's nest needs his own Mother), the scored end (Claude's choice 9) |
| 14 role scale | a role's `"scale"` (Linnea at 0.3) |
| 15 the map | the generator |
| 16 the hub after the prologue | hub `"after"` (title, about, still, tint) and hotspot / talk `"flag"` gating (new: CampaignMenu.flags_ok) |

Also: exits that open `after` a trigger and keep `except` tags (the canoes take people only once the station falls, and
never the two heroes), a counter set from a count (`count`, `plus`), a mission `"floor"` tint for the ground.

## The voice lines (for the owner's Chatterbox recordings)

Recorded lines go in `campaign/voice/b01/<line id>.ogg` (or .wav / .mp3); the game plays them when present (CampaignVoice).
The King's lines in the King's voice (tools/voice_clone, refs king_ref.wav). DR. LINDQVIST (old, telling it before the King;
the same voice serves his scene lines, or a younger version raised in pitch), VALADARES, PIETER, LIEUTENANT TELES, FREI
JOAQUIM and BENEDITO need DESIGNED voices first (a 10-20 s sample each, the owner's rule: ElevenLabs only to design, then
Chatterbox for all the lines; tools/voice_clone/refs/ has 5 designed voices, one may fit). "The Rio Negro" is a narrator
(could be Lindqvist himself, or the King's narrator voice). "The Forest" (versus only) can stay text. Linnea's call, the
pack's answer and the Sire's roar are SOUNDS (assets/audio/campaign/), not voices.

| file (campaign/voice/b01/) | voice | when (trigger) | line |
| --- | --- | --- | --- |
| k_open1.ogg | The King | opening | Two letters came that year. The first came from the Amazon, from the Crown's mapmaker. |
| k_open2.ogg | The King | opening | The naturalist they brought me in chains. He knows these creatures better than any man alive. Let him tell it. |
| l_open1.ogg | Dr. Lindqvist | opening | I was the happiest man in the world that summer, Majesty. Write that down, whoever writes. |
| l_open2.ogg | Dr. Lindqvist | opening | The Academy's station at the rapids of São Gabriel. The river high, the forest standing in the water. |
| l_open3.ogg | Dr. Lindqvist | opening | She came from an egg a trader found after the flood. In forty days she had trebled. |
| l_open4.ogg | Dr. Lindqvist | opening | I meant to give the Crown a beast of war no army had. I meant to give her a mate first. |
| l_1.ogg | Dr. Lindqvist | intro | She has outgrown her crate. A proper pen today, beside the specimen house. |
| p_1.ogg | Pieter | intro | The stakes are cut and marked, Doctor. |
| tip_1.ogg | Pieter | intro | Select the hands and right-click a marked stake. They go on to the next by themselves. |
| l_weigh.ogg | Dr. Lindqvist | call_1 | Hear her? She calls when she is hungry. Eleven pounds heavier than Monday. |
| l_pen.ogg | Dr. Lindqvist | pen_done | There. Room to grow. |
| p_pen.ogg | Pieter | pen_done | She will need a bigger one by August. |
| n_canoe.ogg | The Rio Negro | valadares | A canoe comes down from the boundary survey: the Crown's mapmaker, Duarte Valadares. |
| tip_meet.ogg | Pieter | valadares | Walk Dr. Lindqvist down to the jetty to greet him. |
| v_1.ogg | Valadares | meet_done | Doctor. They say at the fort you keep a lizard the size of a dog. |
| l_v1.ogg | Dr. Lindqvist | meet_done | Not a lizard. Something no man has named. The Crown will have a cavalry that needs no hay. |
| v_2.ogg | Valadares | meet_done | You mean to sell this to the army, Doctor? Then why do you whisper when you speak of her? |
| p_tracks.ogg | Pieter | tracks | Doctor, come and see. At the creek. These are not hers. |
| p_tracks2.ogg | Pieter | tracks_found | Three toes, deep in the mud. Too many to count. |
| v_tracks.ogg | Valadares | tracks_found | These came down from the north. From where your trader found the egg. |
| l_tracks.ogg | Dr. Lindqvist | tracks_found | Then she has a family. Splendid. |
| n_call.ogg | The Rio Negro | goats_come | At dusk she called. Something in the forest answered. |
| l_call.ogg | Dr. Lindqvist | goats_come | Listen. Listen to that. |
| v_goats.ogg | Valadares | goats_attack | At the goats! Guns, quickly! |
| l_kin.ogg | Dr. Lindqvist | goats_done | She has kin. Do you see what that means? Not one beast. A breed. |
| v_tell.ogg | Valadares | teles_choice | Send to Teles, Doctor. Tell him what we saw at the creek, and bring the village in before dark. |
| l_quiet.ogg | Dr. Lindqvist | teles_choice | If Teles sees those tracks he will shoot everything in this forest, beginning with her. One night. |
| v_told.ogg | Valadares | teles_choice / told | My man is already on the path to the fort. |
| l_one_night.ogg | Dr. Lindqvist | teles_choice / quiet | One night, Valadares. The Crown will have its beasts tame or not at all. |
| n_eve.ogg | The Rio Negro | eve | The Eve of Saint John. Rain on the river, and the bonfires lit at Nazaré. |
| l_lure1.ogg | Dr. Lindqvist | eve | Now my lure. I made it from the shell of her egg and her own musk. |
| l_lure2.ogg | Dr. Lindqvist | eve | Any of her kind that smells it follows the scent to the jar, and stands there sniffing like a dog. |
| l_lure3.ogg | Dr. Lindqvist | eve | Three jars at the forest's edge. Whatever comes will come to them, and we will be waiting with the guns. |
| v_lure.ogg | Valadares | eve | You are calling something you have never seen, Doctor, to a house full of people. |
| l_stallion.ogg | Dr. Lindqvist | eve | I am calling a stallion for my mare. By morning the Academy will have a pair. |
| tip_lure.ogg | Pieter | eve | Walk Pieter to the three marks at the forest's edge. Set the guns where the jars are. |
| p_set.ogg | Pieter | lure_set | All three jars are open, Doctor. I can smell it from here. |
| l_set.ogg | Dr. Lindqvist | lure_set | Good. Now we wait by the jars. |
| t_told.ogg | Lieutenant Teles | eve_told | The village is at the fort. My men hold the causeway, and the gun is at your landing. One night, Doctor. |
| j_raid.ogg | Frei Joaquim | bonfire_raid | Doctor! They are at the bonfires! In the name of God, send us your guns! |
| j_come.ogg | Frei Joaquim | folk_go | Come, all of you. Up to the station, quickly. |
| j_in.ogg | Frei Joaquim | village_in | We are all inside the palisade. God keep us till morning. |
| t_late.ogg | Lieutenant Teles | teles_late | Shots at the station! Half of you with me, along the causeway. |
| p_past.ogg | Pieter | walked_past | Doctor, they walked past the jars. |
| v_past.ogg | Valadares | walked_past | They are not after your scent. They are going to her. |
| p_island.ogg | Pieter | turtle_comes | The island at the creek's mouth. It is walking. |
| v_island.ogg | Valadares | turtle_comes | Kill it before it settles. The ground goes to mud round it. |
| v_turtle.ogg | Valadares | turtle_dead | The island is dead. The mud is drying already. |
| n_quiet.ogg | The Rio Negro | quiet_falls | Near midnight the forest went quiet. |
| l_quiet2.ogg | Dr. Lindqvist | quiet_falls | You see? They have had enough. By morning she will have her mate. |
| n_ground.ogg | The Rio Negro | turn | Then the ground shook. |
| p_sire.ogg | Pieter | turn | Down the creek trail. Doctor, it is as big as the house. |
| l_lost.ogg | Dr. Lindqvist | turn | He has come for her. My lure brought him. |
| v_lost.ogg | Valadares | turn | We cannot hold this place. Benedito is bringing his canoes round from the rapids. Get the people to the jetty, and hold them there. |
| tip_3.ogg | Valadares | turn | Walk everyone you can into the canoes at the jetty. Dr. Lindqvist and I must be there when they leave. |
| b_bonus.ogg | Benedito | turtle_bonus | The island is dead, so the mud is gone from the landing. I can wait a little longer. |
| t_steps.ogg | Lieutenant Teles | turn_folk_told | The village goes down the fort's steps to the boats. Hold them off us! |
| l_groom.ogg | Dr. Lindqvist | sire_rooted | He did not want to eat her. He lay down beside her like a groom. |
| tip_rooted.ogg | Valadares | sire_rooted | Lying down he cannot bite. Hurt him now and he gets up, and the calling stops a while. |
| p_eggs.ogg | Pieter | eggs_seen | Doctor, there are eggs in her straw. |
| l_young.ogg | Dr. Lindqvist | eggs_seen | She is too young. She is far too young. |
| n_nothing.ogg | The Rio Negro | sire_up | He rose roaring, and the pack closed round him. Nothing they had would kill him. |
| p_fire.ogg | Pieter | fire_1 | Their spit is in the lamp oil! The garden is burning! |
| n_taken.ogg | The Rio Negro | taken | He broke the pen like kindling, and she followed him. |
| l_taken.ogg | Dr. Lindqvist | taken | No. No! She is mine! Shoot him, not her! |
| v_taken.ogg | Valadares | taken | Let her go, Doctor. Your notes, your people. Now. |
| n_room.ogg | The Rio Negro | research_choice | The specimen house was alight. The eggs lay in the trampled straw. |
| v_burn.ogg | Valadares | research_choice | Burn them, Doctor. Whatever she was, do not carry her children down this river. |
| l_save.ogg | Dr. Lindqvist | research_choice | Ten years of work. The Crown's beasts are in that straw. I will not leave them to the fire. |
| v_lamp.ogg | Valadares | research_choice / burned | Give me the lamp. |
| l_crate.ogg | Dr. Lindqvist | research_choice / saved | The crate, Pieter. The notes on top. I carry it myself. |
| b_here.ogg | Benedito | canoes_here | The canoes are at the jetty! In, all of you, quickly! |
| p_pack_goes.ogg | Pieter | pack_goes | They are going with him. All of them, up the creek. Doctor, the eggs! |
| p_fire_took.ogg | Pieter | fire_took | The roof is down on the straw. The eggs are gone, Doctor. |
| l_pieter.ogg | Dr. Lindqvist | pieter_lost | Pieter. Pieter went back for the book. |
| b_warn.ogg | Benedito | warn_2 | Two minutes, Doctor! Then I push off, with you or without you. |
| v_hurt.ogg | Valadares | hurt_l | Doctor, you are hurt. Keep back from them. To the jetty. |
| n_leave.ogg | The Rio Negro | leave | The last canoe pushed off in the grey before dawn. |
| b_leave.ogg | Benedito | leave | Paddle! Do not look back. |
| n_behind.ogg | The Rio Negro | left_behind | The canoes left without them. |
| f_intro.ogg | The Forest | intro_p | She calls. Answer her. Take her home, and leave nobody to follow. |
| l_end1.ogg | Dr. Lindqvist | ending | We went down the river at first light with the station burning behind us. She was gone. He took her from me as a thief takes a horse. |
| l_end_saved.ogg | Dr. Lindqvist | ending | I had the research. I told the Academy I had saved my notes. That was the first lie. |
| l_end_burned.ogg | Dr. Lindqvist | ending | Valadares threw the lamp. I had nothing left but my word, and no one wanted it. |
| l_end_fire.ogg | Dr. Lindqvist | ending | The fire took her eggs before I reached them. I had nothing left but my word, and no one wanted it. |
| l_end_pieter.ogg | Dr. Lindqvist | ending | Pieter sat in the canoe with the specimen book on his knees and did not speak all day. |
| l_end_nopieter.ogg | Dr. Lindqvist | ending | Pieter went back for the specimen book. I have it still. He does not. |
| l_end_north.ogg | Dr. Lindqvist | ending | Valadares turned his canoe round at the first island. He went north after her, up the creek, to the mountain in the cloud. |
| l_end2.ogg | Dr. Lindqvist | ending | I meant to give the Crown its beasts, Majesty. I still think I was right. |
| k_end1.ogg | The King | ending | He wrote that his lure called them. It did not. She called them, and they came for her. |
| k_end2.ogg | The King | ending | She was never stolen. She went home. |
| k_end_saved.ogg | The King | ending | And what he carried out of the fire was not research. It was her children. |

## Balance (tools/sim_campaign_b01.gd)

`godot --headless --fixed-fps 30 --script res://tools/sim_campaign_b01.gd -- active teles=quiet|told clutch=saved|burned`
(a simple bot: the hands build the pen, then two Barracks and work the garden, Musketeers while there is gold; Lindqvist to
the jetty to meet Valadares and then back by the house; Pieter to the ford, then the three jars; the army at the goats, at
the jars while the lure works, at the village (quiet), half of it at the turtle; in Part 3 the people to the jetty, the
army shoots the Sire only while he lies down with few creatures near him, and goes to the jetty when he is up or 2:30 is
left; Lindqvist to the specimen house once she is taken, then to the jetty). Without `active` the player does nothing.

| run (0.38.45) | Part 1 | Part 2 | Part 3 | end |
| --- | --- | --- | --- | --- |
| active, told, saved (last rules) | pen 0:46, Valadares met, goats ~3:45 | lure set, turtle killed, quiet at ~11:00 | the Sire rooted, 5 eggs, taken at 5:30, the crate carried | out: 31 saved of 33 ("many"), gun kept, Pieter lost |
| active, quiet, burned (last rules) | the same | the village in at once, turtle killed | the same; the eggs burned by choice | out: 29 of 33 ("many"), Pieter lost |
| active, told, saved (before the canoes' 1:40 and the bot's retreat) | | | the army attacked the Sire, he rose and killed it (12 to 0 in a minute) | out: 21 of 33 |
| active, quiet, saved (filmed, before powder: no shots) | | | | out: 20 of 32 |
| active, quiet (before the pack left with the Sire) | | | Lindqvist killed going to the specimen house among 17 creatures | DEFEAT |
| passive (does nothing) | the pen never built; the goats' two hunters never driven off (the choice by time at 15:04) | Lindqvist killed at the pen by the waves (~21:00) | | DEFEAT |

Reading: Parts 1 and 2 are won by anyone who plays them (the pen takes a minute, the goats are two Raptors, the lure and
the village are walks, the turtle falls to half a dozen Musketeers). Part 3 is a fair retreat: a player who keeps the
people at the jetty under guard, keeps out of the Sire's way when he gets up and walks Lindqvist to the specimen house
after the pack has gone with her saves nearly everyone (the outline: "a perfect run ... saves nearly everyone"); a player
who fights the Sire loses his army in a minute ("Nothing you have will kill it.") and saves about two thirds; walking the
heroes into the pack loses the mission. Pieter is the one most often lost (110 health, he walks with the hands): the bot
never once kept him. Doing nothing loses (Lindqvist dies at the pen in Part 2). Speed: the passive Part 1 is long (15
minutes: the goats wait to be driven off; the choice comes by time).

## Stills: the prompts for the owner (ChatGPT, one request each, at most 3 reference images)

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
- The stills (simple drawings; b01 and b08 made from the King's painting p01_01, b03 from the station hub painting).
- The people are stand-ins: Lindqvist a Musketeer (a fowling piece), Valadares and Teles Officers, Pieter, Benedito and the
  villagers Labourers, Frei Joaquim a Missionary, Linnea a Brood Mother's sprite at 0.3 in the station's yellow. Their art
  folders are named (above).
- The sounds: Linnea's call is the Brood Mother's voice raised to a trill, the forest's answer a Raptor's far off, the
  Sire's roar his own pitched down.
- The map: the station's pen and buildings stand on the rise; the igapó is water and trees standing in it (no swamp ground
  tile exists: the Mound Turtle's own swamp is the swamp); the jetty, beach and steps are bank cells with boat props; the
  waterfall is the creek's top under the rock wall.
- The hub after the fall: the station's painting tinted, its title and lines changed (the warehouse's own painting later).

## Claude's choices for the owner

1. LINNEA ON A TEAM OF HER OWN: "station-owned" is built as a fourth team, `pen` (the station's side, the station's YELLOW,
   scripted), not as a Brood unit inside the Crown station's own team: the player never gets a Brood Mother's card to press,
   and the Brood's own rules run on a Brood team. She is a Brood Mother's kind drawn at 0.3 (her own art later), caged and
   untouchable all night (never the target: shooting at her does nothing).
2. THE PACK IS SCRIPTED, not the Brood computer (as the Clockwork's machine): the Brood computer plans from a Mother and an
   economy, and the pack has neither; the waves come on the calls' timetable from three trail heads, capped (22 alive in Part
   2, 12 while the Sire calls in Part 3).
3. THE LURE: Lindqvist EXPLAINS it first (three lines: what it is made of, what it does, where the jars go), then the
   objective; the first two waves go to their trail's jar if that jar is set, from the third they walk past (said once).
4. THE PEN is 11 stakes and a gate laid out as building sites the hands build (the owner's "build her pen"); a site knocked
   down meanwhile doesn't hold the objective up.
5. THE SIRE IN PART 3: he walks through the station to her pen without biting (as if it were reeds), lies down beside it;
   rooted he cannot bite; his health stops at a third (he gets up roaring, two Raptors come, he lies down again 30 s later,
   healed to 70%); while he lies there he calls every 30 s (3 Raptors) and she lays one egg every 25 s (5 in all).
6. HE TAKES HER at 5:30 into Part 3 (on its own clock, so the turtle's extra 1:30 for the canoes never makes him take her
   after the specimen house has burned); THE PACK GOES WITH THEM, but for stragglers ("They are going with him. Doctor, the
   eggs!"): the window for the second choice. The specimen house is spared from the pack's attacks in Part 3, only the fire
   takes it (at 2:30, in 6:00).
7. THE PEOPLE COUNTED: everyone of the station's team but the two heroes, and the villagers, when Part 3 begins; anyone who
   walks onto the jetty (or, told, the villagers onto the fort's steps) is saved. The bands: few under 10, some 10-19, many 20+.
   The garrison's soldiers are not counted (they go by the fort's steps with the village).
8. LINDQVIST AND VALADARES have 320 health (a Musketeer has 70, an Officer 80): heroes of the story, still killable. Pieter
   110, Teles 160, Benedito 120 (spared at his canoes).
9. VERSUS is "kill a hero" (as the Clockwork's): the pack's player gets every wave and the Sire as his units and wins by
   killing Lindqvist or Valadares. Not built from the outline: choosing a trail head for each call, rooting the Sire himself
   by her pen (a father's nest needs his own Mother; the scripted root works for a scripted Sire only), the scored end
   (the saved under half). The clutch and the taking still come on time in versus.
10. NO "WILD" TEAM FLAG: nothing in a mission needed it (the end is the mission's); a versus pack player sees the Brood's HUD
   with no Mother.
11. THE BONFIRES are the map's campfire props (the engine has no placed lights); the fire's light is the `fire_night` tint.
12. THE STORYLINE'S HUB BEFORE THE FALL keeps the station's painting with HER CRATE; the plateau's egg and the specimen jar
   (the hub's old lines) wait for the Specimens (`requires` a05_specimens, an id for that mission when it is written).
13. EASY / HARD: the campaign has no difficulty setting yet; the outline's "Easy gives two minutes more" is not built.
14. THE CANON (proposed in the outline: keep it quiet, save the research) is each choice's default.
15. THE CANOES COME ROUND 1:40 INTO PART 3 (Benedito: "The canoes are at the jetty!"): until then the jetty takes nobody,
   so the people must be held there (or kept back); without it a player walked everyone aboard in the first seconds.
16. POWDER: the station starts with 400 powder and gets 250 more at nightfall (the Crown starts with none, and no Powder
   Mill is built for it: the Musketeers it trains would come out with no shots). It may still build a Powder Mill.

## Tests run

- tools/test_campaign_b01.gd: 277 checks, 0 failures (the data and translations; every engine feature on its own; three
  play-throughs: A told + burned, B quiet + saved, C quiet + the fire takes the eggs, Pieter lost; the two defeats; the hubs
  after, by the flags; the King's study).
- tools/test_campaign.gd: 0 failures (the engine's own test, every mission's data, the hubs; its hub check now opens THE
  NATURALIST: `naturalist`, HER CRATE).
- tools/test_campaign_m1.gd: 0 failures (the Crown's prologue unchanged).
- tools/test_campaign_c01.gd: 0 failures (the Clockwork's prologue unchanged).
- tools/test_tutorial.gd: 0 failures.
- tools/test_brood_new.gd: 1 failure, PRE-EXISTING (the same check fails on main 0.38.44 without this job's changes: the
  Venom Sire's BUILD-card tooltip is empty headless); the Brood hooks this job added (a caged egg, a role's scale, a
  scripted father's nest) only act on units a mission marks.
- PRE-EXISTING: every headless Godot run here ends with "Aborted" (exit 134) AFTER its last line (as the Clockwork build
  noted).
- Not run: the faction and AI tests (no unit, price or skirmish rule changed; the new Entity/Unit fields default to off).
