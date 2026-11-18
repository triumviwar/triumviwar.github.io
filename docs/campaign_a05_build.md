# Act 1, "The Specimens": what was built (job a05-specimens, 0.38.64)

Act 1's mission a05_specimens (docs/campaign_act1_plan.md, "a05_specimens", with its OWNER ANSWERS of 2026-11-17
22:04 and the Brood prologue's flip): the Naturalist line's third mission, after The Lost Plateau. Two years after the
station burned, the Academy pays for an expedition to the cloud mountain, and DR. LINDQVIST comes back for the
creatures: a breeding stock (a young Sire for the eggs he saved) or eggs to begin again. Played by default as THE
EXPEDITION: by night take the eggs and cage the sleeping young; by day guard the cage carts down to the river while the
pack comes for them; load what is left into Benedito's canoes. Lindqvist tells it, old and a prisoner before the King
(2795), as his finest expedition; the King frames it and says where it was not. THE CREATURES are the mirror (the solo
side pick and versus), bound to the roster ladder's B3 (GROW, MATURE). No choice: the counts carry.

EVERY LINE OF TEXT IS A PLACEHOLDER for the owner to rewrite (kept short and plain on purpose). The stills are stand-ins.

## Files

| what | where |
| --- | --- |
| the mission | `campaign/missions/a05_specimens.json`, written by `tools/campaign/make_a05_mission.py` (edit the script, run it) |
| the map | `campaign/maps/plateau_descent.json` (`campaign:plateau_descent`), written by `tools/campaign/make_plateau_descent_map.py`; opens in the MAP EDITOR |
| the stills (stand-ins) | `campaign/stills/a05_01.jpg` .. `a05_05.jpg`, drawn by `tools/campaign/make_a05_stills.py`; the King's pages reuse `b01_08` (the naturalist in chains before the King) |
| texts pt / es | `tools/i18n/campaign/a05_specimens.txt` (then `python3 tools/i18n_build.py`); cage cart = carroça-jaula / carro-jaula |
| the storyline, the hub | `campaign/campaign.json` ("naturalist": b01, a03, a05; the warehouse at the Barra after a05; Lindqvist's lines by the side and the cages) |
| a03's way on | `tools/campaign/make_a03_mission.py`: `"next": {"party": "a05_specimens"}` (a nest win leads nowhere, as a02's Machine) |
| the war map | `campaign/warmap.json`: a05's pin is live (its working title dropped: the mission's own), rules by `cages` and by a creatures' win |
| the roster ladder | `tools/campaign/roster_ladder.py`: a05's card time and side, B3's NEW cards in pt / es |
| the engine | `scripts/campaign/mission_run.gd` (CAGE CARTS: `cart`, `cargo`, exits `cargo` / `max` / `cargo_counter`; `remove`; sleep `except_tags`; `spare` off leaves a carted creature untouchable), `scripts/game.gd` (`mends`, mission `mend_allies`), `scripts/unit.gd` (a cage cart never blows up; repair by `mends`), `scripts/brood_mature.gd` (a caged creature can't MATURE), `scripts/campaign/rebels.gd` (roles), `scripts/campaign/campaign.gd` (the checks) |
| test | `tools/test_campaign_a05.gd` (`godot --headless --fixed-fps 30 --script res://tools/test_campaign_a05.gd`) |
| balance | `tools/sim_campaign_a05.gd` (`-- [active] [side=expedition|creatures] [clutch=..] [saved=..] [pieter=..] [eggs=..] [map=drawn|withheld] [diff=..] [none]`) |

## The map: the plateau's descent (128 x 150, the jungle biome)

- NORTH, THE TOP: the plateau (high ground); THE NEST'S HOLLOW in its north-middle (low ground, two ramps from the
  south), the Mother rooted there, her hunters and grown ones asleep round her. THE EGG BED in the reeds at the hollow's
  west edge (13 tiles from the sleepers).
- THE FERNS: three beds of young on the top south of the hollow (west, middle, east), apart from the nest; the
  EXPEDITION'S CAMP on the plateau's south edge with the cage carts.
