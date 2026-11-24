# The Chatterbox list: every voice line still to record

The owner records voices on his PC with `tools/voice_clone/` (Chatterbox; `run.bat`, `lines.txt` "name | text", a
`[ref refs/<name>_ref.wav]` line switches the voice). ElevenLabs only to DESIGN a new voice (a 10-20 s sample saved as
`tools/voice_clone/refs/<name>_ref.wav`), then Chatterbox for all its lines. Designed voices only, never a real person's.

ALL CAMPAIGN TEXT IS PLACEHOLDER: the owner rewrites the dialogue before recording. This list says WHAT is waiting and
WHERE its table is; the tables themselves live in each mission's build doc.

DONE 0.38.74 (re-recorded at pitch 0, in the game). REDO THE KING (owner 2026-11-18 21:57: "sounds weird like inside a box"): the -1.5 pitch shift (librosa) muffled him; his 85 new
lines were taken out of the game (0.38.73). Re-record with tools/voice_clone/lines_king.txt ([pitch 0]); first delete
out\*__k_*.wav, out\a07__tip_church.wav and out\a07__tip_fire.wav or the run skips them.

RECORDED 2026-11-18 (0.38.70): the big run (tools/voice_clone/lines_big.txt, 374 lines) is in the game: the Brood
announcer's 21 lines in Lindqvist's v2 voice and every mission line of the King, Hollweg, Lindqvist, Valadares (explorer ref),
Fairleigh, Ruggieri and Varenne. Still to do: the voices marked * below (design them first), then make_big_lines.py again.

NEXT RUN (2026-11-22): tools/voice_clone/lines_big.txt holds Father Ferrer's 51 lines (his voice designed 2026-11-22,
refs/ferrer_ref.wav) and the 3 lines added since the big run (Hollweg's two c01 endings about the mill seed, Fairleigh's
p01 line about the second camp). The rest waits on a voice to DESIGN first (section 3): 254 lines, most of them Tomasz
49, Jakob 26, Delorme 17, Benedito 16.

NEXT RUN, UPDATED (2026-11-22, 0.38.157): ten more voices designed in the second ElevenLabs account (refs/README.txt:
Jakob, Delorme, Benedito, Brother Anselm, Colonel von Rauch, the Machine, the Captain of the Watch, Pieter, the
Sergeant, old Cardinal Tomasz). lines_big.txt now holds 166 lines: Ferrer 51, Jakob 26, Delorme 17, Benedito 16,
Brother Anselm 13, von Rauch 13, the Machine 11, the Captain 7, Pieter 7, Cardinal Tomasz 2, Hollweg 2, Fairleigh 1.
Still to design: young Tomasz (49 lines; the owner's first account has a "Tomasz Wierzbicki" voice), the Cardinal Dean
(a07; make_big_lines.py SAME_KEY keeps him apart from old Cardinal Tomasz), and the one-line parts.

NEXT RUN, FINAL (2026-11-22, 0.38.159): every campaign speaker now has a voice. lines_big.txt holds 235 lines: the 166
above plus young Tomasz 49, the Free Assembly 7, and the Cardinal Dean, Rouviere, Mere Gautier, the Commissary, the
guide (2 each), Teles, Frei Joaquim, Will Hollins (1 each). Only the Sergeant has no line outside the test bed.

RECORDED 2026-11-22 (0.38.164): the 235 lines of lines_big.txt are in the game (every campaign speaker but the
Sergeant and the Lyon watchman). lines_big.txt is empty until new lines are written.

EMOTION RUN RECORDED 2026-11-22 (0.38.168): the 278 emotional takes replaced the calm ones (the calm takes are in git
history before 0.38.168). If some still sound flat, the next step is a second, angry reference per main character.

THE EMOTION RUN (owner 2026-11-22: "certain lines have no emotion at all", Valadares accusing the doctor and firing the
thatch): tools/voice_clone/emotions.json tags 280 campaign lines shout / angry / urgent / grief / wonder, each with a
Chatterbox exaggeration and cfg (presets in the file; a line not listed is calm). `make_big_lines.py --emotion` writes
lines_emotion.txt: those lines again (recorded or not), with [exaggeration] / [cfg] before each change. Run
`run.bat --lines lines_emotion.txt --out out_emotion`, listen, and send out_emotion back: import_voice.py replaces the
calm takes. New lines get their emotion from the same file in the normal run. What Chatterbox can and cannot do:
exaggeration (0.25-2.0) raises the energy, a lower cfg slows it down and lets the emotion breathe, punctuation helps
("!" shouts, "..." hesitates), but it copies the REFERENCE clip's delivery most of all: a calm reference speaks calmly.
The strongest fix is a second reference per main character, the same voice speaking angrily or shouting
(refs/<name>_angry_ref.wav), used for the shout and angry lines.

## 1. The Brood announcer: a new set in Lindqvist's new voice (owner 2026-11-18 15:55)

"Now that the voice of the naturalist changed we need a completely new voice line set for the Brood announcer."
The Brood's skirmish announcer is the campaign's scientist, Dr. Lindqvist. Its 21 lines (2026-11-04) were made in the
FIRST ElevenLabs scientist voice; Lindqvist's voice is now v2 (`refs/lindqvist_ref.wav`: an elderly Oxford-educated
Scandinavian professor, a condescending atheist lecturer). Record all 21 again in that voice.

- Voice: `[ref refs/lindqvist_ref.wav]`
- Files: `assets/voice/announcer/brood/<key>.ogg` (replace the old ones; same keys, same names; English only, see
  `Sfx.ENGLISH_ONLY`). Keep the old set's sources in `art/audio_src/brood_scientist/` as they are.
- Texts: today's lines below (from docs/announcers.md). The owner may rewrite them to sound like the new Lindqvist
  (condescending, lecturing) before recording; keep each short (the alarms are said in a fight).

| key | when | text today |
| --- | --- | --- |
| unit_ready | not wired | Another splendid specimen. |
| building_done | a building finished | Ah, it has taken root. |
| research_done | a research finished | Fascinating! They have adapted. |
| under_attack | units attacked | Oh no, the Brood is under attack! |
| base_attack | rooted creatures attacked | Good heavens, they are attacking the nest! |
| workers_attack | grubs attacked | The poor grubs are under attack! |
| ally_attack | an ally attacked | The Brood's allies are in trouble, I'm afraid. |
| expansion | a new ground rooted | A new nest! How marvellous. |
| building_lost | a rooted creature killed | Oh, one has fallen. Such a pity. |
| site_lost | a growth killed | The growth has been torn away! |
| bad_place | can't root there | It won't take root there, I'm afraid. |
| no_gold | not enough food | They're hungry. More food is needed. |
| no_res2 | not enough spoils | The Brood needs more spoils. I'm afraid. |
| no_supply | no room left | The clutch needs more room. |
| depleted | ground spent | This ground is quite exhausted. |
| victory | match won | Magnificent! Nature triumphs! |
| defeat | match lost | Oh... the end of a magnificent species. |
| paused | game paused | Let us pause and observe. |
| resumed | game resumed | Splendid. Let us continue. |
| mother_attack | the Mother attacked | The Mother! Someone protect the Mother! |
| sire_lost | a father killed | Oh dear. A Sire has fallen. |

