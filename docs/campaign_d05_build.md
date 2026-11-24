# Act 2, "The Mission of São Rafael": what was built (job d05-aldeia)

Act 2 build step 9 (docs/campaign_act2_plan.md "d05_aldeia"): the Crown line's second mission of Act 2, after d01_minas.
The Tapajós, the wet season of 2776: Father Tomasz's own mission village of São Rafael (proposed) on a bluff above the
flooded forest, a week's paddle above the river fort. The first time the Crown meets THE BROOD as a swarm. Father Tomasz
tells it; the King frames it. EVERY LINE OF TEXT IS A PLACEHOLDER for the owner.

THE BROOD IS NOT A PERSON (owner 2026-11-19 / 2026-11-22): no creature has a name, a will, a plan, a feeling or a home.
The swarm hunts and feeds; its flyers circle and the pack follows where they circle; its forward Mother roots and lays.
People may call a creature something: the dragoons call the big Sire "the Lindqvist Sire" (one line, with a05 `cages`
all); nothing more. The Cardinal's hub line says it plainly: "the swarm does not hate anyone. It eats." LOCAL PEOPLE ARE
MINOR: Brother Tiago (the village's catechist) and Captain Sobral (the river fort) have a handful of lines each; Tomasz
carries the mission.

## Files

| what | where |
| --- | --- |
| the map | `campaign/maps/sao_rafael.json`, written by `tools/campaign/make_sao_rafael_map.py` (`--ascii` prints it) |
| the mission | `campaign/missions/d05_aldeia.json`, written by `tools/campaign/make_d05_mission.py` (edit the script, run it) |
| the stills (stand-ins) | `campaign/stills/d05_01.jpg` .. `d05_04.jpg`, drawn by `tools/campaign/make_d05_stills.py`; the King's pages reuse p01_01 |
| texts pt / es | `tools/i18n/campaign/d05_aldeia.txt` (written by the mission script; then `python3 tools/i18n_build.py`) |
| the storyline, the hub | `campaign/campaign.json`: d05 joins the Crown line ("prologue") after d01; d01's `next` is d05 for both sides (`tools/campaign/make_d01_mission.py`); the King's study: the King's talk after d05 by `fields`, the Cardinal's |
| the war map | `campaign/warmap.json` already had d05's pin and rules (act2-warmap: the Tapajós to the Brood with `fields` left, contested and the burnt church with burned, a ledger line by `aldeia`, a broken seal for a swarm's win). Checked against the flags set here: they match |
| the roster ladder | `tools/campaign/roster_ladder.py`: C6 = d05 (THE DRAGOON + THE CAVALRY CHARGE), bound team `mission`, NEW cards at 8 s, side `crown`, the cards in pt / es; docs/campaign_roster_ladder.md |
| the roles | `scripts/campaign/rebels.gd`: tomasz_rafael, tiago, mission_militia, rafael_villager, sobral, forward_mother (stand-ins) |
| the engine | THE VÁRZEA: mission `"wade"` (`scripts/campaign/mission_run.gd` `wade` / `wade_free`, `scripts/unit.gd` the pace in the flood, `scripts/game.gd` placement_problem: nothing built in it); docs/campaign_engine.md "Added by Act 2's d05_aldeia" |
| tests | `tools/test_campaign_d05.gd` (`godot --headless --fixed-fps 30 --path . --script res://tools/test_campaign_d05.gd [-- only=data,varzea,flags,part1,part2,part3,defeat,mirror,save,ironman,hubs]`); `tools/test_war_map.gd` (d05 built: locked until d01) |
| the balance sim | `tools/sim_campaign_d05.gd` (`-- active [side=swarm] [diff=easy/hard] [lazy] [fields=burned] [people=many] [brood_n=few/all] [gold=few] [minas=restless] [cages=all] [until=s] [save_at=s] [shots=dir]`) |
| voices | docs/chatterbox_todo.md "d05_aldeia" (45 lines with their feeling); tools/voice_clone/emotions.json `d05__<id>` |
| pictures | docs/shots/d05_aldeia/ (CHECK THE FEEL, below) |
| patch note | scripts/patch_notes.gd and tools/i18n/patch/notes.txt under 0.38.999 |