- THE TWO WAYS DOWN: THE SHORT WAY (the commission's path, from Valadares' map) leaves the camp's middle by a ramp and
  goes straight south; THE LONG WAY (Benedito's memory) goes west along the top to an old ramp at the far west and winds
  through the forest. Both are cleared trails through a dense forest; the PACK'S PATHS lead from small clearings in the
  forest (where the raids wait) to the trails; the Sire's from the east down to the quay.
- SOUTH: THE QUAY on the river: Benedito's canoes, and two LISBON CRATES "for the mines in the south", a gear stamped
  on the wood: the act's one crate hint (question 12).

## How it plays: THE EXPEDITION (the default side; solo, or versus against the creatures)

Opening (the King and his prisoner; Lindqvist goes on, by b01's `clutch`): two years after the station, the Academy's
money again; the eggs he saved had hatched and needed a father, or he had nothing but his notes.

- THE SIDES. The expedition (YELLOW, yours): LINDQVIST (320 health, his fowling piece), PIETER if he lived (the
  specimen book), the HIRED GUNS (Musketeers) and PORTERS (Labourers); 150 gold and 60 powder, nothing to build (the
  team's roster denies every building). THE CONVOY (YELLOW, scripted, the same side): a CAGE CART for each bed of young
  (a Powder Wagon with a cage: 320 health, it never blows up; it carries the expedition's powder: a musketeer refills
  beside one). The porters MEND a hurt cart (an ally's: the mission's `mend_allies`). BENEDITO waits at the quay (pinned,
  spared). The creatures (GREEN, scripted): the Mother (spared: not the doctor's business), a Rootmaw and grubs, SIX
  RAPTORS, TWO SPITTERS, TWO TYRANT CHALLENGERS and a VENOM CHALLENGER asleep (last year's young, grown), a Mound
  Turtle; the CLUTCH (five eggs, kept as eggs) at the egg bed; the YOUNG asleep in the ferns: a Raptor (west), a Spitter
  (east) and, with a breeding stock, THE YOUNG SIRE (a Tyrant Sire at 0.55, 480 health) in the middle. THE PACK (GREEN,
  scripted): the raids.
- NIGHT and a light mist (sight 0.75). "Dawn in 10:00: the nest wakes with the sun."
- PART 1, THE TAKING: stand by each sleeping young one 4 s (any of the expedition's men): it is NETTED and its cart
  comes; the cart beside it, the young one is CAGED on it. THE EGGS (optional): Lindqvist stands 8 s at the egg bed; the
  eggs are lifted off and he carries them (slower, unarmed: b01's crate) to the end. WALK SOFTLY (optional): a man within
  6 tiles of a sleeping hunter, or a hunter hurt, WAKES THE NEST: Part 2 at once with what is caged. The young are
  spared while they sleep (the men don't shoot them), so netting never wakes anything.
- PART 2, THE TRAIL (every young caged, the nest woken, or dawn): the nest wakes, the light greys to day, the mist
  lifts; the empty carts stay on the mountain; the caged carts roll down by a ROUTE at an ox's pace (0.4 of a wagon's):
  THE SHORT WAY if a03's map was drawn (or not known), THE LONG WAY if withheld. THE RAIDS: every 1:15 from 0:35 the pack
  comes out of a clearing along the way and goes for the nearest cart (Raptors; from the second raid the grown ones,
  Tyrant Challengers, then Spitters and Venom Challengers: "Those are not hatchlings"); with no cage left on the road
  they go for the men. A CART BROKEN FREES ITS CREATURE: it is on its feet, open to attack, and turns on the men within
  20 tiles. The nest's own hunters keep near home (14 tiles).
- PART 3, THE LANDING (a cart at the river): "The canoes leave in 3:00"; Benedito's lines and THE CRATES; the carts that
  reach the quay are LOADED, cage and all, as many as the canoes hold (NAZARÉ'S PADDLERS by b01's `saved`: 2 / 3 / 4);
  20 s later THE TYRANT SIRE comes out of the forest to the east for the last cart. Lindqvist goes last: on the quay 2 s
  once every cage is loaded or lost, the canoes full, or their time come: the canoes push off and the win comes 5 s
  later.
- THE WIN: flag `cages` few / some / all (of those that set off: under half, half or more, all; `cages_n` the number),
  `eggs` taken / left, `pieter` alive / lost, `way` short / long, `crates` seen.
- THE DEFEATS (retry): Lindqvist killed; nothing caged when the carts must go (dawn); every cage broken before the
  river; the canoes gone without him.

## How it plays: THE CREATURES (the solo side pick, YOU PLAY: THE CREATURES; or the friend in versus)

No creature speaks (b01): the King's two lines in the opening and the ending, objectives and sounds only.

- You are the nest in its hollow: the Mother, a Rootmaw and grubs (a standard start), 500 food and 40 spoils, the
  hunters and grown ones asleep, the turtle. THE NEST SLEEPS: your hunters sleep, and every new one with them, until
  the strangers come within 6 tiles or the carts set off; the Mother, the grubs, the Rootmaws and the turtle work on.
  The young in the ferns sleep apart (`except_tags`): they are the expedition's to take.
- THE ROSTER LADDER'S B3 (the NEW cards, 8 s in): GROW (the Mother rooted, to stage 2: 300 food) and MATURE (a Raptor
  into a Tyrant Challenger, a Spitter into a Venom Challenger, from her stage 2). No Tyrant Sire of your own (the story's
  deny: he is away; he comes in Part 3, yours).
- The expedition is scripted: Lindqvist to the egg bed, then to each bed in turn (the men following him, the carts
  coming), then the carts down the way and the men following them, Lindqvist to the quay in Part 3.
- THE HUNT (Part 2): "free the young: break the cage carts (half will do), or kill the doctor, before the canoes
  leave": you win when half the cages that set off are freed or Lindqvist dies; you lose when he goes down to the
  canoes. A freed young one is yours again. A caged one can't MATURE ("It is caged.").
- A creatures' win counts for its player (side `creatures`, flag `specimens` freed); its ending is the King's: "That is
  not how it went. The carts came down to the river."

## The flags read (a missing flag is the canon) and what they change

| flag | value | a05 |
| --- | --- | --- |
| b01 `clutch` | saved (canon) | A BREEDING STOCK: three carts, the young Sire among the young ("a father for my line"), six guns and four porters; the ending: "In a year I had a breeding stock" |
| | burned | A FRESH START: two carts (a Raptor, a Spitter), four guns and two porters; "Enough to begin again"; the ending: "my new beginning" |
| b01 `saved` | few / some (canon) / many | Nazaré's paddlers: room in the canoes for 2 / 3 / 4 cages (Benedito says so with few or many) |
| b01 `pieter` | alive / lost (canon) | Pieter with the expedition (110 health), the specimen book, "One in the book"; lost: Lindqvist keeps the book himself |
| b01 `eggs` | taken / left (canon) | taken: four more young Raptors in the nest, "The pack carried my clutch up here after all" |
| a03 `map` | drawn (canon) / withheld | drawn: the short way and two more guns (the Academy's copy of the map, "more of it"); withheld: the long way through the forest |
| a03 `party` | | not read (the plan's note only) |

Flags it SETS (kept when won): `cages` few / some / all and `cages_n`, `eggs` taken / left, `pieter` alive / lost, `way`
short / long, `crates` seen; the creatures' win: `specimens` freed. For a07: `cages` is the size of the escaped
creatures' side, `eggs` Lindqvist's line.

## The engine (docs/campaign_engine.md "Added by Act 1's a05_specimens")

- CAGE CARTS: `{"cart": {"tag", "cart", "caged", "freed", "freed_tag"}}` cages each creature of the tag on the nearest
  free cart of the cart tag (one a cart): carried with it every frame, caged (can't move or fight), spared, shoving
  nobody, the cage's bars drawn round it; the cart broken (dead) FREES it (counted, tagged); the cart leaving by an exit
  with `"cargo": true` takes it along (and an exit takes only carts with a cage). Exits also take `"max"` (a number or a
  counter: the canoes' room) and `"cargo_counter"`. Condition `{"cargo": {"tag", "at_least" / "below"}}`: living carts
  with a cage. Role `cage_cart` (a Powder Wagon that never blows up: meta `cage_cart`).
- `{"remove": {"tag", "empty"}}`: taken off the map (not killed: the eggs lifted into Lindqvist's crate; `empty`: only
  carts with no cage).
- sleep `"except_tags"`: those sleep apart (the young never wake the nest).
- `spare` off leaves a carted creature untouchable until its cart breaks.
- mission `"mend_allies": true`: workers may repair an ally's machines and buildings (Game.mends; the right-click and
  the repair work): the porters mend the convoy's carts.
- MATURE refuses a caged creature.
- Roles: `porter`, `hired_gun`, `cage_cart`, `young_sire` (Rebels.ROLES).

## Balance (tools/sim_campaign_a05.gd, NORMAL)

The expedition's bot: Lindqvist alone to the egg bed (the men wait at the camp), then three guns to each bed in turn
until it is caged; on the trail the guns keep round the carts (spread over them) and fight what comes within 7 tiles of
a cart, the porters mend the most hurt cart under 80%, Lindqvist walks behind the last cart; in Part 3 he goes onto the
quay once the carts are in (or 40 s before the canoes go). The creatures' bot GROWs the Mother when it can and, from
Part 2, sends every hunter and the Sire at the nearest cart with a cage (a musketeer in its way first).

BALANCE_TABLE

Reading: the taking is quiet (a minute and a half for a bot that knows the beds; a person exploring at night takes
longer, inside the 10:00 dawn). The trail is the fight: a bot that spreads the guns round the carts loses a cage or
none to the raids; the Sire at the river usually breaks one. The long way is longer and passes more clearings. Speed:
the sim runs about 1.4x real time headless.

## Stills: the prompts for the owner (ChatGPT, one request each, at most 3 reference images; each prompt stands alone)

House style as the prologues: an oil painting in the manner of an 18th-century history painting, visible brushwork, 3:2
landscape (cut to 1280 x 853), no text or lettering anywhere. Lindqvist: a Swedish naturalist in his fifties, lean,
grey side-whiskers, round spectacles, a long brown coat, a satchel of notebooks; the hired guns in plain buff and
yellow coats (not the Crown's purple: they are the Academy's men); the creatures REPTILIAN, olive-brown scales with
VENOM-GREEN frills and spines, never insect-like. Save each as `art/campaign/stills/a05_0N.png` and cut it to 1280 x
853 into `campaign/stills/a05_0N.jpg` (nothing else changes).

- a05_01 THE CAMP. "Oil painting, 18th-century history painting style. Night on the edge of a misty mountain plateau in
  the Amazon: an expedition's camp of white canvas tents round a fire; three ox carts, each carrying an empty cage of
  iron bars; a lean grey-whiskered naturalist in spectacles and a long brown coat studies a notebook by a lantern, hired
  musketeers in buff and yellow coats sit by the fire. Cold blue moonlight, warm firelight, mist drifting. 3:2
  landscape, no text." (References: campaign/stills/b01_08.jpg (Lindqvist, old, before the King), campaign/stills/p01_05.jpg (the style).)
- a05_02 THE TAKING. "Oil painting, 18th-century history painting style. Night among tall ferns on a mountain top: men in
  buff coats throw a rope net over a young reptilian creature asleep in the ferns, lean and two-legged, olive-brown
  scales and a venom-green frill; a grey-whiskered naturalist in spectacles holds up a lantern and watches, rapt; behind
  them, far off in the mist, a hollow where huge shapes sleep. Hushed, tense. 3:2 landscape, no text." (References:
  art/redraws/raptor_walk_se_chatgpt.png, campaign/stills/b01_08.jpg, campaign/stills/p01_05.jpg.)
- a05_03 THE TRAIL. "Oil painting, 18th-century history painting style. Dawn on a narrow trail through dense tropical
  forest: a file of ox carts with iron cages, young reptilian creatures inside them; musketeers in buff coats walk beside
  them, muskets ready; in the shadows between the trees, yellow eyes and the green frills of hunting reptiles. Grey-gold
  light through mist. 3:2 landscape, no text." (References: art/redraws/raptor_walk_se_chatgpt.png, campaign/stills/p01_05.jpg.)
- a05_04 THE LANDING. "Oil painting, 18th-century history painting style. Afternoon at a sand quay on a wide jungle
  river: dugout canoes drawn up, river men loading an iron cage with a reptile inside into the largest; a river trader
  in a straw hat directs them; beside the canoes two heavy wooden crates, a cogwheel stamped on their boards; a
  grey-whiskered naturalist in a long coat looks at the crates. Warm humid light. 3:2 landscape, no text." (References:
  campaign/stills/b01_07.jpg (the canoes, Benedito), campaign/stills/p01_05.jpg.)
- a05_05 THE SIRE. "Oil painting, 18th-century history painting style. Dusk at the edge of the jungle by a river: a
  colossal tyrannosaur-like reptile with green-tipped spines bursts out of the trees toward the last ox cart with its
  cage, its jaws open; musketeers in buff coats fire in a ragged line, smoke everywhere; a young creature in the cage
  screams back at it. Red sky, flying leaves. 3:2 landscape, no text." (References: art/redraws/tyrannosaur_concept_chatgpt.png,
  campaign/stills/p01_05.jpg.)

## The voice lines (for the owner's Chatterbox recordings)

Recorded lines go in `campaign/voice/a05/<line id>.ogg` (or .wav / .mp3); the game plays them when present. The King's
in the King's voice (tools/voice_clone, refs king_ref.wav). LINDQVIST (old: in 2795), PIETER and BENEDITO as designed
for b01 (still to design; Lindqvist's older here); "The Mountain" (the narrator) can stay text. No creature speaks. The
roster ladder's NEW cards are the game's own voice (not recorded).

| file (campaign/voice/a05/) | voice | when | line |
| --- | --- | --- | --- |
| k_open1.ogg | The King | opening (expedition) | The doctor came before me in chains, an old man. He asked to tell it himself. |
| k_open2.ogg | The King | opening (expedition) | I let him. He tells it as his finest hour. I will say where it was not. |
| l_open1.ogg | Dr. Lindqvist | opening (expedition) | Majesty. Two years after the station burned, the Academy gave me money again. |
| l_open_saved.ogg | Dr. Lindqvist | opening (expedition) | The eggs I carried out of the fire had hatched. I needed a father for them. |
| l_open_burned.ogg | Dr. Lindqvist | opening (expedition) | I had nothing left but my notes. I needed eggs, and young ones. |
| l_open2.ogg | Dr. Lindqvist | opening (expedition) | In the dry season we went up the mountain, with guns, porters and carts. |
| k_open_c.ogg | The King | opening (creatures) | No creature told me this. But the nest was theirs, and the young were theirs. |
| k_open_c2.ogg | The King | opening (creatures) | That dry season men came with cages while the nest slept. |
| l_1.ogg | Dr. Lindqvist | intro | Quietly. The young sleep apart from the nest, in the ferns. |
| l_2.ogg | Dr. Lindqvist | intro | Stand by each one a moment and net it. The carts will come for them. |
| tip_1.ogg | Dr. Lindqvist | intro | The eggs lie at the swamp's edge in the hollow. I will fetch those myself. |
| l_sire.ogg | Dr. Lindqvist | intro_sire | And the young Sire in the middle. A father for my line. |
| l_fresh.ogg | Dr. Lindqvist | intro_fresh | Two young and a clutch of eggs. Enough to begin again. |
| l_short.ogg | Dr. Lindqvist | way_short | We have the mapmaker's road. The carts go straight down the commission's path. |
| l_long.ogg | Dr. Lindqvist | way_long | No map. Benedito remembers an old way down on the west side. A long road through the forest. |
| p_book.ogg | Pieter | pieter_book | I have the specimen book, Doctor. I will count every cage. |
| l_pieter.ogg | Dr. Lindqvist | pieter_lost | I keep the book myself now. Pieter used to. |
| l_taken.ogg | Dr. Lindqvist | taken_eggs | So many young. The pack carried my clutch up here after all. |
| tip_porters.ogg | Dr. Lindqvist | porter_tip | The porters can mend a cart. Keep them close to the cages. |
| l_net_w.ogg | Dr. Lindqvist | net_w | The net is on it. Bring the cart. |
| l_net_m.ogg | Dr. Lindqvist | net_m | Gently. He weighs more than three men already. The cart! |
| l_net_e.ogg | Dr. Lindqvist | net_e | Mind its mouth, it spits even asleep. The cart. |
| l_caged.ogg | Dr. Lindqvist | load_w | Caged. |
| p_count.ogg | Pieter | pieter_count | One in the book. |
| l_eggs.ogg | Dr. Lindqvist | eggs_taken | The eggs. Warm. I carry them myself. |
| l_all.ogg | Dr. Lindqvist | caged_all | All of them. Now down, before the sun. |
| l_woke.ogg | Dr. Lindqvist | woke_early | They are awake! The carts, now! Down the mountain! |
| l_empty.ogg | Dr. Lindqvist | empty | Nothing. We go down with empty cages. |
| l_trail.ogg | Dr. Lindqvist | trail_lines | The carts are rolling. Keep the guns round them. |
| tip_trail.ogg | Dr. Lindqvist | trail_lines | The carts carry our powder too. A man who has fired his shots refills beside one. |
| l_raid1.ogg | Dr. Lindqvist | raid1 | In the trees! They want the cages! |
| l_grown.ogg | Dr. Lindqvist | raid2 | Those are not hatchlings. Last year's young, grown. Look at them. |
| l_freed.ogg | Dr. Lindqvist | first_freed | A cage is broken! It is loose! |
| l_lost.ogg | Dr. Lindqvist | all_lost | Every cage broken. Two years for nothing. |
| b_1.ogg | Benedito | landing_lines | Here, Doctor! The canoes are ready. Load the cages. |
| l_crates.ogg | Dr. Lindqvist | landing_lines | Whose crates are those on the quay? |
| b_crates.ogg | Benedito | landing_lines | From Lisbon, for the mines in the south. Heavy. A gear stamped on the wood. |
| b_room_few.ogg | Benedito | room_line | Few paddlers came from Nazaré, Doctor. Two cages, no more. |
| b_room_many.ogg | Benedito | room_line_many | All of Nazaré came to paddle. There is room for every cage. |
| n_roar.ogg | The Mountain | sire_line | Up the river bank something roared, and the forest went quiet. |
| l_sire_comes.ogg | Dr. Lindqvist | sire_line | The Sire. He has come for the last cart. Hold him off! |
| b_load.ogg | Benedito | loaded_line | One aboard! Bring the next! |
| b_full.ogg | Benedito | full | No more room, Doctor! The canoes are full! |
| b_push.ogg | Benedito | the_end | Push off! Paddle! |
| l_end.ogg | Dr. Lindqvist | the_end | We went down the river with the cages rattling. |
| b_gone.ogg | Benedito | canoes_gone | The canoes are going, Doctor! We cannot wait! |
| l_hurt.ogg | Dr. Lindqvist | hurt_l | I am hurt. Keep them off me! |
| l_end_all.ogg | Dr. Lindqvist | ending (expedition) | Every cage came down to the river. The finest expedition of my life. |
| l_end_some.ogg | Dr. Lindqvist | ending (expedition) | Not every cage came down, but enough. |
| l_end_few.ogg | Dr. Lindqvist | ending (expedition) | Only a few cages came down. It was enough for me. |
| l_end_saved.ogg | Dr. Lindqvist | ending (expedition) | The young Sire was for the eggs I saved. In a year I had a breeding stock. |
| l_end_burned.ogg | Dr. Lindqvist | ending (expedition) | The eggs I took that night were my new beginning. |
| l_end_eggs.ogg | Dr. Lindqvist | ending (expedition) | I carried the eggs down myself, all the way to the river. |
| l_end_pieter.ogg | Dr. Lindqvist | ending (expedition) | Pieter wrote every cage in the book. |
| k_end1.ogg | The King | ending (expedition) | His finest hour, he calls it. He took a mother's young in the night. |
| k_end2.ogg | The King | ending (expedition) | And the crates on that quay went south to the mines. Nobody opened them. |
| k_end_c1.ogg | The King | ending (creatures) | That is not how it went. The carts came down to the river. |
| k_end_c2.ogg | The King | ending (creatures) | But it could have gone that way. Then the doctor would have come home with empty cages. |

## What is placeholder

- Every line, every objective's words, the briefings and the debriefs.
- The stills (simple drawings). Lindqvist is a Musketeer stand-in (b01's role), the porters and Benedito Labourers, the
  cage cart a Powder Wagon with bars drawn round its creature in code (docs/art_style_inconsistency.md), the young Sire
  a Tyrant Sire at 0.55.
- The voice folder a05 is empty (silent).

## Claude's choices for the owner

1. NETTING IS A STAY: any of the expedition's men 4 s by a sleeping young one nets it; then its own cart comes (the
   convoy is scripted, so the player never drives a cart); one cart for each bed.
2. THE YOUNG SLEEP APART and are spared while asleep, so the men never shoot them and netting never wakes the nest; the
   nest wakes only for men near its hunters (6 tiles) or a hunter hurt.
3. THE EGGS ARE OPTIONAL and Lindqvist's own: 8 s at the egg bed, then he carries them, slow and unarmed, to the end
   (b01's crate). The plan's "take eggs" with a cost.
4. THE CARTS ARE A SCRIPTED CONVOY on the expedition's side (YELLOW), on a ROUTE at an ox's pace; the player escorts;
   the porters MEND them (the mission lets workers repair an ally's machines). Empty carts stay on the mountain.
5. THE CARTS CARRY THE POWDER: a cage cart is a Powder Wagon (120 shots), so the escort refills beside a cart; it never
   blows up.
6. THE RAIDS: every 1:15 from 0:35 while the carts are on the road, from clearings along the way, growing (Raptors, then
   the grown ones: the ladder's B3 shown from the other side). They go for the carts first.
7. A FREED CREATURE turns on the men who caged it (20 tiles) in the expedition's game; in the creatures' it is the
   player's again.
8. THE CANOES' ROOM is the plan's paddlers: 2 / 3 / 4 cages by b01's `saved`; a cart that finds no room stays on the
   quay (Benedito: "No more room").
9. THE SIRE comes 20 s into Part 3, from the forest to the east of the quay, for the last cart (then for the men).
10. THE FLAG `cages` is a SHARE of the cages that set off (under half few, half or more some, all), so it holds with two
    or three carts; a run with no cage down is a loss (every cage broken), not "few".
11. THE CREATURES WIN by half the cages freed (the plan) or Lindqvist killed; a Tyrant Sire of their own is denied (he
    comes in Part 3), as in a03.
12. THE EXPEDITION MAY BUILD NOTHING: 150 gold for the porters' mending, every building denied in its roster (it is not
    bound to a ladder: the Naturalist's ladder is the creatures').
13. THE MAP DRAWN gives two more guns (the plan's "more of it") as well as the short way.
14. MODES: solo (either side) and versus (the friend is the creatures). No co-op (one small party).
15. CAMPAIGN DIFFICULTY: EASY / HARD scale the raids and the nest (0.75 / 1.2) for the expedition's player, the
    expedition's guns and porters for the creatures', and the dawn and the canoes' countdowns (x1.25 / x0.9).
16. ONE CRATE HINT: the two Lisbon crates on the quay are props with a ping and Benedito's line; the King's last line
    says they went south unopened.

## Tests run

TESTS_RUN

## The roster ladder

The creatures are bound to B3 (GROW = `stage2`, MATURE = `tyrant_challenger` / `venom_challenger`; the story's deny of
the Tyrant Sire on top); the NEW cards are said to the side `creatures` 8 s in (pt / es in roster_ladder.py and this
mission's texts). The expedition is not bound (no production).