## 2. The campaign missions (built, all text placeholder)

Each mission plays `campaign/voice/<id>/<line id>.ogg` when the file is there (CampaignVoice). The voice table with
every line is in the doc named. Counts are lines per speaker; speakers marked * need a voice DESIGNED first.

| mission | table | lines | speakers |
| --- | --- | --- | --- |
| p01_leaf (Prologue, Virginia) | docs/campaign_mission1_voice.md | about 40 | the King (recorded in ElevenLabs), Tomasz*, Fairleigh, Ruggieri, Varenne |
| c01_thirteenth (Nuremberg) | docs/campaign_c01_build.md | 67 | Hollweg 31, Jakob* 12, Ferrer* 12, Captain of the Watch* 5, the King 4 |
| b01_specimen (Rio Negro) | docs/campaign_b01_build.md | 65 | Lindqvist 33, Valadares* 11, the King 6, Pieter* 5, Teles*, Frei Joaquim*, Benedito* 1 each |
| a01_presses (Lyon) | docs/campaign_a01_build.md | 61 | Tomasz* 19, Captain Delorme* 17, the King 7, Rouvière*, Mère Gautier*, Sergeant*, Cardinal Tomasz* 2 each |
| a02_furth (the Fürth line) | docs/campaign_a02_build.md | 58 | Hollweg 20, Colonel von Rauch* 12, Jakob* 9, the King 8, the Commissary* 2 |
| a03_plateau (the Lost Plateau) | docs/campaign_a03_build.md | 57 | Valadares* 37, the King 9, Benedito* 7, the guide from Nazaré* 2 |
| a04_visit (Ferrer's visit) | docs/campaign_a04_build.md | 79 | Ferrer* 35, Hollweg 13, Brother Anselm* 9, the King 6, Jakob* 4 |
| a06_barricades (Paris) | docs/campaign_a06_build.md | 69 | Fairleigh 28, Tomasz* 10, the King 9, Ruggieri 8, Varenne 3, Will Hollins* 1 |
| a05_specimens (the Specimens) | docs/campaign_a05_build.md | 58 | Lindqvist 39, the King 8, Benedito* 8, Pieter* 2 |
| a07_council (the Council of Rome) | docs/campaign_a07_build.md | 49 | the King 28, Tomasz* 7, Hollweg 4, Ferrer* 3, Lindqvist 3, Valadares* 2, the Cardinal Dean* 2 |
| d02_exodus (the Exodus, Act 2) | this file, "d02_exodus" below; docs/campaign_d02_build.md | 63 (+12 narrator, 2 NEW cards) | Hollweg 25, Ulrich* 16, the King 6, Ferrer 6, Colonel von Rauch* 5, Jakob* 3, Commissary Brandt* 2 |
| d03_fazenda (the Island, Act 2) | this file, "d03_fazenda" below; docs/campaign_d03_build.md | 60 (+13 narrator, 2 NEW cards) | Lindqvist 20, Valadares* 17, Pieter* 12, the King 6, Desembargador Fonseca* 5 |
| d04_concordia (the City of Gears, Act 2) | this file, "d04_concordia" below; docs/campaign_d04_build.md | 74 (+15 narrator, 2 NEW cards) | Hollweg 31, Ulrich* 18, Captain Arruda* 10, the King 6, Varenne 4, Citizen Morel* 3, Padre Anselmo* 2 |
| d01_minas (the Gold of Vila Rica, Act 2) | this file, "d01_minas" below; docs/campaign_d01_build.md | 69 (+19 narrator, 3 NEW cards) | Tomasz* 30, Captain Meneses* 21, Lieutenant Ramos* 9, the King 6, Cardinal Tomasz 2, a townsman* 1 |
| d06_queen (the Queen, Act 2) | this file, "d06_queen" below; docs/campaign_d06_build.md | 39 (+28 narrator, 2 NEW cards) | Lindqvist 24, Pieter* 9, the King 6 |

Narrator lines ("Nuremberg", "Paris", "The Machine", "The Free Assembly", "The Rio Negro", "Lyon", "Fürth", "The
Mountain", "Rome", "The Creatures", "The Automata") can stay as text.

### d02_exodus (the Exodus)

Line ids are the mission's (`campaign/voice/d02_exodus/<id>.ogg`). The feeling is how the line should sound; lines
without one are plain. The narrator's 12 lines and the two NEW cards can stay as text.

| id | speaker | text (placeholder) | feeling |
| --- | --- | --- | --- |
| k_open1 | the King | Ten months after Rome I signed the commissary's orders myself. Seize the works at Fürth. Stop every machine that winds itself. | heavy, owning it, no regret in the voice |
| k_open2 | the King | Hollweg was told the commissary was coming. He did not wait for him. | dry |
| h_open1 | Hollweg | I called it a rescue. The families had nowhere else. The machines had nowhere at all. | old, defensive, still proud |
| h_open2 | Hollweg | We rang the night bell at the barn. By morning Fürth was empty. | quiet, remembering |
| k_open_c | the King | Father Ferrer rode with the commissary as Rome's witness. He wrote down what he saw. He always did. | warm about Ferrer |
| f_open_c | Ferrer | We were a day's ride off when the dogs found their scent. The guild was already on the road. | tired |
| h_1 | Hollweg | Every family to its cart. Every machine that can walk, wind it. We leave tonight. | urgent, commanding, low (a night order) |
| u_tip1 | Ulrich | The carts wait at the barns, Meister. Send one of ours to each and the family climbs in. The marked ones on the map. | |
| u_tip2 | Ulrich | Your spring cart winds anything that stands on the brass plates round it. Keep the soldiers near it on the road and they never run down. | |
| u_tip_new | Ulrich | The Clock Soldiers know the shield wall now, Meister. Raise their shields with SHIELD FORWARD on their card when the muskets face them. | |
| h_draw0 | Hollweg | And the drawings. Every sheet of the Perpetual. Nobody touches those chests but me. | possessive, sharp |
| h_draw | Hollweg | The drawings are aboard. If they take that cart, they take everything I ever made. | relief with fear under it |
| h_people | Hollweg | No drawings this time. I left them in Nuremberg for the people. I carry the Perpetual in my head. | bitter pride |
| j_wait | Jakob | Meister. Before you go. Come here, please. | nervous, young |
| j_stay1 | Jakob | I am not coming, Meister. I told Father Ferrer what I found, and I will tell the commissary. | DRAMATIC: firm but shaking, he loves the old man |
| h_stay | Hollweg | They will melt everything, Jakob. Everything we built. | DRAMATIC: hurt, pleading without saying please |
| j_stay2 | Jakob | Then let them. I would rather melt a wheel than see it take out its own stop-work again. God keep you, Meister. | DRAMATIC: steady, a goodbye; soft on the last words |
| h_nojakob | Hollweg | Jakob would have known which wheels to leave. Jakob is not here. | grief held down |
| u_warn | Ulrich | Riders on the Bamberg road, Meister. Not long now. | tense |
| h_fallen | Hollweg | The machine sits in my own works. My own tower. Burn its seed, or no cart leaves this yard. | anger at himself |
| h_reclaimed | Hollweg | It is down. Now the families. Quickly. | breathless |
| u_dogs | Ulrich | Dogs, Meister! They are early! The carts must go now! | alarm, shouted |
| h_road | Hollweg | West over the Rednitz, then down the valley to the Main. Keep a fighter by every cart. | commanding |
| u_take | Ulrich | They will not shoot the carts, Meister. They will stand round one until it is theirs. Drive them off it and the bar empties. | |
| u_riders | Ulrich | Riders in the valley! They came round by the Würzburg track, from the north! | shouted |
| u_dogs2 | Ulrich | Dogs on the slope, Meister, and riders behind them! They have our scent! | shouted |
| u_riders2 | Ulrich | More riders on the track! | shouted |
| u_column | Ulrich | The commissary's column is in the yard behind us. Musketeers, and guns. | grim |
| u_column_m | Ulrich | The commissary's column is in the yard behind us. Musketeers, and more nets than guns. | grim, a little relieved |
| h_sortie | Hollweg | Let it have the walls. It will meet the commissary before it meets us. | cold |
| u_retake | Ulrich | Get round that cart before it reaches their camp and it is ours again! | shouted |
| h_draw_taken | Hollweg | The drawings! They have the drawings! | DRAMATIC: a cry, real loss |
| r_minute | von Rauch | Halt. All of you. Let them go, God help them. One minute. | DRAMATIC: an officer's order, but his voice gives (Nuremberg's bells) |
| b_minute | Brandt | Colonel! You have the Crown's orders! | shocked, thin, officious |
| h_minute | Hollweg | Von Rauch remembered the bells of Nuremberg. Go, now, while he looks away! | moved, then urgent |
| r_minute_end | von Rauch | The minute is up. After them. | flat, duty again |
| u_clock | Ulrich | We set up the travelling clock by the brook, Meister. Its field winds anything near it. Five of the journeymen came over on the first barge: they are yours. There is a turret in the crates. | brisk |
| h_bridge | Hollweg | Hold the bridge until the last barge is loaded. The shields in front, the turret behind them. | a last stand, calm |
| u_turret | Ulrich | Send a Winder to the turret's site at the bridge's foot. It builds it with the guild's last coins. | |
| u_broken | Ulrich | The rearguard is gone, Meister! They are on the landing: get to the barges before they lay hands on you! | DRAMATIC: panic |
| u_last | Ulrich | The last barge is loaded, Meister! Come aboard, now! | shouted, hopeful |
| h_aboard | Hollweg | Cast off. Do not look back. There is nothing behind us now but the Crown. | DRAMATIC: exhausted, final, no triumph |
| h_hurt | Hollweg | I am hit. Keep them off me, they want me alive. | pain, through teeth |
| b_c1 | Brandt | By the Council of Rome and the King's seal: the works at Fürth are the Crown's. Ride. | reading a document, pompous |
| f_c1 | Ferrer | Take the carts, Commissary. Do not harm the families. And I want Hollweg alive, to answer. | firm, a priest's authority |
| r_c_tip | von Rauch | My riders take a cart by standing round it with none of theirs by it. Bring Hollweg down and stand a man by him: he is taken. | soldier's briefing |
| f_c_road | Ferrer | They are on the road west. The barges on the Main will not wait for us. | |
| r_c_sortie | von Rauch | The machine is in the works behind us. Watch the rear. | |
| r_c_push | von Rauch | The reserve is on the track, Commissary. Three more muskets and a rider. | |
| f_c_won | Ferrer | He is taken. God forgive us both, Meister. | DRAMATIC: sorrow, no victory |
| f_c_lost | Ferrer | The last barge is gone down the Main. He is beyond the Crown now. | quiet, almost relieved |
| h_end1 | Hollweg | We went down the Main to the sea, and at Hamburg we took ship. Nobody there asked what was in the crates. | old, storytelling |
| h_end_many | Hollweg | Nearly every family came with us. I counted them on the deck, every morning. | tender |
| h_end_some | Hollweg | Some of the families came. The others went back to Fürth in the Crown's carts. | regret |
| h_end_few | Hollweg | Few of the families came. The deck was very quiet. | DRAMATIC: grief |
| h_end_draw | Hollweg | And the drawings came with me. Every sheet. | quiet pride |
| h_end_drawlost | Hollweg | The drawings stayed with the Crown. I drew them again from memory, on the ship. | stubborn |
| h_end_jakob | Hollweg | Jakob stayed. I wrote to him from Hamburg. He never answered. | DRAMATIC: hurt, held back |
| h_end_manifest | Hollweg | The ship's manifest said: machinery, for a mine in the southern highlands of Brazil. That was true. It was my mine. | sly, a hint of what is coming |
| k_end1 | the King | He calls it a rescue. I call it what it was. The guild left the Crown that night, and took its families with it. | DRAMATIC: firm, sad, the verdict |
| k_end2 | the King | I do not blame the families. I blame the man who told them the Crown would melt their children's bread. | gentle, then hard |
| k_end_c | the King | Hollweg in the Crown's custody, twenty-four years before he came to my fire. That is not how it went. | dry correction |
| f_end_c | Ferrer | We brought him to Rome in irons, and the carts back to Fürth. The commissary called it a success. | DRAMATIC: bitter, he does not agree |

### d03_fazenda (the Island)

Line ids are the mission's (`campaign/voice/d03_fazenda/<id>.ogg`). The feeling is how the line should sound; lines
without one are plain. The narrator's 13 lines and the two NEW cards can stay as text. The strongest lines have a preset
in tools/voice_clone/emotions.json (`d03__<id>`).

| id | speaker | text (placeholder) | feeling |
| --- | --- | --- | --- |
| k_open1 | the King | Lindqvist walked out of Rome with the animals the Council had ordered destroyed. He went home to his river. | flat, a judgement |
| k_open2 | the King | Two years later I sent Valadares up that river with Rome's order in his satchel. | dry, a little weary |
| l_open1 | Lindqvist | An island below Óbidos. Sugar for the tax man, and behind the cane, the forest, and in the forest, my pens. | old, fond of the place |
| l_open2 | Lindqvist | They were not monsters. They were a new kind of animal, and every animal can be bred. I had the lures. They came to the lures. | conviction, a scientist lecturing |
| l_open_linnea | Lindqvist | And among them her daughter. Out of the clutch we carried from the station. Growing. | tender, proud |
| l_open_plateau | Lindqvist | And a young Mother we netted on the mountain. My breeding stock. | proud |
| k_open_c | the King | Valadares wrote me a report from that island. It is the only honest account of it I have. | respect for Valadares |
| v_open_c | Valadares | We came up the river at first light. Sugar on the banks, a white house, a doctor at the landing with his hat in his hand. | plain report, wary |
| l_1 | Lindqvist | Pieter! A boat on the river, below the point. The Crown's flag. Get them out of the old pens. All of them. Into the forest, now. | DRAMATIC: urgent, sharp orders, fear held down |
| p_tip1 | Pieter | They follow the lures, Doctor, nothing else. The keepers go first, and the animals stay inside the ring. Out of it they wander. |  |
| p_tip2 | Pieter | Over the creek by a ford, then up the paths to the clearings. The young Mother roots best in the nest clearing, in the middle. |  |
| l_storm | Lindqvist | The big egg. It is cracking. Pieter, the book. Write the hour. | hushed, excited |
| l_storm2 | Lindqvist | Wings. A Storm Sire. The first one ever bred by a man. Root him by her, and she will lay for him. | DRAMATIC: wonder, a father's pride, almost a prayer |
| l_hatch | Lindqvist | Hatchlings. They will sit in the canopy and watch the river for me. Nobody looks up at a bird. | pleased, sly |
| p_ready | Pieter | They are all in the forest, Doctor. Quiet. I can hear the oars. | whispered, relieved |
| p_warn | Pieter | The canoes are rounding the point, Doctor. Not long now. | tense, low |
| f_land | Desembargador Fonseca | Doctor Lindqvist. I carry an order of the Holy See and of His Majesty. You know its contents. | formal, cold |
| l_land | Lindqvist | Sugar, Desembargador. Sugar and a few goats. Search what you like. | too easy, a host's smile |
| v_land | Valadares | I have seen what you keep, Doctor. On the mountain. I will know its prints. | quiet threat |
| v_land_w | Valadares | I do not know what I am looking for, Doctor. So I will look at everything. | blunt, patient |
| p_still | Pieter | Keep them still, Doctor. A still animal in the forest is a shadow. A moving one is an animal. | whispered, urgent |
| l_dinner | Lindqvist | The Desembargador has come a long way. He will be hungry. I will ask him to dine. | smooth, scheming |
| f_dinner | Desembargador Fonseca | Dinner? Well. The search can spare its magistrate for an hour. Sergeant, your men with me. | pompous, tempted |
| v_dinner | Valadares | Go and eat, Desembargador. I am not hungry. | dry contempt |
| f_dinner_end | Desembargador Fonseca | A fine table, Doctor. Now. Back to work, men. | full, satisfied, then brisk |
| p_decoy | Pieter | A lure post at the west point, or at the old chapel, and they will go and look at it. Men always go and look. | a grin in the voice |
| p_riders | Pieter | The riders have crossed the creek at the west ford, Doctor. They are going up the paths now. | tense, fast |
| v_hunch | Valadares | Everything on this island walks from the middle out. We look in the middle. | thinking aloud, sure |
| v_tracks | Valadares | Fresh prints. Three toes, a dragged claw. This way. | low, a hunter |
| v_found | Valadares | There. You see it? Sugar and goats, the Doctor said. | DRAMATIC: cold triumph, contempt |
| l_found | Lindqvist | No. Not that one. Pieter, move them. Move the others. | DRAMATIC: panic, a man losing a child |
| p_half | Pieter | They have found half of them, Doctor. If they find many more, they will burn the pens and the house with them. | frightened |
| p_dusk | Pieter | The light is going. They will not search the forest in the dark. | relief |
| p_restless | Pieter | Doctor! One of the young is up. It smells the goats. It is going for the camp! | DRAMATIC: alarm, shouted in a whisper |
| l_restless | Lindqvist | A lure under its nose, right under it, or it will not turn. If it reaches those goats they will see everything. | urgent, tight |
| l_held | Lindqvist | Got it. Easy now. Back to the forest, slowly. | soft, soothing an animal |
| p_back | Pieter | It is back in the forest, Doctor. It is lying down. | relief, breathless |
| v_fight | Valadares | Torches! Into the forest, all of you! Now we know where they are. | DRAMATIC: shouted, fierce |
| p_lost | Pieter | They have found nearly all of them, Doctor. They are bringing the pitch for the pens. | DRAMATIC: despair |
| f_dawn | Desembargador Fonseca | We found what we found, Doctor. It will all be in my report, and in Rome. | formal, a warning |
| v_dawn | Valadares | You did not breed them, Doctor. Nobody breeds a thing like that. Somebody made it, long ago, and it is still being made. | DRAMATIC: quiet, grave, almost pity |
| l_dawn | Lindqvist | Superstition. They evolved. Everything evolves. | dismissive, stubborn |
| v_c1 | Valadares | Three parties, Desembargador: the west paths, the middle and the east. The riders take the fields. I follow the prints. | commanding, practical |
| v_c_tip | Valadares | They sleep in the clearings in the day. Walk close, and have your muskets ready: a sleeping one sees you at three steps. | low, careful |
| v_c_tracks | Valadares | Pale claw marks on the ground are fresh prints. They lead to the ones that walk. |  |
| f_c_dinner | Desembargador Fonseca | The Doctor asks me to dine. I will go, Valadares. Somebody must watch the man himself. | pompous |
| v_c_night | Valadares | Night. They will move in the dark: watch the camp and the goats. | alert |
| v_c_won | Valadares | Enough. Burn the pens. Write it down, Desembargador: we found them. | DRAMATIC: hard, final |
| v_c_lost | Valadares | Dawn, and the canoes. We found too little. He will say we found nothing. | bitter |
| l_end1 | Lindqvist | They left at dawn. The Desembargador wrote his report. Valadares wrote another. | old, slow |
| l_end_all | Lindqvist | They found nothing. Nothing. I stood at the landing and waved my hat. | DRAMATIC: triumph, an old man laughing |
| l_end_some | Lindqvist | They found some, and burned what they found. The rest lay in the forest and did not move. | stubborn |
| l_end_few | Lindqvist | They found most of them. I watched the pens burn from the house. I kept what was left. | DRAMATIC: grief, defiant |
| l_end_storm | Lindqvist | And the Storm Sire flew over the canopy every evening after, and came back to the lure. | wonder, wistful |
| k_end1 | the King | He tells it as if he won. Valadares found more than he thinks. Valadares found enough to know what was on that island. | firm correction, no anger |
| k_end2 | the King | And Lindqvist still believes the thing evolved. The Church told him what it was. He did not listen then either. | tired, sorry for him |
| v_end_c | Valadares | We burned the pens we found. The Doctor stood at the landing with his hat in his hand, and did not look at the smoke. | grave, plain |
| k_end_c | the King | He told me Valadares found nothing. Valadares found enough. | firm |
| v_end_c_lost | Valadares | We left at dawn with half a report. I knew they were there. I could smell them. | bitter, sure |
| h_hurt | Lindqvist | My leg. Pieter, the lures. Keep them together. | pain, clipped |

### d04_concordia (the City of Gears)

Line ids are the mission's (`campaign/voice/d04_concordia/<id>.ogg`). The feeling is how the line should sound; lines
without one are plain. The narrator's 15 lines and the two NEW cards can stay as text. Varenne and Morel never speak in
the same game (a06 `varenne` spared: Varenne; executed: Morel).

| id | speaker | text (placeholder) | feeling |
| --- | --- | --- | --- |
| k_open1 | the King | He named it for concord. The valley named it otherwise. | dry, a small sad smile |
| k_open2 | the King | Two years after he left my Crown, Hollweg bought a dead mine at the bottom of the world, and built a city on it that answered to nobody. | measured, a judge reading a record |
| h_open1 | Hollweg | A city that governs itself. A council of masters, every voice a wheel, and the wheels in time. That was the plan. | old, proud of a dream he now doubts |
| h_open2 | Hollweg | Rome had said those very words were a sin. I said them louder. | DRAMATIC: defiance remembered, with shame under it |
| h_open_v | Hollweg | A ship from Lisbon brought us a man I never thought I would need: Etienne Varenne, the Assembly's orator, whom the King had spared and sent away. | wry |
| h_open_m | Hollweg | A ship from Lisbon brought us one of the Assembly's men, Citizen Morel. Varenne was dead. Morel had not forgiven anyone for it. | uneasy |
| h_1 | Hollweg | The tower first. Over the old shaft, where the ground is sound. Everything else turns round it. | brisk, a builder again |
| u_tip1 | Ulrich* | The tower's site is marked by the shaft, Meister. Send the Winders; four hands raise it quickly. |  |
| u_dark | Ulrich* | And look how little we know of this place. Everything off the plateau is dark to us: anyone could walk up those roads and we would not see him. |  |
| h_tower | Hollweg | The tower stands. Now the spring, then the birds. I want this country mapped from the air, every road, before the first winter. | pleased, eager |
| u_field | Ulrich* | The tower's gears are turning, Meister. Keep the soldiers on the gear rings round our buildings: there they stay wound. Off the gears they run down in a minute or so. |  |
| u_spring | Ulrich* | The Aviary runs on Tension, Meister, and Tension comes from the Mainspring. Its site is by the Escapement. |  |
| u_presses | Ulrich* | While the Aviary rises: the city has cogs for now, not for ever. The press north of the tower brings more, and the Light Works turns them into soldiers. |  |
| u_aviary | Ulrich* | The spring is wound. Now the Aviary: its site is east of the tower. A Winder or two will raise it. |  |
| u_swifts | Ulrich* | The Aviary is up. Pick it and make Swifts. Little brass birds: they fight only other birds, but they see a long way. |  |
| h_map | Hollweg | Fly them down the three ways: the cart road west, the pine path north-west, the ranch track south. What a bird has seen, the guild knows. | commanding, hungry to know |
| h_mapped_all | Hollweg | There. The whole country under one eye. From above, every road is only a gear's tooth. | DRAMATIC: rapture, a little too much (the flaw speaking) |
| v_1 | Varenne | A city without a lord, Meister. I have heard this sermon before. I preached it, in Virginia and in Paris. | ironic, tired |
| h_v1 | Hollweg | Yours was made of men, Varenne. Mine is made of wheels. Wheels keep time. | gentle certainty |
| v_2 | Varenne | Paris burned keeping time. I watched it from a boat. | DRAMATIC: quiet, haunted |
| m_1 | Citizen Morel* | No lord and no bishop. Good. Then let the valley learn it too, Meister, and quickly. | cold, impatient |
| h_m1 | Hollweg | The valley can learn what it likes. We did not come here to teach. | curt |
| h_crates_seen | Hollweg | Somewhere under us lie the two crates I sent from Nuremberg. They had lain on a quay in the jungle once, I learned later. | remembering, a shadow over it |
| h_memory | Hollweg | No Heavy Works yet. I build it from memory, and memory is slow. The drawings are in Nuremberg, or in the Crown's hands. | frustrated, ashamed |
| u_captain | Ulrich* | A rider from the valley, Meister. Their captain, coming up the cart road. |  |
| a_wait | Captain Arruda* | I am Bento Arruda, captain of the valley's militia. I will talk with the master of this place. Here, on the road. Not up there among those things. | plain, stubborn, a cattleman |
| u_parley | Ulrich* | He wants to talk, Meister. Walk down to him: the council's speaker will go with you. We will keep the machines back. |  |
| a_parley1 | Captain Arruda* | My people say you raise the devil's own works up here. Clocks that walk. They say it was such things that ended the old world. | blunt, honestly afraid |
| h_parley | Hollweg | They are tools, Captain. I have ordered them never to raise a hand against a man of your valley. Not one. | earnest, a promise |
| v_parley | Varenne | Captain, I have stood where you stand, at the head of frightened men. Go home. Nobody here wants your land. | DRAMATIC: warm, one exile to a frightened man |
| m_parley | Citizen Morel* | Your priests have told you to fear us. Ask yourself who profits by your fear, Captain. | cold, needling |
| a_parley2 | Captain Arruda* | I will take your word down the hill. I cannot promise they will believe it. | grudging respect |
| a_nobody | Captain Arruda* | Nobody comes down to talk. So be it. | hard, disappointed |
| u_raid | Ulrich* | Riders on the cart road, Meister, and muskets! The valley does not mean to talk. | alarm |
| u_raid_dark | Ulrich* | I hear horses on the dark roads, Meister, and I cannot see them. The Swifts! | DRAMATIC: fear of what he cannot see |
| h_raid_over | Hollweg | They have gone back down. Let them. Mend what they broke. | weary |
| u_dusk | Ulrich* | The sun is going down over the valley, Meister. There are lights on the road. Many lights. | uneasy, low |
| h_fear | Hollweg | Nobody strikes them. Do you hear me? Not one blow. I saw Rome burn. It will not start again here, and not by my machines. | DRAMATIC: fierce, almost shouting; Rome is in his voice |
| u_fear | Ulrich* | Then we stand in their way, Meister. Put fighters round a man with a torch and he will think better of it. Shields up: they throw stones. | steady, practical |
| u_fire | Ulrich* | A house is burning! Anyone, to the fire: a man of ours beside it puts it out. |  |
| m_fear | Citizen Morel* | Let the machines teach them, Meister. One lesson tonight saves a hundred later. | cold, reasonable (the danger of it) |
| h_m_fear | Hollweg | No, Citizen. I have seen the end of that lesson. | DRAMATIC: very quiet, final |
| v_fear | Varenne | Hold, Meister. Hold. A crowd that is not struck goes home in the end. A crowd that is struck never does. | urgent, kind |
| u_temper | Ulrich* | The fires are seen from the valley, Meister. Every one makes them angrier. | worried |
| p_1 | Padre Anselmo* | Enough! Is this how a Christian keeps the Sabbath, with a torch in his hand on a stranger's hill? | DRAMATIC: a country priest's anger, loud, fatherly |
| p_2 | Padre Anselmo* | Home, all of you. If these men are wrong, God and the Church will judge them, not your torches. | firm, then gentle |
| h_anselmo | Hollweg | He did with one word what all my shields could not do. I wrote that down. I did not understand it until much later. | DRAMATIC: wonder, the first crack in his certainty |
| h_boil | Hollweg | They are coming with muskets now. Into the tower's field, all of you. We hold. | grim |
| h_crates1 | Hollweg | The crates. Before anything else today, I want to see the crates. Ulrich, the lantern. | eager, almost a boy |
| u_crates | Ulrich* | The deepest gallery is behind the spoil heaps, Meister, north-east. The seal will know your hand. | respectful |
| h_opened | Hollweg | Two soldiers of a pattern I do not remember drawing. A Winder. And plates, so many plates. My best work. It must have been. | DRAMATIC: awe that should frighten him and does not |
| u_plates | Ulrich* | The plates are lying across the gallery floor, Meister. I did not see anyone lay them. | uneasy, puzzled |
| h_plates | Hollweg | They slid out of the straw. Leave them. They wind whatever stands on them: a gift. | dismissive, too quick |
| h_jakob | Hollweg | Jakob would have counted the teeth on those plates. Jakob was in Fürth. | grief held down |
| u_attack | Ulrich* | Meister! The militia, up all three roads at once! Riders on the ranch track! | shout |
| a_attack | Captain Arruda* | For the valley, and for God! Burn the tower! | battle cry |
| a_attack_p | Captain Arruda* | I gave them your word, clockmaker. The night gave them theirs. Forgive me. | DRAMATIC: sorry, but riding anyway |
| h_attack | Hollweg | These are soldiers. Defend the city. Shields to the front, the Winders behind. | cold command |
| a_break | Captain Arruda* | Back! Back down the hill! Enough have died for one morning. | hoarse, beaten |
| h_concord | Hollweg | Concord. | DRAMATIC: one word, tired, half a prayer |
| h_hurt | Hollweg | I am hit. Keep them off the tower, never mind me. | pain, through teeth |
| a_v1 | Captain Arruda* | There it is, on our hill: the thing the old world died of. Burn their houses before they take root, or bring the tower down. | hard, sure of himself |
| a_v_tip | Captain Arruda* | The Barracks in the town and the Horse Breeder at the ranches are ours. The people will go up the road tonight whatever we do. | plain |
| h_end1 | Hollweg | By the first winter the city had a wall of timber, a council and a name. I sat at the head of the council table and called it concord. | old, proud |
| h_end_parley | Hollweg | The valley's captain had taken my word down the hill. That word was the best thing I built that year. | warm, the best memory of the year |
| h_end_fought | Hollweg | The valley never forgave us that dawn. Its people crossed themselves when our birds flew over. | regret |
| h_end_v | Hollweg | Varenne spoke for the city's people in the council. He was the only one of us who was afraid of it. I thought it was the habit of exile. | fond, missing the point |
| h_end_m | Hollweg | Morel spoke for the city's people in the council, and wanted the valley taught. I would not have it. That much I had learned in Rome. | firm |
| h_end2 | Hollweg | I had learned to hold my machines back from the valley. I had not learned to hold them back from themselves. | DRAMATIC: the old man knows now what the young one did not |
| k_end1 | the King | The plates in that gallery were not his best work. They were the Perpetual's. He had sent them ahead himself, six years before. | grave, slow |
| k_end_people | the King | He had left the pattern in Nuremberg. He had already sent it ahead. | grave |
| k_end2 | the King | A priest of the valley stopped a crowd that night with two sentences. Hollweg wrote it down. It took him twenty years to read it. | DRAMATIC: soft, the King respects the priest |
| k_end_v | the King | The valley burned the city's first houses on its first night. That is not how it went. It stood, and grew. | stern correction |
| a_end_v | Captain Arruda* | We burned it before it took root. The bishop wrote to thank us. I did not sleep well, all the same. | troubled |

### d01_minas (the Gold of Vila Rica)

Line ids are the mission's (`campaign/voice/d01/<id>.ogg`). The feeling is how the line should sound; lines
without one are plain. The narrator's 19 lines and the three NEW cards can stay as text. Tomasz here is a grown man of
about thirty (between a01's young priest and the old Cardinal); the Cardinal's two lines are the old man in the frame.

| id | speaker | text (placeholder) | feeling |
| --- | --- | --- | --- |
| k_open1 | the King | After Rome I sent Tomasz to Brazil. He asked to go. He said the fire would come there next, and he wanted to be standing in it. | warm, a little proud of the young priest |
| k_open2 | the King | The gold of the mines paid for my armies. In Vila Rica, the men who dug it had been told that it paid only for my chains. | DRAMATIC: grave, a king who knows the gold had a cost |
| c_open | Cardinal Tomasz | I was thirty, and I thought I had learnt everything in Lyon. Minas taught me the rest. | old, wry, fond of his younger self |
| t_open1 | Tomasz* | Vila Rica sits on two hills and a ridge, with a church on every height and gold in every stream. The day I came, the derrama was to be read on the square. | a traveller's wonder |
| t_open2 | Tomasz* | The derrama: the gold the town still owed the Crown, collected house by house in one day. Nobody in the mines had a kind word for it, and some had a plan. | plain, uneasy |
| t_open_saved | Tomasz* | I had seen what Virginia's families became when someone stood by them. I meant to stand by these. | quiet resolve |
| t_open_left | Tomasz* | I never stopped praying for the road we left them on, in Virginia. I did not mean to leave anyone on a road again. | DRAMATIC: guilt carried for years |
| t_open_risen | Tomasz* | I carried a letter from Lyon in my breviary. Lyon had risen behind us. The Assembly's ink had crossed the sea before I did. | worried |
| m_1 | Captain Meneses* | Father, I have fourteen muskets and four horses for a town of thirty thousand. If they rise, I hold the Foundry House and nothing else. | blunt soldier, worried |
| t_1 | Tomasz* | Then let us see that they do not rise, Captain. I will go to the churches. Every quarter has one, and every church has its people. | calm, sure |
| m_tip1 | Captain Meneses* | And the Assembly's men are somewhere in those houses, with powder. My men will knock on doors. Stand a man at a door and we will know what is behind it. | practical |
| m_tip2 | Captain Meneses* | Their runners carry the pamphlets from house to house. Ride them down before they reach the churchyards: every one that gets there makes the town angrier. | urgent |
| m_armoury | Captain Meneses* | One more thing, Father. The Crown sent us an Armoury this year, and it has not been used. If there is fighting on those stairs tonight, I want better locks and bayonets that can stay fixed. | dry, a soldier's wish |
| m_researched | Captain Meneses* | Matchlocks and socket bayonets. Now the men must go to the Armoury to be fitted: turn on AUTO REFIT and send them by. | satisfied, brisk |
| t_pamphlet_calm | Tomasz* | The pamphlets were printed on the Lyon type. The last of it, the printer swore. The ink was still wet. |  |
| t_pamphlet_sullen | Tomasz* | The pamphlets were printed on the Lyon type. Lyon still prints. |  |
| t_pamphlet_rome | Tomasz* | ROME BURNED AND THE CHURCH DID NOT FALL, said the pamphlet. THE NEXT FIRE WILL BE OURS. Half the town had read it. | DRAMATIC: reading the slogan aloud, cold |
| t_martyrs | Tomasz* | Varenne's face was on every pamphlet, drawn as a saint. I had asked for his life in Paris. They had made his death into a banner. | DRAMATIC: grief, a mercy turned against him |
| t_printer | Tomasz* | The printer's mark from Lyon was on the pamphlets, and Captain Meneses' men knew it. One house printed nothing but it had the same ink on its step. |  |
| t_calm_pilar | Tomasz* | The Pilar's people are shopkeepers and clerks. I told them that a tax can be argued, and a rising cannot be taken back. They went home to argue. |  |
| t_calm_carmo | Tomasz* | At the Carmo the masters of the mines asked me whose side the Church was on. I said: on the side of the souls in this square, all of them. |  |
| t_calm_rosario | Tomasz* | The Rosário is the miners' own church, built with their own gold dust. They knew the tax better than any officer. I listened before I spoke. | humble, listening |
| t_calm_efigenia | Tomasz* | In the diggings they had pamphlets under every stone. I read one aloud to them, slowly, and asked who would pay for it when the soldiers came. Nobody answered. | steady, a hard question asked gently |
| t_calm_all | Tomasz* | Four churches, four sermons, and my voice nearly gone. The town was quiet. Quiet is not the same as at peace. | tired, hoarse, not fooled |
| w_runner | Captain Meneses* | There, a runner with a bundle of pamphlets! He is making for a churchyard. Ride him down. |  |
| m_found | Captain Meneses* | An armoury! Break it open and burn what is in it. | sharp command |
| w_hint | a townsman* | Father! The house with the shutters always closed: men go in at night and nobody comes out. I have marked it for you. | a whisper, frightened |
| m_temper15 | Captain Meneses* | Father, they are close to the edge. Stop the runners, or speak to them, or we lose the town. | alarmed |
| m_soon | Captain Meneses* | Both of their armouries closed! They know they are found. They will give the signal now, tonight. Get the men in hand. | urgent |
| t_ledger | Tomasz* | In the second armoury we found a ledger. The muskets had been paid for in coin from the south, from the agents of a guild of clockmakers. Machines paying for a revolution. | DRAMATIC: disbelief turning to dread |
| t_ledger_d04 | Tomasz* | Concórdia, the ledger said. The city of gears on the southern highlands. The guild wanted the Crown's metal, and the Assembly wanted money. They had found each other. | slow realisation |
| r_signal | Lieutenant Ramos* | Vila Rica! The gold is yours, not Lisbon's, not Rome's! Up, and take the Foundry House! | DRAMATIC: a rousing shout, warm and dangerous |
| m_signal | Captain Meneses* | There it is. They will come up the stairs to the square from below and along the ridge. Hold the stairs, bayonets fixed. Not one of them on the square. | steel, a battle order |
| t_signal | Tomasz* | The miners with them have picks, not muskets. They are not soldiers, Captain. Some of them sang at the Rosário this morning. | pleading for the miners |
| m_signal_t | Captain Meneses* | Then go and get them back, Father, if you can. My men will hold the stairs either way. | respect, a nod |
| t_miners | Tomasz* | I stood in the Rosário's churchyard and rang its own bell, the right bell, and called the brotherhood by name. They came. Not all of them, but they came. | DRAMATIC: relief and sorrow, not all came |
| m_bayonet | Captain Meneses* | Bayonets! Hold the top of the stairs, and let them climb to you. | a battle cry |
| r_fall | Lieutenant Ramos* | Enough! Back, back to the gorge! The gold still has to leave this town, and there is only one road. | furious, then cold |
| t_hurt | Tomasz* | I am hit. Do not stop for me, Captain. | in pain, steady |
| m_gold | Captain Meneses* | The Governor's order: the gold goes to the coast today, before they try again. Four carts, one road, through the gorge. | brisk orders |
| m_gorge | Captain Meneses* | If I were Ramos, I would wait on the rocks above the gorge. Send men up the ledges' stairs before the carts go in, and keep a few by every cart. | a soldier thinking aloud |
| t_gold | Tomasz* | I asked to ride with the gold. The Captain thought I meant to guard it. I meant to bury whoever died on that road. | DRAMATIC: quiet, the priest's real reason |
| r_ambush | Lieutenant Ramos* | Now! Off the rocks! Take the carts, never mind the soldiers! | a shout |
| m_ambush | Captain Meneses* | There he is, Ramos himself, on the road ahead! Take him alive if you can: the Governor will want his names. | urgent |
| m_retake | Captain Meneses* | After it! Get round that cart before it crosses the ford and it is ours again. | urgent |
| r_run | Lieutenant Ramos* | It is lost here. South, to the free city! They will want a man who knows the mines. | bitter, a man who has lost |
| m_run | Captain Meneses* | He is running for the hollow beyond the east ford! Catch him before he is across! | a shout |
| r_taken | Lieutenant Ramos* | Do it quickly, then. The mines will remember me. | DRAMATIC: proud, defeated |
| t_taken | Tomasz* | He asked me to hear his confession before they took him to the Governor. I did. What he said is between him and God. What he did is between him and the King. | DRAMATIC: gentle, firm, the priest and the King both respected |
| m_done | Captain Meneses* | The gold is on the coast road. Vila Rica is the King's. | relief |
| t_calm_hint | Tomasz* | A woman of the Rosário came to me after the rosary. Strangers carry powder into a house with its shutters always closed. I sent word to the Captain. | quiet, passing on a confidence |
| m_gun | Captain Meneses* | They have a gun up there! They took it from the militia's store. Get the dragoons onto the ridge before it fires on the square. | urgent |
| r_last | Lieutenant Ramos* | Once more, up the Rua Direita! Every man who can still stand! | DRAMATIC: hoarse, desperate |
| m_last | Captain Meneses* | Here comes Ramos himself, from the Rosário, up the broad stair. Everyone to the south stair! | urgent, steady |
| m_raiders | Captain Meneses* | Riders behind us, out of the hollow over the east ford! They are after the carts. Keep men by them! | alarm |
| r_v1 | Lieutenant Ramos* | Today they read their derrama on our square. Tonight we ring the bell. Walk the pamphlets to the churchyards; let the town hear it. | rousing |
| r_v_tip | Lieutenant Ramos* | Our armouries hide among the houses until a soldier knocks. Keep them hidden: the agitators come out of them. | conspiratorial |
| t_end1 | Tomasz* | The gold went down to the coast and across the sea, and Vila Rica paid its derrama. I stayed a year among the miners. | looking back, quiet |
| t_end_quiet | Tomasz* | The town was quiet after. Not because of the bayonets. Because someone had come to their churches before the bell rang. | a small pride |
| t_end_restless | Tomasz* | The town was quiet after, under the bayonet. I learnt that a quiet bought that way has to be bought again every year. | regret |
| t_end_taken | Tomasz* | Ramos was tried at Vila Rica. I wrote to the King for his life, as I had for Varenne's. | hope |
| t_end_fled | Tomasz* | Ramos was never found. Years later I heard his name again, from the south, from the city of gears. | foreboding |
| t_end2 | Tomasz* | In Lyon I had learnt to speak to a crowd. In Minas I learnt to stay with it afterwards. | DRAMATIC: the lesson of his life |
| k_end1 | the King | I signed Ramos' sentence and Tomasz' letter lay beside it. I commuted it to exile. You may judge whether I learnt from Paris. | DRAMATIC: a king judging himself |
| k_end_fled | the King | The gold reached Lisbon. The man who wanted it reached the city of gears. Both kept their appointments with me, later. | dry foreboding |
| k_end2 | the King | The mines stayed mine. I did not lower the tax. Perhaps I should have. Tomasz never said so; he only sent me the names of the dead. | DRAMATIC: honest doubt |
| c_end | Cardinal Tomasz | Three hundred names. I still have the list. | DRAMATIC: very quiet, an old man's grief |
| k_end_v | the King | The Assembly took the Foundry House and proclaimed its republic of the mines. That is not how it went. The gold reached the coast. | stern correction |
| r_end_v | Lieutenant Ramos* | For one night Vila Rica belonged to the men who dug it. They will not forget it, whatever comes. | defiant, proud |

### d06_queen (the Queen)

Line ids are the mission's (`campaign/voice/d06_queen/<id>.ogg`). The feeling is how the line should sound; lines
without one are plain. The narrator's 28 lines (the Island) and the two NEW cards can stay as text. The strongest lines
have a preset in tools/voice_clone/emotions.json (`d06__<id>`). Pieter is the grown Pieter of d03 (about thirty).

| id | speaker | text (placeholder) | feeling |
| --- | --- | --- | --- |
| k_open1 | the King | Three years after the commission the river rose higher than anyone on it could remember. | flat, a judgement |
| k_open2 | the King | Lindqvist still tells that night as a breeding season that went wrong. | dry |
| l_open1 | Lindqvist | The wet season of 2775. The water came up into the cane, then into the low pens. | old, remembering water |
| l_open2 | Lindqvist | I had two breeding Mothers on the island by then. I thought I was a rich man. | rueful, a laugh at himself |
| l_open_saved | Lindqvist | The first from the clutch we carried out of the station. The second bred from her. | tender |
| l_open_burned | Lindqvist | The first netted on the mountain. The second bred from her. | proud, then quiet |
| k_open_f | the King | Lindqvist says he burned the pens that night. Listen to how much he burned. | dry, a test of the witness |
| l_open_f | Lindqvist | The water was in the cane. Something was calling from the north shore. I sent for the torches. | tense memory |
| l_1 | Lindqvist | The low pens are under water. Pieter, the keepers. Bring the stock up to the big pen. All of it. | DRAMATIC: urgent orders, fear held down |
| p_tip1 | Pieter* | They follow the lures, Doctor, nothing else. The keepers walk up the paths; the animals have to stay inside their rings. | quick, practical |
| p_call | Pieter* | Doctor, the ones outside the rings are walking toward it. | uneasy |
| p_in | Pieter* | They are all up in the big pen, Doctor. Wet, but all there. | relief, out of breath |
| p_late | Pieter* | The water is on the paths, Doctor. We cannot wait for the rest. | urgent |
| l_drop | Lindqvist | Leave the lures. Everyone to the house. Shut the gate. | DRAMATIC: sharp, frightened |
| p_fight | Pieter* | They are fighting each other, Doctor. Mother against Mother. | awe and fear |
| l_fight | Lindqvist | Write it down, Pieter. Every hour of it. Nobody has ever seen this. | DRAMATIC: wonder, a scientist forgetting the danger |
| l_house | Lindqvist | Close the shutters. Load the swivel guns. Pieter, bring the stud book down. | clipped, giving orders |
| p_changing | Pieter* | Doctor, the big one in the middle is changing. She is getting bigger. | DRAMATIC: dread |
| l_shoot | Lindqvist | Keepers! To the big pen. Shoot her. Shoot her now, before it is done. | DRAMATIC: shout, panic |
| l_show | Lindqvist | Every animal on the island turned toward the big pen. I had no lure for that. | DRAMATIC: hollow, an old man still shaken |
| l_run | Lindqvist | Pieter! The canoes. Leave everything. | DRAMATIC: shout |
| p_book | Pieter* | The book, Doctor! The lure book is upstairs! | urgent, shouted |
| l_book | Lindqvist | Leave it! | DRAMATIC: angry, final |
| l_f1 | Lindqvist | Torches. We burn the pens before they settle it among themselves. Then the canoes. | hard, decided |
| p_f1 | Pieter* | The guns first, Doctor. They are asleep in the straw, and they wake when you walk up to them. | low, careful |
| l_f_big | Lindqvist | The big pen is burning. They will have to settle it somewhere else, and that takes time. | grim satisfaction |
| l_f_go | Lindqvist | Enough. To the canoes, all of you. | tired command |
| p_f_warn | Pieter* | Doctor, the big one in the middle is changing. It is getting bigger. | dread |
| l_f_won | Lindqvist | Push off, Pieter. Do not look back. | quiet, grief |
| l_f_lost | Lindqvist | Too late. It is growing. Everything on the island is turning to it. | DRAMATIC: despair |
| l_end1 | Lindqvist | I stood up in the canoe and looked back. The whole island was moving. | old, slow |
| l_end_all | Lindqvist | Every animal I had bred was on that bank. Not one came to the lure. | DRAMATIC: grief and awe |
| l_end_some | Lindqvist | Half my stock was on that bank. The rest lay dead in the pens. | heavy |
| l_end_few | Lindqvist | Few of mine were on that bank. The pens had killed most of them. | DRAMATIC: grief |
| k_end1 | the King | He says the flood did it. He bred nothing. He kept animals that were made long ago to become exactly that. | firm correction, no anger |
| k_end2 | the King | The Church told him what they were. He still says they evolved. | tired, sorry for him |
| l_end_f | Lindqvist | We burned three pens and went down the river at first light. I have the stud book. I burned the rest. | defensive |
| k_end_f | the King | He told me he burned them. He did not burn enough. | firm |
| h_hurt | Lindqvist | My arm. Pieter, the torch. | pain, clipped |

## 3. Voices to design first (ElevenLabs Voice Design, then a ref file)

Done: hollweg, lindqvist (v2), fairleigh, ruggieri, varenne, ferrer (2026-11-22), explorer (now Valadares? the owner to say). The King
uses king_ref.wav / king_ref_b.wav.
Still to design: Tomasz young (a01, a06, p01; a "Tomasz Wierzbicki (the young seminarian)" voice is in the owner's
ElevenLabs account: its sample would do) and old (the Cardinal), Jakob, Valadares (or the explorer ref),
Pieter, Benedito, Captain Delorme, Colonel von Rauch, Brother Anselm, Will Hollins, and the one-to-two-line parts
(Teles, Frei Joaquim, the Captain of the Watch, the Commissary, Rouvière, Mère Gautier, the Sergeant, the guide, the
Cardinal Dean of a07). Act 2: Ulrich (the guild's foreman: d02, a rough Franconian voice, older than Jakob) and
Commissary Brandt (a dry chancery official, German); d03: Desembargador Fonseca (a Portuguese-Brazilian high-court
judge, fifties, pompous and comfortable) and Pieter grown (the plan's d03: ten years after b01, a man of thirty);
d04: Captain Bento Arruda (a southern Brazilian cattleman-officer, forties, plain and stubborn, Portuguese-Brazilian),
Padre Anselmo (a kind country priest, sixties, a voice that calms a crowd) and Citizen Morel (an Assembly man, French,
thirties, cold and clipped); d01: Tomasz grown (about thirty: between the young seminarian and the old Cardinal; one
voice aged by pitch would do), Captain Luís de Meneses (a Portuguese dragoon officer, forties, blunt and loyal) and
Lieutenant Inácio Ramos (a Brazilian orator, thirties, warm and dangerous), and "a townsman" (one line).

## 4. Act 2 (planned, not built)

docs/campaign_act2_plan.md "VOICES" lists Act 2's speakers and the new voices to design (Tomasz grown, Commissary
Brandt, Desembargador Fonseca, Captain Arruda, Padre Anselmo, Citizen Morel, Matthias, Captain de Meneses (built: d01), Lieutenant
Ramos (built: d01), Brother Tiago, the prince if the heir is named). Each mission's table joins section 2 when it is built.

## 5. Later

- pt / es versions of the announcers (Crown herald, Brood scientist): not decided (docs/announcers.md).
- The Clockwork announcer: see the owner's question of 2026-11-18 (Hollweg / the Machine's voice), undecided.
