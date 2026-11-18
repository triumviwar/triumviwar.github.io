# Notes for Claude

- **Version:** every pushed change advances the game version. Run `tools/bump_version.sh`
  (patch number, e.g. 0.7.3 -> 0.7.4) before committing; bigger features may bump the minor
  number by hand. Also add an entry for the new version to `scripts/patch_notes.gd` (the PATCH NOTES page in Settings); the script updates the version in README.md itself. The version shows in the main menu and on the first line of every match log.
- **Art:** legs and tools drawn in code are tracked in `docs/art_style_inconsistency.md` (the owner wants them redrawn by ChatGPT later for one uniform style); add every new code-drawn edit there.
- **Web build:** `tools/web/build_web.sh` (CI uses it): a code pack, an art pack (`assets/`, cached by the browser across updates) and the music downloaded on demand; see `docs/web_load.md`. Keep runtime files out of `docs/` and `art/`.
- THE NAME (owner, 2026-11-13): **Triumviwar** (config/name "Triumviwar"; the subtitle "Is All Lost?" was DROPPED by the owner at 20:32, "a bit too much"). ADDRESS (owner, 2026-11-13): organization triumviwar, repository triumviwar.github.io, site https://triumviwar.github.io/ (was holdfastrts/Holdfast); downloads Triumviwar.apk / Triumviwar_windows.zip; UpdateCheck tries the new site, then the old one. Match logs (playtest reports pasted by the user) start with `Triumviwar vX.Y.Z match log` (older ones: `Working Title for RTS v...`, `Holdfast v...`; GameName.is_log_header accepts all). Holdfast is taken by another game: never use it as the name. The shown name comes from project.godot `application/config/name` (scripts/game_name.gd); the user folder stays `Pocket RTS`.
- **Design:** read `docs/design_principles.md` (fairness, anti-snowball, meaningful base building)
  before balance, economy, AI or building changes; the owner wants these followed.

## Backlog (owner's list, easiest first; jobs marked "branch" were stopped half done: the work is kept on their branch (worktree-agent-*; uncommitted parts were saved as a "WIP snapshot" commit and the worktrees removed to free disk): recreate a worktree from the branch to resume, or merge it)

- Crown research: the owner is thinking about spreading the Armoury's 9 researches over other buildings (e.g. Cavalry Charge at the Horse Breeder, Prepared Charges at the Powder Mill); undecided, pros and cons discussed 2026-10-27.
- BROOD REDESIGN, DECIDED in principle (owner, 2026-10-28): the Brood has NO buildings, only units; some units ROOT (armour and defensive buffs while rooted; uprooted they move as units); the QUEEN roots too, hoards the resources, and is the losing condition (kill her and you win). Details: docs/idea_brood_mobile_buildings.md. NOW THE ONLY BROOD (0.18.0, branch brood-replace, docs/brood_replace.md): the old Brood (its buildings, swamp, Spore Mother, Bloater, old AI) is removed; faction "brood" is the Brood of creatures (BroodNew.on(g,t) = factions[t] == "brood"; Game.nb_teams is gone; the old slot id "brood_new" still loads as "brood"); saves and replays with the old Brood are refused with a note (Defs.old_brood, BROOD_FORMAT 2, replay FORMAT 2). First built as an experiment (branch brood-redesign, merged 0.15.9). scripts/brood_new.gd, scripts/ai_brood_new.gd, tools/import_brood_new.py, tools/test_brood_new.gd; docs/brood_new.md has the numbers, Claude's choices for the owner to confirm (supply, swamp, spoils (was essence), the old buildings' roles) and what is missing (online lobby, other fathers, research). FATHERS (owner, 2026-10-28): the tech is father creatures (a Tyrannosaur for ground warriors, a Pterodactyl for fliers, another for Spitters...), one of each, each must be near the Queen to fertilise her eggs. ART DIRECTION (owner, 2026-10-28): the Brood is REPTILIAN first; some insect is fine, too much makes it a Zerg knock-off.
- Queen animation (not started; the Queen is a still sprite at the Brood capital).
- Armoury art polish (patch wobble, yellow specks, dummy target colour in its experiment animations): the Crown animation audit (anim-audit-crown) looks at it; wall balance check; optional player build grid; loosen the 24-tile limit in tools/test_ai_placement.gd.
- AI wall timing and scouting: DONE for the Crown Musketeer opening (AI._wall_wanted/_wall_off/adopt_site, AIScout rush evidence by faction; tools/test_ai_wall_vs_rush.gd: wall at ~2:00 behind the Barracks and Mill, 3 Musketeers by ~2:30, vs the owner's extreme rush). Still open: the walled Brood AI scouting by a patrolling grub at the ramp foot, Clockwork's equivalent, and a Crown that holds 3 Musketeers by 2:00 (needs the early farm income, which pays in lumps).
- AI: Brood AI on Rush built no army by 4:30 after the capital/income nerf: wt-brood-ai (0.14.45) reworked the Brood computer; check it in the study-v2 results.
- Exhausting resources: DECIDED (owner): resources run out (the Crown's soil too); only the timing of when they run out may need fine tuning (once seen ~10 min for the Crown, with 1-2k unspent gold at the supply cap).
- MUSIC: all three factions have 20 pieces in the same shape (Music.ROLES: opening, skirmish, full battle, calm). Clockwork merged 0.14.58 (tools/music/clock_more.py, one motif, the owner's clock recordings as percussion via tools/music/clock_kit.py; docs/music_clockwork.md, tools/test_music_clock.gd); Brood merged 0.14.60 (tools/music/brood_more.py, the Hive Call motif; docs/music_brood.md, tools/test_music_roles.gd). Still to do: an "army" select sound (voice/<faction>_army) for mixed Brood and Clockwork selections.
- Art (make better): the Clockwork buildings' turning parts (Cog Press, Mainspring, Escapement and the other gear buildings): the owner wants them as perfect as possible. The Clockwork animation audit (anim-audit-clockwork) checks every Clockwork building's loops; details of the rough parts in docs/art_style_inconsistency.md.
- Done and crossed off (2026-10-29): the dismounted Cuirassier (dismounted_armoured) redrawn by ChatGPT in every strip (0.15.21 idle/walk/aim/fire, 0.15.22 sword attack and death, all at 33 px helmet to soles; docs/art_style_inconsistency.md).
- Done and crossed off (2026-10-27): the in-game music player (scripts/ui/menu_music.gd); the labourer leading a horse getting stuck and the limbered guns and vanishing horses (fix-guns-horses, 0.14.37; the horse and hauler tests pass on 0.14.53); the late-game lag pass (perf-lag, 0.14.43); the Crown losing all its workers to a Raptor counterattack (obsolete, owner); Brood ground (0.14.42).

## Current work

- a04_visit BUILT (job a04-visit, 0.38.63, branch a04-visit, docs/campaign_a04_build.md): step 7 of Act 1's build order.
  "Father Ferrer's Visit" (the Clockmaker line after a02, Fürth, autumn 2769, told by Ferrer, the King framing): map
  campaign:furth_works (a02's map grown: tools/campaign/make_furth_works_map.py starts FROM furth_line.json), mission
  tools/campaign/make_a04_mission.py, stand-in stills a04_01..05 (make_a04_stills.py; prompts in the doc). Sides: `visit`
  = Ferrer's party (PURPLE, p1: Ferrer 300 hp, 2 lay brothers, escort by a02 `furth` strong 8 / thin 5, the gate men)
  + THE GUILD (BLUE, co-op p2, bound to THE ROSTER LADDER's K3: HEAVY WORKS + PENDULUM) + THE WORKS (TEAL, scripted: the
  automata that act alone); THE MACHINE (RED, versus p2). Part 1 six workshops (a STAY of 10 s each; signs: a Winder
  winding another, the Assembly's pamphlets on the Lyon type if a01 was played), Hollweg called away, Jakob brings the
  stop-works (lost: his old log in the barn), the dusk 10:00; Part 2 night: FOLLOW the night Winder (within 8, never 3:
  it stops), the reveal at the river (c01 `gate` pattern / people), the dawn 7:00; Part 3 THE RIOT: the broken ones
  CONVERT and march over the bridge and the meadow gap (an open gap) to the machine's ground (counted: lost_to_machine),
  the machine's sortie, the guild's Pendulum at the yard's gate; THE CHOICE THE BROKEN ONES: MELT (Ferrer) / KEEP
  (Hollweg), default and canon KEPT. Flags `broken`, `lost_to_machine` (a number: a tally banded by itself), `stopworks`
  found / logged, `jakob`. VERSUS only. Engine: the `wind` action. ALL TEXT PLACEHOLDER; Ferrer and Brother Anselm need
  voices. Tests tools/test_campaign_a04.gd, balance tools/sim_campaign_a04.gd. 16 Claude's choices in the doc.
- a06_barricades BUILT (job a06-barricades, 0.38.59, branch a06-barricades, docs/campaign_a06_build.md): step 6 of Act 1's
  build order. "The Barricades of Paris" (the Crown line after a01, July 2769, told by Field Marshal Fairleigh, Tomasz the
  King's chaplain): map campaign:paris_barricades (the city generator, tools/campaign/make_paris_map.py: the camp outside
  the toll wall, ONE gate, the faubourg's one street, the Marais, the Grève and the Hôtel de Ville, the Seine with the
  Cité and Notre-Dame, the left bank), mission tools/campaign/make_a06_mission.py, stand-in stills a06_01..05 (prompts in
  the doc). THE ROSTER LADDER's C3: the FOUNDRY + MORTAR (army and Ruggieri's guns, co-op p2, bound; no Town Hall/Farm).
  Part 1 THREE BARRICADES two palisades deep across the only street (the Mortar on the men behind, round shot on the
  palisades, a RUSH out of each breach: CANISTER), THE KING'S PATIENCE 20:00 (EASY 25, HARD 15) and SORTIES at the camp;
  Part 2 the Bastille's magazine becomes the army's, the bridges (Lyon men by a01's `lyon`), TORCHES over the Petit Pont
  for NOTRE-DAME (burnt only by torches); Part 3 the hall's palisade ring, CAPTURE Varenne (he runs for the boat at the
  Port Saint-Nicolas once the square is stormed: 30 s at the quay and he is gone); THE CHOICE VARENNE: Tomasz asks
  mercy, SPARE (exile, the default / canon) or EXECUTE; flags `varenne`, `paris` stood. Reads p01 `families` (six
  Hollins volunteers), a01 `lyon`, `printer`. VERSUS only (the friend = the Free Assembly). ALL TEXT PLACEHOLDER.
  Tests tools/test_campaign_a06.gd, balance tools/sim_campaign_a06.gd. 15 Claude's choices in the doc.
- a01_presses BUILT with THE CITY GENERATOR (job a01-presses, 0.38.57, branch a01-presses, docs/campaign_a01_build.md,
  docs/city_generator.md): step 5 of Act 1's build order. tools/campaign/city_gen.py (a town from a seed: rivers, fords as
  bridges, hills and stairs, districts of solid house blocks, squares, streets, traboules with doors, hidden yards, lots,
  walls; areas for the mission; check / ascii; a demo town) and Lyon (campaign:lyon_presses by make_lyon_map.py). Act 1's
  "The Printing Houses" (the Crown line after p01, spring 2768, Father Tomasz; the storyline titled THE CROWN): six of
  twelve houses are DISGUISED presses (the town's yellow, untouchable until a Crown man stands 3 s at the door; three
  layouts, the seed picks), runners to the squares raise THE CITY'S TEMPER (20: lost), close four; Part 2 the weavers'
  hill (Tomasz's STAY, the agitators turn weavers while he is away, bands up the three stairs); Part 3 the traboules
  (doors shut until then) to the great press, CAPTURE Rouvière (he names Paris). Reads p01 `families`; sets `lyon`
  calm/sullen (risen if the Assembly wins), `printer` taken. VERSUS only (the friend = the Free Assembly); co-op friend =
  the City Watch. Engine: disguise/unmask/unmasked/disguised, tags, spawn near, ping by tag, choice default random,
  counter min/max, order only_team. ALL TEXT PLACEHOLDER. Tests tools/test_city_gen.gd, tools/test_campaign_a01.gd,
  balance tools/sim_campaign_a01.gd. Claude's choices in the doc.
- THE ROSTER LADDER (owner DECIDED 2026-11-18 07:26-07:27 "Ye"; job roster-ladder, 0.38.57, branch roster-ladder,
  docs/campaign_roster_ladder.md, tools/campaign/roster_ladder.py, tools/test_roster_ladder.gd): like StarCraft's campaign,
  each mission brings 1-2 new pieces; THREE LADDERS (Crown line C1-C12, Clockmaker K1-K9, Naturalist B1-B9), each alone;
  the other side not bound. Act 1: C1 p01 Musketeer + Field Cannon (given), C2 a01 Horse Breeder + Horseman, C3 a06
  Foundry + Mortar, C4 a07 Church + Missionary; K1 c01 Winder + Clock Soldier, K2 a02 Springer + Netter (Escapement), K3
  a04 Heavy Works + Pendulum; B1 b01 Tyrant Sire + Raptors, B2 a03 (the nest) Venom Sire + Spitters, B3 a05 (the
  creatures) GROW stage 2 + MATURE. Engine: team "roster": {"allow", "new", "deny"} (Campaign.roster_items /
  roster_denied; refusals reach research, grub morphs, eggs, MATURE, GROW: pieces "stage2"/"stage3"); a NEW card (speaker
  "new", trigger ladder_new, to the ladder side). Generators call roster_ladder.apply(M, id); p01_leaf is patched with
  `python3 tools/campaign/roster_ladder.py p01_leaf` (make_m1_mission.py is older than its JSON). MERGED 0.38.58 with LYON'S C2 APPLIED
  (a standing Horse Breeder at [108, 47], the garrison's story deny on top, C2's pt/es cards). a06 Paris on C3: built (0.38.59). ALL TEXT PLACEHOLDER; 9
  Claude's choices in the doc (1: the Naturalist's mirrors ARE bound).
- THE WAR MAP v1 BUILT (job war-map-v1, 0.38.56, branch war-map-v1, docs/war_map_v1.md): step 4 of Act 1's build order.
  campaign/warmap.json (one data file for every skin: bounds/projection, views, regions with holders, marks, a pin per
  Act 1 mission with place/date/line, RULES by progress and flags) + campaign/warmap_land.json (Natural Earth 1:50m,
  public domain, tools/campaign/make_warmap_land.py); WarMapData (state, ledger, problems), WarMap (the King's PARCHMENT
  drawn in code, a `base` painting slot; pan, wheel, pinch, views THE WORLD / VIRGINIA / EUROPE / THE AMAZON; wax seals
  planned / locked / open / done / broken), CampaignMenu.war_map (LEDGER, LIST, the pin card: BRIEFING, CO-OP / VERSUS;
  desktop card right, phone card bottom). The King's study's war_table hotspot ("map": "parchment") opens it; every war
  table has a WAR MAP button. Planned pins (a01, a04, a05, a06, a07) carry working titles and rules on the plan's flags.
  ALL TEXT PLACEHOLDER; parchment/seal/rose prompts for the owner in the doc. tools/test_war_map.gd, tools/shot_war_map.gd,
  pictures docs/shots/war_map/. 12 Claude's choices in the doc.
- a03_plateau BUILT (job a03-plateau, 0.38.55, branch a03-plateau, docs/campaign_a03_build.md): Act 1's "The Lost
  Plateau" (the Naturalist line after b01, September 2767): map campaign:cloud_plateau (tools/campaign/make_cloud_plateau_map.py:
  the landing and the forest at the foot, the waterfall stair and the split in the rock, the misty top, the nest's hollow,
  four survey marks), mission tools/campaign/make_a03_mission.py, stand-in stills a03_01..05 (make_a03_stills.py; prompts in
  the doc). Played as VALADARES' CROWN PARTY (YELLOW): the climb in the MIST, 40 s at each mark while the nest SLEEPS (6
  tiles wakes it: Part 3 early, survey cut), patrols and prowlers, THE MAP choice (flag map drawn canon / withheld), then
  the Sire comes home up the way NEAREST Valadares and the party crosses the top to the other way, down to Benedito's
  canoe on a 4:30 countdown (exit counted: flag party few/some/all); passive = lost at the 14:00 rains. SOLO MIRROR / versus:
  THE NEST (GREEN, its hunters and new ones asleep, workers awake; from Part 3 kill Valadares or bring the party under
  half; flag plateau kept). Reads b01's saved (guides 0/1/2), eggs (taken: 4 young), turtle (early: 2nd turtle), rival
  (standing: red pack in the forest, a third side), teles, pieter; Linnea role linnea_grown (0.5). b01's next is a03; the
  Naturalist hub's Lindqvist reads the report. Engine: sleep keep/except_kinds, counter add_counter, tally of, order kind.
  ALL TEXT PLACEHOLDER; the guide from Nazaré needs a voice. Tests tools/test_campaign_a03.gd, balance
  tools/sim_campaign_a03.gd (bot wins ~5:45 either way down). 16 Claude's choices in the doc.
- a02_furth BUILT (job a02-furth, 0.38.53, branch a02-furth, docs/campaign_a02_build.md): Act 1's "The Fürth Line" (the
  Clockmaker line after c01, March 2768): map campaign:furth_line (tools/campaign/make_furth_map.py), mission
  tools/campaign/make_a02_mission.py, stand-in stills a02_01..05 (make_a02_stills.py; prompts in the doc). The guild
  (BLUE) fits the Honest One's STOP-WORK (a STAY) and builds a Light Works, holds the Crown's palisade line (PURPLE army,
  co-op p2) against three sorties, burns the Rednitz mill's seed: a WIN (flag furth strong / thin). SOLO MIRROR: the
  Machine (RED, the seeds' timetable as income) burns the Honest One or kills Hollweg before 18:00 (flag furth fallen;
  the King: "that is not how it went"). Reads c01's bells / saved / jakob / cut / gate (missing = c01's defaults). The
  Clockmaker hub is the guild's barn at Fürth after c01 (the c01 painting tinted) and the Machine's City for a player
  who won a02 as the Machine (Campaign.record keeps "side"; hub "sides" / "not_sides"). Engine: count "built", order
  "idle", hunt "prey_team". c01's next is a02. ALL TEXT PLACEHOLDER; Colonel von Rauch and the Commissary need voices.
  Tests tools/test_campaign_a02.gd, balance tools/sim_campaign_a02.gd. 15 Claude's choices in the doc.
