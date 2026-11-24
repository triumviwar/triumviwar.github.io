# The roster ladder: what each campaign mission gives the player (job roster-ladder, 0.38.57)

The owner's decision (2026-11-18 07:26-07:27, "Ye"): as in StarCraft's campaign (the Marine, then the Marauder, then
the Medic), EACH CAMPAIGN MISSION BRINGS NEW PIECES, so nobody meets every tool at once; the pace need not be one a
mission ("give one, give two, give two again, give one"). The TUTORIAL teaches the controls; the CAMPAIGN teaches what
each piece is FOR.

The framing agreed with Claude:

- THREE LADDERS, one per faction line: the Crown line teaches the Crown, the Clockmaker line the Clockwork, the
  Naturalist line the Brood. Each stands alone: the lines can be played in any order (docs/campaign_act1_plan.md), so
  a ladder never counts on another line's lessons.
- ONE OR TWO NEW THINGS A MISSION (a unit, a building, a research, an ability; pairs where they belong together:
  Musketeer and Field Cannon, Winder and Clock Soldier, Tyrant Sire and Raptors).
- EACH MISSION SHOWS OFF WHAT IT JUST GAVE: the new piece is the answer to that mission's fight.
- ACT 1 covers each faction's CORE; ACTS 2-3 the rest (the other Sires, the Brass Serpent, the balloon, the band...).
- THE OTHER SIDE IS NOT BOUND: the opposing, scripted, versus and allied-of-another-faction sides get what the story
  needs (the Machine in c01 / a02, the rival pack in b01, the Free Assembly, the Franconian army...).

## How it works in the game

