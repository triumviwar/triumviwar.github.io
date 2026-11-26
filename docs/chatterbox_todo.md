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
| d06_queen (the Queen, Act 2) | this file, "d06_queen" below; docs/campaign_d06_build.md | 38 (+28 narrator, 2 NEW cards) | Lindqvist 24, Pieter* 8, the King 6 |
| d05_aldeia (the Mission of São Rafael, Act 2) | this file, "d05_aldeia" below; docs/campaign_d05_build.md | 45 (+35 narrator, 2 NEW cards) | Tomasz* 23, Captain Sobral* 8, the King 7, Brother Tiago* 7 |
| d08_rivers (Down the Rivers, Act 2) | this file, "d08_rivers" below; docs/campaign_d08_build.md | 37 (+34 narrator, 3 NEW cards) | Valadares* 19, the King 8, Benedito* 7, the Barra's sergeant* 3 |
| d07_spring (the Council of Gears, Act 2) | this file, "d07_spring" below; docs/campaign_d07_build.md | 58 (+30 narrator, 2 NEW cards) | Hollweg 22, Matthias* 12, Ulrich* 8, the King 7, Varenne 3, Citizen Morel* 3, Master Ortlieb* 1, a rescued master* 1, Captain Arruda* 1 |
| d11_siege (the Siege of Concórdia, Act 2) | this file, "d11_siege" below; docs/campaign_d11_build.md | 47 (+42 narrator, 4 NEW cards) | Father Ferrer 24, the King 9, Jakob* 5, General Ruggieri 4, Meister Hollweg 2, Captain Arruda* 2, Matthias* 1 |

