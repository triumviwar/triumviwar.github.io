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

## 3. Voices to design first (ElevenLabs Voice Design, then a ref file)

Done: hollweg, lindqvist (v2), fairleigh, ruggieri, varenne, ferrer (2026-11-22), explorer (now Valadares? the owner to say). The King
uses king_ref.wav / king_ref_b.wav.
Still to design: Tomasz young (a01, a06, p01; a "Tomasz Wierzbicki (the young seminarian)" voice is in the owner's
ElevenLabs account: its sample would do) and old (the Cardinal), Jakob, Valadares (or the explorer ref),
Pieter, Benedito, Captain Delorme, Colonel von Rauch, Brother Anselm, Will Hollins, and the one-to-two-line parts
(Teles, Frei Joaquim, the Captain of the Watch, the Commissary, Rouvière, Mère Gautier, the Sergeant, the guide, the
Cardinal Dean of a07). Act 2: Ulrich (the guild's foreman: d02, a rough Franconian voice, older than Jakob) and
Commissary Brandt (a dry chancery official, German).

## 4. Act 2 (planned, not built)

docs/campaign_act2_plan.md "VOICES" lists Act 2's speakers and the new voices to design (Tomasz grown, Commissary
Brandt, Desembargador Fonseca, Captain Arruda, Padre Anselmo, Citizen Morel, Matthias, Captain de Meneses, Lieutenant
Ramos, Brother Tiago, the prince if the heir is named). Each mission's table joins section 2 when it is built.

## 5. Later

- pt / es versions of the announcers (Crown herald, Brood scientist): not decided (docs/announcers.md).
- The Clockwork announcer: see the owner's question of 2026-11-18 (Hollweg / the Machine's voice), undecided.