## The map: São Rafael on the Tapajós (104 x 128, the VÁRZEA biome, rain, night then day)

The painted várzea ground of the act2-terrain job (the flood water and reeds, the wet grass and mud, the várzea trees and
buriti palms, aninga, floating grass, snags).

- THE VÁRZEA: everything off the dry ground is shallow flood water (ford cells) among drowned trees (a quarter of the
  cells): open enough that the creatures cross it anywhere.
- THE BLUFF (north-centre, high ground): the village: the church (a timber church with a bell; 900 hp), the granary, four
  houses, the mission's Barracks. Three ramps: west to the causeway, east to the landing, south to the trail.
- THE FIELDS below the bluff, dry clearings in the flood: the WEST field, the NORTH field, the RIVER field (east, by the
  landing). Each a Farm building (the mission's fields), spared by the creatures (only THE CHOICE's fire takes them).
- THE LANDING on the Tapajós (east): a beach, canoes drawn up, a drying rack, a wayside cross.
- THE CAUSEWAY west to THE HAMLET of Santa Luzia (proposed): two houses and its chapel.
- THE TRAIL to the river fort (south): about 90 tiles of dry path winding through the flood, a wayside cross and a signpost.
- THE RIVER FORT at the south end on its dry rise: its Barracks and Horse Breeder, a palisade along the north edge with
  the gate open where the trail comes in.
- THE MUD BANK in the north flood, where the swarm's forward Mother roots.
- Hummocks with buriti palms in the flood (ground, not roads).

## THE VÁRZEA rule (the engine's piece of this mission)

Mission `"wade": {"pace": 0.5, "free": ["brood"]}`: a ground unit standing on a ford cell walks at half pace, except the
Brood's (the creatures go through the flood as fast as on dry ground); flyers are not touched; nothing is built on a ford
cell ("Not in the flooded forest: nothing stands in the várzea's water."). So the dry trails are the men's roads and the
flood the swarm's: the swarm comes out of it anywhere along the trail, and a rider who leaves the trail to chase a pack
is slow. The plan's "only creatures and canoes cross" became "men wade slowly" (Claude's choice 1).

## How it plays: THE MISSION (the Crown; solo, versus p1)