Narrator lines ("Nuremberg", "Paris", "The Machine", "The Free Assembly", "The Rio Negro", "Lyon", "Fürth", "The
Mountain", "Rome", "The Creatures", "The Automata") can stay as text.

### d02_exodus (the Exodus)

Line ids are the mission's (`campaign/voice/d02_exodus/<id>.ogg`). The feeling is how the line should sound; lines
without one are plain. The narrator's 12 lines and the two NEW cards can stay as text.

| id | speaker | text (placeholder) | feeling |
| --- | --- | --- | --- |
| k_open1 | the King | Ten months after Rome I signed the commissary's orders myself. Seize the works at Fürth. Stop every machine that winds itself. | heavy, owning it, no regret in the voice |
| k_open2 | the King | Hollweg was told the commissary was coming. He did not wait for him. | dry |
| h_open1 | Hollweg | I called it a rescue. The Crown meant to melt our works, and the families had lived off those works for three generations. | old, defensive, still proud |
| h_open2 | Hollweg | We rang the night bell at the barn. By morning Fürth was empty. | quiet, remembering |
| k_open_c | the King | Father Ferrer rode with the commissary as Rome's witness. He kept a diary of it in that small Catalan hand of his. I have it still. | warm about Ferrer |
| f_open_c | Ferrer | We were a day's ride off when the dogs found their scent. The guild was already on the road. | tired |
| h_1 | Hollweg | Every family to its cart. Every machine that can walk, wind it. We leave tonight. | urgent, commanding, low (a night order) |
| u_tip1 | Ulrich | The carts wait at the barns, Meister. Send one of ours to each and the family climbs in. The marked ones on the map. | |
| u_tip2 | Ulrich | Your spring cart winds anything that stands on the brass plates round it. Keep the soldiers near it on the road and they never run down. | |
| u_tip_new | Ulrich | The Clock Soldiers know the shield wall now, Meister. Raise their shields with SHIELD FORWARD on their card when the muskets face them. | |
| h_draw0 | Hollweg | And the drawings. Every sheet of the Perpetual. Nobody touches those chests but me. | possessive, sharp |
| h_draw | Hollweg | The drawings are aboard. If they take that cart, they take forty years of my life. | relief with fear under it |
| h_people | Hollweg | No drawings this time. I left them in Nuremberg for the people. I carry the Perpetual in my head. | bitter pride |
| j_wait | Jakob | Meister. Before you go. Come here, please. | nervous, young |
| j_stay1 | Jakob | I am not coming, Meister. I told Father Ferrer what I found, and I will tell the commissary. | DRAMATIC: firm but shaking, he loves the old man |
| h_stay | Hollweg | They will melt everything, Jakob. Everything we built. | DRAMATIC: hurt, pleading without saying please |
| j_stay2 | Jakob | Then let them. I would rather melt a wheel than see it take out its own stop-work again. God keep you, Meister. | DRAMATIC: steady, a goodbye; soft on the last words |
| h_nojakob | Hollweg | Jakob would have known which wheels to leave behind. I shall have to guess. | grief held down |
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
| h_aboard | Hollweg | Cast off. Mind the ice by the piers. | DRAMATIC: exhausted, final, no triumph |
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
| h_end_few | Hollweg | Few of the families came. There was room on the deck to walk. | DRAMATIC: grief |
| h_end_draw | Hollweg | And the drawings came with me. Every sheet. | quiet pride |
| h_end_drawlost | Hollweg | The drawings stayed with the Crown. I drew them again from memory, on the ship. | stubborn |
| h_end_jakob | Hollweg | Jakob stayed. I wrote to him from Hamburg. He never answered. | DRAMATIC: hurt, held back |
| h_end_manifest | Hollweg | The ship's manifest said: machinery, for a mine in the southern highlands of Brazil. The clerk at Hamburg did not ask whose mine. | sly, a hint of what is coming |
| k_end1 | the King | He calls it a rescue. The law calls it desertion, and so do I. The guild left the Crown that night and took its families with it. | DRAMATIC: firm, sad, the verdict |
| k_end2 | the King | I do not blame the families. Someone told them the Crown was coming for their children's bread, and they believed him. It was Hollweg who told them. | gentle, then hard |
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
| l_open2 | Lindqvist | Rome called them abominations. I called them a new species, and I had bred every species I ever kept. I had the lures. They came to the lures. | conviction, a scientist lecturing |
| l_open_linnea | Lindqvist | And among them a young Mother, out of the clutch we carried from the station. Linnea's get. Growing. | tender, proud |
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
| p_still | Pieter | Keep them still, Doctor. A soldier sees what moves. The rest is just forest to him. | whispered, urgent |
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
| k_end1 | the King | He tells it as if he won. Valadares found enough on that island to know what it was, and he wrote it down. | firm correction, no anger |
| k_end2 | the King | And Lindqvist still believes the thing evolved. The Church told him what it was. He did not listen then either. | tired, sorry for him |
| v_end_c | Valadares | We burned the pens we found. The Doctor stood at the landing with his hat in his hand, and did not look at the smoke. | grave, plain |
| k_end_c | the King | Lindqvist told me Valadares came away with nothing. Valadares' report is on my desk. It runs to forty pages. | firm |
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
| h_mapped_all | Hollweg | There. The whole country under one eye. Ulrich, have it copied onto the council's table. | DRAMATIC: rapture, a little too much (the flaw speaking) |
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
| v_fear | Varenne | Hold, Meister. Hold. I have led crowds like this one. Leave them be and they go home to bed. Shoot one and you will have them for ten years. | urgent, kind |
| u_temper | Ulrich* | The fires are seen from the valley, Meister. Every one makes them angrier. | worried |
| p_1 | Padre Anselmo* | Enough! Is this how a Christian keeps the Sabbath, with a torch in his hand on a stranger's hill? | DRAMATIC: a country priest's anger, loud, fatherly |
| p_2 | Padre Anselmo* | Home, all of you. If these men are wrong, God and the Church will judge them, not your torches. | firm, then gentle |
| h_anselmo | Hollweg | He sent them home with two sentences. My shields had been at it for an hour. I wrote down what he said. | DRAMATIC: wonder, the first crack in his certainty |
| h_boil | Hollweg | They are coming with muskets now. Into the tower's field, all of you. We hold. | grim |
| h_crates1 | Hollweg | The crates. Before anything else today, I want to see the crates. Ulrich, the lantern. | eager, almost a boy |
| u_crates | Ulrich* | The deepest gallery is behind the spoil heaps, Meister, north-east. The seal will know your hand. | respectful |
| h_opened | Hollweg | Two soldiers of a pattern I do not remember drawing. A Winder. And plates, so many plates. My best work. It must have been. | DRAMATIC: awe that should frighten him and does not |
| u_plates | Ulrich* | The plates are lying across the gallery floor, Meister. I did not see anyone lay them. | uneasy, puzzled |
| h_plates | Hollweg | They slid out of the straw. Leave them. They wind whatever stands on them: a gift. | dismissive, too quick |
| h_jakob | Hollweg | Jakob would have counted the teeth on those plates before he let them lie. But Jakob was in Fürth. | grief held down |
| u_attack | Ulrich* | Meister! The militia, up all three roads at once! Riders on the ranch track! | shout |
| a_attack | Captain Arruda* | For the valley, and for God! Burn the tower! | battle cry |
| a_attack_p | Captain Arruda* | I gave them your word, clockmaker. After last night they would not hear it. Forgive me. | DRAMATIC: sorry, but riding anyway |
| h_attack | Hollweg | These are soldiers. Defend the city. Shields to the front, the Winders behind. | cold command |
| a_break | Captain Arruda* | Back! Back down the hill! Enough have died for one morning. | hoarse, beaten |
| h_concord | Hollweg | Count our dead, Ulrich. And theirs. | DRAMATIC: one word, tired, half a prayer |
| h_hurt | Hollweg | I am hit. Keep them off the tower, never mind me. | pain, through teeth |
| a_v1 | Captain Arruda* | There it is, on our hill: the thing the old world died of. Burn their houses before they take root, or bring the tower down. | hard, sure of himself |
| a_v_tip | Captain Arruda* | The Barracks in the town and the Horse Breeder at the ranches are ours. The people will go up the road tonight whatever we do. | plain |
| h_end1 | Hollweg | By the first winter the city had a wall of timber, a council and a name. I sat at the head of the council table and called it concord. | old, proud |
| h_end_parley | Hollweg | The valley's captain had taken my word down the hill, and for a while the valley kept to it. | warm, the best memory of the year |
| h_end_fought | Hollweg | The valley never forgave us that dawn. Its people crossed themselves when our birds flew over. | regret |
| h_end_v | Hollweg | Varenne spoke for the city's people in the council. He was the only one of us who was afraid of it. I thought it was the habit of exile. | fond, missing the point |
| h_end_m | Hollweg | Morel spoke for the city's people in the council, and wanted the valley taught. I would not have it. That much I had learned in Rome. | firm |
| h_end2 | Hollweg | I kept my machines off the valley's people that year. It never crossed my mind that I might need to keep them off my own. | DRAMATIC: the old man knows now what the young one did not |
| k_end1 | the King | The plates in that gallery were not his best work. They were the Perpetual's. He had sent them ahead himself, six years before. | grave, slow |
| k_end_people | the King | He had left the pattern in Nuremberg. He had already sent it ahead. | grave |
| k_end2 | the King | A priest of the valley stopped a crowd that night with two sentences. Hollweg wrote them down. He told me, at my fire, that he understood them twenty years later. | DRAMATIC: soft, the King respects the priest |
| k_end_v | the King | The valley burned the city's first houses on its first night. That is not how it went. It stood, and grew. | stern correction |
| a_end_v | Captain Arruda* | We burned it before it took root. The bishop wrote to thank us. I did not sleep well, all the same. | troubled |

### d01_minas (the Gold of Vila Rica)

Line ids are the mission's (`campaign/voice/d01/<id>.ogg`). The feeling is how the line should sound; lines
without one are plain. The narrator's 19 lines and the three NEW cards can stay as text. Tomasz here is a grown man of
about thirty (between a01's young priest and the old Cardinal); the Cardinal's two lines are the old man in the frame.

| id | speaker | text (placeholder) | feeling |
| --- | --- | --- | --- |
| k_open1 | the King | After Rome, Tomasz asked to be sent to Brazil. He said the fire would go there next. He was right, as he usually was, and I let him go. | warm, a little proud of the young priest |
| k_open2 | the King | The gold of the mines paid for my armies. In Vila Rica, the men who dug it had been told that it paid only for my chains. | DRAMATIC: grave, a king who knows the gold had a cost |
| c_open | Cardinal Tomasz | I was thirty, and I thought I had learnt everything in Lyon. Minas taught me the rest. | old, wry, fond of his younger self |
| t_open1 | Tomasz* | Vila Rica sits on two hills and a ridge, with a church on every height and gold in every stream. The day I came, the derrama was to be read on the square. | a traveller's wonder |
| t_open2 | Tomasz* | The derrama: the gold the town still owed the Crown, collected house by house in one day. I heard it cursed in three languages before I had found my lodging. | plain, uneasy |
| t_open_saved | Tomasz* | I had seen what Virginia's families became when someone stood by them. I meant to stand by these. | quiet resolve |
| t_open_left | Tomasz* | I never stopped praying for the road we left them on, in Virginia. I did not mean to leave anyone on a road again. | DRAMATIC: guilt carried for years |
| t_open_risen | Tomasz* | I carried a letter from Lyon in my breviary. Lyon had risen behind us. The Assembly's ink had crossed the sea before I did. | worried |
| m_1 | Captain Meneses* | Father, I have fourteen muskets and four horses for a town of thirty thousand. If they rise, I hold the Foundry House and nothing else. | blunt soldier, worried |
| t_1 | Tomasz* | Then let us keep them from rising, Captain. I will go round the churches. Every quarter has its own, and every church its brotherhood. | calm, sure |
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
| t_calm_all | Tomasz* | Four churches, four sermons, and by the last one my voice was a croak. The town was quiet. The Captain said that was what worried him. | tired, hoarse, not fooled |
| w_runner | Captain Meneses* | There, a runner with a bundle of pamphlets! He is making for a churchyard. Ride him down. |  |
| m_found | Captain Meneses* | An armoury! Break it open and burn what is in it. | sharp command |
| w_hint | a townsman* | Father! The house with the shutters always closed: men go in at night and nobody comes out. I have marked it for you. | a whisper, frightened |
| m_temper15 | Captain Meneses* | Father, one more stone and this town goes up. Get to the churches. My riders will see to the runners. | alarmed |
| m_soon | Captain Meneses* | Both of their armouries closed! They know they are found. They will give the signal now, tonight. Get the men in hand. | urgent |
| t_ledger | Tomasz* | In the second armoury we found a ledger. The muskets had been paid for in coin from the south, through the agents of a guild of clockmakers. I read the page twice to be sure of it. | DRAMATIC: disbelief turning to dread |
| t_ledger_d04 | Tomasz* | Concórdia, the ledger said: the clockmakers' city on the southern highlands. Metal went one way and coin came back the other, all entered in a clerk's neat hand. | slow realisation |
| r_signal | Lieutenant Ramos* | Vila Rica! The gold is yours, not Lisbon's, not Rome's! Up, and take the Foundry House! | DRAMATIC: a rousing shout, warm and dangerous |
| m_signal | Captain Meneses* | There it is. They will come up the stairs to the square from below and along the ridge. Hold the stairs, bayonets fixed. Not one of them on the square. | steel, a battle order |
| t_signal | Tomasz* | The miners with them have picks, not muskets. They are not soldiers, Captain. Some of them sang at the Rosário this morning. | pleading for the miners |
| m_signal_t | Captain Meneses* | Then go and get them back, Father, if you can. My men will hold the stairs either way. | respect, a nod |
| t_miners | Tomasz* | I stood in the Rosário's churchyard, rang its own bell at the right hour, and called the brotherhood man by man. Most of them came down. | DRAMATIC: relief and sorrow, not all came |
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
| t_taken | Tomasz* | He asked me to hear his confession before they took him to the Governor. I heard it sitting on a cart wheel, with a dragoon standing off out of earshot. That is all I will say of it. | DRAMATIC: gentle, firm, the priest and the King both respected |
| m_done | Captain Meneses* | The gold is on the coast road. Vila Rica is the King's. | relief |
| t_calm_hint | Tomasz* | A woman of the Rosário came to me after the rosary. Strangers carry powder into a house with its shutters always closed. I sent word to the Captain. | quiet, passing on a confidence |
| m_gun | Captain Meneses* | They have a gun up there! They took it from the militia's store. Get the dragoons onto the ridge before it fires on the square. | urgent |
| r_last | Lieutenant Ramos* | Once more, up the Rua Direita! Every man who can still stand! | DRAMATIC: hoarse, desperate |
| m_last | Captain Meneses* | Here comes Ramos himself, from the Rosário, up the broad stair. Everyone to the south stair! | urgent, steady |
| m_raiders | Captain Meneses* | Riders behind us, out of the hollow over the east ford! They are after the carts. Keep men by them! | alarm |
| r_v1 | Lieutenant Ramos* | Today they read their derrama on our square. Tonight we ring the bell. Walk the pamphlets to the churchyards; let the town hear it. | rousing |
| r_v_tip | Lieutenant Ramos* | Our armouries hide among the houses until a soldier knocks. Keep them hidden: the agitators come out of them. | conspiratorial |
| t_end1 | Tomasz* | The gold went down to the coast and across the sea, and Vila Rica paid its derrama. I stayed a year among the miners. | looking back, quiet |
| t_end_quiet | Tomasz* | The town stayed quiet after. The brotherhoods remembered who had come to their churches before the bell rang. | a small pride |
| t_end_restless | Tomasz* | The town was quiet after, with a dragoon on every corner. The Captain asked the Governor for more men every year after that, and got them. | regret |
| t_end_taken | Tomasz* | Ramos was tried at Vila Rica. I wrote to the King for his life, as I had for Varenne's. | hope |
| t_end_fled | Tomasz* | Ramos was never found. Years later I heard his name again, from the south, from the city of gears. | foreboding |
| t_end2 | Tomasz* | I baptised forty children in Vila Rica that year, and buried eleven of the men who had come up those stairs. | DRAMATIC: the lesson of his life |
| k_end1 | the King | I signed Ramos' sentence and Tomasz' letter lay beside it. I commuted it to exile. You may judge whether I learnt from Paris. | DRAMATIC: a king judging himself |
| k_end_fled | the King | The gold reached Lisbon. Ramos reached the city of gears. I was to hear of both again. | dry foreboding |
| k_end2 | the King | The mines stayed mine. I did not lower the tax, and I have wondered since whether I should have. Tomasz never told me. He sent me the names of the dead instead. | DRAMATIC: honest doubt |
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
| l_open_saved | Lindqvist | The first from the clutch we carried out of the station. I named her Linnea, after her dam. The second was bred from her. | tender |
| l_open_burned | Lindqvist | The first netted on the mountain. The second bred from her. | proud, then quiet |
| k_open_f | the King | Lindqvist says he burned the pens that night. Listen to how much he burned. | dry, a test of the witness |
| l_open_f | Lindqvist | The water was in the cane. Something was calling from the north shore. I sent for the torches. | tense memory |
| l_1 | Lindqvist | The low pens are under water. Pieter, the keepers. Bring the stock up to the big pen. All of it. | DRAMATIC: urgent orders, fear held down |
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
| l_f_won | Lindqvist | Push off, Pieter. Keep to the middle of the channel. | quiet, grief |
| l_f_lost | Lindqvist | Too late. It is growing. Everything on the island is turning to it. | DRAMATIC: despair |
| l_end1 | Lindqvist | I stood up in the canoe and looked back. The whole island was moving. | old, slow |
| l_end_all | Lindqvist | Every animal I had bred was on that bank. Not one came to the lure. | DRAMATIC: grief and awe |
| l_end_some | Lindqvist | Half my stock was on that bank. The rest lay dead in the pens. | heavy |
| l_end_few | Lindqvist | Few of mine were on that bank. The pens had killed most of them. | DRAMATIC: grief |
| k_end1 | the King | He says the flood did it. He bred nothing. He kept animals that were made long ago to become exactly that. | firm correction, no anger |
| k_end2 | the King | The Church told him what they were. He still says they evolved. | tired, sorry for him |
| l_end_f | Lindqvist | We burned three pens and went down the river at first light. I have the stud book. I burned the rest. | defensive |
| k_end_f | the King | He told me he burned them. He burned three pens and ran for the canoes. | firm |
| h_hurt | Lindqvist | My arm. Pieter, the torch. | pain, clipped |

### d05_aldeia (the Mission of São Rafael)

Line ids are the mission's (`campaign/voice/d05/<id>.ogg`). The feeling is how the line should sound; lines without one
are plain. The narrator's 35 lines ("São Rafael", and "The Flood" for the swarm's side) and the two NEW cards can stay as
text. The strongest lines have a preset in tools/voice_clone/emotions.json (`d05__<id>`). Tomasz is the grown Tomasz of
d01 (about thirty-five); Brother Tiago is a young catechist of the village, gentle (a designed voice: no accent
caricature); Captain Sobral a Portuguese-Brazilian dragoon officer in his forties, tired and plain.

| id | speaker | text (placeholder) | feeling |
| --- | --- | --- | --- |
| k_open1 | the King | After Minas, Tomasz asked for the hardest place in Brazil. They sent him up the Tapajós. | dry, fond of him |
| k_open2 | the King | In the wet season of 2776 he met the swarm, before any of us in Rome knew what it was. | heavy, a warning |
| t_open1 | Tomasz* | São Rafael. Thirty families, a church of timber, fields on the dry ground above the flood. | warm, a man describing home |
| t_open2 | Tomasz* | Brother Tiago taught the catechism in his own tongue. I taught it in Portuguese, and the children laughed at my accent. | self-mocking, fond |
| t_open_many | Tomasz* | Word of Rome had come up the river before me. They trusted me before I had earned it. | humbled |
| t_open_minas | Tomasz* | I had left Minas uneasy. I thought the frontier would be quieter. | rueful |
| t_open_fled | Tomasz* | Ramos was somewhere in the south by then. I prayed for him on the boat. | quiet, a prayer |
| t_open3 | Tomasz* | That year the river came up into the forest and did not go down. | low, ominous |
| k_open_s | the King | Tomasz tells that night as a priest. Here it is from the flooded forest, where nobody was keeping count. | cold, a test of the listener |
| t_bell | Tomasz* | Tiago, the bell! Ring it! | urgent, shouting over rain |
| ti_bell | Brother Tiago* | They are out in the fields, Father. In this rain they will not hear it. | urgent, afraid |
| t_field | Tomasz* | To the church! All of you! Leave the baskets! | shouting, out of breath |
| ti_w1 | Brother Tiago* | Those are not jaguars, Father. | fear, hushed |
| ti_in | Brother Tiago* | Everyone from the fields is in the churchyard, Father. The children too. | relief |
| t_pray | Tomasz* | Kneel, all of you, and stay down. Let the men shoot over you. | steady, calming the people |
| t_dawn | Tomasz* | Dawn. I have never been so glad of a grey sky. | exhausted relief, almost a laugh |
| c_arrive | Captain Sobral* | Captain Sobral, of the river fort. Your canoe reached us yesterday. We rode all night. | brisk, soldierly, tired |
| c_small | Captain Sobral* | The Governor's purse is thin since Minas. I could bring only a few. | apologetic, blunt |
| t_hamlet | Tomasz* | Santa Luzia. The hamlet on the causeway. Nobody came in from there. | worried |
| ti_hamlet | Brother Tiago* | My sister's family is there. They will have gone into the chapel. | afraid for his own, holding it in |
| c_charge | Captain Sobral* | My horsemen are drilled for the charge, if the fort gives them the time. A charge breaks the small ones like reeds. | confident |
| c_hatch | Captain Sobral* | Shoot those birds down! They are not birds. | shouting, alarmed |
| ti_found | Brother Tiago* | They hid in the chapel all night. They prayed the whole time, my sister says. | tearful joy |
| ti_back | Brother Tiago* | They are in, Father. All we could find. | relief, tired |
| c_sire | Captain Sobral* | And that Sire beside her. My men call him the Lindqvist Sire. They say he came out of the doctor's cages. | wry, uneasy |
| c_cannot | Captain Sobral* | We cannot hold this, Father. Not with these men. The fort can. | grim, honest |
| t_go | Tomasz* | Then we go. Everyone. The old ones in the middle. | decided, firm |
| c_burn | Captain Sobral* | Burn the fields and the granary, Father. Leave them nothing to eat. | hard, practical |
| t_bread | Tomasz* | That is the people's bread for the winter. | pained |
| ti_choose | Brother Tiago* | They ask you to choose, Father. They will do what you say. | gentle, grave |
| t_burned | Tomasz* | God forgive me. Burn them. | anguish, a whisper |
| t_left | Tomasz* | No. It is their bread. We will hold them off with powder. | firm, sorrowful |
| c_mother_dead | Captain Sobral* | The big one in the flood is down! They come slower now. | triumphant shout |
| t_hurt | Tomasz* | I am hit. Keep them walking, Tiago. | in pain, steady |
| t_lead | Tomasz* | Stay close to me. Do not look into the water. | tender, to frightened people |
| t_end1 | Tomasz* | We came through the fort's gate at dusk, and I counted them. | tired, quiet |
| t_end_many | Tomasz* | Most of them were there. I counted twice to be sure. | grateful |
| t_end_some | Tomasz* | Some of them were there. I named the others that night, on my knees. | grief held in |
| t_end_few | Tomasz* | Few of them were there. I have their names still. | grief |
| t_end_burned | Tomasz* | Behind us the smoke of the fields stood over the forest all night. | guilt |
| t_end_left | Tomasz* | Behind us the fields stood green in the rain. The swarm fed on them all season. | sober, accepting the cost |
| k_end1 | the King | A priest, a catechist and a handful of dragoons brought a village through the flood. | proud, plain |
| k_end_left | the King | He would not burn the poor's bread. My soldiers paid for that bread on the Tapajós for years. I would have done the same. | approving, a king's weight |
| k_end_burned | the King | He burned the poor's bread to starve the swarm. He has confessed it every year since. It was a hard thing, and he chose it. | grave, respectful |
| k_end_s | the King | That is not how it went. Tomasz brought them to the fort. Hear it again from him. | stern, correcting |
### d08_rivers (Down the Rivers)

Line ids are the mission's (`campaign/voice/d08/<id>.ogg`). The feeling is how the line should sound; lines without one
are plain. The narrator's 34 lines (the Rio Negro) and the three NEW cards (to the swarm's player only) can stay as
text. The strongest lines have a preset in tools/voice_clone/emotions.json (`d08__<id>`). Valadares is the a03 / d03
Valadares, about twenty years older than on the plateau; the Barra's sergeant is a new small part (an old
Portuguese-Brazilian soldier, a parade-ground voice).