- ACT 1 PLANNED (owner 2026-11-17 14:39 "Do it all"; job campaign-act1-plan, branch campaign-act1-plan, docs only:
  docs/campaign_act1_plan.md, supersedes docs/campaign_act1.md): seven missions 2767-2770 on three lines: the Crown
  a01_presses (Lyon, Tomasz) -> a06_barricades (Paris, Fairleigh; the VARENNE choice); the Clockmaker a02_furth (the guild in
  exile holding the line at Fürth against the Machine, Hollweg) -> a04_visit (Ferrer; choice THE BROKEN ONES); the
  Naturalist a03_plateau (Valadares; the FIRST BROOD PLAY as its solo mirror; choice THE MAP) -> a05_specimens (Lindqvist);
  all three -> a07_council (Rome, the King; the 1st crossing; three sides). Every prologue flag's effect in a table; the
  WAR MAP's design (one data file, three skins); engine needs (solo side pick, >2 sides, city generator, route/follow,
  sleep, mist, stay, cage carts, spreading fire, difficulty); build order a02, a03, war map v1, city + a01, a06, a04,
  a05, a07. ALL TEXT PLACEHOLDER. OWNER ANSWERED 2026-11-17 22:04 "Yes to all your suggestions" (all 14 as recommended:
  Fürth, the Fürth hub, Valadares/Ferrer tell their own, map DRAWN, mirrors a02/a05 (+b01), broken ones KEPT, Tomasz
  asks mercy and Varenne SPARED, Rome 2 players, missions before the war map, EASY/NORMAL/HARD, the dates, one crate
  hint, the heir later, both tellers at Rome). AND (22:00) THE BROOD PROLOGUE IS PLAYED AS THE BROOD: the Sire's pack v
  a rival pack, the station scripted, it still falls, the player takes Linnea; the first Brood play is b01, not a03
  (doc "OWNER ANSWERS"). MERGED: act1-engine0 0.38.49 (docs/act1_engine0.md:
  difficulty, solo side pick, if/stay/near/seen, route/follow, sleep/wake, mist, capture) and brood-prologue-flip 0.38.50
  (docs/campaign_b01_build.md: the Sire's pack v the rival pack (Brood computer Easy capped at 36 + scripted hunters),
  the station scripted, root/lay/roar/Linnea teaching strip, ONE choice TAKE/LEAVE THE CLUTCH (flags clutch, eggs, rival),
  14 Claude's choices, new stills b09-b11). Job a02-furth (the Fürth Line) started 2026-11-18 00:00.
- BROOD PROLOGUE FLIPPED (owner 2026-11-17 22:00-22:04; job brood-prologue-flip, 0.38.49, docs/campaign_b01_build.md, which
  supersedes the station-played build below): b01_specimen is PLAYED AS THE BROOD, the campaign's first Brood play: the
  player is the Tyrant Sire's pack (green: the Old Mother's standard start in a north-west den, the Sire, Raptors); a teaching
  strip in the objectives (ROOT in the father range, LAY AND HATCH, THE SIRE'S ROAR at the forest's edge, root by Linnea's pen
  while she lays 5 eggs, break the gate, take her home to the den: the win); the rival pack (red) = the Brood computer Easy
  (supply_cap 36, ai_foe sire) + scripted hunters; the station (yellow/purple) scripted, its story by the script with the canon
  (teles quiet, the research saved), Lindqvist narrating; the player's ONE CHOICE: TAKE THE CLUTCH / LEAVE IT (flags eggs,
  clutch, fire; new rival). Engine: nest_free, heel, ai_foe, supply_cap, hall_tag on a Brood team (docs/campaign_engine.md).
  Sim tools/sim_campaign_b01.gd: wins in ~9:30-10:00. 14 Claude's choices in the doc.
- BROOD PROLOGUE BUILT (owner 2026-11-17 08:01 "Now make the campaign missions" / "Prologues first", ANSWERS 10:22; job
  brood-prologue-build, 0.38.45, docs/campaign_b01_build.md): "Specimen One" (b01_specimen) is THE NATURALIST's first
  mission (the Brood storyline renamed from The Explorer; open after p01_leaf): map campaign:rio_negro_station
  (tools/campaign/make_rio_negro_map.py, jungle, floor darkened), mission tools/campaign/make_b01_mission.py, stand-in stills
  b01_01..08 (make_b01_stills.py; the owner's ChatGPT prompts in the doc), sounds campaign/linnea_call, forest_answer,
  sire_roar; the station YELLOW, the garrison PURPLE, the pack GREEN (scripted); Linnea a Brood Mother's kind at 0.3 on a
  team of her own (caged, spared); three parts (the pen, Valadares, the tracks, the goats, the TELES choice; the lure
  learnt then set, the village, the walking turtle; the Tyrant Sire roots by her pen, the clutch, the fire, he takes her,
  the CLUTCH choice, the canoes on an 8:40 countdown) ending in a STORY LOSS that counts (THE STATION IS LOST; flags teles,
  clutch, saved, pieter, turtle, gun). Lindqvist tells it as a prisoner before the King (b08); the King's study lists him
  held; the hub after the fall is the warehouse at the Barra (crate or singed notebook by the flag). ENGINE
  (docs/campaign_engine.md "Added by the Brood prologue"): cage, spare, pin, carry, floor, heal, hp, root/uproot, rooted by
  tag, to_if, burn, building sites + build objective, exits after/except, counter from a count, rain, jungle lights, floor
  tint, role scale, hub flag gating. ALL TEXT PLACEHOLDER; Lindqvist/Valadares/Pieter/Teles/Joaquim/Benedito voices need
  designing. Tests tools/test_campaign_b01.gd, balance tools/sim_campaign_b01.gd. Claude's choices in the doc.
- CLOCKWORK PROLOGUE BUILT (owner 2026-11-17 08:01 "Now make the campaign missions" / "Prologues first"; job
  clockwork-prologue-build, 0.38.43, docs/campaign_c01_build.md): "The Thirteenth Hour" (c01_thirteenth) is the Clockwork
  storyline's first mission (open after p01_leaf): map campaign:nuremberg_advent (tools/campaign/make_nuremberg_map.py,
  snow), mission tools/campaign/make_c01_mission.py, stand-in stills c01_01..07 (make_c01_stills.py; the owner's ChatGPT
  prompts in the doc), sounds campaign/bell_toll + off_beat; three parts (the order and the gift; the mill island, the
  children turn red, the BELLS choice; Part 3 on a 9:00 countdown: Hollweg to the west gate, townsfolk out and counted,
  links, Jakob's drawings, the GATE choice) ending in a STORY LOSS that counts (NUREMBERG IS LOST; flags bells, saved,
  jakob, cut, gate). ENGINE (docs/campaign_engine.md "Added by the Clockwork prologue"): manual_end, debrief banner and
  text_if, if-lines in endings, counters/exits/tally, clocks and countdown objectives, repeating triggers, convert,
  roster deny/unlock (Game.can_train/requirement_text), sound, name, hunt order, netted, winter lights, snow, campaign
  roles citizen/hollweg/jakob/ferrer (Rebels.ROLES general, role hp), hub "after"/requires/until. The machine is
  SCRIPTED (seeds), not the Clockwork computer. ALL TEXT PLACEHOLDER; Hollweg/Ferrer/Jakob voices need designing. Tests
  tools/test_campaign_c01.gd, balance tools/sim_campaign_c01.gd. 12 Claude's choices in the doc.
