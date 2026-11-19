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

Narrator lines ("Nuremberg", "Paris", "The Machine", "The Free Assembly", "The Rio Negro", "Lyon", "Fürth", "The
Mountain", "Rome", "The Creatures", "The Automata") can stay as text.

## 3. Voices to design first (ElevenLabs Voice Design, then a ref file)

Done: hollweg, lindqvist (v2), fairleigh, ruggieri, varenne, explorer (now Valadares? the owner to say). The King
uses king_ref.wav / king_ref_b.wav.
Still to design: Tomasz young (a01, a06, p01) and old (the Cardinal), Ferrer, Jakob, Valadares (or the explorer ref),
Pieter, Benedito, Captain Delorme, Colonel von Rauch, Brother Anselm, Will Hollins, and the one-to-two-line parts
(Teles, Frei Joaquim, the Captain of the Watch, the Commissary, Rouvière, Mère Gautier, the Sergeant, the guide, the
Cardinal Dean of a07).

## 4. Act 2 (planned, not built)

docs/campaign_act2_plan.md "VOICES" lists Act 2's speakers and the new voices to design (Tomasz grown, Commissary
Brandt, Desembargador Fonseca, Captain Arruda, Padre Anselmo, Citizen Morel, Matthias, Captain de Meneses, Lieutenant
Ramos, Brother Tiago, the prince if the heir is named). Each mission's table joins section 2 when it is built.

## 5. Later

- pt / es versions of the announcers (Crown herald, Brood scientist): not decided (docs/announcers.md).
- The Clockwork announcer: see the owner's question of 2026-11-18 (Hollweg / the Machine's voice), undecided.