The player has Father Tomasz (a hero: wounded, not killed), Brother Tiago (a hero, a Missionary: he brings the fallen
back), 8 militia Musketeers (10 with a07 `people` many) with THE ROSTER LADDER's C5 kit drilled (the Matchlock and the
Socket Bayonet), 300 gold and 300 powder, the village's Barracks, and down the trail the river fort's Barracks and Horse
Breeder. Nothing new is built (a mission village and a river fort: the story's deny); Musketeers and Dragoons are trained.
THE GRANARY feeds whoever holds it (the mission's own while it stands, 20 gold every 10 s; the swarm's when creatures
stand round it and none of the mission's).

- PART 1, THE FIRST NIGHT (night, rain; dawn at the latest at 4:00 NORMAL): Tomasz has the bell rung; the families in the
  three fields can't hear it in the rain. A soldier or Tomasz reaching a field (5 tiles) sends its people running for the
  churchyard. Raptors come out of the flood at the west field (0:20), the north field (0:45) and the river field (1:10,
  with a Tyrant Challenger on NORMAL / HARD); then the push on the bluff for the churchyard (at 1:40, or as soon as
  everyone is in). Everyone in and the push beaten: dawn at once (NO WAITING).
- PART 2, THE RELIEF (dawn, then day): Captain Sobral, 4 Dragoons (2 with d01 `gold` few: "the Governor's purse is thin
  since Minas") and 3 Horsemen ride in on the player's team, with 200 gold (NEW: THE DRAGOON and THE CAVALRY CHARGE).
  THE HAMLET: a pack round the chapel at Santa Luzia (7 Raptors, a Tyrant Challenger); the hamlet's people are shut in
  their chapel (untouchable) until one of the player's men stands there with the pack gone; then they come out and walk
  back to the churchyard. On the way back the pack comes at the causeway (more of it while the flyers live). THE
  CHARGE: the river fort's Horse Breeder is pinged; select it on the map and drill the Charge (nobody need go there).
  THE FLYERS: Hatchlings circle the village ("where they circle, the pack follows"): shoot them down. A probe comes up
  at the village while the riders are away. The chapel holds for 4:00 (NORMAL); after that the pack breaks in.
- PART 3, THE ROAD TO THE FORT: the forward Mother roots on the mud bank with a Tyrant Sire; while she lives every wave is
  bigger (an optional objective to kill her). Every one of the people FOLLOWS TOMASZ (at the column's pace: they carry
  their things): walk him down the trail to the river fort with the soldiers round the column; the fort's gate shuts
  at dusk (5:00 NORMAL). Waves out of the flood beside the trail every 22 s (bigger from the third while the forward
  Mother lives, a Raptor more while the fields feed them, a Tyrant Challenger from the third on NORMAL / HARD). 16 s in:
  THE CHOICE.
- THE CHOICE, THE FIELDS: Sobral would burn the fields and the granary; Tomasz: "That is the people's bread for the
  winter"; Tiago: they ask you to choose. BURN THEM (the fields and the granary burn down in 25 s, the waves get no
  bigger for want of food) or LEAVE THEM (the canon, and the default after 60 s: the swarm feeds, one Raptor more in
  each wave). Canon LEFT (owner 2026-11-22: "the fields LEFT").
- THE END: every one of the people at the fort or fallen, or the gate shut at dusk: WON if anyone reached the fort; the
  flags. LOST: the church broken before the road, every one of the people dead, or the gate shut with nobody in.

## How it plays: THE SWARM (the solo pick, or versus p2)

The forward Mother rooted on the mud bank from the start (stage 2), the Tyrant Sire and the Storm Sire rooted by her
(Raptors and Hatchlings on her card), a pack of 8 Raptors (10 with d06 `brood_n` all), 300 food, 30 food every 10 s
besides the granary (no grubs in the flood). No Spitters, Brutes or third stage (the story's deny: the scripted swarm's
own pieces). The village plays on a timetable: the bell is heard at 0:12 and the fields' people go in, the militia hold
the bluff, the relief arrives at 2:30 and rides to the hamlet, the people take the road at 5:00 behind Tomasz with the
soldiers following. WIN: break the church, or catch more than half the people before the fort. LOSE: the Mother killed,
or the column at the fort. A swarm win is not how it went (the King: "That is not how it went."): the war map's seal is
broken (act2-warmap's rule).

## The flags read and set

Read (every one has the canon as its default when missing):

| flag | effect |
| --- | --- |
| a07 `people` many | two more militia, and Tomasz's line "They trusted me before I had earned it" |
| d01 `minas` restless | Tomasz's opening line "I had left Minas uneasy" |
| d01 `conspirator` fled | Tomasz's opening line, a prayer for Ramos |
| d01 `gold` few | the relief smaller (2 Dragoons, not 4) and Sobral's line on the Governor's purse |
| d06 `brood_n` few / some (canon) / all | every scripted wave one Raptor smaller / as written / one bigger; the hamlet's Challenger only from some; the swarm player's pack 8 / 10 |
| a05 `cages` all | the dragoons call the forward Mother's Sire "the Lindqvist Sire" (one line) |

Set:

| flag | values |
| --- | --- |
| `fields` | burned / left (THE CHOICE; left when nobody answers, and on a swarm's win) |
| `aldeia` (+ `aldeia_n`) | the people who reached the fort as a share of all 30: few under 40%, some, many from 70%; a swarm's win: few |
| `forward` | killed / rooted (the forward Mother on the mud bank: for d10's forward nests) |

## Balance (tools/sim_campaign_d05.gd; the last runs)

SIM_TABLE

## Pictures (docs/shots/d05_aldeia/, CHECK THE FEEL)

SHOTS_NOTES

## Stills: the prompts for the owner (ChatGPT, one request each, at most 3 reference images; each prompt stands alone)

House style as Act 1: an oil painting in the manner of an 18th-century history painting, visible brushwork, 3:2
landscape (cut to 1280 x 853), no text. Save each as `art/campaign/stills/d05_0N.png` and cut it into
`campaign/stills/d05_0N.jpg`.

- d05_01 SÃO RAFAEL. "Oil painting, 18th-century history painting style. A mission village on a riverside bluff in the
  Amazon in the wet season: a timber church with a whitewashed front and a wooden bell tower beside it, thatched houses,
  small green fields on dry ground below; native converts and a priest of about thirty-five in a black cassock at the
  church door; all round, a forest standing in brown flood water. Soft evening light. 3:2 landscape, no text."
  (References: campaign/stills/b01_02.jpg, campaign/hub/rome_tomasz.png (made younger), campaign/stills/d01_02.jpg.)
- d05_02 THE BELL. "Oil painting, 18th-century history painting style. Night and heavy rain at a timber mission church
  in the Amazon: a priest in a black cassock pulls a bell rope with both hands while villagers run in from the fields
  toward the lamplit door; at the edge of the flooded forest behind them pale eyes and lean green reptilian shapes, like
  small raptors, low in the water. 3:2 landscape, no text." (References: campaign/stills/b01_04.jpg, d05_01 when painted.)
- d05_03 THE DRAGOONS. "Oil painting, 18th-century history painting style. Dawn in a muddy jungle clearing beside a
  flooded forest: mounted soldiers in purple coats and tricornes gallop with sabres raised into a pack of lean green
  raptor-like reptiles that scatter before them; spray and mud. 3:2 landscape, no text." (References:
  campaign/stills/a05_03.jpg, campaign/stills/b01_04.jpg.)
- d05_04 THE FIELDS. "Oil painting, 18th-century history painting style. Dusk at a mission village: a priest in a black
  cassock and a cavalry captain in a purple coat stand by a wooden granary with a lit torch between them, not yet
  lowered; behind them a long column of villagers carrying bundles walks down a trail into a flooded forest; the
  fields beside them green and full. A grave, quiet moment. 3:2 landscape, no text." (References:
  campaign/hub/rome_tomasz.png (made younger), d05_01 when painted.)

## The voice lines

docs/chatterbox_todo.md "d05_aldeia": 45 lines (Tomasz 23, Captain Sobral 8, the King 7, Brother Tiago 7) with the
feeling of each; the 35 narrator lines ("São Rafael", and "The Flood" on the swarm's side) and the two NEW cards can
stay as text. Brother Tiago and Captain Sobral are new voices to design (section 3 of that file); Tomasz is d01's grown
Tomasz. Ten lines have a preset in tools/voice_clone/emotions.json (`d05__<id>`).

## What is placeholder

Every line of text (en, pt, es). The four stills (drawn in code). The new people's art: Tomasz is a01's art, Tiago Frei
Joaquim's, the militia the hired guns', the villagers Nazaré's, Sobral a plain Horseman, the forward Mother the Brood
Mother's art drawn small. The granary is a Cottage named "The granary" and the fields are Farms. The bell is c01's
`campaign/bell_toll` sound.

## Claude's choices for the owner

1. THE VÁRZEA'S RULE: the plan says the flooded forest is "walkable only for creatures and canoes, slow for men". Built
   as: everyone can enter it, men and horses wade at half pace, the Brood at full pace, nothing is built in it. A true
   no-go for men would need pathfinding by faction; half pace already makes the trails the men's roads (the sims' riders
   stayed on them). Canoes stay stills (no naval play).
2. THE FIELDS' PEOPLE DON'T HEAR THE BELL: Part 1's task is to fetch them (a soldier or Tomasz within 5 tiles of a field
   sends its people to the church), so the night has something to do from the first second (SAY IT PLAINLY, NO WAITING).
3. THE RELIEF ARRIVES AT THE VILLAGE'S FOOT on the player's team (not riding up the whole trail as a scripted column):
   4 Dragoons and 3 Horsemen with Captain Sobral. The Dragoon is C6's new piece, but the CAVALRY CHARGE works on Horsemen
   (Defs: "Horsemen and Cuirassiers charge"), so the relief brings both; the Charge is drilled at the fort's Horse Breeder
   by selecting it on the map (60 gold; the relief brings 200).
4. THE HAMLET'S PEOPLE ARE SHUT IN THEIR CHAPEL (untouchable) until the player comes: otherwise the pack would kill them
   before anyone could ride out. Their chapel holds 4:00 (NORMAL); after that they are lost.
5. THE FLYERS (Hatchlings) bite only flyers, so they hurt nobody: their part is that "where they circle, the pack
   follows": while any lives, the flank wave on the causeway is twice as big. No line gives them any knowing.
6. THE PEOPLE FOLLOW TOMASZ in Part 3 (the engine's FOLLOW on every one of them, at 0.4 of a Labourer's pace: they carry
   their things): the player walks him down the trail. The plan's "groups" became one column.
7. THE CHOICE comes 16 s into the road (Sobral, Tomasz, Tiago; a still), not when "the last group leaves": the column is
   one group (choice 6). Unanswered after 60 s: LEFT, the canon. BURNED: the fields and the granary burn down in 25 s
   (the rain does not put this fire out); LEFT: one Raptor more in every wave after (the swarm feeds) and the granary
   feeds the swarm's player in the mirror.
8. THE FORWARD MOTHER roots in Part 3 (in the mirror from the start: the swarm's player needs her); killing her is
   optional; the flag `forward` (killed / rooted) is set for d10's forward nests.
9. THE SWARM'S SIZE BY d06 `brood_n`: one Raptor fewer / more in every wave (never under one); the mirror's pack 8 / 10.
10. `aldeia`: few under 40% of the thirty at the fort, many from 70%.
11. THE CHURCH must stand until the road (a primary objective): the people kneel in its yard all night.
12. THE MIRROR'S VILLAGE runs on a timetable (the bell heard at 0:12, the relief at 2:30, the road at 5:00) and has four
    more militia than the Crown's player has, so the night is a fight for the swarm too. The swarm's player wins by more
    than half the people (16 of 30) or the church.
13. NOTHING NEW IS BUILT by the mission (a village and a fort): the Barracks train Musketeers and Dragoons, the church
    trains Missionaries.
14. HARD's waves are x1.6 (the engine's default x1.25 left the sims' careful player losing no more people on HARD); EASY
    x0.7.
15. THE KING'S FRAME: "You will hear how it was born. He met it first." (the plan's choice 2: a player who plays the Crown
    line first meets the swarm before d06).
16. NAMES (proposed): São Rafael, the hamlet of Santa Luzia, Brother Tiago, Captain Duarte Sobral, "the river fort" (left
    unnamed).
17. THE HUB: the King's talk after d05 by `fields`; the Cardinal's "On the Tapajós I learnt that the swarm does not hate
    anyone. It eats. That is worse."; no new hub painting (the King's study stays the Crown's hub).

## What is left

- The owner's texts, stills and voices; Tiago's and Sobral's voices to design.
- d10_jungle reads `fields` (forward nests) and `forward`.
- The mission is short for a bot that plays it well (about five minutes); a person takes longer (the sims' Part 2 is
  quick because the bot sends every rider at once).

## Tests run

TESTS_RUN