- BROOD PROLOGUE OUTLINE (owner 2026-11-17 08:01 "Now make the campaign missions", prologues first; ANSWERS 09:18; jobs
  brood-prologue-outline + brood-prologue-revise (branch brood-prologue-outline, docs only): docs/campaign_brood_prologue.md,
  "Specimen One" (June 2767, Saint John's Eve, the Academy's station on the Rio Negro). DECIDED: a mission the scientists
  LOSE (the station falls in Part 3, told only then; the people escape by the jetty, counted); the NARRATOR is LINDQVIST
  himself (the Brood line's main character, the heretical scientist) in person in the present, the King opens/closes and
  corrects him; the player plays the STATION (pack = versus only; first Brood play stays the Lost Plateau); their aim:
  tame and sell BEASTS OF WAR to the Crown; Valadares warns, ignored; Linnea (a young Brood Mother, never said; Queen
  only hinted) lays a clutch while the Tyrant Sire roots by her pen, then he leads her into the forest (always lost);
  choices: tell the lieutenant, BURN THE EGGS or SAVE THE RESEARCH (flag clutch). Lindqvist's hub moves downriver
  (Barra do Rio Negro, proposed). Open: where he tells it from (proposed: a room with no name), the lure, colours, the
  gun, names, the storyline's name. All lines are placeholders.
- CROWN BROOD MEASURE (job crown-brood-measure, data on 0.38.38, docs/crown_brood_measure.md, data docs/crown_brood_measure/):
  152 games v the Brood, arms M as is / C coach:off / H honest:off / F screenfirst+gunsfirst off: M = C (6 v 7, p 1.0);
  the HONEST RECKONING (rule 3, only read v the Brood) HURT (H v M income 8:00 26 v 12, p 0.034; 12:00 21 v 8, p 0.024),
  so since 0.38.42 it is OFF by default (switch broodhonest:on); screen/guns first no measurable effect, kept. OPTIMAL
  still opens the Horseman rush v the Brood in 37 of 38 (no blind rush is off v the Brood). Measured before 0.38.40 (army
  floor) and 0.38.41 (guns rework). NORUSH MEASURED (job crown-norush-measure, merged 0.38.51, docs/crown_norush_measure.md,
  114 games on 0.38.46): WITHOUT the rush the Crown does WORSE (N v A 4 better / 14 worse, p 0.031; army 8:00 lower in 33
  of 38; halls lost 1.03 v 0.42): the unharassed Brood's army at 8:00 is 1,794 v 1,051. The rush STAYS ON v the Brood.
  Proposals P1-P3 (a cheaper later harass that still makes the Brood read AGGRESSIVE; a later second greed look).
- CROWN GUNS COACHED (owner 2026-11-15 22:20 / 2026-11-16 23:25 "setting cannon before the engagement is very important";
  job crown-guns-coach, 0.38.40, docs/crown_guns_coach.md, scripts/ai_crown_guns.gd AICrownGuns, tools/bench_crown_guns.gd,
  tools/study/crown_guns_coach.py + _report.py, data docs/crown_guns_coach/): the Crown computer's FIGHTING only (no number
  changed): the line keeps its guns from the wave's shared loop (gkeep), guns set where they stand in time and go up to
  reach (gset), follow the line (gfollow), the held line by its guns is a state (gawait), the wave keeps with its guns on
  the march (gpace), no column into a ramp (gramp; rarely fires), the defence's and home posts' guns set (gdef, gpost), a
  rider keeps the enemy in sight for the guns (gspot); switch gunscoach:off. Plus the COUNT of every fight (result.json
  crown_ai guns, Unit.fired_t). 152 games to 12:00: guns set at contact v Clockwork 15% -> 38%, v Brood 20 -> 33%; firing
  in the first 10 s 50 -> 65%, 37 -> 56%; kills per loss in fights 1.26 -> 1.98, 0.88 -> 1.07; halls lost 0.74 -> 0.53,
  0.79 -> 0.68; outcomes unchanged (still 0 wins). Open: flanks out of swamp/fog, posts behind an attacked wall move, a
  line forming across a ramp. 8 Claude's choices in the doc.
- CROWN MIRROR COACHED AGAIN (owner 2026-11-16 23:25; job crown-mirror-coach, 0.38.39, docs/crown_mirror_coach.md, data
  docs/crown_mirror_coach/, tools/study/crown_mirror_coach.py + crown_mirror_report.py + crown_mirror_diag.py, pictures
  docs/shots/crown_mirror_coach/): the Crown COMPUTER in the mirror only (no number changed), AICrownMirror: the side ahead
  PRESSES from 8:00 (1.3x the enemy it reckons, 900+: the wave's bar comes down; the Siege push goes without its full kit),
  the OUTLYING HALLS FIRST (the cheapest enemy hall as the wave's and the push's target), GUNS FOR THE WALLED HALL (up to 3
  Field Cannons once only walled halls are left). Switches cmc:off (all), cmcpress/cmctarget/cmcguns:off. 38 games to
  15:00, 0.38.38 v after: decided 2 v 2 (no change), halls lost 1.71 v 1.71; leaders' waves after 10:00 0.41 -> 0.63; the
  loser's main on its plateau holds and 15:00 is short. Rules left ON (Claude's choice 1). Proposals P1-P4 (measure to
  20:00, guns' spot v a main, the new hall's guards, a fading defender's advantage). OWNER DECISIONS WAITING.
- CROWN BROOD ARMY (owner 2026-11-16 23:25 "start all coaching jobs needed"; job crown-brood-army, 0.38.39,
  docs/crown_brood_army.md, tables docs/crown_brood_army/tables.md, films docs/crown_brood_army/films/, tools
  tools/crown_brood_trace.gd, tools/study/crown_brood_army*.py): the Crown COMPUTER v the Brood only (no number changed),
  AICrownVBrood parts 5-7: 5 THE ARMY FLOOR TIED TO THE BROOD 4:00-9:30 (the Brood seen + 500 by 6:00 / 1,000 by 7:30,
  55 a labourer; Barracks two deep and a gun before any stage spends, their gold held; a Barracks more when all busy; a look
  at 4:00-6:30), 6 HOLD THE FIRST PUSH (no wave before 10:00 unless 2x the Brood reckoned, never under BROOD_TABLE; the
  counter filmed and NOT kept, cbacounter:on), 7 the coach's economy rules after a held push or from 9:00. Switches cba:off,
  cbafloor:off, cbahold:off, cbaecon:off, cbafloor:k=. 38 games x 3 arms to 12:00: army 8:00 1.07-1.14 of the Brood's
  (main 0.81; 25-26 of 38 bigger, p 0.07/0.03), first-arrival losses 7 -> 3-5, won or led 6 (main 3; p 0.55), income no
  worse; still 2 halls to the Brood's 4. Open: "held" counts value_killed (fires in 8-13 of 38), part 7 rarely fires (the
  line short), the fight inside the natural's wall (crown-guns-coach); 9 Claude's choices in the doc.
- CROWN COACH (owner 2026-11-15 22:20, coached by Claude in the session; branch crown-coach-1116 MERGED 0.38.38, owner "Yes"
  2026-11-16 22:37; scripts/ai_crown_coach.gd AICrownCoach, docs/crown_coach_measure.md, docs/crown_coach_measure_2.md,
  docs/crown_farmfirst_measure.md): FARM FIRST (2nd Farm before the Barracks, every plan but the Rush), LABOURERS FIRST with
  THE ARMY FLOOR, HALLS ON TIME (2 by 3:30, 3 by 7:30, 4 by 11:30), an HONEST RECKONING of the Brood, NO BLIND RUSH, the
  SCREEN FIRST, GUNS FIRST. Measured (190 games, 12:00): v Clockwork income 8:00 0.57 -> 0.68 (31 of 38, p<0.001), army
  8:00 0.55 -> 0.71; v Brood the economy rules left it thin (army 5:00 120 v 360, outcome worse 12 v 3, p 0.035), so v the
  Brood rules 1, 2, 4 are OFF (switch broodecon:on brings them back). Switches coach:off, labsfirst:off, hallsontime:off,
  honest:off, norush:off, screenfirst:off, gunsfirst:off, farmfirst:off, armyfloor:off, broodecon:on. Next: a Brood-only
  measure (crown-brood-measure) of the merged Crown v coach:off; an army floor tied to the scouted Brood army; guns still
  march limbered, waves climb Clockwork ramps in a column.
- CLOCKWORK V BROOD COACHED AGAIN (owner 2026-11-15 22:20 / 2026-11-16 07:07, K1; job clockwork-v-brood-coach-2, 0.38.37,
  docs/clockwork_v_brood_coach_2.md, scripts/ai_cw_brood.gd AICwBrood, tools/cw_trace.gd, tools/study/cvb2.py, pictures
  docs/shots/clockwork_v_brood_coach_2/): the Clockwork COMPUTER only, against the Brood only (no number changed): its first
  turtle is no greed (Clock Soldier rush only on 3+ grounds / 5+ Rootmaws; else the economy opening goes on), one Clocktower
  keeps Winders under the rush and the rush soldiers stop once it is over, the Escapement with the new presses then the
  shared rules (Heavy Works ~5:13), Pendulums (1 per 5 others, up to 8) before the Serpent with their Tension kept, a third
  Clocktower from 6:00, the push only 2x the reckoning with 2 Pendulums (C2's counter unchanged), attack-moves near Raptors.
  Switches cvb2:off (all), cvbread/cvbwind/cvbrushend/cvbserp/cvbhall/cvbpend/cvbtension/cvbyard/cvbpush/cvbamove:off,
  study cvbgreedy:<plan>. 38 games to 12:00 on 0.38.35: W-D-L 4-27-7 -> 5-32-1, won or led 14 -> 33 (p 0.00001), income
  at 12:00 1,711 -> 2,386 a minute, halls lost 0.66 -> 0.05 a game; v Crown and the mirror unchanged on 4 games. Open: its
  counters into the Brood's swamp still lose now and then; 9 Claude's choices in the doc.
- BROOD SPOT STUDY (owner 2026-11-15 22:20 "spots should be equal"; job brood-spot-study, 0.38.36, docs/brood_spot_study.md,
  data docs/brood_spot_study/, tools/study/brood_spot_study.py + brood_spot_report.py + brood_spot_income.py, spot_trace.gd,
  map_mirror_check.gd): the Brood mirror's P1 edge is the SPOT, not player order (switch `spotswap` puts P1 on spot B: spot
  A kept its ~5% income lead) and not the maps (every cell an exact mirror). Cause: the Brood's rooted feet hang below the
  footprint on screen, so rules and the Brood computer measured spot B from other points (a far Rootmaw drank slower, a
  Sire's reach, new ground, the grub's Rootmaw, swamp mending, the morph grub, turtle sites, Rootmaw spot scores), and every
  game on a map replayed one opening. FIX (switches fairspot:off, thinkphase:off): BroodRoot.sym_feet / BroodNew.fdist /
  anchor for spot B; a think phase from the match seed, the same for every computer (AI.first_phase). 76 games after:
  spot A won or led 28-25-23 (p 0.78, was 34-25-17), the opening even (2:00 1.002); a small mid-game lean is left (1-3% at
  5:00-8:00, only between two Broods; P1 34-19, p 0.053: watch). Proposals P1-P4 in the doc. 8 Claude's choices.
- BROOD ROOTMAW COACH (owner DECIDED 2026-11-15 21:34 "yes"; job brood-rootmaw-coach, 0.38.35, docs/brood_rootmaw_coach.md,
  tools/study/brood_coach_report.py, data docs/brood_rootmaw_coach/): the Brood COMPUTER only (no number changed): from 5:00
  it reckons the Rootmaws it will want a turtle's walk ahead (plan curve + walking + under 900 food left) against fresh
  room + room on its way and roots a Mound Turtle on new ground at once (AIBroodNew._maw_expand_due / _nb_expand_spot:
  its turtle sites own side first, then any fresh ground 18-40 tiles out where a Rootmaw fits, _nb_fresh_turtle_spot);
  not under the alarm, an enemy at the Mother, a rush, her growth due; 30 tiles while riders are about; a home supply
  turtle the layout refuses no longer ends the think; up to 10 grubs over the plan's while rich (_extra_grubs; the Rush
  plans keep theirs; test_ai_brood's grub check follows). Switch maweco:off. Alone (9 runs) +9% at 12:00 (Rootmaws 6.3
  -> 9.8), same until 5:00; games (24 a side on 0.38.20) v Clockwork +8% at 8:00, +14% at 12:00, v Crown about even, +4%
  at 12:00; more grubs/turtles lost out there (choice 7: escorts proposed). Measured before the cavalry package (0.38.31-33):
  rerun the v Crown games after the merge if wanted. 9 Claude's choices in the doc.

- WINDERS ESCORT THE ARMY (owner's report 2026-11-15 20:11, DECIDED 20:15 "both"; job winder-escort, 0.38.18,
  docs/winder_escort.md, scripts/winder_escort.gd WinderEscort, tools/test_winder_escort.gd, pictures docs/shots/winder_escort/):
  Winders in a group order (move, attack-move, drag-a-line, right-click on an enemy, Shift) WITH Clockwork fighting units
  get the order "escort" (Unit.cmd_escort): behind the group's rearmost man away from its front, winding/mending the
  neediest (lowest charge or health share, spread over the Winders, not next to an enemy), stepping back from enemies
  within 64 px, hitting back only when pinned 0.8 s; they stay with it after the order ends; only-Winder groups unchanged;
  card ESCORTING. WIND UP (W, icon a copy of ab_mend) on the Winder's card: Game.wind_up_order (the rest of the selection,
  or the unit tapped next and those within 3 tiles). The computers' Winders don't use group orders: unchanged. 8 Claude's
  choices in the doc.
- THE ESCAPEMENT'S THREE RESEARCHES (owner DECIDED 2026-11-15 20:34; job escapement-research, 0.38.19,
  docs/escapement_research.md, tools/test_escapement_research.gd, bench tools/bench_netter_range.gd): SHIELD WALL moved
  from the Light Works to the Escapement (same price; the Escapement's Tension rule, like HIGH LEAP; an old save's SHIELD
  WALL queued at a Light Works is paid back); the Netter's reach 180 -> 150; new LONG CHAIN at the Escapement (a drill,
  +90 -> 240; 100 cogs + 50 Tension, 40 s; stand-in icon in code); the Field Cannon (430) still the longest reach; keys
  HIGH LEAP=E SHIELD WALL=S LONG CHAIN=C; the computer buys SHIELD WALL at its Escapement (no systematic slip in 5 games)
  and LONG CHAIN at 2 Netters. 8 Claude's choices in the doc.
- WIND-UP KEYS ON THE CLOCKWORK ARMY (owner DECIDED 2026-11-15 20:15: "a wind-up KEY on its back like the Winder has";
  job wind-keys, 0.38.21, docs/wind_keys.md, tools/clockwork/import_wind_key.py, scripts/wind_key.gd + wind_key_data.gd,
  tools/shot_wind_keys.gd, pictures docs/shots/wind_keys/): one painted key (the owner's ChatGPT still, turned at import:
  16 frames x views s/se/e/ne/n + "u" standing up for flyers, assets/units/_shared/wind_key_<size>.png) on the back of
  the Clock Soldier, Springer, Netter, Pendulum, Swift and Ticking Owl, a child of the body sprite following measured
  per-frame spots; it TURNS with `wind` (a turn per 1.2 s full, still run down), stepped by Unit._animate (on screen only,
  10 Hz in big battles); hidden on death. Not the Winders, Ballista or (Claude's choice 1) the Brass Serpent (its wind
  never runs down). Switch windkeys:off. 8 Claude's choices in the doc.