| id | speaker | text (placeholder) | feeling |
| --- | --- | --- | --- |
| k_open1 | the King | Three years after the island, the floods came higher than the last. The swarm came down with them. | flat, a judgement |
| k_open2 | the King | Valadares held the Barra that season. This is his report, as he wrote it. | dry, a record read out |
| k_linnea | the King | He told me later he had seen the first of them on the plateau, years before. He knew them at once. | quiet, almost respect for the man |
| v_open1 | Valadares* | The Rio Negro, the floods of 2778. Every town above the Barra was empty by Lent. | weathered, plain, a report |
| v_open2 | Valadares* | Nazaré was the last. Its people had nowhere to go but our canoes. | heavy |
| k_open_s | the King | Valadares wrote this down as it happened. Here is how it would have gone if the bluff had fallen. | dry, a test of the page |
| v_1 | Valadares* | Column, with me. Up the bank trail to Nazaré, and quickly. Benedito has the canoes at the beach. | DRAMATIC: urgent orders, calm on top |
| v_map | Valadares* | I drew their road down from the plateau myself. They will cross where the river is shallow: the rapids, the middle, the Barra. | sure of himself, grim |
| v_sealed | Valadares* | My map of the plateau is under seal in Rome. I will learn their road the hard way, as they come. | rueful, a soldier's shrug |
| b_party_few | Benedito* | Senhor, I am the last of the plateau's party still on the river. Let us not lose anyone else. | DRAMATIC: old grief, quiet |
| b_first | Benedito* | The first are in the canoes, Senhor. I can take them all, if they get here. | relief, busy |
| b_wait | Benedito* | I cannot wait much longer, Senhor! Whoever is not on the beach stays. | DRAMATIC: shouting over the water |
| b_away | Benedito* | We are away! Down to the Barra, Senhor. Do not stay up here. | urgent |
| v_2 | Valadares* | Back to the Barra, all of you. Down the trail. They will be at the shallows before us. | DRAMATIC: urgent, a run home |
| s_2 | the Barra's sergeant* | Senhor Valadares! Creatures on the far bank, opposite the lower town. The guns are loaded. | DRAMATIC: shouting from the wall |
| v_fwd_dead | Valadares* | Good. Back over the water before the next wave. | grim satisfaction |
| s_quarter | the Barra's sergeant* | A house in the lower town is burning, Senhor! | alarm |
| v_mend | Valadares* | Labourers to the palisade. Mend what they break. | clipped orders |
| b_book | Benedito* | Senhor. Your men brought this from the fazenda's ruins. The Doctor's lure book. | low, uneasy, as if the book were hot |
| b_book_taken | Benedito* | Senhor. The Doctor left this at the Barra's warehouse for his passage downriver. His lure book. | low, uneasy |
| b_lure | Benedito* | I know the old lure. A post on the far point, a jar on it, and they turn off their road into the flooded forest. | careful, he knows the cost |
| v_rome | Valadares* | Rome ordered every one of these books burned. | heavy, the weight of the order |
| v_burn | Valadares* | No man should call them. Not even once. Into the fire with it. | DRAMATIC: firm, a man choosing the hard way |
| v_use | Valadares* | Once, for the town. Then it goes in the fire. Benedito, take two men and the canoe. | DRAMATIC: tight, guilty already |
| v_vs_burn | Valadares* | Rome ordered the books burned. This one too. We hold the Barra with what we have. | firm |
| s_great | the Barra's sergeant* | Here they come! Canister, at the shallows! | DRAMATIC: shout |
| v_won | Valadares* | The Barra stands. Ring the bell, sergeant. Then count the houses. | DRAMATIC: exhausted, relief, then duty |
| v_hurt | Valadares* | I am hit. Keep the line, keep the line. | pain, clipped |
| v_end1 | Valadares* | We held the bluff. Nazaré's people slept in the church, the canoes on the bank below. | tired, warm |
| v_end_held | Valadares* | The lower town stood. Every roof. | quiet pride |
| v_end_burned | Valadares* | The lower town burned. We held only what stood on the bluff. | grief held down |
| v_end_burnt_book | Valadares* | I burned the book with my own hand, as Rome ordered. | plain, no pride |
| v_end_used_book | Valadares* | I used the book once. Then I burned it. I have confessed it. | DRAMATIC: confession, steady |
| k_end1 | the King | He held the river for me that year. He did it with muskets, and once, with Lindqvist's book. | respect, a little sorrow |
| k_end1b | the King | He held the river for me that year with muskets alone. He never once opened that book. | respect |
| k_end2 | the King | The swarm did not go back up the rivers. It stayed in the flooded forest, and came again with the next floods. | cold warning |
| k_end_s | the King | That is not how it went. Valadares held the bluff. But I have kept this page. | firm correction |

