# Act 2, "Between Two Fires": what was built (job d09-crossroads)

Act 2 build step 12 (docs/campaign_act2_plan.md "d09_crossroads"): THE SECOND CROSSING. The dry season of 2780: the army
of Brazil under General Ruggieri marches from Salvador's road through the sertão to Fort Constantine (proposed) at the
crossroads of the São Francisco, and both fires find it: the swarm from the north-west, the city of gears' machines from
the south-west. At the fort, in one evening, the Crown chooses which to fight first. Father Tomasz tells it; the King
frames it, and at the choice he stops his story and asks the listener. EVERY LINE OF TEXT IS A PLACEHOLDER for the owner.

The rules it keeps: THE BROOD IS NOT A PERSON (no creature has a name, a reason, a want or a plan: the swarm "came far from
the rivers, after the herds"; nothing more). The machines are not people either: nobody in the city will say who sent
them, and Varenne, their envoy, does not know whose they are. LOCAL PEOPLE ARE MINOR: Major Teixeira (the fort) and the
frontier's rider have a few lines each; the villagers none. The Crown and the Church are the good side: Tomasz's counsel
is a priest's, honest about both fires. THE CROSSING HAS NO CANON (owner 2026-11-22): the player chooses, and the King
tells the choice as what Ruggieri did.

## Files

| what | where |
| --- | --- |
| the map | `campaign/maps/sao_francisco.json`, written by `tools/campaign/make_sao_francisco_map.py` (`--ascii` prints it) |
| the mission | `campaign/missions/d09_crossroads.json`, written by `tools/campaign/make_d09_mission.py` (edit the script, run it) |
| the stills (stand-ins) | `campaign/stills/d09_01.jpg` .. `d09_03.jpg`, drawn by `tools/campaign/make_d09_stills.py`; the King's pages reuse p01_01 |
| texts pt / es | `tools/i18n/campaign/d09_crossroads.txt` (written by the mission script; then `python3 tools/i18n_build.py`); two war map lines in `tools/i18n/campaign/warmap_act2.txt` |
| the storylines | `campaign/campaign.json`: d09 is the last mission of all three lines (after d05, d07 and d08, like a07 in Act 1); d05's, d07's and d08's `next` (their own side's win) is d09 (their generators and JSONs) |
| the hubs | the King's study: the King's talk after d09 by `first`, the Cardinal's, a new talk RUGGIERI'S DISPATCH (in the hub's list); `campaign/hubs_grow.json`: General Ruggieri's line after d09; the Clockmaker's hub: Hollweg after d09 by d07 `spring`; the Naturalist's hub: Valadares after d09 by `first` |
| the war map | `tools/campaign/warmap_act2.py` (run it: it writes `campaign/warmap.json`): d09's rules were already planned (the sertão the Crown's, the fort, the ledger by `first` and `sertao`, the waiting front's clock); added: a versus friend's win breaks the seal |
| the roster ladder | `tools/campaign/roster_ladder.py`: C7 = d09 (ARMOUR + THE POWDER WAGON), bound team `army`, NEW cards at 8 s, side `crown`, the cards in pt / es; docs/campaign_roster_ladder.md (the checked table printed again: it also shows d05's C6 now) |
| the roles | `scripts/campaign/rebels.gd`: ruggieri_general, tomasz_vicar, hollins_sergeant, fort_commander, sertanejo (new keys, no duplicate) |
| the engine | `scripts/campaign/mission_run.gd`: a unit's or spawn's `"kit"` (Unit.set_kit: the armour, a lock, a bayonet as it comes out); docs/campaign_engine.md "Added by Act 2's d09_crossroads" |
| tests | `tools/test_campaign_d09.gd` (`godot --headless --fixed-fps 30 --path . --script res://tools/test_campaign_d09.gd [-- only=data,flags,part1,part2,part3,defeat,versus,save,ironman,hubs]`); `tools/test_war_map.gd` (its d09 check) |
| the balance sim | `tools/sim_campaign_d09.gd` (`-- active [lazy] [diff=easy/hard] [first=brood/clockwork] [families=leave] [fields=burned] [spring=stopped] [brood_n=few/all] [varenne=executed] [until=s] [save_at=s] [shots=dir]`) |
| voices | docs/chatterbox_todo.md "d09_crossroads" (59 lines with their feeling); tools/voice_clone/emotions.json `d09__<id>` |
| pictures | docs/shots/d09_crossroads/ (CHECK THE FEEL, below) |
| patch note | scripts/patch_notes.gd and tools/i18n/patch/notes.txt under 0.38.999 |

## The map: the road to the São Francisco (160 x 96, the SERTÃO biome, a dry white day, dusk, night)

The painted sertão of the act2-terrain job: cracked red-brown earth and pale dust, thorn scrub (caatinga), mandacaru and
xique-xique cactus, ox skulls, red sandstone mesas.

- THE ROAD from Salvador's way (the east edge) west: RIACHO SECO (proposed, the first village: a well, a cross, a drying
  rack), LAGOA BRANCA (proposed, the second, by a dried pond), then a long DRY STRETCH to the fort.
- FORT CONSTANTINE on the river's east bank (west-centre): a palisade with a NORTH GATE, a SOUTH GATE and the road's EAST
  GATE; inside the fort's MAGAZINE (in the middle) and chapel, and the army's depot (Barracks, Armoury, Foundry, horse
  lines, quarters).
- THE SÃO FRANCISCO along the west with three FORDS: the north ford (the swarm's way over), the fort's ford under its west
  wall (where they meet), the south ford (the machines' way over). Beyond: the north-west trail (the jungle's way) and the
  south-west trail (the highlands' way). A signpost at the fort's ford (the letter, with a06 `varenne` executed).
- Mesas in the scrub, each with one ramp, away from the road; thicker thorn brakes where the raids come out.

## How it plays: THE ARMY OF BRAZIL (solo; co-op p1; versus p1)

The player has General Ruggieri and Father Tomasz (heroes: wounded, not killed), 6 Musketeers and 4 GUARDSMEN (all with
the C5 kit: Matchlock and Socket Bayonet), 3 Dragoons and 3 CUIRASSIERS (the Cavalry Charge drilled), 2 Field Cannons, a
Mortar and 2 POWDER WAGONS, 300 gold and 160 powder; with p01 `families` save (the canon) Sergeant Hollins and 4
Virginia volunteers. Armour is researched; nothing new is built (a march and a fort: the story's deny). NEW (C7): ARMOUR
and THE POWDER WAGON, both explained by their NEW card.

- PART 1, THE ROAD (a countdown: the fort holds out 5:30 NORMAL; out, the siege begins without the army). March west.
  There is no Mill on the road: the wagons refill the line (the lesson at 0:32). TWO SKIES at 0:14: the swarm's Hatchlings
  and the city's Swifts meet over the road and fight each other (both bite only flyers). The villages' people JOIN THE
  COLUMN when the army reaches them and FOLLOW FATHER TOMASZ (16 in all). RAIDS: Raptors out of the north scrub at Riacho
  Seco (just after the army reaches it); Clock Soldiers and Springers out of the south thorns at Lagoa Branca; two
  TICKING OWLS dropping on the powder wagons (an objective); the machines again in the dry stretch with Netters; Raptors
  and a Tyrant Challenger between the army and the fort. Scripted Raptors hunt the people; the machines go for the army.
- PART 2, THE FORT (when ten of the army reach the east gate, or the fort's clock runs out): both besiege it at once,
  THE CREATURES AT THE NORTH GATE, THE MACHINES AT THE SOUTH GATE, three waves each over 1:30; at 0:20 a band of each comes
  over to the fort's ford and they TEAR AT EACH OTHER there (a line, the ford shown). The army's pay chest (300 gold) comes
  with it: the fort's Barracks trains armoured men, the Foundry guns and wagons, the wagons refill at the Barracks.
  RELIEVED when the last waves are in and fewer than three of either stand round the fort; at dusk (4:00 NORMAL) both
  draw back anyway (NO WAITING).
- PART 3, THE COUNCIL OF WAR: a mid-match show (solo pauses): the frontier's rider (the swarm fed on the Tapajós or
  starved there by d05 `fields`; the Barra held or burned by d08 `barra`; the lure by d08 `lure`), the city's envoy
  (VARENNE under a white flag with a06 `varenne` spared, who does not know whose the machines are; executed: a letter
  nailed to the ford's post), Matthias's masters by d07 `honest` many, Tomasz's counsel (both ways, honestly), Ruggieri's
  "One army. Two fires.", and THE FRAME AT THE CHOICE: the King: "Here I stop. I will tell you what we chose. First, tell me
  what you would choose."
- THE CHOICE, WHICH FIRE FIRST: THE SWARM FIRST / THE CITY FIRST, each button saying what follows (the front fought
  first is fresh, the other waits and grows). The King then says it as Ruggieri's choice. Nobody answers in two minutes:
  the match's seed picks (the same on every machine): no canon.
- THE NIGHT (2:05, the same on every difficulty): the fire NOT chosen strikes the fort first, four waves at its gate (the
  swarm at the north gate with Spitters, Tyrant Challengers and at last a BRUTE; the machines at the south gate with
  Springers, Netters, owls on the buildings, a Pendulum and at last a SPRING BALLISTA). DAWN: WON, with the flags.
- LOST: the fort's MAGAZINE blown (at any time).

## Co-op and versus

- CO-OP: the second player is the fort's garrison (BLUE: Major Teixeira, 8 Musketeers at the two gates, a Field Cannon);
  scripted it holds its gates.
- VERSUS: the friend picks THE CREATURES or THE MACHINES (a07's VERSUS PICK). His side's band waits on its bank (the swarm:
  8 Raptors, 2 Spitters, a Tyrant Challenger, 4 Hatchlings; the machines: 6 Clock Soldiers, 2 Springers, a Netter, 2
  Swifts, kept wound), every raid and wave of his side is his to lead, and he gets a little food or cogs every 10 s. He
  wins by blowing the fort's magazine before dawn. The other side stays scripted and fights both. A friend's win is not how
  it went: the war map's seal is broken.

## The flags read and set

Read (every one has the canon as its default when missing):

| flag | effect |
| --- | --- |
| p01 `families` save (canon) / leave | the Virginia volunteers and Sergeant Hollins march with the army (and two lines), or not |
| a06 `varenne` spared (canon) / executed | Varenne the city's envoy at the council (four lines) / a letter on the ford's post |
| a06 `paris` stood | Tomasz: the colours were blessed at Notre-Dame |
| a07 `people` many | Tomasz: the villages came out to meet the priest |
| d05 `fields` left (canon) / burned | the rider: the swarm fed all season / starved where the fields burned; left: one Raptor more in every siege and night wave of the swarm |
| d06 `brood_n` few / some (canon) / all | every swarm wave one Raptor fewer / as written / one more |
| d07 `spring` running (canon) / stopped | stopped: every machines' wave one Clock Soldier fewer (dead brass); Varenne: "the city runs without him. It runs very well." |
| d07 `honest` many | Tomasz: the honest masters went with Hollweg; the ones who stayed are the city's |
| d08 `barra` held (canon) / burned, `lure` used | the rider's report from Valadares |

Set:

| flag | values |
| --- | --- |
| `first` | brood / clockwork (THE CHOICE; no canon; unanswered: the seed's pick) |
| `fort` | held (at dawn); fallen (a versus friend's win) |
| `sertao` (+ `sertao_n`) | the road's people who reached the fort, as a share of all 16: few under 40%, some, many from 70% |

## Balance (tools/sim_campaign_d09.gd; the last runs)

On 0.38.203 + this branch, `godot --headless --fixed-fps 30 --script res://tools/sim_campaign_d09.gd -- <args>`:

| run | result | time | sertao | longest idle |
| --- | --- | --- | --- | --- |
| active first=clockwork (NORMAL) | WON | 4:58 | many (16) | 18 s |
| active diff=easy first=brood | WON | 4:56 | many (16) | 27 s |
| active diff=hard first=brood | WON (the army down to about a third by dawn) | 5:00 | many (16) | 17 s |
| active, every flag the other way (fields burned, spring stopped, brood_n all, families leave, Varenne executed), first=clockwork | WON | 5:15 | many (16) | 27 s |
| active, saved at 3:20 and loaded (save_at=200) | WON, "SIM LOAD SAME yes" | 4:58 | many (16) | 25 s |
| lazy (nothing done) | LOST: the siege begins without the army at 5:30, the magazine blown at 9:03 | 9:03 | none | (lazy) |

The longest stretch with nothing to do was the end of the night (the last wave beaten, dawn not yet): 47-66 s with a 2:30
night, so the night is 2:05 with its waves at 0:06, 0:34, 1:02 and 1:30, and does not grow on EASY (a longer night is no
easier). The bot plays it fast (it marches straight down the road); a person fighting each raid takes longer.

## Pictures (docs/shots/d09_crossroads/, CHECK THE FEEL)

From `xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --script res://tools/sim_campaign_d09.gd -- active
first=clockwork shots=docs/shots/d09_crossroads`: the start on the road, the two skies, Riacho Seco, the first raid, the
machines at Lagoa Branca, the owls, the last raid, the fort besieged, the ford, the siege's second waves, the council and
the choice, the night (twice), dawn. What was looked at is in "Looked at" below.

## Stills: the prompts for the owner (ChatGPT, one request each, at most 3 reference images; each prompt stands alone)

House style as Act 1: an oil painting in the manner of an 18th-century history painting, visible brushwork, 3:2
landscape (cut to 1280 x 853), no text. Save each as `art/campaign/stills/d09_0N.png` and cut it into
`campaign/stills/d09_0N.jpg`.

- d09_01 THE ARMY OF BRAZIL. "Oil painting, 18th-century history painting style. A long column of soldiers in purple
  coats, cuirassiers in breastplates and covered powder wagons marches along a dusty road through dry thorny scrub and
  tall candelabra cactus under a white sky, red earth and a red mesa far off; a grey-haired general on a grey horse; a
  priest of about forty in a black cassock walks beside the guns. 3:2 landscape, no text." (References:
  campaign/stills/p01_05.jpg, campaign/stills/a06_02.jpg.)
- d09_02 TWO SKIES. "Oil painting, 18th-century history painting style. Over a dry red-earth plain with thorn scrub and
  cactus, two flights meet in a pale sky: small brass clockwork birds from the left and small green winged reptiles from
  the right, tearing at each other; soldiers in purple coats below shade their eyes and look up. 3:2 landscape, no text."
  (References: campaign/stills/d03_04.jpg, campaign/stills/a07_06.jpg.)
- d09_03 THE COUNCIL OF WAR. "Oil painting, 18th-century history painting style. Inside a whitewashed fort's room lit by
  oil lamps at evening, a grey-haired general of artillery in a purple coat stands over a map of Brazil on a table; a
  priest of about forty in a black cassock beside him; in the doorway two messengers, one a young dragoon dusty from a
  long ride, one a lean man in black holding a white flag. 3:2 landscape, no text." (References: campaign/stills/a06_05.jpg,
  campaign/hub/rome_tomasz.png (made younger), campaign/stills/a07_03.jpg.)

## The voice lines

docs/chatterbox_todo.md "d09_crossroads": 59 spoken lines (Tomasz, Ruggieri, the King, Varenne, Major Teixeira, the
frontier's rider, Sergeant Hollins, the prince's two if the heir is named) with the feeling of each; the 41 narrator lines
("The Sertão", "The Fort", "The Scrub", "The Highlands' Road") and the two NEW cards can stay as text. Ten lines have a
preset in tools/voice_clone/emotions.json (`d09__<id>`). New voices to design: Major Teixeira, the frontier's rider,
Sergeant Hollins grown (section 3 of that file).

## What is placeholder

Every line of text (en, pt, es). The three stills (drawn in code). The people's art: Ruggieri and Tomasz are Act 1's art,
Hollins the volunteer's, Major Teixeira a plain Officer, the villagers Nazaré's. The fort's magazine is a Powder Mill, its
chapel a Church, the army's quarters Cottages. The machines' raiders are kept wound by the mission (the city's plates far
off: no Winders on the road).

## Claude's choices for the owner

1. THE NAMES (proposed): Fort Constantine, Riacho Seco, Lagoa Branca, Major Teixeira, Sergeant Hollins (Will Hollins of
   p01 grown).
2. NO CANON FOR THE CHOICE: unanswered for two minutes, the match's seed picks (the same on every machine and replay). The
   King says the player's choice as Ruggieri's ("So Ruggieri chose, before dawn, and so it was"), and the hubs too ("You
   chose the swarm first, as Ruggieri did").
3. THE FRAME AT THE CHOICE is inside the mission: the council's show ends on the King's page ("Here I stop... First, tell
   me what you would choose") and the choice's line is his question; with the heir NAMED (campaign.json "heir") the prince
   says his answer too (two lines), with UNSEEN (the owner's answer) the button is the answer.
4. THE NIGHT is fought against the fire NOT chosen (the plan): the swarm first means the machines strike the fort that
   night, and the other way. It is 2:05 on every difficulty (NO WAITING; a longer night would not be easier).
5. THE ARMY'S DEPOT IN THE FORT is the player's (Ruggieri's staging fort, built the year before): the fort's Barracks,
   Armoury, Foundry and horse lines can train from the start (from afar, as d05's breeder), and the pay chest (300 gold)
   comes at the fort, so the night can be met with new Guardsmen and wagons. The garrison owns only the palisade, the
   chapel and the magazine.
6. ARMOUR COMES RESEARCHED: C7's two pieces are the armoured men (4 Guardsmen, 3 Cuirassiers in the column, more from the
   fort's Barracks) and the wagons; nothing has to be researched on a march.
7. THE MAGAZINE is the fort: the one thing that must stand (primary). The heroes are wounded, not killed; the people are an
   optional count (`sertao`).
8. THE VILLAGERS FOLLOW TOMASZ (d05's FOLLOW) once the army reaches them, at three quarters of a Labourer's pace (a little
   under a Musketeer): "keep him with the army" is the line. They are counted in at the fort's gate.
9. THE TWO SKIES are Hatchlings against Swifts: both bite only flyers, so they fight each other and hurt nobody on the
   ground (the crossing in one picture). Scripted Raptors go for the people; scripted machines for the army.
10. THE MACHINES ARE KEPT WOUND by the mission (the friend's too: there are no Winders on the road); d07 `spring` stopped
    makes every machines' wave one smaller.
11. THE FORD: at 0:20 of the siege a band of each is sent to the fort's ford so the player sees them fight each other
    (the plan's "the creatures and the machines fight each other at the ford").
12. THE SIEGE ENDS at the last waves with fewer than three of either round the fort, or at dusk; what is left of both is
    taken off the map when the council begins (they "draw back over the river"), so the night's attack comes fresh.
13. THE MARCH ENDS when ten of the army stand before the east gate (not four quick riders), so the guns and wagons are part
    of the march; if the fort's clock runs out first, the siege begins without them (the march objective simply closes).
14. VERSUS: the friend wins by the magazine, not by the people (one clear aim for a raid); his side's band and its waves
    are his; he gets 15 food or cogs every 10 s, enough for a little; THREE SEATS (the plan's "later") are not built.
15. VARENNE does not know whose the machines are ("Those are not the city's... I do not know whose they are."): the
    timeline's deception on the city's side, and no machine given a will.
16. THE RIDER'S REPORT reads d05 and d08 as the plan says; d05 `fields` left (the canon) also makes the siege's and the
    night's swarm one Raptor bigger (it fed).
17. HOLLWEG'S HUB after d09: with the spring running he hears the masters "agree, all of them, at once"; stopped, he hears
    from the coast of Varenne's errand. VALADARES' hub line follows `first`.
18. THE KING'S STUDY gets RUGGIERI'S DISPATCH as a talk in the hub's list (no painted hotspot yet: the plan's "a new
    hotspot"; a painting can place it later), and Ruggieri's armoury line after d09.

## Looked at (CHECK THE FEEL)

The pictures in docs/shots/d09_crossroads/, looked at one by one:

- The sertão reads as dry land: red cracked earth, pale dust, cactus and thorn scrub, the villages' huts small beside the
  soldiers (the scale is right: a man about a hut's door high). The road is easy to see on the minimap.
- The skies (4, 6): the brass owls and the green flyers are small but clear against the red ground; the NEW card for
  ARMOUR (7) comes up during the third raid's fight and covers the top right of the screen: readable, but a player in a
  fight may skip it; the objective line keeps the gist.
- The fort (8, 9): the palisade ring, the magazine and the depot show; the two gates are told apart by Ruggieri's line
  ("north gate the beasts', south gate the machines'"), and the pings fall on the gates.
- THE NIGHT WAS NOT DARK in the first run: a slow dusk (4 minutes) started with the siege was still under way when the
  night came, and the two fought over the colour, so the night stayed nearly day. Fixed in the engine (a new light stops
  the old one: docs/campaign_engine.md); the second run's night (12, 13) is a deep blue and the dawn (14) warm.
- The council (10) and the choice (11): the still, the King's frame line and the two buttons fit on a 1280 x 720 screen.
- Small things left: the siege objective says "(0 left)" for a moment before the first waves are counted; the
  narrator's card shows initials (TS: no portrait for a place, as everywhere).

## What is left

- The owner's texts, stills and voices; Major Teixeira's, the rider's and Hollins' voices to design.
- d10_jungle and d11_siege read `first` (FRESH / GROWN, act2-engine0's versions) and lock the front not chosen until the
  first is won (owner question 9).
- Three seats online (Act 3).

## Tests run

- tools/test_campaign_d09.gd: 0 failures (data, flags, every part, the choice both ways, defeat, versus, save, ironman,
  hubs, no script error).
- Every other tools/test_campaign_*.gd, tools/test_roster_ladder.gd and tools/test_war_map.gd: 0 failures, but
  test_campaign_m1's "no recording yet for Tomasz" check, which fails on main too (the emotion run of 0.38.168 recorded
  t_open3). test_campaign_a07 needed d09's `needs` to name a07_council (every mission after Rome does); test_war_map's
  Act 2 state check now expects d08 and d09 (built) locked, d10 and d11 planned.
- tools/i18n_build.py and tools/i18n_patch_build.py ([]).