- ONLINE SPECTATORS (owner 2026-11-15 20:30; job online-spectators, 0.38.21, docs/online_spectators.md,
  tools/test_online_spectators.gd via `tools/test_online.sh spectators`, pictures docs/shots/online_spectators/): in a
  friendly room a guest picks SPECTATOR (WATCH) in its FACTION list (or WATCH beside JOIN; a full room or a match under
  way seats one as a spectator too) and is listed apart under SPECTATORS (n) with its ping, at most NetLobby.SPEC_MAX 4,
  not counted as players; TAKE A SEAT goes back. In the match (game.net_watch, demo): every side (NetSession.spec_view,
  NetView.spectator: no fog filter, sent only to spectators' relay ids), VIEW / PRODUCTION / ARMY & STRUCTURES, no AI
  STORY, no orders (the host refuses "spectator"), no pause; chat to spectators only unless the host's SPECTATORS TALK
  TO PLAYERS; leaving changes nothing; the host's whole replay reaches spectators too. The host always plays; no
  spectators in campaign rooms. Upload: ~11 KB/s a spectator in an early fight, ~40 KB/s in a 240-unit battle.
  Ranked spectating NOT built (needs watch tickets, a delay): 9 Claude's choices and the three-device test in the doc.
- CLOCKWORK PROLOGUE OUTLINE (owner 2026-11-15: every faction gets a prologue; the Clockwork's is a LOSING mission: we
  play the good Clockwork with the inventor, find a self-replicating failing mechanism too late, fight to contain it and
  lose, and the Clockwork expands. Answers 21:34: the runaway machine IS the whole Clockwork faction; the inventor is
  MEISTER HOLLWEG (his Nuremberg workshop = the Clockwork hub); he was building THE PERFECT MACHINE). Job
  clockwork-prologue-outline (branch, docs only): docs/campaign_clockwork_prologue.md, "The Thirteenth Hour" (Advent
  2767, Nuremberg; the Perpetual built without a stop-work; parts: it wakes / the mill island / the thirteenth hour;
  only Hollweg's death is a real loss, the rest is saved-and-carried-forward; choices: the bells, people or pattern;
  6 stills with ChatGPT prompts; 15 engine needs for a build job; 10 OWNER QUESTIONS). All lines are placeholders.
 OWNER ANSWERS 2026-11-15 22:20 in the doc (Advent 2767; Hollweg narrates from exile in the King's palace; Ferrer warns; Hollweg took the machine for a true intelligence (heresy, deceived); 2 choices; Nuremberg = the machine's hub; told only at Part 3).
- ECONOMY LIMIT BY HALL (owner DECIDED 2026-11-15 18:06: "it should be 2 per Town Hall, 2 per Clocktower"; job
  econ-limit-local, 0.38.16, docs/econ_limit_local.md, tools/test_econ_limit_local.gd): every Farm / Powder Mill / Cog Press /
  Mainspring belongs to the hall it draws from (its nearest BUILT hall, a tie to the older) and each hall allows
  Defs.econ_per_hall round it (Game.econ_by_hall / econ_at / econ_full_at; econ_limit = sum of max(per, n), so
  econ_count >= econ_limit still means "no hall has room"); refusal "This Town Hall already has its Farms (2/2). Build near
  another Town Hall." (en/pt/es); hall cards FARMS 1/2 · POWDER MILL 0/1, COG PRESSES 2/2 · MAINSPRING 1/1; a hall going up
  allows nothing; a fallen hall's buildings go to the next nearest (over its count they work, no new one there). The
  computers skip a full hall (AI._econ_spot, AICwMacro) and recycle a spent building of the hall that needs the place.
  Bench unchanged; the computers alone within noise (12:00, 6 runs a side: Crown 0.0%, Clockwork +2.0%, its Tension +8%).
  The Powder Mill and the Mainspring are local too. CONFIRMED (owner 2026-11-15 21:34): the Mainspring stays LOCAL, 1 per
  Clocktower.

- PENDULUM HIGH SWING (owner's ChatGPT sheets; job pendulum-high-swing, 0.38.16, docs/pendulum_air.md "The HIGH SWING",
  tools/pendulum_guide/import_high_swing.py, pictures docs/shots/pendulum_air/high_swing/): at a FLYER the Pendulum plays
  attack_hi_r / attack_hi_l (130 x 136 cells, feet where the 91-px strips have them; Pendulum.HIGH added to Unit.arm as
  the wind-up starts), the blade over its head on the same hit frame; ground targets keep the low sweep. NE's left arm from its
  own sheet (the owner's redo 2026-11-15 21:50, pendulum_high_swing_ne_left_chatgpt.png, SHEET_ARM): every view alternates arms.
- BROOD ROOTMAW SPOTS (owner DECIDED 2026-11-15: the Brood keeps the only radius economy, made fair and easy; job
  brood-rootmaw-spots, 0.38.14, docs/brood_rootmaw_spots.md, scripts/rootmaw_spots.gd RootmawSpots, tools/test_rootmaw_spots.gd,
  tools/measure_rootmaw_fit.gd, pictures docs/shots/rootmaw_spots/): a COUNT (Defs.NB maws_queen 3, maws_turtle 2; ROOTMAWS n/3
  on the card, "Full: ..." refusal), the circle KEPT at 8 tiles (3 fit round every start and 2 round every turtle site on
  every map, measured), 3,000 food each unchanged; gold BEST ROOTMAW SPOTS on the player's own swamp (Brood only, no
  snapping, Settings SHOW ROOTMAW SPOTS), the computer roots on them first (switch mawspots:off); the Rootmaw's swamp rule
  reads its footprint's middle (BroodNew.maw_on_swamp; mirror-fair). NUMBERS (12 min): bench Brood +11-17% (3 fit at home
  sooner), 0.87-0.93 of the others from 8:00; the Brood computer -4% alone, -7% by 8:00 in 24 games (its 4th+ Rootmaws must
  go to new ground); in games Brood/Crown 1.27-1.38, Brood/Clockwork 0.64 at 5:00 to 0.97 at 12:00. RECOMMENDATION WAITING:
  no Rootmaw number change; coach the Brood computer's 4th/5th Rootmaws onto new ground. 9 Claude's choices in the doc.
- WIN RATES 2026-11-17 (study job winrate-2026-11-17, merged 0.38.59, docs/winrate_2026_11_17.md, data
  docs/winrate_2026_11_17/, tools/study/winrate_1117*.py/.sh): 228 games to 12:00 on 0.38.45 + 19 Crown mirror games to
  20:00. Brood v Clockwork TURNED OVER (Clockwork wins or leads 34 of 38, was 9; the Brood computer's GREEDY-read rush and
  half-size waves); the Crown still 0 wins but holds (halls lost v Brood 1.21 -> 0.24, army 8:00 1.17 of the Brood's,
  income 8:00 +16% v both) and trails at the bell (holds its wave while BIGGER 21 times in 13 games v the Brood: the
  reckoning; v the Clockwork the gap is economy, 34 v 47 workers at 8:00, and the Balloon pick 0 of 12); Brood mirror spot
  edge GONE (14 v 8, p 0.29); Crown mirror breaks only after 15:00 (2 wins, 13 of 19 1.5x apart at 20:00); 6 proposals.
- WIN RATES 2026-11-15 (study job winrate-2026-11-15, 0.38.15 tools only, docs/winrate_2026_11_15.md, data
  docs/winrate_2026_11_15/, tools/study/winrate_1115*.py/.sh): on 0.38.14 the Crown computer still won 0 and led 0 of 76
  (v Brood 0-13-25, v Clockwork 0-22-16: worse, the Clockwork computer now reaches its bench, 1.01 at 8:00, the Crown
  0.6); its halls idle while Farm posts are empty, the blind Horseman rush v every Brood (38 of 38), it over-reckons the
  Brood and holds back while ahead; Brood mirror P1 (spot A) 26-9 (p 0.006); Brood v Clockwork now 26-6-6 for the Brood.
  Proposals C1-C6, K1, S1-S3, R1-R2 in the doc. OWNER DECISIONS WAITING.

- KEEN SABRES TEST (owner 2026-11-15 10:03: "Why do we need Keen Sabres?"; job keen-sabres-test, 0.38.12,
  docs/keen_sabres_test.md, tools/study_keen_sabres.gd, tools/study/keen_sabres_games.py + keen_sabres_report.py): hit and
  run + the Cavalry Charge did NOT hold Raptors at equal cost; a Charge x2.2 v light with no wait-round micro measured as
  well as Keen Sabres. DECIDED and DONE (owner 21:34): see THE CHARGE PACKAGE below (keensabres:off and chargelight: are gone).