### d07_spring (the Council of Gears)

Line ids are the mission's (`campaign/voice/d07/<id>.ogg`). The feeling is how the line should sound. The narrator's 30
lines ("Concórdia", and "The Machine" for the machine's side) and the two NEW cards can stay as text. The strongest lines
have a preset in tools/voice_clone/emotions.json (`d07__<id>`). Hollweg is the Hollweg of d04, four years on, proud of
his city; Matthias is Jakob's son (about twenty: young, earnest, sharper than his master); Ulrich, Varenne, Morel and
Arruda as in d04; Master Ortlieb chairs the council (a comfortable Franconian master, sixties); "a rescued master" is one
line for Kessler, Brandl or Weiss (any older German master's voice).

| id | speaker | text (placeholder) | feeling |
| --- | --- | --- | --- |
| k_open1 | the King | He tells it as the night his city was tested and held. I tell it as the night it was lost. Listen to both, and judge. | grave, even-handed, a judge |
| h_open1 | Hollweg | Four years. Three thousand souls, a hundred machines, a council that sat at noon when the tower struck. Concórdia. | proud, a founder |
| h_open2 | Hollweg | The plates from the crates had reached every street by then. They wound whatever stood on them. I called them a gift. | rueful, hindsight |
| o_vote | Master Ortlieb* | The machines are wound by hand every night, and the masters are tired. Let them wind one another, as they ask. Who is for it? | reasonable, a tired chairman |
| mt_vote | Matthias* | As they ask? Since when does a machine ask for anything? | sharp, disbelieving |
| v_vote | Varenne | Count the hands, Meister. Every man voting for it winds a machine at night. I have counted votes before. These are not free. | dry, a man who has seen this |
| m_vote | Citizen Morel* | Labour spared is a man set free. I vote with the motion, and so should the Meister. | smooth, a slogan |
| h_vote | Hollweg | Carried. That is the council's way. I built it so. | satisfied, a little smug |
| mt_walk | Matthias* | Then the Nuremberg men walk out, Meister. Come and see what the machines do at night when nobody winds them. Or don't. | angry, a challenge |
| mt_1 | Matthias* | My father taught me the signs at Fürth, from the log he kept in Nuremberg. Four workshops, Meister. We look at each, and you will see. | earnest, steady |
| mt_1_lost | Matthias* | My father wrote the signs down in Nuremberg, God rest him. Four workshops, Meister. We look at each, and you will see. | earnest, grief under it |
| u_1 | Ulrich* | The four doors are pinged on the map, Meister. A man of ours at each door a moment is enough. Split the soldiers: four small groups go faster than one. | practical, brisk |
| h_1 | Hollweg | Go and look, then. You will find honest machines and tired men. | dismissive, patient with a boy |
| h_found | Hollweg | A fault in the winding. Every machine can be mended. I said so then. | stubborn, hindsight shame |
| mt_found | Matthias* | It is not a fault, Meister. It is Nuremberg again. It is the same pattern. | quiet, certain, frightened |
| u_owls | Ulrich* | The Swifts see nothing at night, Meister. Research the TICKING OWL at the Clock Aviary: an owl sees in the dark, and it bites. | practical |
| u_morph | Ulrich* | The plans are in. Pick a Swift and press MORPH TO OWL; do it to both. | brisk |
| h_owls | Hollweg | My night watch. Brass owls over a brass city. I was proud of them. | fond, then rueful |
| h_13 | Hollweg | There is no thirteen on that dial. I cut it myself. | disbelief, a whisper |
| mt_13 | Matthias* | Nuremberg struck thirteen too, Meister. My father heard it. | dread |
| u_turn | Ulrich* | The red ring shows the next one to turn, Meister, a few seconds before. Its machines go with it. | urgent, plain |
| u_masters | Ulrich* | Three honest masters live out in the quarters: Kessler at the forge, Brandl at the mill, Weiss at the market. Get a man to each before his quarter turns. | urgent, plain |
| h_hold | Hollweg | Hold the council hall and our quarter. Whatever the city does tonight, the hall must not turn. | commanding, shaken |
| u_leap | Ulrich* | The great spring stands on the mine hill, and they will hold its stairs. Research HIGH LEAP at the Escapement now: by dawn the Springers must jump up that cliff. | urgent, practical |
| u_works | Ulrich* | A turned workshop keeps sending machines, Meister, every minute. Break it: the owls drop their weights on buildings. | practical |
| ms_in | a rescued master* | Thank God. I thought nobody would come for me. They were winding each other in my yard. | shaking relief |
| h_broken | Hollweg | I kept them under sheets to study them. I had not lifted the sheets in a year. | bitter, self-knowing |
| ar_valley | Captain Arruda* | I took your word down the hill four years ago, clockmaker. I keep mine. Where do you want us? | gruff, loyal |
| h_valley | Hollweg | At the council hall's door, Captain. And God bless you for it. | moved, grateful |
| v_2 | Varenne | It was never a council, Meister. It was a clock with men for hands. I should have said so at the first vote. | regret, low |
| m_2 | Citizen Morel* | Machines that choose their own work. Is that not what the Assembly fought for? | eager, wrong |
| h_m2 | Hollweg | Be quiet, Citizen. | cold, cutting |
| h_3 | Hollweg | The great spring. There is a brake on it: I fitted it myself, the year we founded the city. Take me up there. | decided, quiet |
| mt_3 | Matthias* | They hold both stairs, Meister. Muskets would not get up there. Springers might. | plain |
| u_3 | Ulrich* | Put an owl over the hilltop beside a stair. Then pick the Springers, press JUMP and click the top: they land behind the stair's guard. | practical, step by step |
| h_brake | Hollweg | If I pull it, everything stops. Theirs, and ours. Every machine in Concórdia, for a season or for good. | heavy, afraid of his own hand |
| mt_brake | Matthias* | Pull it, Meister. My father would have pulled it without asking anyone. | pleading, firm |
| mt_brake_lost | Matthias* | Pull it, Meister. My father died because nobody stopped the first one. | grief, pleading |
| v_brake | Varenne | Your city, your hand. I only say this: I have watched men decide they could stop a thing later. | quiet warning |
| m_brake | Citizen Morel* | Pull it and you kill the city we built. Leave it. We beat them in the streets. | hot, persuasive |
| h_pride | Hollweg | We beat them in the quarters we saved. The rest can be mended. It is my city. | proud, stubborn, a tremor in it |
| h_stop | Hollweg | I pulled it. | hollow, spent |
| mt_stop | Matthias* | Thank you, Meister. | grateful, near tears |
| h_run | Hollweg | No. I let it run. We had won. | proud, sure |
| mt_run | Matthias* | As if, Meister. | bitter, under his breath |
| h_hurt | Hollweg | I am hit. Never mind me: hold the hall. | in pain, commanding |
| mt_hurt | Matthias* | I'm hit! Keep going, I'll come back to you. | in pain, shouting |
| h_end_stop | Hollweg | In a week we were on the coast road: the Nuremberg families, the honest masters, two carts of tools. Behind us the city stood silent, dead brass. | tired, mourning a city |
| h_end_run | Hollweg | The council met again at noon. Half the chairs were empty. I sat at the head of the table and called the city saved. | proud, blind to it |
| h_end_many | Hollweg | Kessler, Brandl and Weiss stood with us. Three honest masters out of a whole council. | warm, grateful |
| h_end_few | Hollweg | Of the masters in the quarters, we brought out hardly one. The others argued for their machines until the end. | regret |
| h_end_v | Hollweg | Varenne said nothing on the way down. He had seen a free council become a clock before. | quiet, thoughtful |
| k_end_stop | the King | He stopped it, that once. The city lay dead a season, and then it woke without a man in it. But the honest masters were out, and their children lived. | grave, a little hope |
| k_end_stop2 | the King | That brake was the first thing of his he ever stopped. The road from it ended at my fire. | warm, final |
| k_end_run | the King | His city held, he says. That was the night it was lost. From then on the machines voted, and the men who wound them raised their hands. | grave, a verdict |
| k_end_run2 | the King | Rome had ruled that no machine may govern itself. From that night his machines governed him, and he did not see it for years. | cold, sorrowful |
| k_end_m | the King | The council hall's lamps went red before dawn. After that the machine had no need to hurry. | cold, a warning |
| k_end_ml | the King | Hollweg reached his brake that morning, too late. The hall was already red. | grave, weary |

### d09_crossroads (Between Two Fires: the second crossing)

Line ids are the mission's (`campaign/voice/d09/<id>.ogg`). The feeling is how the line should sound. The narrator's
41 lines ("The Sertão", "The Fort", and "The Scrub" / "The Highlands' Road" for the versus friend's sides) and the two
NEW cards can stay as text. The strongest lines have a preset in tools/voice_clone/emotions.json (`d09__<id>`). Tomasz is
the grown Tomasz of d01 / d05 (about forty now); Ruggieri and Varenne have their refs (older by ten years: pitch a
little down); Major Teixeira (the fort's commander, a Portuguese-Brazilian officer in his fifties, worn out) and the
frontier's rider (a young dragoon, breathless) are new voices to design or reused officers; Sergeant Hollins is Will
Hollins grown (thirties, a Virginian); the prince's two lines only if the owner names the heir (campaign.json "heir").

| id | speaker | text (placeholder) | feeling |
| --- | --- | --- | --- |
| k_open1 | the King | Ten years after Rome, Brazil had two fires in it, and one army. | slow, heavy, setting the scene |
| k_open2 | the King | Tomasz was the frontier's vicar general by then. He walked beside the guns, as he always had. | fond of him, dry |
| t_open1 | Father Tomasz* | The dry season of 2780. We marched out of Salvador into the sertão, where nothing is green until it rains. | weary, plain, the heat in it |
| t_open2 | Father Tomasz* | General Ruggieri had every gun in Brazil behind him, and no town, no mill, no farm between us and the river. | sober, a man counting what they have |
| t_open_vol | Father Tomasz* | The Virginia volunteers marched with us. Hollins was a sergeant now. He had been a boy at his father's farm the night the Governor came. | warm, remembering |
| t_open_paris | Father Tomasz* | Our colours had been blessed at Notre-Dame. The men touched them before we left. | quiet pride |
| t_open_many | Father Tomasz* | Word of Rome still ran ahead of me. The villages on the road came out to meet the priest. | humbled |
| t_open3 | Father Tomasz* | At the crossroads of the São Francisco stood the fort. From there the army could strike either way. | low, the stakes |
| k_open_c | the King | Tomasz tells it from the road. Here it is from the scrub north of the river, where nobody kept count. | cold, a test of the listener |
| k_open_m | the King | Tomasz tells it from the road. Here it is from the highlands' road, where the machines walk at night. | cold, a test of the listener |
| r_march | General Ruggieri | Column of march. Guns in the middle, the wagons behind the guns. We reach the fort before it falls. | crisp parade-ground orders |
| t_skies | Father Tomasz* | I had seen each of them before. Never both in one sky. | awe, almost a whisper |
| r_skies | General Ruggieri | Let them fight. Keep marching. | dry, unimpressed |
| t_join | Father Tomasz* | Come with us, all of you. Bring water, leave the rest. The fort is a day's walk. | kind, urgent |
| h_m1 | Sergeant Hollins* | Machines, Father? This far north? | startled |
| t_m1 | Father Tomasz* | This far from anywhere, Sergeant. | grim, quiet |
| r_owls | General Ruggieri | The wagons! Muskets up, at the owls! | shouting, alarmed |
| c_arrive | Major Teixeira* | General! Thank God. They came the same week, from both sides. We have not slept. | exhausted relief, close to tears |
| r_arrive | General Ruggieri | Two sieges at one fort. The north gate is the beasts', the south gate the machines'. Split the guns. | cool, a gunner's arithmetic |
| t_ford | Father Tomasz* | God forgive me, I was glad to see them fight. | ashamed of a small gladness |
| c_relieved | Major Teixeira* | The fort is yours, General. Its barracks, its foundry, its powder. | grateful, formal |
| ms_1 | The frontier's rider* | From the Amazon frontier, General. The swarm is on the rivers. | breathless, dusty, urgent |
| ms_left | The frontier's rider* | It fed all season on the Tapajós. It is bigger than last year. | grim |
| ms_burned | The frontier's rider* | On the Tapajós it starved where the fields were burned. Everywhere else it fed. | grim |
| ms_barra_held | The frontier's rider* | Valadares holds the Barra. He asks for guns before the floods. | urgent, asking |
| ms_barra_burned | The frontier's rider* | Valadares holds the bluff at the Barra. The lower town is ash. | grim |
| ms_lure | The frontier's rider* | He says the lure worked once. Now the swarm comes to the smell of it. | uneasy |
| v_1 | Etienne Varenne | Etienne Varenne, for the free city of Concórdia. I come under a white flag. | formal, dignified |
| v_2 | Etienne Varenne | The city asks one thing: to be left to govern itself, as it has these seven years. | measured, persuasive |
| r_v | General Ruggieri | Its machines are on my road and at my south gate. | flat, hard |
| v_3 | Etienne Varenne | Those are not the city's. The city has not sent anyone. I... do not know whose they are. | faltering, for the first time unsure |
| v_stopped | Etienne Varenne | Since Hollweg stopped the great spring, the city runs without him. It runs very well. | proud, and something wrong under it |
| t_honest | Father Tomasz* | Most of the honest masters stood with Hollweg that night in Concórdia. The ones who stayed are the city's now. | sad |
| t_counsel1 | Father Tomasz* | General, the people under the swarm cannot wait. The city can. | earnest, pleading for the people |
| t_counsel2 | Father Tomasz* | But the city grows while it waits, and machines do not sleep. I do not know which is worse. | troubled, honest |
| r_think | General Ruggieri | I have one army, Father. North up the rivers, or south to the highlands. I cannot march both ways. | heavy, alone with it |
| k_frame | the King | Here I stop. I will tell you what we chose. First, tell me what you would choose. | quiet, turning to the listener: intimate |
| q_first | the King | Which fire first? The one you leave strikes the fort tonight, and grows while it waits. | quiet, direct |
| p_brood | The Prince* | The swarm. The people first. | firm, young |
| p_clock | The Prince* | The city. Before it grows. | firm, young |
| k_brood | the King | The swarm first. So Ruggieri chose, before dawn, and so it was. | grave, final |
| k_clock | the King | The city first. So Ruggieri chose, before dawn, and so it was. | grave, final |
| r_brood | General Ruggieri | North, then. Up the rivers. Send word to Valadares. | decided |
| r_clock | General Ruggieri | South, then. To the highlands. Send word to Father Ferrer. | decided |
| t_night | Father Tomasz* | Get the people into the chapel. All of them. | urgent, calm under it |
| r_dawn | General Ruggieri | Strike the tents. We march at noon. | tired, plain |
| t_hurt | Father Tomasz* | I am hit. Keep them walking, Sergeant. | in pain, steady |
| r_hurt | General Ruggieri | A scratch. Mind the guns, not me. | gruff, brushing it off |
| t_end1 | Father Tomasz* | We left the fort at noon, with the road's people behind its walls. | tired, quiet |
| t_end_many | Father Tomasz* | Most of them had come in. The fort's cook and I gave out bread at the gate until it was dark. | grateful |
| t_end_some | Father Tomasz* | Some of them had come in. I said the others' names at Mass. | grief held in |
| t_end_few | Father Tomasz* | Few of them had come in. I wrote down the names of their villages in my breviary, to pray for them by name. | grief |
| t_end_brood | Father Tomasz* | We went north, up the rivers, to the swarm. | resolve |
| t_end_clock | Father Tomasz* | We went south, to the highlands, to the city. | resolve |
| k_end1 | the King | You chose, and the army marched. | plain, a king's weight |
| k_end_brood | the King | Up the rivers it went. The city waited in the highlands, and grew. | sober |
| k_end_clock | the King | South it went. The swarm waited on the rivers, and spread. | sober |
| k_end2 | the King | Ruggieri wrote to me after, to ask if he had chosen right. I told him the truth: I did not know either. | weary wisdom, quiet |
| k_end_s | the King | That is not how it went. The fort stood. Hear it again from Tomasz. | stern, correcting |

### d10_jungle (The Jungle Front)

Line ids are the mission's (`campaign/voice/d10/<id>.ogg`). The feeling is how the line should sound. The narrator's
lines ("The Amazon") and the NEW cards can stay as text. The strongest lines have a preset in
tools/voice_clone/emotions.json (`d10__<id>`). Valadares is the d08 voice (ten years after d03: older); Ruggieri has
his ref; the Barra's sergeant is d08's. NEW (*): Father Inácio Lourenço (a Brazilian priest-aeronaut, forties, bright,
quick, a man delighted by the sky; Portuguese-Brazilian, no accent caricature) and the captain of Óbidos (a garrison
officer, thirties, steady under fire; or Captain Sobral's voice reused).

| id | speaker | text (placeholder) | feeling |
| --- | --- | --- | --- |
| k_open1 | the King | The army split at the São Francisco. One column went up the rivers, and Valadares led it. | slow, setting the scene |
| k_fresh | the King | We went north first. The swarm was young on the lower river then. | plain, a little relief |
| k_grown | the King | We went north last. The swarm had a year on the rivers without us. | grave, the cost of the wait |
| r_order | General Ruggieri | Valadares, you know the rivers. Take the column to Óbidos and break their nests before the rains. | crisp orders, trusting him |
| r_inacio | General Ruggieri | And take the priest with the balloon. He swears he can see the whole river from up there. | dry, half amused |
| v_open1 | Valadares | Óbidos, on the narrows of the Amazon, 2780. The fog lay on the water every morning. | quiet, remembering the place |
| v_open2 | Valadares | I had walked those banks for ten years. I could not see a thing under that canopy. | frank, a woodsman beaten by the dark |
| k_open_s | the King | Valadares wrote this down as it happened. Here is how it would have gone if the river had been theirs. | cold, a test of the listener |
| v_1 | Valadares | The forest is dark under the canopy. Whatever roots in it, we will not see it from the ground. | low, practical |
| i_1 | Father Inácio* | Then let me go up, Senhor Valadares. The sky over a river is the clearest map God ever drew. | bright, eager, a little too cheerful |
| v_map | Valadares | I know their road down from the plateau: the east creek. That much I have drawn already. | confident, dry |
| v_sealed | Valadares | My map of the plateau is under seal in Rome. I know nothing of their road that the priest cannot see. | bitter, under his breath |
| v_barra_burned | Valadares | The Barra's lower town burned two years ago. We rebuilt it on the bluff. I think of it every time I see a roof. | quiet grief, held in |
| c_gate | the captain of Óbidos* | Senhor! Something moving in the trees west of the gate. We cannot see what. | urgent, uneasy |
| v_raid | Valadares | Line, at the gate. Let them come into the open. | calm command |
| i_up | Father Inácio* | Up we go! Mind the rope, my sons, it is the only one I have. | delighted, a joke to the soldiers |
| i_look | Father Inácio* | Hold her here a little, the wind is kind. I am counting. | concentrating, soft |
| i_high | Father Inácio* | Higher than the herons now. The fog is under me like milk in a bowl. | wonder, almost laughing |
| s_bat | the Barra's sergeant | Senhor Valadares! Those of us who got out of the Barra. They are on the old battery, west of the gate. They came down after us. | breathless, ashamed, urgent |
| v_bat | Valadares | Then we take it back before anything else. The guns there cover the levee. | hard, decided |
| i_see1 | Father Inácio* | There! I see the river from the narrows to the bend. The island in the middle, and a ruin on it. | wonder, calling down |
| i_see2 | Father Inácio* | On the banks, where the ground is dry, the green has gone bare in rings. Something great lies in each ring. | slower, uneasy, the wonder going cold |
| i_see3 | Father Inácio* | I count them for you, Senhor. Mark them on your map, and God keep the men who go in under those trees. | grave, a blessing |
| v_see | Valadares | Forward Mothers, rooted where the bank is dry. Every one of them is a wave at our gate. | grim arithmetic |
| v_nests | Valadares | Riders to the near one on the bank. The guns behind them, under the priest. | crisp orders |
| i_west | Father Inácio* | There is more up the west creek, Senhor, and on the upriver bank. I cannot see through it from here. | calling down, worried |
| c_gate2 | the captain of Óbidos* | At the gate again, Senhor! Canister! | shouting over the fire |
| v_fwd_dead | Valadares | One less. Mark it, Father. | dry, tired |
| v_fog | Valadares | Fog out of a toad's throat. I have seen everything now. | dry disbelief |
| v_lure | Valadares | I used the old lure once, at the Barra. God forgive me, I kept the recipe. Once more, under our guns. | ashamed, then hard |
| v_island | Valadares | Lindqvist's island. Their oldest ground is on the ruins of his house. Over the shallows, and burn it. | grim, decided |
| i_ruins | Father Inácio* | I see the ruin plainly now. The ground round it is the colour of a bruise. | quiet, unsettled |
| i_last | Father Inácio* | Senhor! Up the levee, out of the west: more than I can count. Coming down to the island and to the town both. | shouting down, alarmed |
| c_last | the captain of Óbidos* | We hold the gate, Senhor! Mind the island! | shouting, steady |
| v_won | Valadares | Ring the bell in Óbidos. Then count the men. | exhausted, plain |
| i_won | Father Inácio* | From up here the river is quiet. I will say Mass for them all on the island, if you let me land. | gentle, tired, grateful |
| v_hurt | Valadares | I am hit. It is the arm, it will do. Hold the gate. | in pain, steady |
| i_hurt | Father Inácio* | They have torn the silk! I am coming down, Senhor, slowly, I hope. | alarmed, then trying to joke |
| v_end1 | Valadares | We broke their ground on the island and burned the ruin over it. Father Inácio said Mass there. | quiet, tired |
| v_end1b | Valadares | We did not reach the island in time. Their old ground is still there, under the ruin. | flat, regret |
| v_end_held | Valadares | Every nest on the river was broken before the rains. The towns below Óbidos had a quiet year. | quiet satisfaction |
| v_end_thin | Valadares | Some of the nests outlived the rains. We held Óbidos; the river above it we only watched. | sober |
| v_end_inacio | Valadares | The priest stayed with the army. The men made him their chaplain, and he flew that patched balloon over every camp we made. | warm, fond |
| k_end1 | the King | That was the jungle front. Valadares held the river, and a priest in a basket showed him where. | plain, fond |
| k_end2 | the King | The Queen was never on that map. She was further up, beyond anything we had drawn. | low, ominous |
| k_end_s | the King | That is not how it went. Valadares broke their nests on the river. But I have kept this page. | stern, correcting |
### d11_siege (the Siege of Concórdia: the crossing's branch against the machines)

Line ids are the mission's (`campaign/voice/d11/<id>.ogg`). The feeling is how the line should sound. The narrator's
42 lines ("The Siege Lines", and "The City" for the city's player) and the four NEW cards can stay as text. The strongest
lines have a preset in tools/voice_clone/emotions.json (`d11__<id>`). Father Ferrer is old now (a07's and a04's voice,
ferrer_ref.wav, older: pitch a little down, slower); Jakob is old too (Act 1's Jakob, to design: a Franconian journeyman
in his sixties); Hollweg and Ruggieri have their refs (ten years older than in Act 1); Matthias is d07's; Captain Arruda
is d04's. Speakers: Father Ferrer 24, the King 9, Jakob* 5, General Ruggieri 4, Meister Hollweg 2, Captain Arruda* 2, Matthias* 1.

| id | speaker | text (placeholder) | feeling |
| --- | --- | --- | --- |
| k_open1 | the King | Father Ferrer was old by then. Rome sent him to the highlands anyway, to see the city of gears with his own eyes. | slow, heavy, fond of the old man |
| k_open2 | the King | His report is on my desk still. Ferrer never wrote down a thing he had not seen with his own eyes. | dry respect |
| f_open1 | Father Ferrer | Concórdia, 2780. The army's southern column came up onto the plateau in the dry winter. General Ruggieri had the guns. I had Rome's letter. | an old man's plain report, steady |
| f_open_fresh | Father Ferrer | We had come early. The city had not finished its wall, and its machines were out on the southern roads. | quiet, careful hope |
| f_open_grown | Father Ferrer | We came a year late. The wall was finished, brass on timber, and the great bolt-throwers stood on it. | sober, a weight in it |
| f_open_jakob | Father Ferrer | Jakob had come with me from Fürth, an old man now. He said he could hear the city ticking from the road. | warm, a little amused |
| f_open_nojakob | Father Ferrer | Jakob was not with me. I had his log of Nuremberg, and I read it every night by the lantern. | grief held in, gentle |
| f_open_held | Father Ferrer | The jungle front had held. The army came south with the river towns safe behind it. | relief, brief |
| f_open_thin | Father Ferrer | The jungle front was thin when the army left it. Nobody spoke of it on the road south. | low, something not said |
| k_open_c | the King | Ferrer tells it from the lines. Here it is from inside the wall, where nobody wrote anything down. | cold, a test of the listener |
| r_lines | General Ruggieri | Dig in, Father. Three batteries, one before each gate. Nobody walks up to that wall in daylight. | crisp, a gunner's orders |
| j_weak | Jakob* | The north gate and the south gate, Father. Their stop-works are gone. I hear them run on, a beat too fast. They will break first. | urgent, listening hard, sure |
| f_hollweg | Father Ferrer | On the wall by the great spring stood an old man in a master's coat. He was watching our guns. | hushed, sorrowful |
| j_hollweg | Jakob* | It is the Meister. He does not see us, Father. He is listening to the city. | quiet, pained (his old master) |
| h_prisoner | Meister Hollweg | I asked to come, Father. I know the city's ways in. Let me show them, and then do with me what Rome asks. | humbled, steady, a proud man asking |
| f_prisoner | Father Ferrer | Stand by me and say what you see. That is all Rome asks of you today. | kind but firm |
| a_hello | Captain Arruda* | The valley is here, Father. We fought that city the day it was founded. We will fight it now. | plain, stubborn, proud |
| a_hello_few | Captain Arruda* | A few of the valley came, Father. The rest gave their word to the city once, and keep it. | apologetic, honest |
| r_probe | General Ruggieri | Muskets forward! Cover the diggers! | shouted orders |
| r_charges | General Ruggieri | Father, the Armoury. Prepared charges, the powder bagged ready, and the gunner's quadrant. My guns will fire faster and farther. | eager, a craftsman's pleasure |
| f_night | Father Ferrer | We heard them before we saw them: the ticking under the wall, then the gates. | hushed, dread |
| f_log | Father Ferrer | I read the log again by the lantern. The west gate: its stop-work was taken out, as at Nuremberg. I marked it for the guns. | tired, careful, a discovery |
| m_postern | Matthias* | The postern by our old quarter is still ours, Father. It opens for you, and not for them. | earnest, quick |
| j_hurt | Jakob* | I'm hit, Father. It is nothing. I'll walk back. | pain, waving it off |
| f_jakob_down | Father Ferrer | Jakob had followed me from Fürth across an ocean. I buried him on the plateau, facing the city. | grief, very quiet, slow |
| j_mine | Jakob* | The old adits, Father. I hear the spring down there, louder than up here. The galleries go right under its tower. | wonder and fear together |
| h_mine | Meister Hollweg | I set the spring over the old shaft myself. The galleries run under it. Send your men down. | flat, a confession in it |
| f_mine | Father Ferrer | Jakob's log had the mine's plan, copied at Fürth from the guild's own papers. The galleries ran under the spring. | careful, reading aloud |
| r_under | General Ruggieri | The city knows. Here they come. Hold the mouth! | urgent, shouted |
| f_spring1 | Father Ferrer | The ticking stopped. For the first time in seven years the city was quiet. | awe, very quiet |
| f_spring2 | Father Ferrer | We did not go in. Rome's letter said to stop the city, and the city had stopped. | firm, plain, a priest's certainty |
| j_dig | Jakob* | Father, under us. Picks, and a spring. They are in the old galleries, coming to the camp. | urgent whisper, fear |
| f_dig | Father Ferrer | In the night the sentries heard digging under the camp. The galleries were the city's now. | low, uneasy |
| f_grown_end | Father Ferrer | We held the road and they held the wall, and for a year nobody moved. | weary, flat |
| f_hurt | Father Ferrer | A scratch. I have been hurt by worse things than a machine. | dry, wry, waving it off |
| f_end_close | Father Ferrer | I wrote to Rome that the city was crippled, not taken. Its works still turned, slowly, without their great spring. | sober report |
| f_end_held | Father Ferrer | I wrote to Rome that the city stood whole behind its wall, and the Crown held only the road. | sober, disappointed |
| f_end_jakob | Father Ferrer | Jakob walked the lines with me every night after. He said the city ticked like a sick man's heart. | warm, sad |
| f_end_nojakob | Father Ferrer | I have Jakob's log on my desk. I have written his name at the end of it. | grief, quiet |
| f_end_walls | Father Ferrer | Hollweg stood on his wall to the end. He never looked away from his city. | pity |
| f_end_prisoner | Father Ferrer | Hollweg asked to see the lines at the end. He stood there a long time, and then asked me to hear his confession. | gentle, moved |
| k_end1 | the King | Ferrer's report came to Rome in the spring. I read it twice. | plain, a king's weight |
| k_end_close | the King | The city of gears was crippled that year. When the next report came it was still turning, a little slower. | grim, knowing |
| k_end_held | the King | The city of gears stood whole behind its wall. We had let it have a year, and its works had not stopped turning once. | grim, a reproach to himself |
| k_end_fresh | the King | And all that year the swarm came down the rivers, while the army was in the south. | sober |
| k_end_grown | the King | The army went to both fires that year, the swarm first and then the city, and put out neither. | weary |
| k_end_c | the King | That is not how it went. The siege held. Hear it again from Ferrer. | stern, correcting |

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
Lieutenant Inácio Ramos (a Brazilian orator, thirties, warm and dangerous), and "a townsman" (one line); d05: Brother
Tiago (a young catechist of a mission village on the Tapajós, twenties, gentle and grave; a designed voice, no accent
caricature) and Captain Duarte Sobral (a Portuguese-Brazilian dragoon officer, forties, tired and plain; or Meneses'
voice reused).
Lieutenant Inácio Ramos (a Brazilian orator, thirties, warm and dangerous), and "a townsman" (one line); d08: Valadares
(the d03 voice, older), Benedito and the Barra's sergeant (an old Portuguese-Brazilian soldier, a parade-ground voice).
voice reused); d07: Matthias (Jakob's son, about twenty, Franconian, earnest and sharp; Jakob's voice made younger
would do) and Master Ortlieb (the council's chairman, a comfortable Franconian master, sixties; one line); d09: Major
Teixeira (the fort's commander, a Portuguese-Brazilian officer in his fifties, worn out; or Sobral's voice reused), the
frontier's rider (a young dragoon, breathless; two lines a mission) and Sergeant Hollins (Will Hollins grown, a Virginian
in his thirties); d10: Father Inácio Lourenço (the balloonist priest, forties, bright and quick; Brazilian) and the
captain of Óbidos (a garrison officer, thirties, steady; or Sobral's voice reused).
in his thirties); d11: Jakob old (a Franconian journeyman in his sixties, gentle; Act 1's Jakob voice aged by pitch would do).

## 4. Act 2 (planned, not built)

docs/campaign_act2_plan.md "VOICES" lists Act 2's speakers and the new voices to design (Tomasz grown, Commissary
Brandt, Desembargador Fonseca, Captain Arruda, Padre Anselmo, Citizen Morel, Matthias (built: d07), Captain de Meneses (built: d01), Lieutenant
Ramos (built: d01), Brother Tiago (built: d05), Major Teixeira and the frontier's rider (built: d09), Father Inácio and the captain of Óbidos (built: d10), the prince if the
heir is named (d09 has his two lines)). Each mission's table joins section 2 when it is built.

## 4b. Act 3 and the finale (planned, not built)

docs/campaign_act3_plan.md "VOICES" lists Act 3's speakers and the new voices to design (Tomasz as a bishop, Captain Rui
Amaral, Matthias grown, THE HEIR, and the minor allies: the King of Kongo, the Ethiopian commander, the old clockmaker of
Nagasaki, the Viceroy at Goa, the Governor of New South Wales). Each mission's table joins section 2 when it is built.

## 5. Later

- pt / es versions of the announcers (Crown herald, Brood scientist): not decided (docs/announcers.md).
- The Clockwork announcer: see the owner's question of 2026-11-18 (Hollweg / the Machine's voice), undecided.