- A bound team has `"roster": {"allow": [...], "new": [...], "deny": [...]}` (docs/campaign_engine.md "Added by the
  roster ladder"). Everything of its faction NOT on `allow` is "Not in this mission." wherever the player meets it:
  the build menu (Game.requirement_text), a building's train buttons (Game.can_train), research (Game.research_problem,
  the Brood's BroodResearch.problem), a grub's BUILD (BroodRoot.morph_problem), the Mother's eggs
  (BroodNew.lay_problem), MATURE (BroodMature.problem: the mature form is its own piece) and her GROW
  (BroodNew.grow_problem: her stages are the pieces `stage2`, `stage3`). `deny` is the STORY's own refusal on top
  (a03: no Tyrant Sire, he is away); the `unlock` / `deny` actions still change it mid-mission (a02's Light Works
  after the stop-work; its Heavy Works and Pendulum for `gate` pattern).
- What the mission HANDS the player (heroes, given units, a building already standing) is not limited: the ladder is
  about what can be made more of. Ruggieri's guns in p01 are given and fight; more Field Cannons wait for a Foundry
  (C3). A story may also give a TASTE of a later piece (c01's Netter and its Pendulum showpiece): given, not makeable.
- THE NEW CARD: a few seconds in, the dialogue box says a line from the speaker NEW per new piece ("NEW: THE
  MUSKETEER. ..."), `to` the ladder side only (a versus friend or a solo player on the other side never sees it).
  pt NOVO, es NUEVO; Brood words: clutch = Ninhada (pt) / Nidada (es). ALL TEXT PLACEHOLDER.
- The data lives in ONE place, tools/campaign/roster_ladder.py: the kits, the steps, the bound teams, the cards. The
  mission generators call `roster_ladder.apply(M, "<id>")`; p01_leaf's JSON is patched by
  `python3 tools/campaign/roster_ladder.py p01_leaf` (its generator, make_m1_mission.py, is older than the JSON: the
  eco-revert job edited the JSON by hand; the generator also applies the ladder now, but running it would undo that
  job's map changes). `--table` prints the CHECKED TABLE below.
- tools/test_roster_ladder.gd reads the CHECKED TABLE from this doc and checks every built mission against it (data and
  live: the refusals and the cards).

## The kits (what every mission of a line starts from)

The economy a faction cannot play without; the first mission of the line teaches it alongside its two pieces.

| line | kit |
| --- | --- |
| the Crown | Town Hall, Labourer, Farm, Cottage, Palisade, Gate, Barracks, Powder Mill |
| the Clockwork | Clocktower (and its Winders: the K1 piece), Cog Press, Mainspring, Regulator, Light Works |
| the Brood | Brood Mother, Grub, Rootmaw, Mound Turtle |

## The Crown line (Tomasz's and Fairleigh's: p01 -> a01 -> a06 -> a07)

| step | mission | new | why it fits the story and the fight | where it shows off |
| --- | --- | --- | --- | --- |
| C1 | p01_leaf, The Leaf and the Fire (Virginia 2767) | MUSKETEER (trained) + FIELD CANNON (Ruggieri's two guns, given: CANISTER) | a plantation held at night by lines of muskets and two guns; the Crown's whole doctrine in one night | Part 1: the line holds the barns; Part 3: canister into the charge at the fort's gate |
| C2 | a01_presses, The Printing Houses (Lyon 2768) | HORSE BREEDER + HORSEMAN (the horse, the Officer and the Messenger come with them) | the plan's garrison already has "4 Horsemen, the only cavalry in a city: fast messengers between quarters"; a fog hunt of RUNNERS wants speed, not lines | Part 1: ride the runners down before they reach the squares (the CITY'S TEMPER) |
| C3 | a06_barricades, The Barricades of Paris (1769) | FOUNDRY + MORTAR (your own Field Cannons now) | the army's base outside the walls has a Foundry; barricades are a gunner's work: "take them with lines and guns, not by walking in" | Part 1: the Mortar lobs over the three barricades; cannon canister down the streets behind |
| C4 | a07_council, The Council of Rome (1770) | CHURCH + MISSIONARY | Rome, the Church's city; Tomasz leads the people to the basilica; the night of fire leaves many fallen | Part 3: hold the bridges till dawn with Missionaries raising the fallen behind the line |
| C5 | d01_minas, The Gold of Vila Rica (Minas Gerais 2772) | ARMOURY + MATCHLOCK + SOCKET BAYONET (the Armoury stands; the research and the REFIT are the lesson) | the garrison of a hill town: a fight on stairs, close, where reload and the bayonet decide it | Part 2: the bayonet on the square's stairs on the night of the signal |
| C6 | Act 2, slot 2 | DRAGOON + CAVALRY CHARGE | mounted infantry and the charge for a war of distances (Brazil, the crossing) | raids and the charge into light Brood creatures |
| C7 | d09_crossroads | ARMOUR (Guardsmen, Cuirassiers) + POWDER WAGON | a long campaign away from the halls: armour and powder that travels | a march without a base (the wagon refills the line) |
| C8 | d10_jungle (the column) | OBSERVATION BALLOON | seeing over the forest / the Clockwork's walls | spot for the guns at long range |
| C9 | Act 2, slot 5 | PREPARED CHARGES + GUNNER'S QUADRANT | the guns' science, against the machines' plates | a siege of a Clockwork works |
| C10 | Act 3, slot 1 | THE DRUMMER | the army marching to the global war | a long march against the clock |
| C11 | Act 3, slot 2 | FIFER + PIPER (a full BAND) | the band complete for the great battles | a band's solo at the decisive moment |
| C12 | Act 3, slot 3 | FLINTLOCK, CAPLOCK, SHOT POUCH (the Mounted Missionary with them) | the last of the Crown: everything | the finale: the whole roster |

## The Clockmaker line (Hollweg's: c01 -> a02 -> a04; Rome's automata are scripted / versus)

| step | mission | new | why it fits the story and the fight | where it shows off |
| --- | --- | --- | --- | --- |
| K1 | c01_thirteenth, The Thirteenth Hour (Nuremberg 2767) | WINDER + CLOCK SOLDIER | Hollweg's guild: hands that wind and soldiers that are wound; the Netter (Part 2) and the Pendulum showpiece (`bells` rung) are GIVEN as a taste, not makeable | Part 1: six Clock Soldiers to the wagons; Part 3: Winders keeping the line wound while the townsfolk get out |
| K2 | a02_furth, The Fürth Line (1768) | SPRINGER + NETTER (their Escapement with them) | the plan's guild is "Winders, Clock Soldiers, Netters, Springers"; holding an earthwork line wants the net (hold them at the wire) and the leap (onto the guns behind a sortie) | Part 2: the three sorties at the earthworks; Part 3: leap onto the Rednitz mill's seed |
| K3 | a04_visit, Father Ferrer's Visit (1769) | HEAVY WORKS + PENDULUM | Fürth grown into a small town of gears; the riot of meshed automata needs a giant that sweeps a crowd (a02 gives them early with `gate` pattern: Hollweg's pride) | Part 3: stop the converted automata before they reach the meadow |
| K4 | d02_exodus (built) | RATCHET TURRET + SHIELD WALL | the guild's rearguard at the last bridge before the Main's barges (d02) (the turret only as a reactive answer: the owner's rule, static defence is not a build) | the commissary's riders and muskets at the bridge |
| K5 | d04_concordia (Act 2) | CLOCK AVIARY + SWIFT | the machines take to the air | scouting a jungle the Brood owns |
| K6 | d07_spring (Act 2) | TICKING OWL (the morph) + HIGH LEAP | Swifts grown into owls; Springers that leap farther | the owls break the turned works; the Springers leap the mine hill's cliff to the great spring |
| K7 | Act 2, slot 4 | SPRING BALLISTA + LONG CHAIN | the guild's siege engines | a siege of a Crown fort or a Brood nest |
| K8 | Act 3, slot 1 | GREAT WINDER | the war's wrecks swept and mended | a long battle won by mending |
| K9 | Act 3, slot 2 | BRASS SERPENT (and its gears) | the Machine's masterpiece in the guild's hands | the finale |

## The Naturalist line (Lindqvist's and Valadares': b01 -> a03 -> a05; Rome's creatures are scripted / versus)

| step | mission | new | why it fits the story and the fight | where it shows off |
| --- | --- | --- | --- | --- |
| B1 | b01_specimen, Specimen One (Rio Negro 2767) | TYRANT SIRE (given; another if he falls) + RAPTORS | the Sire's pack is the story: he roots by the Old Mother, fathers her Raptors, roars at the forest's edge | the teaching strip: ROOT, LAY AND HATCH, the ROAR, the yard's guns, the gate of Linnea's pen |
| B2 | a03_plateau, The Lost Plateau (1767), THE NEST (the solo side pick and versus) | VENOM SIRE + SPITTERS | the nest's own creatures: the plan gives it "Raptors, a Spitter or two"; the Tyrant Sire is AWAY (the story's deny: he comes home in Part 3) | Part 3: acid from behind the Raptors at a party of Musketeers on the cliff path |
| B3 | a05_specimens, The Specimens (1769), THE CREATURES (solo pick and versus) | GROW to stage 2 + MATURE (Tyrant and Venom Challengers) | two years on, the nest's young are grown: the creatures that come for the cages are the matured ones | Part 2: Challengers break the cages on the trail |
| B4 | Act 2, slot 1 | STORM SIRE + HATCHLINGS | the flyers of the Brood; the swarm on Brazil's border | over the river the Clockwork can't cross |
| B5 | d06_queen, The Queen (the island, 2775) (was B6: Act 2's plan swapped B5 and B6, Claude's choice 13 there) | GROW to stage 3 + BRUTE | the Mother full grown: the Queen IS stage 3; the fazenda's palisade needs a battering beast | Part 3: GROW in the big pen, then Brutes through the palisade |
| B6 | d08_rivers, Down the Rivers (the Rio Negro, 2778) (was B5: Act 2's plan swapped B5 and B6) | BIGGER CLUTCH (Raptors), PACK HUNT, QUICK ROOTS | the swarm grows faster: research at the Sire and the Mother; bound to the swarm (the solo pick and versus: the Naturalist's mirrors are bound) | catching Nazaré's people before the canoes; a forward Mother rooted again before the guns find her |
| B7 | d10_jungle (the swarm: mirror and versus) | MIST TOAD + FOG BANK + MIASMA | the jungle's fog as a weapon | hiding the swarm from the guns |
| B8 | Act 3, slot 1 | STORM CHALLENGER + UPDRAFT + BIGGER CLUTCH (Hatchlings) | the sky in the global war | an air battle with the Clockwork's owls |
| B9 | Act 3, slot 2 | the rest: BIGGER CLUTCH (Spitters), SLITHER, LONG SPIT, BATTERING HORNS, SWAMP MENDING | everything | the finale |

## Act 1's three missions still to build (for Claude to apply at their merge)

- a01_presses: APPLIED at the merge (0.38.58): a standing Horse Breeder in the garrison's yard at [108, 47], the
  garrison's story deny kept on top, C2's cards in pt/es, the row in test_roster_ladder.gd. (Was: at its merge, call
  `roster_ladder.apply(M, "a01_presses")` in its generator before the JSON is written. Check the team ids in
  `BOUND["a01_presses"]` (written as the plan's "garrison" and "watch": the CITY WATCH is co-op p2 and the same side's
  Crown: bound too). The plan's garrison has a Barracks and a Powder Mill and no Horse Breeder: give it one standing
  (or a site) so the C2 pieces can be MADE, or the step teaches only the given Horsemen. Add C2's cards (CARDS has
  them; pt/es to write: CARDS_PT / CARDS_ES) and its row in test_roster_ladder.gd's "built" list.
- a04_visit: APPLIED (job a04-visit, 0.38.63): Ferrer's party (Crown, PURPLE) is the solo default and has no
  production: not bound. THE GUILD (co-op p2) is bound to K3: Heavy Works + Pendulum (a Heavy Works stands among the six
  workshops, a Pendulum is given and holds the yard's gate in the riot); the cards go to the side `visit` 8 s in, in pt
  / es. A solo player meets K3's pieces only if the guild is played (or through a02's `gate` pattern): Claude's choice 2.
- a05_specimens: APPLIED (job a05-specimens, 0.38.64): THE CREATURES (the solo pick and versus) are bound to B3: GROW
  (stage 2) and MATURE (Tyrant and Venom Challengers), the story's deny of the Tyrant Sire on top (he is away and comes
  for the last cart, as a03's); B3's cards to the side `creatures` 8 s in, in pt / es. The expedition (Crown stand-in,
  the default) has no production (its own roster denies every building) and is not bound. The scripted raids show the
  grown ones (Challengers) from the expedition's side (docs/campaign_a05_build.md).
- a06_barricades: APPLIED (job a06-barricades, 0.38.59): the army ("army") and Ruggieri's "guns" (co-op p2) bound to
  C3, the story's deny (no Town Hall or Farm in a siege camp) on top; the camp has a Foundry and a Horse Breeder
  standing; the Mortar is given (one) and can be made; C3's cards in pt/es; the row in test_roster_ladder.gd. The
  mission shows the Mortar on the barricades' men and canister on the rushes (docs/campaign_a06_build.md).
- a07_council: BUILT (a07-council, 0.38.68): the King's guard and the garrison bound to C4, the story's deny (no Town
  Hall or Farm: the King's treasury pays) on top; SANTO SPIRITO (a Church) stands by the piazza; Missionaries trained
  there LEAD THE PEOPLE as Father Tomasz does (auto_tags); C4's cards in pt/es, said at 0:08. The creatures and the
  automata (scripted / versus, the friend's pick) and the Assembly's cell are not bound (docs/campaign_a07_build.md).

## The rule for the other side

The ladder binds only the teams of the LINE'S OWN FACTION on the side its player leads (BOUND in roster_ladder.py),
in every mode (solo, co-op, versus: the binding is the team's, whoever moves it). It never binds:

- the enemy of that side (the Machine in c01 and a02 keeps its own story deny; the rival pack in b01; the Free
  Assembly; the expedition and the party in a03 / a05);
- an ally of ANOTHER faction on the same side (the Franconian army in a02, the city watch in c01): they get what the
  story needs;
- a scripted team of the same faction that no person plays (b01's kin, a03's patrol and kin).

The one exception is the Naturalist line's solo mirrors (a03's nest, a05's creatures), bound although they are the
mirror side: Claude's choice 1.

## THE CHECKED TABLE

Read by tools/test_roster_ladder.gd (columns: step, mission, the bound teams, the NEW pieces, what comes with them, the
allow-list = the kit + every step so far). Printed by `python3 tools/campaign/roster_ladder.py --table`; change the
ladder there, never here by hand.

| step | mission | teams | new | comes with | allow-list (code ids) |
| --- | --- | --- | --- | --- | --- |
| C1 | p01_leaf | governor guns | musketeer cannon | - | town_hall labourer farm cottage wall gate barracks powder_mill musketeer cannon |
| C2 | a01_presses | garrison watch | horse_breeder cuirassier | horse dismounted messenger | town_hall labourer farm cottage wall gate barracks powder_mill musketeer cannon horse_breeder cuirassier horse dismounted messenger |
| C3 | a06_barricades | army guns | foundry mortar | - | town_hall labourer farm cottage wall gate barracks powder_mill musketeer cannon horse_breeder cuirassier horse dismounted messenger foundry mortar |
| C4 | a07_council | guard garrison | church missionary | - | town_hall labourer farm cottage wall gate barracks powder_mill musketeer cannon horse_breeder cuirassier horse dismounted messenger foundry mortar church missionary |
| C5 | d01_minas | garrison | armoury matchlock bayonet | - | town_hall labourer farm cottage wall gate barracks powder_mill musketeer cannon horse_breeder cuirassier horse dismounted messenger foundry mortar church missionary armoury matchlock bayonet |
| C6 | d05_aldeia | mission | dragoon charge | - | town_hall labourer farm cottage wall gate barracks powder_mill musketeer cannon horse_breeder cuirassier horse dismounted messenger foundry mortar church missionary armoury matchlock bayonet dragoon charge |
| C7 | d09_crossroads | army | armour powder_wagon | - | town_hall labourer farm cottage wall gate barracks powder_mill musketeer cannon horse_breeder cuirassier horse dismounted messenger foundry mortar church missionary armoury matchlock bayonet dragoon charge armour powder_wagon |
| C8 | d10_jungle | column | balloon | - | town_hall labourer farm cottage wall gate barracks powder_mill musketeer cannon horse_breeder cuirassier horse dismounted messenger foundry mortar church missionary armoury matchlock bayonet dragoon charge armour powder_wagon balloon |
| C9 | (slot) | - | charges quadrant | - | town_hall labourer farm cottage wall gate barracks powder_mill musketeer cannon horse_breeder cuirassier horse dismounted messenger foundry mortar church missionary armoury matchlock bayonet dragoon charge armour powder_wagon balloon charges quadrant |
| C10 | (slot) | - | band | - | town_hall labourer farm cottage wall gate barracks powder_mill musketeer cannon horse_breeder cuirassier horse dismounted messenger foundry mortar church missionary armoury matchlock bayonet dragoon charge armour powder_wagon balloon charges quadrant band |
| C11 | (slot) | - | band_fifer band_piper | - | town_hall labourer farm cottage wall gate barracks powder_mill musketeer cannon horse_breeder cuirassier horse dismounted messenger foundry mortar church missionary armoury matchlock bayonet dragoon charge armour powder_wagon balloon charges quadrant band band_fifer band_piper |
| C12 | (slot) | - | flintlock caplock pouch | mounted_missionary | town_hall labourer farm cottage wall gate barracks powder_mill musketeer cannon horse_breeder cuirassier horse dismounted messenger foundry mortar church missionary armoury matchlock bayonet dragoon charge armour powder_wagon balloon charges quadrant band band_fifer band_piper flintlock caplock pouch mounted_missionary |
| K1 | c01_thirteenth | guild | winder clock_soldier | - | clocktower cog_press mainspring regulator movement_works winder clock_soldier |
| K2 | a02_furth | guild | springer netter | escapement | clocktower cog_press mainspring regulator movement_works winder clock_soldier springer netter escapement |
| K3 | a04_visit | guild | heavy_works pendulum | - | clocktower cog_press mainspring regulator movement_works winder clock_soldier springer netter escapement heavy_works pendulum |
| K4 | d02_exodus | guild | ratchet_turret shield_wall | - | clocktower cog_press mainspring regulator movement_works winder clock_soldier springer netter escapement heavy_works pendulum ratchet_turret shield_wall |
| K5 | d04_concordia | guild | cuckoo_house cuckoo | - | clocktower cog_press mainspring regulator movement_works winder clock_soldier springer netter escapement heavy_works pendulum ratchet_turret shield_wall cuckoo_house cuckoo |
| K6 | d07_spring | guild | owl_morph high_leap | ticking_owl | clocktower cog_press mainspring regulator movement_works winder clock_soldier springer netter escapement heavy_works pendulum ratchet_turret shield_wall cuckoo_house cuckoo owl_morph high_leap ticking_owl |
| K7 | (slot) | - | ballista long_chain | - | clocktower cog_press mainspring regulator movement_works winder clock_soldier springer netter escapement heavy_works pendulum ratchet_turret shield_wall cuckoo_house cuckoo owl_morph high_leap ticking_owl ballista long_chain |
| K8 | (slot) | - | great_winder | - | clocktower cog_press mainspring regulator movement_works winder clock_soldier springer netter escapement heavy_works pendulum ratchet_turret shield_wall cuckoo_house cuckoo owl_morph high_leap ticking_owl ballista long_chain great_winder |
| K9 | (slot) | - | brass_serpent | serpent_gear_s serpent_gear_b | clocktower cog_press mainspring regulator movement_works winder clock_soldier springer netter escapement heavy_works pendulum ratchet_turret shield_wall cuckoo_house cuckoo owl_morph high_leap ticking_owl ballista long_chain great_winder brass_serpent serpent_gear_s serpent_gear_b |
| B1 | b01_specimen | sire | tyrannosaur raptor | - | brood_mother grub rootmaw mound_turtle tyrannosaur raptor |
| B2 | a03_plateau | nest | dilophosaurus spitter | - | brood_mother grub rootmaw mound_turtle tyrannosaur raptor dilophosaurus spitter |
| B3 | a05_specimens | creatures | stage2 tyrant_challenger venom_challenger | - | brood_mother grub rootmaw mound_turtle tyrannosaur raptor dilophosaurus spitter stage2 tyrant_challenger venom_challenger |
| B4 | d03_fazenda | stock | pterodactyl hatchlings | - | brood_mother grub rootmaw mound_turtle tyrannosaur raptor dilophosaurus spitter stage2 tyrant_challenger venom_challenger pterodactyl hatchlings |
| B5 | d06_queen | stock | stage3 brute | - | brood_mother grub rootmaw mound_turtle tyrannosaur raptor dilophosaurus spitter stage2 tyrant_challenger venom_challenger pterodactyl hatchlings stage3 brute |
| B6 | d08_rivers | swarm | nb_clutch_raptor nb_pack_hunt nb_quick_roots | - | brood_mother grub rootmaw mound_turtle tyrannosaur raptor dilophosaurus spitter stage2 tyrant_challenger venom_challenger pterodactyl hatchlings stage3 brute nb_clutch_raptor nb_pack_hunt nb_quick_roots |
| B7 | d10_jungle | swarm | mist_toad nb_fog nb_miasma | - | brood_mother grub rootmaw mound_turtle tyrannosaur raptor dilophosaurus spitter stage2 tyrant_challenger venom_challenger pterodactyl hatchlings stage3 brute nb_clutch_raptor nb_pack_hunt nb_quick_roots mist_toad nb_fog nb_miasma |
| B8 | (slot) | - | storm_challenger nb_updraft nb_clutch_hatchlings | - | brood_mother grub rootmaw mound_turtle tyrannosaur raptor dilophosaurus spitter stage2 tyrant_challenger venom_challenger pterodactyl hatchlings stage3 brute nb_clutch_raptor nb_pack_hunt nb_quick_roots mist_toad nb_fog nb_miasma storm_challenger nb_updraft nb_clutch_hatchlings |
| B9 | (slot) | - | nb_clutch_spitter nb_slither nb_long_spit nb_battering_horns nb_swamp_mending | - | brood_mother grub rootmaw mound_turtle tyrannosaur raptor dilophosaurus spitter stage2 tyrant_challenger venom_challenger pterodactyl hatchlings stage3 brute nb_clutch_raptor nb_pack_hunt nb_quick_roots mist_toad nb_fog nb_miasma storm_challenger nb_updraft nb_clutch_hatchlings nb_clutch_spitter nb_slither nb_long_spit nb_battering_horns nb_swamp_mending |

## What changed in the built missions

- p01_leaf: the Governor (and Ruggieri's co-op team) may make only the kit and Musketeers; the Field Cannons are
  Ruggieri's (no Foundry); no Horse Breeder, Armoury, Church or Foundry to build (the manor's chapel stands: no
  Missionaries from it: Tomasz is the only one). Cards: the Musketeer, the Field Cannon.
- c01_thirteenth: the old story deny (Heavy Works, Aviary, the big machines) is now the ladder's K1: also no
  Escapement, Springers, Netters (given only), Ratchet Turret or research. Cards: the Winder, the Clock Soldier.
- b01_specimen: the Sire's pack: the kit, the Tyrant Sire, Raptors; no Venom or Storm Sire, no GROW, no MATURE, no
  research. Cards: the Tyrant Sire, the Raptors.
- a02_furth: the old guild deny is now K2 (Escapement, Springer, Netter added; still no Heavy Works / Pendulum but by
  the `gate` pattern unlock, no Aviary, turret, Serpent or research). Cards: the Springer, the Netter.
- a03_plateau: THE NEST: B2 (the Venom Sire and Spitters makeable) plus the story's deny of the Tyrant Sire. No
  GROW / MATURE / research. Cards (to the nest only): the Venom Sire, the Spitters.
- a04_visit (0.38.63): THE GUILD (the co-op friend): K3, the Heavy Works and the Pendulum makeable (a Heavy Works among
  the six workshops, a Pendulum given); no Aviary, turret, Serpent, Great Winder, Ballista or research. Cards (to the
  visit's side): the Heavy Works, the Pendulum.

## Engine (docs/campaign_engine.md "Added by the roster ladder")

- team `"roster": {"allow": [pieces], "new": [pieces], "deny": [pieces]}`: Campaign.roster_items(faction),
  roster_denied(m, team), roster_known(k); MissionRun reads roster_denied at the start.
- pieces now include researches and the Brood's stages (`stage2`, `stage3`); the refusal reaches research, grub morphs,
  the Mother's eggs, MATURE and GROW.
- Campaign.problems checks every roster name and every unlock / deny kind; `new` must be on `allow`.

## Tests and the balance sims (0.38.57, Godot 4.7 headless)

All on the branch (0 failures; real failures start "FAIL "): tools/test_roster_ladder.gd (185 checks), test_campaign.gd,
test_campaign_m1 / c01 / b01 / a02 / a03, test_war_map.gd, test_tutorial.gd; the boot (`--quit-after 300`) with no
SCRIPT ERROR. (Run the campaign tests ONE AT A TIME: they share user://campaign.json, and run side by side they fail
each other's flag checks.) Two tests changed: b01's "no creature speaks" and a03's "no line is said to the nest" let
the NEW speaker through (the game's own voice, not a creature).

The balance sims, NORMAL, the active bot (the bots never needed a piece the ladder took away: they build and train only
what their step allows):

| sim | result | time |
| --- | --- | --- |
| p01_leaf, active | the night held, dawn with 4 barns | 8:10 (the sim stops at dawn) |
| c01, active, quiet (four runs) | WON 3 (saved some: 51, 57; one run on main many: 61), LOST 1 (Hollweg killed by two Springers at the gate a minute before the stroke, as in the build's own table: variance, not the roster: the machine is not bound and the guild bot builds the same) | 15:51-16:01; the loss 12:11 |
| c01, active, rung | WON, saved many (130) | 15:41 |
| b01, active | WON twice, saved some (15) | 8:52, 10:52 |
| b01, active, BEFORE the bot fix (on main too) | LOST: the pack stood at the pen chasing the fort's garrison it can't reach, the den raid killed the Old Mother | 18:38 |
| a02, guild, active | WON, `furth` strong (13) | 8:44 |
| a02, machine, active | WON (the machine burnt the line) | 7:44 |
| a03, party, active | WON, `party` all (7) | 5:44 |
| a03, nest, active | WON (the party under half) | 4:44 |

THE b01 BOT FIX (tools/sim_campaign_b01.gd, the "nest" step): it counted every enemy within 420 px of the rooted Sire as
a threat, so the pack chased the fort's garrison holding behind its walls and never went for the gate (on main as well:
the last run before this job lost the same way). Now a threat is an enemy within 200 px or one going for the pack.

## Claude's choices, for the owner

1. THE NATURALIST'S MIRRORS ARE BOUND. The Naturalist line's default sides in a03 and a05 are humans (the party, the
   expedition) with no production, so a Brood ladder bound only to default sides would have ONE step in Act 1. The
   nest (a03) and the creatures (a05) are bound to B2 / B3, although the rule says a mirror side is free: the a03 plan
   already calls the nest a teaching strip. In versus they are bound too (the binding is the team's). Say if the mirrors
   should be free instead (then B2-B3 move to Act 2).
2. a04's solo player is Ferrer's Crown party, so the Clockmaker line's K3 (Heavy Works + Pendulum) is met in a04 only
   by the guild's co-op player (and early in a02 with `gate` pattern). Alternative: move K3 to a02 for everyone and
   leave a04 with nothing new; I kept the pace one-two-two.
3. THE KIT IS NOT DRIPPED. Each first mission gives the whole economy at once (Town Hall, Farms, Cottages, walls,
   Barracks, Powder Mill; the Clocktower's presses and Mainspring; the Mother's grubs, Rootmaws, turtles): the
   tutorial already teaches it, and the prologues' fights need it. Only the fighting pieces are laddered.
4. GIVEN IS NOT MADE. Heroes and story pieces (Ruggieri's guns, Tomasz, c01's Netter and Pendulum, a02's starting
   Springers and Netters when the guild is short) are handed over whatever the step; only making MORE is laddered.
   p01's chapel stands but trains no Missionary (C4 is Rome's).
5. PAIRS AND WHAT COMES WITH THEM: the Horseman brings the horse, the Officer (the same man on foot, the same price) and
   the Messenger (a Labourer mounted) in C2; the Springer and Netter bring their Escapement in K2; the Storm Sire's
   Hatchlings in B4; the Serpent's gears in K9. The Venom Challenger shares the Tyrant Challenger's card (one MATURE).
6. MOUNT IS NOT GATED. A Musketeer or Labourer mounting a horse (a Dragoon, a Messenger) is not a training, so the
   roster does not stop it; before C2 there are no horses to mount (the guns' horses are part of the guns).
7. Act 2-3's slots are ORDER, not missions: the acts are not planned yet. The order follows the story's direction
   (Brazil, the swarm, the machines in the air, the global war) and keeps the pace at one to three pieces.
8. The NEW card is a line in the dialogue box (the speaker NEW), not an objective: an objective line would sit in the
   panel all mission and would read as a task. The tutorial's pointer (`point`) is not used: the pieces are on cards
   the player already knows from the tutorial.
9. The ladder binds the same teams in every mode. In versus a friend on the line's side plays with the same pieces as
   a solo player (the mission was tuned for them).