- THE CHARGE PACKAGE (owner DECIDED 2026-11-15 21:34; job cavalry-charge-package, 0.38.31, docs/cavalry_charge_package.md,
  tools/test_charge_package.gd): KEEN SABRES REMOVED (research, button, blow, texts, icon, test; an old save's flag is dropped
  on load); the CAVALRY CHARGE at the HORSE BREEDER (was the Armoury; 60 gold, 25 s; old saves keep it), a charged blow x2.2 on
  LIGHT units (Defs.CHARGE "light"; one charge kills a 38-hp Raptor), x2 on the rest; the computer's riders (AICavMicro
  _swarm: 4+ fast light biters within 420 px, at least 0.75 of the rider's pace) take each blow as it comes instead of
  galloping round for the next charge (switch cavswarm:off); the computer drills it at 2 riders, or with the first rider
  (out or queued) on a rider plan (AI._rider_plan: opening "breeder"). OFFICER 100 gold (was 75) = the Horseman's own price
  (a horse is always 40 apart: Officer + horse == Horseman + horse, 140; armoured 130 + 40 both ways; powder 5 each; the rule
  of every pair: Labourer = Messenger, Musketeer = Dragoon; Claude's choice 1: UP, not 75 -> 60, which would widen the gap).
  NUMBERS: fight study (2v11, 8v45) the package trades 1.04-3.57 without Pack Hunt, 0.62-0.89 with (Keen Sabres 0.50-3.04 /
  0.78-2.82; without the swarm rule x2.2 only 0.23-0.69); 16 computer games Crown v Brood 0-6-10, on the old 8 seeds 0-4-4
  (Keen on 0-2-6, off 0-5-3: noise), riders kill 1.6 Raptors per rider lost (Keen 1.26), the Charge drilled at 5:50-7:00.
  6 Claude's choices in the doc.
- RAPTOR / HORSEMAN BALANCE (owner DECIDED 2026-11-15 00:38-00:53, after comparing StarCraft II's Zergling and Hellion; job balance-raptor-horseman, 0.38.10, docs/balance_raptor_horseman.md, tools/test_raptor_rider_fight.gd): Raptor 38 health (was 36), speed 92 (was 96), PACK HUNT still 114 (only then does it outrun horses); Horseman 100 health (was 140) and 100 gold (was 115), Cuirassier 130; KEEN SABRES at the Horse Breeder (0.38.10; REPLACED 0.38.31 by THE CHARGE PACKAGE above). The Officer's price and the computer's research: DONE in THE CHARGE PACKAGE. Still waiting: rerun the Crown v Brood and Brood mirror win rates. CAVALRY HIT AND RUN for the Crown computer (owner 00:53; job crown-coach-cavalry, 0.38.9, scripts/ai_cav_micro.gd, switch cavmicro:off). BALLOON (0.38.7, scripts/ai_crown_balloon.gd, blfix:off; OPTIMAL picks it 1/3 v a NORMAL Clockwork, owner: "viable, not 100%"), ECONOMY (0.38.8, crowneco:off) coached too.
- ECONOMY REVERTED + PROLOGUE (owner DECIDED 2026-11-15 10:24: "revert back to 2 buildings, no radius, no effectiveness based on soil... this experiment is proving problematic"; job eco-revert-prologue, 0.38.12, docs/eco_revert_prologue.md): the ORIGINAL economy is the only one (2 Farms / 2 Cog Presses a hall, the hall's own soil/brass pool); the GROUND SYSTEM and NO FARM/PRESS LIMIT are DELETED (ground_layer.gd, ground_view.gd, Defs.ground_on/ground_nocap/LAND, Settings ground_system/ground_nocap/ground_alpha, Game.NO_GROUND_MSG, Defs.nocap_text, their tests, study tools and docs; in git history before 0.38.12); an old cfg/save/replay "ground" is ignored. PROLOGUE (p01_leaf): the manor Town Hall moved south ([8,42], tag manor) with 2 Farms, a second Governor Town Hall north on the west side ([8,23], tag north_hall) with 2 Farms: 4 barns (was 5); dawn still needs 3 barns (now of 4: the night sim's active player ends with 3-4, it ended with 3 of 5 before); a mission's "expansion_spots": false now also stops the Crown/Clockwork spot updates.
- NO FARM/PRESS LIMIT, ALL SIDES: REVERTED by the owner 2026-11-15 10:24 (see above). Was: (owner 2026-11-14 "economic study with the free amount of resources"; job econ-nocap-all, 0.38.6, docs/econ_nocap_all.md, tools/study/econ_nocap_all*.py): RECOMMENDS KEEPING THE LIMIT: with the ground system on, dropping it gives the Clockwork +20% income by 12:00, Crown 0.98, Brood 0.96; Brood v Clockwork 7-3-6 -> 4-3-9; no turtling, no extra snowball. If dropped one day: a Clockwork brake (7,000 brass a district), a Brood counterpart, after the Crown computer reaches its bench. OWNER DECISION WAITING.
- PENDULUM HITS FLYERS (owner 2026-11-15 00:46-00:53, no research; job pendulum-air, 0.38.3, docs/pendulum_air.md,
  tools/test_pendulum_air.gd, tools/bench_pendulum_air.gd, pictures docs/shots/pendulum_air/): every swing also cuts the
  enemy flyers in its arc for 3/4 (Defs.PENDULUM_SWING "vs_air"), light bonus on top; Defs "anti_air" (no "ground_only");
  the Clockwork computer counts a Pendulum as half a Swift; measuring switch `pendair:off`. A HIGH SWING strip for ChatGPT
  in docs/art_style_inconsistency.md. 6 Claude's choices in the doc (the light bonus on flyers above all).
- CROWN CAVALRY MICRO (owner 2026-11-15 00:53; job crown-coach-cavalry, 0.38.3, docs/crown-coach-cavalry.md,
  scripts/ai_cav_micro.gd AICavMicro, switch cavmicro:off, tools/test_cav_micro.gd, tools/study_cav_micro.gd): the Crown
  computer's Horsemen hit and run: pick light/precious prey (never armour, shields, pikes or a guarded mass), strike, ride
  out, come again; with the Cavalry Charge they gallop round until the next blow is a charge (not under guns; a killing
  blow first); hurt riders careful. Riders live longer, stand in melee far less; damage per rider lost even v Brood, up v
  Clockwork and in the mirror. Game.stats cav_blows / cav_charged / cav_dmg / cav_pistol. Proposal: the Armoury and the
  charge earlier in the riding plans (drilled after 10:00 or never today).
- CLOCKWORK LAB REMOVED from the player (owner 2026-11-15 00:56): no EDITOR menu entry, no Settings EXPERIMENTAL switch (a saved "on" is ignored). Main.start_lab, scripts/cw_lab.gd and Settings.cw_lab stay for the test and picture tools (shot_*.gd, test_cw_*).
- CROWN DEFENCE AGAINST A PUSH (owner's game 2026-11-15 00:28, Hollowfen: Musketeers walked past the Clockwork's push on a
  plain move and died 4 for 0; job crown-coach-defence, 0.38.4, docs/crown-coach-defence.md, scripts/ai_crown_defence.gd,
  tools/test_crown_defence.gd, bench tools/crown_defence_bench.gd/.sh): the ALERT (a push seen coming: soldiers before
  labourers, no balloon party, boarding men called off, no wave out, a wave out comes home), NO WALK PAST THE ENEMY (a man
  sent to his post fights or steps round, hopeless away from his post he gets out), the MUSTER (a force at its buildings it
  can't beat: gather out of reach, fight as one). Switches defence:off, dfwarn:off, dfpath:off, dfmuster:off,
  dfsoldiers:behind. 16 games v Clockwork: home kills per loss 1.65 -> 2.77, buildings lost 126 -> 88, income -6.6%;
  7 Claude's choices in the doc.
- BRASS SERPENT (owner 2026-11-14 20:07-20:09, "Do it"; job brass-serpent, 0.38.0, docs/brass_serpent.md, scripts/brass_serpent.gd,
  Defs.SERPENT, tools/test_brass_serpent.gd, pictures docs/shots/brass_serpent/): a Clockwork snake of gears made at the
  Heavy Works; few/small gears = fast, light quick bites; many/big = tanky, slow, heavy bites; damage breaks tail gears
  (wrecks for the Great Winder); Winders repair up to its gears; the Heavy Works builds gears (store of 10): COLLECT GEARS
  or GROW (a Winder carries one out); own units on its body wind up, enemies slowed to 75%; LINK into a Hydra (max 3
  heads, 16 gears a head), UNLINK; OPTIMAL Clockwork computer uses it (switch serpent:off). 17 CLAUDE'S CHOICES for the
  owner in the doc. ART IN 0.38.3 (job serpent-art: tools/serpent/import_art.py, the owner's two ChatGPT sets in art/redraws/brass_serpent/,
  pictures docs/shots/brass_serpent/art/; choices 18-21 in the doc: side cogs don't turn, enamel takes the team colour, the N bite's open frame fudged, the joint facing N is S/SE flipped). Sounds: stand-ins (four serpent sounds to make).
- OVERLAY OPACITY (owner's playtest 2026-11-14 13:18; job overlay-alpha, docs/overlay_alpha.md, tools/test_overlay_alpha.gd,
  pictures docs/shots/overlay_alpha/): the bars, chevrons, band buff marks, stun stars and status marks over units and
  buildings are see-through (Entity.ov_a / ova: Settings.overlay_alpha, default 60%, marks x0.85, a band's "+8%" sqrt of
  that; selected and hovered units full; a hurt health bar stronger), slider OVERLAY OPACITY in Settings > DISPLAY
  (30-100%); guides (selection circles, rings, rally lines) kept. (REVERTED 2026-11-15 with the ground system: ) With NO FARM/PRESS LIMIT on the Town Hall / Clocktower
  texts say the district's soil / brass is the limit (Defs.nocap_text); a Farm / Cog Press away from every hall with the
  ground system on is refused with "No soil here: ..." (Game.NO_GROUND_MSG) and its districts' edges show clearer while
  placing (GroundView). New code drawing over units: take its alpha from ov_a.
- ELEVENLABS MUSIC IN THE GAME (owner 2026-11-14; job music-elevenlabs, docs/music_elevenlabs.md): the owner's 12 ElevenLabs
  pieces + the menu theme mastered (tools/music/master_elevenlabs.py: high-pass, sub-bass capped at 25%, -12.8 LUFS with
  at most 3 dB of peak limiting, -1 dBTP, no compression) into crown/clock/brood _battle_12..16 / _peace_8..10 and
  menu_11, one per role (open, skirmish, full battle, calm); Music.FEATURED picked 3x as often (WEIGHT), Crown of Ashes
  (menu_11) heard FIRST at the menu (MENU_FIRST). Flat by the numbers, remake candidates with prompts in the doc: the
  three Crown battle pieces (Dawn Over the Colony and the Clockmaker's Waltz were remade by the owner, merged 0.37.8). Credits in docs/audio_credits.md. Also: tools/voice_clone/refs/ has 5
  designed character voices; lines.txt "[ref refs/<name>_ref.wav]" switches voice (placeholder lines per character).
- MUSIC STUDY v CLASSICAL PIECES (owner, 2026-11-14: the book of 50 famous pieces; job music-study, docs/music_study_classical.md, charts and per-piece numbers in docs/music_study/, tools tools/music/study_*.py, NO game music changed): the game's 73 pieces measured from their notes and .ogg files against the reference table (docs/music_classical_refs.md). Found: 0% of notes outside the key (real ~12%), loudness range 6.9 LU (real ~12), climax at the last chord, 80% of bars repeat the bar before's rhythm, almost no counter-melodies, too much sub-bass in the battles; the chord speed is fine and the phrases are not too square (less regular than the real pieces); the sides are told apart (Crown most). A demo rewrite of The Queen Stirs in docs/music_study/demos/. OWNER DECISIONS WAITING: which proposals to build (mix pass first?), a loudness-range target (8-10 LU proposed), the Clockwork winding down at the end, the Brood's irregular phrases, the drum-bed marches.
- BAND'S OWN PIECES (owner 2026-11-14 21:47-22:12, "do it all"; 0.37.14, docs/band_music.md "The band's own pieces",
  tools/audio/band_own.py + band_produce.py): Claude's three melodies for the full band by what it does (BandSound.MAIN):
  marching The Pipe Calls (pipes call, fife answers), fighting The Drums Lead, at rest The Fife Calls (sad lament, fife
  leads); the real recordings in turn between; the lone Piper's 4 tunes re-rendered the same way. The owner rejected
  ElevenLabs' "A Highland March" (fife inaudible); his ElevenLabs credits are nearly spent (~266). Production lessons:
  stereo, a section per part, low-mid body, a room (mono/one-player/dry was what sounded "off").
- BAND MUSIC V2 (owner 2026-11-14 09:57-09:58; job band-music-v2, 0.37.4, branch band-music-v2, docs/band_music.md): Scotland
  the Brave note for note from the owner's reference score (not in the repo), 110 (109.91, whole drone cycles), in E; the
  game music ducks -12 dB under a centred band, -16 under a solo, 10 dB/s (BandSound.duck_for). Merge on its DONE.
- BAND REPERTOIRE (owner's playtest 2026-11-14 13:18; job band-repertoire, branch band-repertoire, docs/band_music.md
  "Repertoire and playlist"): a PLAYLIST, not one loop: The British Grenadiers (2/4, 100, in A), Scotland the Brave,
  Garry Owen (6/8, 118, F# dorian), The Minstrel Boy (slow air, 70, G) in turn, each file [roll-off][tune][tail]
  (assets/audio/band/<tune>_<part>[_lead].ogg, BandSound.TUNES/ORDER); fighting skips the air (cut at a phrase end),
  idle 30 s brings it; never twice in a row; lone musicians keep their own playlists (out of step). Files levelled by
  LUFS (the Drummer was 11 LU under the Piper: now the three within 3 LU; tools/audio/band_balance.py); a lone Drummer
  plays a background beating; a SOLO keeps the tune (his part forward, the music -16 dB). Our own drum beatings in the
  Twin City Fife and Drum Corps' style (their sheets NOT in the repo). God Save the King rendered, not used (owner's
  call: a Crown victory?). The web art pack grows ~8 MB. Merge on its DONE.
- MERGED 2026-11-14 05:00-06:30: late-game-sound 0.36.3 (docs/late_game_sound.md: a voice pool, a bigger web sound buffer), cinder-crown-ai 0.36.4 (docs/cinder_crown_ai.md: the Timing attack v the Clockwork lays its 2nd hall behind the army, attacks only while ahead or calls it off at 6:40, labourers keep coming; no GREEDY read of an empty Clockwork base before 2:30; the Crown still loses the matchup), cinder-clockwork-ai 0.36.5 (docs/cinder_clockwork_ai.md: scouts/sentries flee workers coming for them; gun rush v a thin guard; a winning push v the Crown finishes; v Crown W-D-L 5-12-0 -> 8-9-0; OPEN: it rushes 6 guards up a ramp because it sees only part of them), reload-command 0.36.6 (docs/reload_command.md: RELOAD, key R, to the nearest powder that can fill and back; Shift queues). Flaky after: test_clockwork_owls, test_clockwork_sounds, test_ai_optimal, test_cinder_crown [hall]/[labs] (pass on rerun); test_cw_ai/heavy/militia/tier3/tier3_ai and test_crown_mirror fail before these merges too.
- MERGED 2026-11-14: brood-rush-coach 0.36.1 (docs/brood_rush_coach.md: the Brood wave keeps at the wall v riders, the rebuild after a rush fills empty Rootmaw posts first; 10 Raptors lose to 2 Horsemen by the NUMBERS (two sabre blows kill a 36-hp Raptor); BALANCE PROPOSAL waiting: Raptor hp 36 -> 38), replay-render 0.36.2 (docs/replay_render.md: paused/jumped replays pose every unit; the owner's "unrendered" Raptors were drawn: seen from behind on olive moss, an art question). Flaky after: test_ai_expand [clockwork], test_ai_harass [raid] (pass alone); test_brood_v_riders, test_ai_worker_safety fail with the job's changes off too.
- VOICES FOR THE CAMPAIGN (owner, 2026-11-14 02:55: Chatterbox results "very impressive"): new lines in the King's voice are made on the owner's PC with tools/voice_clone/ (Chatterbox, MIT; his RTX 3060, Python 3.11 venv; run.bat, lines.txt "name | text", --pitch -1.5 deeper, --lang pt/es; references king_ref.wav / king_ref_b.wav from his ElevenLabs King). ElevenLabs only to DESIGN a new character's voice (a 10-20 s sample), then Chatterbox for all its lines. Voice rights: only designed voices, his own or consenting people's, or CC0/CC-BY datasets; never a real famous person's.
- RANKED ONLINE, PROTOTYPE (owner, DECIDED 2026-11-13 01:04; job online-ranked, 0.34.0, docs/online_ranked.md): our
  server runs every ranked match (tools/server/match_server.gd, headless, both players guests via the relay with signed
  tickets: LadderTicket), Steam players only (SteamID64 = account; Identity: Steam via GodotSteam, not in the repo, or a
  DEV sign-in for tests), the ladder service tools/ladder/ (Node + SQLite: queue, Glicko-2, placement 5, seasons, bans,
  reports, admin.mjs), RANKED / queue / LEADERBOARD in ui/ranked_menu.gd. Snapshots are cut PER SIDE (NetView; keyframes
  no longer send unseen enemies, friendly online too). Tests: tools/test_ranked.sh, tools/test_net_fog.gd. Not live: the
  owner's steps are in the doc.
- CROWN: FOUNDRY BEFORE THE SECOND BARRACKS, ALWAYS (owner, DECIDED 2026-11-03 22:33), in every plan and matchup (the Horseman
  rush is done with 1 Barracks). The Horse Breeder comes either way (cannons need horses). Canister hits flyers, round shot
  has the longest range (430). Riders are an addition when the scout sees drops/leaps, enemy artillery, a greedy enemy or
  for map control. Apply it to crown-builds-a/b/c's plans at merge. POSSIBLE EXCEPTION, UNDECIDED (owner, 22:36): the
  Dragoon raids might go 2 Barracks before the Foundry, but only when scouted and for a reason, as an answer to something.
  CONFIRMED (owner, 2026-11-04 20:50, asked after his own game went 2 Barracks first): "it depends, but most of the time
  Foundry first is the best option": Foundry first stays the default; a second Barracks first only for a scouted reason.
- FULL QA STUDY (owner, 2026-11-07 23:20: "an overall study and complete systematic test of the game"): five cloud jobs,
  each on its own branch, merge on "DONE: <job>:": qa-tests (run all ~244 tools/test_*.gd, fix/refresh, list untested
  areas), qa-content (tools/test_content_all.gd: every unit/building/ability/research of every faction), qa-matches (Hard v
  Hard, all 9 matchups incl. mirrors, every map, 15:00), qa-ui (every screen, 3 languages, desktop + phone sizes, tutorial,
  campaign, editor, save/load, replays, online loopback, web), qa-perf (tick/draw/memory on every map, big battles).
  Reports docs/qa_2026_11_08_<area>.md. ALL MERGED 2026-11-08: qa-content 0.33.8, qa-perf 0.33.9, qa-ui 0.33.10,
  qa-tests 0.33.11, qa-matches and brood-nerf-study (data/tools). OWNER DECISIONS WAITING: the cannon/mortar double
  building bonus on a right-click (qa_content item 3); ATTACK on unarmed cards; the Clockwork's harass and Great Winder
  sweep under ONE ARMY; draws (dead sides should lose, winners hunt); the P1 start-spot edge (44-25).
  OWNER 2026-11-11 04:55 "ok do it" (Claude's picks, say so if wrong): the bonus applied ONCE but RAISED to keep today's
  siege punch; ATTACK hidden on unarmed cards; a side with no workers/army/means for 60 s is BEATEN and the winner hunts;
  ONE ARMY gets exceptions (harass groups, the Great Winder sweeps). MERGED 2026-11-11: rules-fixes 0.33.12, rebel-art
  0.33.13 (docs/rebel_art.md, redraw prompts inside), crown-ai-v2 0.33.14, clockwork-ai-v2 0.33.15, start-spots (study:
  docs/start_spots_study.md; its fixes WAIT for the owner: mirror the start units exactly, one base anchor (hall centre)
  for the computers, then study again). Then the KING'S STUDY hub 0.33.16 (docs/campaign_hub_art.md).
  OWNER 2026-11-11 22:28: YES to the start-spot fixes (job start-spots-fix: mirror the start units, hall-centre anchor,
  rerun the study) and a COACHED, FILMED Crown v Brood job (crown-v-brood-coach: "crown can beat brood, it's crown AI
  that is bad"; Crown AI play only, no Brood balance change). Merge each on "DONE: <job>:".
  OWNER 22:35: EVERY matchup coached and filmed with the same scrutiny: jobs crown-v-crown-coach, crown-v-clockwork-coach,
  clockwork-v-brood-coach, clockwork-v-clockwork-coach, brood-v-brood-coach (docs/<job>.md each). Six AI jobs at once:
  fixes kept small and gated by matchup; merge them one at a time and rerun the AI tests after each.
  MERGED 2026-11-12: crown-v-crown-coach 0.33.17 (all gated to the mirror, AICrownMirror; Claude's choice 1: open its
  fixes to the Crown's other matchups after a measured batch), crown-v-clockwork-coach 0.33.18 (the Clockwork now wins
  10 of 16; OWNER QUESTIONS in its doc: the Crown earns less per worker than the Clockwork, 34 v 57 a minute at 10:00;
  a Crown march with a formed line and guns is the next job; the Clockwork's fixes kept though they hurt the Crown).
  Then crown-v-brood-coach 0.33.19 (docs/crown_v_brood_coach.md; Crown W-D-L v Brood 0-14-26 -> 1-18-21; BALANCE PROPOSAL
  waiting: Cottage 10 supply or the hall training 2 labourers at once; the GREEDY read of every Brood), clockwork-v-brood-
  coach 0.33.20 (Clockwork won or led 6 -> 9 of 16), clockwork-v-clockwork-coach 0.33.21 (a side clearly ahead wins 11
  of 13, was 8 of 15), brood-v-brood-coach 0.33.22 (income at 8:00 5,546 -> 9,606; the Raptor no longer read as a rider
  in the mirror), start-spots-fix 0.33.23 (docs/start_spots_fix.md: no spot edge left except the Brood mirror 26-13-1, p
  0.05; proposals there). test_ai_brood's stage-3 timing is flaky; test_brood_new_defence's rooted-muskets case fails on
  main too. ALL SEVEN JOBS MERGED 2026-11-12.
  OWNER 2026-11-12 07:59: the Crown computer never uses the player's DRAG-A-LINE (no AI calls Game.line_move): a line of
  Musketeers with the cannons behind it. Job crown-line-fight (coached, filmed; docs/crown_line_fight.md): the line at
  every position and before contact, guns unlimbered behind it, the march as a formed body; merge on its DONE.
  OWNER 08:03: PAIR IT WITH HORSEMEN SCOUTING IN FRONT: queued as job crown-rider-screen, to start once crown-line-fight
  merges (riders ahead and on the flanks of the marching line, find the enemy before the line walks in, pull back behind
  the line at contact, catch fleeing/harassing units; a forward picket at defended positions).
  MERGED crown-line-fight 0.33.24 (2026-11-12; scripts/ai_crown_line.gd, docs/crown_line_fight.md, switch line:off):
  waves form the player's drag-a-line before a known enemy, a gate or a halt, guns 2.6 tiles behind; v Clockwork fights
  1.67 killed per 1 lost (was 1.36); results by 12:00 unchanged; most fights still start unformed (the enemy first seen at
  contact) -> crown-rider-screen started. 9 Claude's choices for the owner in its doc. test_crown_hold's [below] labourer
  check is flaky too.
  MERGED crown-rider-screen 0.33.25 (2026-11-12; scripts/ai_crown_screen.gd, docs/crown_rider_screen.md, switch
  screen:off): 2-4 Horsemen ahead/flanks of a marching wave, the line forms on their sightings (from 8% of the wave),
  flank work at contact, a picket forward at home; 9 of 291 riders lost; fights begun formed: mirror 42% (was 22%), v
  Clockwork 36% (was 28%); trades and results unchanged within noise. Still wrong: v the Clockwork most fights are at its
  bases where units come out at a few seconds' notice; after a won fight the line marches on as a crowd. 8 choices in its
  doc.
  OWNER 2026-11-12 20:47: WIN RATES IN ALL MATCHUPS, coached: study jobs winrate-a (Crown v Brood, Crown v Clockwork),
  winrate-b (Clockwork v Brood, Crown mirror), winrate-c (Clockwork and Brood mirrors): the 0.33.7 qa-matches design (19
  maps x 2 seeds, 15:00), 2 filmed games per pairing with coach's notes and proposals (no code changes); combine into
  docs/winrate_2026_11_12.md. MERGED 2026-11-13 (docs/winrate_2026_11_12.md has the table and the proposals, none
  applied): the Crown computer 0 wins in 76 (v Brood 0-11-27, v Clockwork 0-30-8; its blind Horseman rush v every Brood
  read as GREEDY fails 33 of 38); Clockwork v Brood now even (11-15-12); Clockwork mirror ends (20 decided, was 0); Crown
  mirror 35 of 38 draws; Brood mirror leans to spot A on the named maps, Clockwork v Brood to spot A on the classic maps.
  OWNER 2026-11-12 21:04: ALL ECONOMIES ABOUT EQUAL PER MINUTE, by NERFING the Clockwork and Brood (not buffing the
  Crown), a slower game; asked which RTS the pace resembles. Job economy-parity (branch, docs/economy_parity.md): a
  scripted bench, proposed nerfs applied ON THE BRANCH ONLY, games, the pace compared; DO NOT MERGE until the owner OKs.
  RESULT (docs/economy_parity.md, bench on main, its balance numbers still only on the branch): by DESIGN the economies
  are close (Clockwork 1.02-1.06 of the Crown, Brood 0.75-1.00); the COMPUTERS reach Crown ~55%, Brood ~60%, Clockwork
  72-91% of their bench. OWNER 2026-11-13 01:18: COACH THE COMPUTERS TO ~100% OF THEIR ECONOMY BEFORE ANY BALANCE
  CHANGE ("so we have a complete picture and then make decisions"): jobs econ-coach-crown, econ-coach-clockwork,
  econ-coach-brood (AI only, no numbers; docs/econ-coach-<faction>.md); merge one at a time on DONE. Pace now: Warcraft III
  with a StarCraft II opening. Also running: online-ranked (OWNER 01:04: SERVER-AUTHORITATIVE ranked matches, Steam-only
  ladder, bans by SteamID64 + optional Steam game ban; prototype + docs/online_ranked.md). Main menu painting: hallucination
  fixes by crop repaints (art/menu_fix/, tools/menu_fix_composite.py): gunner and horseman done 0.33.31, the Clockwork
  front and the Brood Mother DONE 0.33.32 (one repaint of the right side, art/menu_fix/f34_right_fixed.png, a stray sword inpainted).
  RANKED ONLINE MERGED 0.34.0 (2026-11-13; docs/online_ranked.md): SERVER-AUTHORITATIVE ranked 1v1 (a headless match
  host, tools/server/match_server.gd; both players guests), keyframes fog-filtered per side (friendly online too), Steam
  identity (scripts/net/identity.gd; GodotSteam only in the Steam build; DEV sign-in for tests), the ladder service
  (tools/ladder/: queue, Glicko-2, seasons, bans by SteamID64 + optional Steam game ban, refused-order logs, admin CLI),
  RANKED page, queue, results, leaderboard. Capacity ~3-4 matches a core, ~0.8 GB each; Oracle Always Free ARM to start.
  Owner's steps to go live in the doc. Tests: tools/test_ranked.sh, test_net_fog.gd, test_online.sh (coop's
  guest_ground_attack_hits_body fails on main too).
  ECON COACHING MERGED 2026-11-13: econ-coach-clockwork 0.34.1 (alone 0.75 -> 1.20 of the bench at 15:00, games 0.66 -> 0.90,
  results within noise; docs/econ-coach-clockwork.md), econ-coach-crown 0.34.2 (spent Farms pulled down when they block a
  fresh hall, free Farm posts first; Economy plan alone reaches the bench by 10:00; in games the gap is the plans OPTIMAL
  picks; docs/econ-coach-crown.md), econ-coach-brood 0.34.3 (games 0.66/0.79/0.76 -> 0.70/0.84/0.81 of the bench at 5/8/10 min;
  v the Clockwork +25% income at 8:00, wins or leads 4 -> 7 of 12; its alone tool is tools/econ_ai_alone_brood.gd;
  docs/econ-coach-brood.md). ALL THREE MERGED; the AI and Brood tests all pass after it. GROUND SYSTEM (REVERTED by the owner 2026-11-15 10:24, eco-revert-prologue 0.38.12) MERGED 0.35.0
  (2026-11-13; docs/ground_system.md, scripts/ground_layer.gd, ground_view.gd, tools/test_ground_system.gd): Settings
  EXPERIMENTAL > GROUND SYSTEM, OFF by default; soil/brass in a district per hall, a 10-tile circle per Farm/Cog Press,
  the "2 a hall" limit made LOCAL with spent ones not counting; bench within 5% of off; 70 ground/AI/faction tests pass.
  OWNER CHOICES WAITING (its doc): keep the local limit or drop it (MEASURED 2026-11-14, job ground-nocap-study 0.36.1,
  docs/ground_nocap_study.md: switch NO FARM/PRESS LIMIT, off; a big Clockwork buff, no turtling; recommends keeping it), saltpetre on the map too, the radii, when to default on. Flaky/stale after the merges: test_ai_cw_horse_raid
  (different check each run), test_ai_scout_sentry (passes alone), test_ai_rush / _rush_followup (Crown v Brood, known),
  test_crown_dragoon_raid's [plan] check (fails before the Crown merge too).
  OWNER 2026-11-13 08:03 on the coaching's questions: (1) spent Farms/Presses counting against the limit: WAIT FOR THE
  GROUND SYSTEM; (2) Crown OPTIMAL v a greedy Clockwork, Timing or Economy race: decide ON DATA (study job
  crown-v-cw-plan-study, greedyclock:economy/balanced v default, docs/crown_v_cw_plan_study.md, recommendation only);
  (3) the 200 SUPPLY CAP STAYS: with every expansion taken the late game is about taking better fights and remaking
  armies; NO cog/gold sink.
  GROUND SYSTEM (REVERTED by the owner 2026-11-15 10:24; was DECIDED 2026-11-13 01:34-01:40; docs/ground_system.md, now in git history): every economy building drinks from a
  CIRCLE of ground like the Rootmaw; spent ground shown RED while placing; overlap with spent ground gives a proportional
  yield; ground exists only in a DISTRICT PER HALL (fixed amount each); the layer shows FAINTLY while placing ANY building
  (owner 01:37: placement strategy), the economy building being placed its own circle stronger. Build it AFTER the three econ-coach jobs merge, as a
  Settings experiment, benched and with the computers coached on it. (Why: today's Farm limit counts spent Farms empire-wide,
  so a fresh hall can stand farmless; the owner: tearing a Farm down never renews the soil.)
  ART 2026-11-12/13: the Clockwork and Brood campaign hubs (hubs-cw-brood 0.33.26: Hollweg's workshop, Lindqvist's
  station), the Clock Soldier's 8-way walk and the Raptor's S/N run (walks-raptor-clock 0.33.27), the rebels' back
  views, Varenne's calm idles, the pikeman's S/SE pike (rebel-art-2 0.33.28), the Raptor's SE (Claude's composite of two
  sheets) and NE run (0.33.29): no code legs left in the Raptor's run.
- CROWN HOLDS ITS WALLED NATURAL (owner's playtest 2026-11-06, Dune Sea; job crown-hold, 0.33.1, docs/crown_hold.md): the
  natural's GATE on the palisade stretch nearest the main's ramp foot (AIExpandWall._gate_by_ramp); once that wall is 70%
  closed with its gate up the army's HOME post is DOWN at the gate (AICrownHold section 7, the gate post; ramp post = main
  alone, cliff edge = no walled natural); SITES KEEP CLEAR for everyone (Game.site_keepout, step_aside keeps HOLD, the
  computer avoids a blocked spot 90 s); 3 Field Cannons before any Mortar in every Crown plan (AI.CANNONS_FIRST).
- AI FOLLOW-UPS (owner's Crown OPTIMAL v Clockwork game 2026-11-06; job ai-followups, 0.33.3, docs/ai_followups.md): the
  Crown puts its ARMY FIRST when far behind the enemy's (AICrown.army_lags: 60% of foe_reckon, 90% after a GREEDY read;
  labourers and tech wait, the natural's wall keeps a few coins); no cliff edge above a walled natural (the gate post at
  half the wall); the Clockwork's push does not chase fast riders (riders_only, march leash, chase cap) and only a real
  attack or a hall/Mainspring about to fall calls it home; a defence gives up a chase 520 px out. Open: the Crown's
  economy (55-75% of the Clockwork's by 8:00; crown-optimal-opening's Barracks-first opening), the late natural wall.
- CROWN AMMUNITION, NO POWDER LOCK (owner, DECIDED 2026-11-05 07:48-07:54; job crown-ammo): Barracks units have NO
  building requirement any more (the Musketeer no longer needs the Powder Mill; the Officer no longer needs the Horse
  Breeder; an Officer without a horse walks). Every unit with a firearm costs POWDER for its ammunition, the Officer too
  (pistol): trained with powder in the bank it comes out armed; trained with gold only it comes out with ZERO shots and
  fights with its melee weapon (bayonet, sabre) until it refills at a reloading point (Mill, Barracks, Town Hall, Powder
  Wagon), the refill taking that powder from the bank. A Barracks toggle ARM WITH POWDER (default ON). PARTIAL ammo when
  the bank holds less than a full load. The gold-only rush is allowed (it is the Horseman rush: the Horse Breeder costs only
  gold). MOUNTED and LIMBERED units keep the Horse Breeder requirement; a Horseman with no horse is an Officer.
- AI PLANS: ADAPTIVE + OPTIMAL (owner, DECIDED 2026-11-05 09:54; job ai-optimal): a scout report is information even
  when it sees nothing (GREEDY / NORMAL / AGGRESSIVE / DEFENSIVE / UNKNOWN). EVERY plan adapts to some point (survival:
  a seen rush is defended; obvious answers) but keeps its identity so the owner can train against / watch each strategy
  (Economy still races v a greedy enemy). NEW plan OPTIMAL per faction: a common opening, an early scout, then it picks
  from ALL the faction's builds by the read, matchup and map (v greedy punish or out-expand; v aggressive defend then
  counter; v defensive out-expand, tech, siege); switches at most once a stage. Horseman rush: good v the Brood, somewhat
  v the Clockwork, NOT v the Crown. Also an audit of every AI STORY line (and the logic behind wrong ones).
- CROWN OPTIMAL OPENING (owner, DECIDED 2026-11-06 09:17; job crown-optimal-opening): the ramp Cottage, the Gate, the
  BARRACKS (rush unknown), then the second FARM; NO Powder Mill before the scout's read. CHANGED (owner DECIDED 2026-11-16
  08:01, measured 5 pairs: income at 5:00 up in all): the second FARM right after the Gate, then the Barracks (a seen rush
  still puts the Barracks first); AICrownCoach.farm_first, switch farmfirst:off (on the crown-coach-1116 branch until it merges). After the read: POWDER MILL
  (Musketeer play) or HORSE BREEDER (riders); v a GREEDY Brood the Horse Breeder to punish (not the Siege push). Also running:
  job crown-hold (2026-11-06 07:55): the natural's gate toward the ramp, the army posted at the natural's palisade, units
  clear building footprints, 3-4 Field Cannons before the first Mortar.
- EXPANSION SPOTS PER FACTION (owner, DECIDED 2026-11-03 22:25): each faction has its own optimal expansion spot (the Brood
  already does: Mound Turtle spots). CROWN: 2nd and 3rd bases at the MINIMUM hall distance (Defs.HALL_SPACING 18) and close
  together, covered by the main's high ground (Musketeer range from its edge) and easy to wall (walls join up); 4th base on:
  the same, as close as possible to its other halls, without the main's high ground. Being built by the local job
  crown-cliff-edge (with: Musketeers at the cliff edge above a threatened building, repairers that juke, Foundry/cannon
  before the Horse Breeder once the Brood is scouted). REDONE (owner, 2026-11-04 07:05; job crown-spots-v2, 0.29.5): the
  2nd base where the old natural was but pulled in to 18 tiles, as near the ramp's foot and the map's border as may be;
  the 3rd its MIRROR on the other side of the main's ramp, same aims ("I don't know why you left the second expansion so
  far out"); the cliff cover is only a tie-breaker now (docs/expansion_spots.md "The Crown's rule").
- STATIC DEFENCE IS NOT A BUILD (owner, 2026-11-03 21:45): "Good base design should be for all builds. Static defense
  isn't a good strategy on its own: it is either a desperate attempt to hold a rush or a later security against harass so
  you can concentrate your army." So cw-builds-a's TURRET TURTLE plan is NOT to be merged as a strategy: at merge, take its
  good base layout (production behind the hall, Regulators/buildings toward the ramp) as a SHARED rule for every Clockwork
  plan, and turrets only REACTIVE: an emergency vs a scouted/arriving rush, and later at expansions/worker lines against
  harass so the army can leave home. The fast second Clocktower part may become the Clockwork's Economy plan.
- COACHED BUILDS, "do it all" (owner, 2026-11-03 20:32): ALL MERGED: brood-ai-tune 0.29.5, cw-builds-a 0.29.6 (Clock
  Soldier rush; Turret turtle kept but hidden), cw-builds-b 0.29.7 (Pendulums, Heavy Works push), cw-builds-c 0.29.8 (Owl
  raids), crown-builds-a 0.29.9 (Dragoon raids), crown-builds-b 0.29.11 (Siege push), crown-builds-c 0.29.14 (Balloon
  harass); the Crown plans keep the Foundry before the second Barracks. RUNNING: cloud job brood-builds (Spitter timing,
  Brute siege; merge on "DONE: brood-builds:"). Later: the computer picks its build by matchup and switches on what its
  scout sees. Brood FOOD_BONUS: SLIGHT NERF 1.5 -> 1.2 in 0.33.6 (owner 2026-11-07 00:43: "nerf the Brood's economy, but just slightly, not a harsh nerf"; far Rootmaws pay x2.2, was x2.5). Earlier: 1.5 -> 0.8 proposed (it out-earns both Hard computers 1.4-2x): NOT YET (owner, 2026-11-04 15:05: "the
  Crown AI is still too stupid to make that judgement"; maybe the Balloon harass is just bad v the Brood; the Horseman rush
  is extremely effective v the Brood Economy). Proposals waiting on the owner:
  Springer: jump recharge 10 -> 6-7 s, range 5 -> 6-7 tiles, Springer range 170 -> 190, High Leap 100 -> 50 Tension; the
  build reports' own proposals (docs/clockwork_builds_*.md, docs/crown_builds_*.md).

- MIXED REPLAYS built by the cloud job replay-mixed (0.29.5, docs/replay_mixed.md): Settings REPLAY RECORDING MIXED
  (default on phones; FULL stays the computers' default): commands (Game.net_forward/net_set -> ReplayRecorder.note_cmd),
  the computers' decisions as order/queue diffs twice a second (no AI runs in playback), a SaveGame keyframe every
  10 s; ReplayMix plays the real game from the keyframes and corrects in place; format 3 (T_KEY, T_CMDS).
- REPLAYS, NEXT (owner said yes, 2026-11-03): after the perf-stutter job reports, a job for MIXED replays: record the
  players' commands (StarCraft-style) plus one full keyframe every ~10 s instead of 5 pictures a second; playback re-runs
  the commands between keyframes and each keyframe corrects drift (determinism a bonus, not a must). The quick Settings
  option REPLAY RECORDING (FULL / LIGHT / OFF, LIGHT default on phones) is the job replay-rate. Also pending after
  perf-stutter: an Android follow-up if it only measured the computer (the owner's slowdowns were on the APK, growing
  late in the game, not at the start).

- TUTORIAL (owner, 2026-11-04: "a TUTORIAL button and a CAMPAIGN button"), 0.30.0 (branch tutorial, docs/tutorial.md):
  TUTORIAL beside CAMPAIGN (menu grid 4 x 3); lessons on the mission engine (campaign/tutorial.json, campaign/missions/
  t*.json with "steps"; Tutorial, TutorialMenu; tutorial conditions and the `point` action in MissionRun; the pointer in
  MissionUi): Basics, the Crown, the Clockwork, the Brood, and an Easy practice game per faction. tools/test_tutorial.gd
  plays every lesson; texts in tools/i18n/campaign/tutorial.txt.

- CAMPAIGN ENGINE (owner, 2026-11-03), 0.30.0 (branch campaign-engine, docs/campaign_engine.md): data in campaign/
  (campaign.json: storylines with hubs, hotspots, talks; missions/<id>.json; maps/ = map editor maps, id "campaign:<name>"),
  scripts/campaign/ (Campaign, MissionRun = game.mission, MissionUi, CampaignMenu, StillView), texts in
  tools/i18n/campaign/, tools/test_campaign.gd. One placeholder mission (p01_revolt: the Crown puts down a revolt; the
  story is being written with the owner). Open: a real two-device online run of CO-OP / VERSUS, saving a mission, art.
- CAMPAIGN STORY (owner, 2026-11-04; the lines below are his decisions and ideas, in order):
  - CAMPAIGN STRUCTURE (owner, DECIDED 2026-11-04 09:41): ONE story spine merging all options: every battle playable from
  both sides (solo pick a side, co-op same side, versus = the other side of the same mission), choices carry forward as
  consequences (start forces, allies, units, heroes alive/dead; a lost battle returns as a reclaim mission), hub remembers,
  branches split and rejoin (diamond), real splits only at the endings; a canon timeline kept for the writers. The two
  storylines (Brood: explorer v scientists; Clockwork: clockmaker v priest) CROSS 3 TIMES: beginning, middle, end.
  - CAMPAIGN STRUCTURE PLAN (owner, DECIDED 2026-11-11 05:49; docs/campaign_structure.md): acts in time order AND
  braided storylines AND a global war map (three-way in Act 3); listeners come and go; the finale is in the present and
  the heir puts the King's lessons into practice; crossings = Church council in Rome, Brazil between Brood and Clockwork,
  the global war (Clockwork and Brood also fight each other); solo/co-op/co-op versus all supported; 2 endings + minor
  variations; 3 hubs (one per faction); no naval in the engine; medium to large; Act 1's choice = spare or execute
  Varenne. HUBS (06:03): layered painting rooms (motion in code) + the war map as each hub's table, different per
  faction. VOICES: ElevenLabs is out; free options offered, undecided.
  - CAMPAIGN FRAME (owner, idea 2026-11-04 09:50): the story is FLASHBACKS. Present: total global war; the Crown (a
  world empire, capital ROME, colonies round the globe, once unchecked) barely holds its key colonies and capitals. The
  campaign follows the fall from hegemony: heretical, rebellious uprisings (themed on the French Revolution) crushed by
  the Church Inquisition and the Crown Armed Forces, then the Clockwork and Brood problems pile up and the Crown loses
  ground, up to the present war.
  - CAMPAIGN NARRATOR (owner, DECIDED 2026-11-04 09:55): the KING is the main narrator (the frame, in the present); each
  part/mission has its own narrator from that side's perspective (the explorer, the scientist, the clockmaker, the priest...).
  - CAMPAIGN TONE (owner, DECIDED 2026-11-04 09:59): the game is Catholic and monarchist; the Crown and the Church are
  objectively the good guys, no subverting expectations. The King narrates truthfully (no unreliable-King twist); the
  other sides' narrators may be mistaken or deceived, the Crown's are not.
  - CAMPAIGN YEAR is about 2767 (owner 2026-11-04, not 2500). A global story.
  - MISSION 1 (owner, 2026-11-04 10:26): a TOBACCO PLANTATION in the American colony attacked by heretical rebels (against
  Church and Crown; they want freedom and secularism). Witness: the missionary PRIEST, then a young seminarian, watches the
  colony's lord put the unrest down with swift, extreme violence (canister into the mob). Play: train and defend the
  plantation with Musketeer lines and cannon, push the rebels back to the province stronghold they took, blast them with
  canister. The King smokes a pipe; other characters smoke cigars and pipes and shudder at rebels destroying the precious leaf.
  - MISSION 1 settled (owner 10:53): VIRGINIA (Brazil saved for another mission); names Claude's choice, European from all
  over (proposed: King Constantine IV in Rome; Lord Edmund Fairleigh, Governor of Virginia; seminarian Tomasz Wierzbicki,
  later the missionary priest; Captain Matteo Ruggieri of the guns; rebel leader Etienne Varenne of the Free Assembly,
  green and black). The REBELS are a minor non-playable faction with their own units and art. OPENING = oil-painting
  STILLS (5+), the first being the King lighting his pipe, which is also the main menu picture.
  - MISSION 1 SCRIPT APPROVED (owner, 2026-11-04 20:50): docs/campaign_mission1.md (the King's lines, three parts, the
  families choice, the canister ending). Being built by the cloud job campaign-m1 with stand-in rebels until the owner's
  ChatGPT rebel art arrives; the King's voice to be recorded by the owner in ElevenLabs.
  OWNER 2026-11-04 21:45: the skeleton is fine but the DIALOGUE has many AI tells: he will rewrite it himself in detail
  later (treat all mission texts as placeholders; hold the other characters' recordings). OPEN: who the King is talking
  to (who the player is: a new general? the King's son?), and the handover to Tomasz needs its own still (Tomasz with the
  King, not the King alone).
  - MISSION 1 BUILT (cloud job campaign-m1, 0.31.0; docs/campaign_m1_build.md): p01_leaf is the Prologue (p01_revolt
  kept only as the engine's test bed); map campaign:virginia_leaf; stills in campaign/stills/; the Free Assembly's roles
  in scripts/campaign/rebels.gd (art drops in via RebelArt.ART); the Pikeman back as a campaign-only unit; the engine
  gained opening/ending shows, choices and flags (Campaign.flag), light (night/dawn), voice files
  (campaign/voice/p01/<line>.ogg, list in docs/campaign_mission1_voice.md); tools/test_campaign_m1.gd.
  - FACTION COLOURS (owner, DECIDED 2026-11-04 12:06): CROWN PURPLE, CLOCKWORK RED (and brass), BROOD GREEN (venom green);
  UiStyle.ACCENT follows (0.29.12); the menu painting's Brood (red spines) to be made green by ChatGPT.
  - CROWN COLOUR IS PURPLE (owner, 2026-11-04 11:35): the Crown's standard colour changes to purple (stills done in purple;
  main menu painting assets/menu/battle.jpg to be redone by ChatGPT, the Crown was blue there). The mission 1 stills are in
  art/campaign/stills/p01_01..06 (move into campaign/ when wired in) (king pipe = also a main menu candidate).
- MARCHING BAND AS A REAL UNIT (owner, 2026-11-05 12:18; experiment since 0.23.0, docs/marching_band.md): BAGPIPES melee,
  DRUMS movement speed, FIFE ranged (Claude: as reload speed); always +5%, a SOLO +30%, each solo its own cooldown (no
  energy); both band and Armoury may buff (tune later). Trained at the ARMOURY, which also researches the musicians: the band
  starts with the Drummer, then Fifer and Piper in any order. Art: a group that grows (drawn as three musicians placed
  together in code); ChatGPT prompts for the SE marching cycles given, refs in docs/redraw_refs/band/. Also: the Mist Toad's
  FOG and MIASMA to be locked behind research (at the Dilophosaurus; TONGUE free). DECIDED (owner 13:35): ONE SOLO AT A TIME
  per band; SEVERAL BANDS allowed (like cannons; rings don't stack: each stat takes the strongest); each band costs MORE per
  researched musician. The owner's SE art is in art/redraws/band_{drummer,fifer,fifer_b,piper}_walk_se_chatgpt.png (two
  fifer options). BUILT by the cloud job marching-band (0.33.0, branch marching-band, docs/marching_band.md: Armoury, research
  musicians, several bands, fifer art option B, Toad FOG/MIASMA research); MERGE IT WITH A SQUASH (the branch carries an
  old rewritten history by an "ours" merge); open questions in its doc.
  INDIVIDUAL MUSICIANS (owner, DECIDED 2026-11-14 02:01-02:08; job band-individuals, 0.37.0, docs/band_individuals.md):
  NO band unit; the Drummer ("band"), Fifer and Piper are units trained at the Armoury, each with his own ring, +5%, solo
  and cooldown; one of each standing within each other's rings FORM A BAND (+8%, solos +40% 10 s, in step, a row);
  lone musicians of different instruments overlapping are OUT OF STEP (only the stronger buff); the same instrument
  never adds up; SOLO = one, Ctrl+SOLO = all; buff markers over soldiers (Settings BAND BUFF MARKS); the Fife costs no
  powder; BandSound: the nearest band in step or up to 3 lone musicians out of step (files untouched).
- MAP VARIETY (owner, DECIDED 2026-11-04 15:50): no single map rule; a pool with variety (some POCKET naturals sharing
  the main's choke, some open naturals, some between; mains hugging the corner is the milder option). He weighed turning
  every ramp toward a corner pocket and rejected it as a global rule (one point of defence = Crown turtling too strong).
  QUEUED after crown-v-brood merges: make a pocket variant of a classic map (e.g. Greenhold, ramp toward the corner) in
  the map editor and run the computer study on it v the normal map: ALL matchups incl. the MIRRORS (Crown v Crown,
  Brood v Brood, Clockwork v Clockwork) and the Clockwork's (owner: "testing is overall a good practice"): win rates,
  game length, halls lost. The corner-pocket natural A/B test is part of crown-v-brood (item 6).
- IDEA BUCKET: the Clockwork tempo/beat (commands in a beat window, sync bonuses), owner 2026-11-04: "leave it in the idea
  bucket". TO DO LATER: translate every announcer line (Crown herald, Brood scientist) into pt/es voices.

- EXHAUSTED MEANS EXHAUSTED (owner, 2026-10-30), 0.24.0 (branch exhaust-economy, docs/exhaust_economy.md): no trickle for
  anyone; spent soil/brass/ground pay 0; powder and Tension fall with their reserve to a FLOOR (Defs.POWDER_FLOOR 15%,
  TENSION_FLOOR 5%, only while worked); each Clocktower's SPRING LIFE (1,320, in its `soil`) feeds its Mainspring, spent =
  FATIGUED; 2 presses + 1 Mainspring per Clocktower; press 7.2/5 and 10/8, Winder 60, brass 9,000. Open: the Crown's
  anti-rush timing slipped to 2:49 (test_ai_wall_vs_rush), the floors unmeasured in fights; tools/test_exhaust.gd.

- Stun mark (owner, 2026-10-29), DONE in 0.15.24 (branch stun-mark): stars over a REALLY stunned unit (scripts/stun_mark.gd; Unit.stun(t, show, until) is the only way to stun; under 0.3 s, internal holds and nets show none); TONGUE pulls flyers through the air and never pulls the Brood Mother or a father (Defs.TONGUE "no_pull" + "father"); the Field Cannon question is still open. docs/stun_mark.md (durations table), tools/test_stun_mark.gd, pictures docs/shots/stun_mark/.
- Swarm performance (owner, 2026-10-28: "200 Raptors a side... not a lag fest"): cloud job branch `swarm-perf` (0.15.6), DONE: docs/swarm_perf.md (numbers before/after, what is left). tools/stress_swarm.gd (+ .sh): idle, walk, melee, offmelee, grubs, muskets scenarios, trace:FILE must match between versions. The unit grid is packed (Game._gpos/_gteam/_grad, GRID_SLACK and grid_slack: a unit moved farther than the slack must call game.note_move or move in its own tick), find_target looks only at enemies (_near_foe), animation steps 10 Hz in a big battle on screen (anim_crowd), replay pictures and the autosave (SaveGame.begin/SaveJob) avoid a tick's frame. Left: the clash's peak ticks, walking crowds, draw calls on phones.

- Turning gear rings experiment (owner, 2026-10-28; cloud job branch `gear-turn`, 0.14.104, DONE; docs/gear_turn.md has the speeds and open questions): only the outer toothed band turns (gear's own speed, meshed gears opposite ways; GearNet.bands / carry_at, scripts/gear_turn.gd); any unit on a band is carried round, walkers drift the full correct amount (no damping); idle units stay where they are and keep being carried (no automatic step-off: the player moves them off; only the computer walks its own idle/HOLD units off); workers at work walk straight in to the building; hold units are carried; big machines (radius >= 22), flyers and limbered guns are not; a walker pinned in a corner by the ride grips the floor 1.5 s and repaths. Setting TURNING GEARS (experiment), on by default, kept in the match cfg ("gear_turn"). Tests tools/test_gear_turn.gd, test_gear_turn_match.gd; film docs/shots/gear_turn/.

- Bodies (owner's rule, 2026-10-28): each faction gets something different from bodies: the Brood spoils (any body; the resource was called essence before 2026-10-29), the Crown resurrects its own, the Clockwork regains cogs (the Great Winder sweeps Clockwork wrecks of both sides). DONE in 0.14.103: the Great Winder's SWEEP pays 30% of the unit's cog price at once (Defs.GREAT_WINDER "share"), as an idle job: it rolls to a wreck near it, skips wrecks with enemies near, rolls back; no parts, no reassembly; MEND stays as it is. docs/great_winder.md, pictures in docs/shots/great_winder_sweep/.
- Expansion spots (owner, 2026-10-27): DONE in 0.14.95 (branch expansion-spots): the two best free hall spots of each side tinted gold on the ground (best brighter), for Crown and Clockwork players and spectators, not the Brood; minimap squares, brighter while placing a hall; Settings SHOW EXPANSION SPOTS. scripts/expansion_spots.gd (rating: room on the hall's level, ways in, walk, safety), docs/expansion_spots.md (each map's spots, weak sites: Thornwood Maze, Redrock third, 4-player classic naturals), tools/test_expansion_spots.gd, pictures in docs/shots/expansion_spots/. Also fixed the classic river maps' fords (not the same on both sides).

- Animation packs are done (Barracks drills, Breeder coats, Armoury experiments in game); the Queen is a still sprite at the Brood capital. Status table: `docs/animation_packs.md`.
- Animation audits (cloud jobs, 2026-10-27): every animation of each faction measured and looked at, safe fixes made, ChatGPT redraw prompts written: branches anim-audit-crown, anim-audit-brood, anim-audit-clockwork (docs/animation_audit_<faction>.md).
- Jobs running in separate cloud sessions (one-shot scheduled tasks), each pushing to its own branch, never to main; merge a branch when its summary doc is written or its last commit starts with "DONE:" / "TOOLS READY:". Merged on 2026-10-27: brood-pit-ground (0.14.42), perf-lag (0.14.43), wt-online (0.14.44), wt-brood-ai (0.14.45), ground-attack (0.14.46), clock-soldier-west (0.14.47), pendulum-sweep (0.14.48), icons round 13 (0.14.49/50), replays (0.14.51; EDITOR kept on the main menu, buttons in two rows), aoe-show (0.14.52), clock-soldier-shield (0.14.53), clockwork-sounds (0.14.54), the local QA pass (0.14.55, docs/qa_2026_10_27.md), anim-audit-crown (0.14.56), anim-audit-clockwork (0.14.57), music-clockwork (0.14.58), the Jack's two-launcher hop and jump (0.14.59, tools/jack_guide/hop_twin.py), music-brood (0.14.60), anim-audit-brood (0.14.61), net-instant (0.14.62), the Musketeer's south-east and north-east aims (0.14.63), fair starts on Jade Wilds (0.14.64), the Musketeer's south aim (0.14.65), qa-web (0.14.66: no crash page after a normal web visit, map editor buttons, phone layouts; docs/qa_web.md), catapult-facing-3 (art). study-v2 (docs/study_v2.md): four cloud machines (study-v2-m1..m4, pinned to 0.14.49) were CUT AT 11:00 on the owner's word ("we can extrapolate from that"); their data is in docs/study_v2/data/ and the report in docs/ai_balance_study_v2.md (tools/study/report_v2.py combine; it marks scripts that stalled). qa-soak merged (0.14.70; docs/qa_soak.md has 5 design questions for the owner, e.g. run-down Clock Soldiers stranded for good). Crown v Clockwork scrutiny (owner, 2026-10-27: a few games looked at closely, with screenshots: tools/shot_ai_match.gd films a match: fights, bases, a wind count of the Clockwork army).
- Pathfinding job (owner, 2026-10-27: "units should not bunch up at a cliff... small corners and other problems"): branch `pathfinding` (0.14.73) is DONE: rim clicks and lines stay on the high ground, group spots spread on the clicked side (Game.group_points/_walk_fill), unreachable goals end at the nearest reachable spot (find_path), melee leaves men it can't reach (Unit._siege_reaches), corner slip in resolve_terrain; test bed tools/test_pathing.gd (+ shot_pathing.gd, test_pathing_match.gd for stuck time in AI games); docs/pathfinding_audit.md has the numbers and what is left (match determinism). 0.14.71 already fixed the computer's siege gathering under the cliff (AI._siege_out) and added the Clockwork Winder escort.
- Clockwork computer job (owner, 2026-10-27: "we need the AI to play better"; DECIDED: repair is NOT to be nerfed, "it is the only thing keeping the Crown from losing, it can be dealt with": Jacks should focus the repairing workers; he thinks 4 Clock Soldiers fit at a gate face): a cloud session (scheduled 13:31) on branch `clockwork-ai` (tech on time, sieges with Jacks on the repairers, better targets, kit micro; docs/clockwork_ai.md); merge when its last commit starts with "DONE: clockwork-ai:". Siege experiment on 0.14.72 (Greenhold, 27-28 Clock Soldiers v 13 Musketeers at the ramp gate): with repair the gate held and the wave lost 25 for 1; without repair the gate fell in 38 s and the wave killed 13 of 15.
- Online (owner, 2026-10-27): asked about a dedicated server (free: Oracle Always Free ARM, 2 cores/12 GB since mid-2026) and lockstep; Claude suggested testing 0.14.44's lag fixes on his two devices first (ping counter, minute lines in the match log), then a server mode; lockstep only if needed (cross-device determinism between web and Android is the risk). Awaiting his choice.
- Musketeer and Guardsman aiming in every direction (Crown animation audit, finding 1): ChatGPT fails all five views in one sheet; one direction per request over a pose guide works (tools/musket_guide/aim_dirs.py writes art/redraws/guides/<unit>_aim_<dir>_guide.png; the owner's answers go to art/redraws/<unit>_aim_<dir>_chatgpt.png and tools/import_musket_aim_dirs.py imports them, then tools/import_vet_trim.py --only <unit>). Done: Musketeer se, ne (0.14.63), s (0.14.65; of the owner's two ChatGPT answers the first was used: the second was blockier with a huge hat and its flash streaked sideways). Guardsman (musketeer_armoured) se, ne, s done (s 0.14.69, ne 0.14.68) (0.14.67); all directions done.
- Gear rules job (owner, 2026-10-27; study docs/clockwork_gear_study.md): branch `gear-rules` (0.14.94; docs/gear_rules.md): the Ratchet Turret's 4-tile circle (no two overlap), the HEAVY WORKS (Pendulum, Spring Ballista, Great Winder; big gear only, by a Mainspring; the machine in training drawn rising in its bay, scripts/heavy_works.gd), the Movement Works shown as the LIGHT WORKS (internal id unchanged), size sets the tempo (Defs.GEAR "tempo", the turret's two screws in Defs.TURRET), brass floor plates for the Tension users, the GEAR VIEW (` key), the computer's kept spots (Game.ai_keep); merge when its last commit starts with "DONE: gear-rules:".
- Jade Wilds 4-player Clockwork start fairness: FIXED in 0.14.64 (Game._find_start_spot scores maxi(0, gap - 1): one lane from the edge still hugs it); tools/test_start_layout.gd passes on every map.
- Clock Soldier: west views in (0.14.47; docs/clock_soldier_west.md has ChatGPT clean-up prompts for the west attack and death and an E repaint so the shield isn't "on its back").
- Great Winder legs: pass 2 merged (shorter crouched legs, brush housing on the ground; 4 legs default). Spring Catapult: facing pass 3 merged (NE cup turned diagonally).
- Icons round 13 (0.14.49): the owner's 7 ChatGPT sheets are in (tools/import_round13.py, art/ui/icons3/; status in docs/command_icons_audit.md "TO DRAW"). The new HOLD icons are in (0.14.50: Clockwork blue arrow, Brood yellow arrow, his picks). Waiting on him: maybe a Brood DEMOLISH redo (it looks like the Brood BUILD), and SPIT with the Bloater (the sheet drew the Mist Toad; brood/ab_spit.png is cut but not wired).
- Clockwork sounds: the owner sent 8 recordings on 2026-10-27 (art/audio_src/clockwork/, SOURCES.txt: bell, alarm clock, crank loop, spring scrape, clangs, typewriter, wobble, metal noise) to cut into the Clockwork's sounds (he had asked to be reminded to find coil, spring and machine sounds). Merged in 0.14.54 (branch clockwork-sounds): voices, combat, deaths, building picks, alarm, research, crank for every gear-mode Clockwork unit and building, all from tools/audio/make_clockwork_sounds.py (one line per sound); docs/clockwork_sounds.md, tools/test_clockwork_sounds.gd.
