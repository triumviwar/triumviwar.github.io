# A review of every system in Triumviwar

Job qa-systems-review, 28 November 2026, on main 0.38.232. The owner asked for "an analysis of all systems in general"
with ideas to add or change.

This is a review only. No game code and no balance number was changed. It is written to be listened to: short
sentences, few tables. Effort is marked S (an afternoon to a day), M (a few days, one cloud job) or L (a week or more,
several jobs). Risk is how likely the idea is to break something or to change how the game feels in a way that needs a
new round of measuring.

## How this was done

I read the project notes (CLAUDE.md), the design principles, the unit, building and research tables in
scripts/defs.gd, the size and shape of the code, and the recent studies: the win rates of 26 November (270 games), the
two battle matrices (about 15,000 equal-value fights), the computer opponent review, the eight playtest reports of 21
November, the November QA reports (tests, content, matches, interface, performance), the world war, tournament, online,
campaign and tutorial documents, and the music study.

I did not run new computer matches. This cloud machine has no Godot engine, and 270 games to 20:00 were played on
0.38.221 two days ago with the same seeds in every cell; new games would add little to that. Where I say something about
balance, it comes from those studies.

## The short verdict

Triumviwar is a deep, unusual game with three factions that really do play differently: the Crown farms, grinds powder
and sets its guns; the Clockwork lives inside a field of meshing gears and has to keep its army wound; the Brood has no
buildings at all and roots its creatures as its base. That asymmetry is the game's biggest asset, and the systems behind
it are mostly sound.

The weak points are not the ideas. They are:

1. **What a new player is told.** Several in-game texts describe systems that are gone (the Clockwork's HOW TO PLAY still
   explains batteries and the Assembly Works), the lessons never teach an attack, and many rules are only learnt by
   failing (a Powder Mill with no workers, a rally point off the gear field, the Brood's laying ceiling).
2. **Fairness across difficulty levels.** The Brood computer plays about one level stronger than the other two at every
   level, and Normal already beats an average player two games in three.
3. **The Clockwork's fighting.** In equal-value fights it loses to both other factions. It wins real games on economy and
   repair, and several of its units (Springer, Netter, Brass Serpent) lose to nearly everything.
4. **Weight of the code.** 64 computer-opponent files, about 180 match switches, a shelved Clockwork economy still kept
   alive by tests, and the three biggest files over 9,000 lines each. Every new job pays for that.
5. **Online robustness.** No way back into a match after a dropped connection, and a 234 MB first download in the browser.

None of these needs a redesign. Most are small or medium jobs. The ranked list near the end puts them in order.

---

## 1. The Crown's economy

**How it works.** Labourers crew Farms, which ripen into lumps of gold; each Town Hall allows two Farms and one Powder
Mill, and holds its own soil and saltpetre, which run out. The Powder Mill turns saltpetre into powder, which every
firearm needs for its shots. Horses come from the Horse Breeder for riders and guns. Cottages give supply.

**Strong.** It is the most "classic" economy and the easiest to read. Running out of soil and saltpetre does push the
Crown to expand, exactly as the design principles ask. Powder as ammunition is a lovely idea: a musket line that runs dry
fights with bayonets, and the Powder Wagon and reload points make supply lines matter. The per-hall limit (two Farms a
Town Hall) keeps the economy local and makes each new hall worth fighting for.

**Weak or confusing.**
- A new Powder Mill or Farm gets no workers by itself, and nothing says so. The playtest's player fought most of a game
  with empty muskets because its Mill showed "POWDER MAKERS 0/6".
- Farms pay in lumps, which makes the early game feel bursty and makes timings hard to hit (the AI notes say the same
  about holding three Musketeers by 2:00).
- Powder is a second worry layered on gold. That is good depth for a veteran, but a beginner does not know why his men
  stopped shooting.
- The Crown's computer earns less per worker than the Clockwork's, and the Crown player is the slowest to get going.

**Ideas.**
- ADD a one-time hint when a Mill or Farm stands with no crew for 20 seconds, and let the builders of a new Mill or Farm
  stay on as its first crew. S, low risk.
- ADD a small "dry" mark over a musket man with no shots, and one alert the first time a third of the line runs dry. S,
  low risk.
- KEEP powder as it is (the owner's decision of 20 November stands; the powder study found no design option that moved
  results).

## 2. The Clockwork's economy

**How it works.** Every building sits in a ring of ground gears that must mesh with a Clocktower's. Winders wind the Cog
Presses for cogs, the money, and the Mainspring for Tension, the second resource that every advanced unit and building
draws on. Each Clocktower has raw brass and a spring life that run out. Units run down away from the gear field and must
be wound.

**Strong.** It is the most original system in the game. Placement really matters: the rings decide where you can build,
the turning gear bands even carry units. Winding gives the faction a clear weakness (fight far from home and you run
down) and a clear strength (repair, the Great Winder sweeping wrecks for cogs).

**Weak or confusing.**
- The opening is long: the first Clock Soldier at about 3:30 for a slow player.
- Tension is the real brake on everything past the Clock Soldier, so cogs pile up while Tension units wait. The late
  macro study found the computer sitting on 889 cogs at 16:00 for the same reason.
- New units come out beside their Light Works' ring, and a rally point off the field lets the waiting army run down. A
  Springer at 9% wind refused to jump. Nothing on screen says "this spot does not wind".
- "SMALL GEAR / BIG GEAR" means two different things in two places.
- Tension above its cap shows as "140/0".
- The gear rings eat a small map's main: on Kestrel Rise the main was full after eight buildings.

**Ideas.**
- CHANGE the default exit of a Clockwork production building to a spot on its own ring, and draw a rally point off the
  gear field in amber with the line "units here run down". S to M, low risk.
- ADD a faint tint over ground that winds, shown while a Clockwork army is selected (the gear view already exists; make
  a light version of it come with the selection). S, low risk.
- CHANGE the Tension readout to "140 (no Mainspring)" when the cap is gone. S, no risk.
- RENAME one of the two gear-size labels so each means one thing. S, no risk.

## 3. The Brood's economy

**How it works.** No buildings. The Brood Mother roots and lays every egg. Grubs carry food from rooted Rootmaws to her,
and food from far Rootmaws pays more. Each Rootmaw drinks from a circle of ground that runs out. Mound Turtles root as
outposts that hold more Rootmaws. A second resource, spoils, comes from bodies (HARVEST) or from offering up one's own
creatures, and it buys every step up: the Mother's growth, the Sires and research.

**Strong.** Truly different, and true to the fiction. Moving the whole base is possible. The far-Rootmaw bonus rewards
risk. The gold "best Rootmaw spots" made it fair and readable. The swamp that lingers when the Mother gets up (0.38.120)
fixed the playtest's worst problem.

**Weak or confusing.**
- Laying is the ceiling, not food. With nine or ten Rootmaws the food cannot be spent: one playtest match ended with
  15,574 food in the bank. The player does not see why.
- The resource has two names on screen, "Biomass" and "food".
- Every step up needs spoils, and spoils only come from bodies or sacrifice, so a Brood that is ahead on food but has not
  fought stays stuck.
- SACRIFICE on workers takes all the selected grubs with one key and no second step.
- Research at a Sire stops his eggs (the owner chose to keep this; it should at least be said on the button).
- Late in the game, re-rooting each spent Rootmaw is chores, not decisions.

**Ideas.**
- ADD a readout on the Mother's card: "lays about N eggs a minute; food beyond that waits". S, no risk.
- CHANGE every on-screen "Biomass" to one name (food or biomass, the owner picks). S, no risk.
- ADD a second press to SACRIFICE when it would take more than two workers. S, no risk.
- ADD an "uproot and re-root on the nearest fresh spot" order for a spent Rootmaw, one key. M, low risk; it changes no
  number.
- The question of turning spare food into spoils, or into faster laying, is in "decisions you might revisit": it touches
  the owner's no-sink rule and waits for the Rootmaw decision.

## 4. Supply

**How it works.** A 200 cap for everyone. The Crown builds Cottages, the Clockwork Spring Towers and Regulators, the Brood
gets supply from the Mother and her turtles.

**Strong.** The cap stays (the owner's decision), and with depletion it does what the principles want: late games are
about better fights and remaking armies, not a bigger bank.

**Weak.** The cap is reached unevenly. The Brood's supply-per-value makes its capped army the strongest late (the crown
rule cleanup study: the Crown leads to 14:00 and loses at 15 to 19 minutes to a capped Brood army at even income). A big
unit like the Tyrant Sire costs only 4 supply for 1,000 health.

**Ideas.**
- KEEP the cap at 200.
- MEASURE value per supply point at the cap for each faction's best army (the battle lab can do this in a day: one
  "at the cap" size per pairing is already there). S, no risk. This turns a feeling into a number for the owner's next
  balance call.

## 5. Combat and counters

**How it works.** Real projectiles and lines: musket volleys, round shot along a line with splash, canister cones,
mortars arcing, melee with charges, armour and light bonuses, high ground, walls, gates. Veterancy adds 1% damage a kill
up to +50%.

**Strong.** Fights look and feel like the period. The battle matrices show clear identities: Musketeers with Officers
are the Crown's backbone, Horsemen punish anything that stands still, Pendulums and Owls carry the Clockwork, and the
Brood has the only true circle inside one faction (flyers beat ground, Venom beats flyers, the Sire's army beats Venom).
The Charge package (one charge kills a Raptor) gave riders a real job.

**Weak.**
- In equal-value straight fights the order is Brood, then Crown, then Clockwork. The Clockwork gets 6 of 100 early
  against the Brood. Its wins come from economy and repair.
- The Tyrant Sire beats every Crown army early and mid: 1,000 health for 150 food.
- Guns and mortars make a Crown army worse in the open, because they set late and hit their own men. They are the
  Crown's identity, so this matters for how the faction feels.
- Veterancy up to +50% is a pro-snowball mechanic with no brake. It is rarely reached, but where it is, it is large.
- There is no retreat order. A pulled-back army walks back the way it came and keeps getting shot.

**Ideas.**
- ADD a RETREAT order (move, do not stop to fight, a small speed boost for a few seconds, a cooldown). The design
  principles list retreat tools as an open question; this is the plainest answer. M, medium risk (it changes fights; it
  must be measured with the battle lab first).
- CHANGE veterancy to a lower cap (say +20%) or give it a brake (a veteran costs a little more to heal or revive). S to
  make, M to measure, medium risk. A balance number: the owner's call.
- The Clockwork's fighting and the Sire are balance questions: see the roster sections and "decisions you might revisit".

## 6. Unit rosters

### The Crown

Labourer, Messenger (mounted labourer), Musketeer and the armoured Guardsman, Dragoon, Officer and Horseman and the
armoured Cuirassier, Field Cannon, Mortar, Powder Wagon, Observation Balloon, the three musicians, the Missionary (and
his mounted self). The campaign also has the Pikeman.

**Strong.** Every unit has a job, the mount and dismount pairs keep prices honest, and the musicians are a charming,
useful idea.

**Weak.** The Dragoon is weak as an army (it rides in, takes 0.8 s to get off and fires slower). The Mortar is weak in
the field. The Balloon was picked 0 of 12 times by the computer against the Clockwork. There is no Crown answer to flyers
except canister and muskets, which is fine, but it is not told anywhere.

**Ideas.**
- CHANGE the Dragoon toward its real-world job: a raider and a gap-filler, not a line unit. One clean way: it can fire
  from horseback at a penalty instead of always getting off. M, medium risk.
- KEEP the Mortar as a siege piece, and say so on its card ("for walls and clumps, not the open field"). S, no risk.

### The Clockwork

Winder, Clock Soldier, Springer, Netter, Pendulum, Spring Ballista, Swift, Ticking Owl, Great Winder, Brass Serpent, and
the Ratchet Turret.

**Strong.** Pendulums and Owls are excellent and clear. The Great Winder and the Serpent are genuinely new ideas in an
RTS.

**Weak.** Springers, Netters and the Brass Serpent lose to nearly everything at equal cost. The Ballista falls behind
the push. Winders do not pay in a short fight. That is three of ten units without a clear winning job.

**Ideas.**
- CHANGE each weak unit toward one job it wins, not a general buff:
  the Springer as a high-ground and wall jumper (it should beat walls and men behind them), the Netter as the answer to
  riders and Raptors (a net that stops fast units cold), the Serpent as a late tank that soaks for Pendulums. A battle-lab
  pass per unit, numbers only after the Rootmaw decision (the owner said the Springer waits for it). M, medium risk.
- ADD the missing comps to the battle lab: Netters with Pendulums against riders, Springers against a walled ramp. S.

### The Brood

Grub, Raptor, Spitter, Brute, Skywing, Mist Toad, the three Sires (Tyrant, Venom, Storm), the three Challengers,
Hatchlings (to become the small wyvern), Rootmaw, Mound Turtle, the Mother.

**Strong.** The best circle in the game. Reptilian first, as the art direction wants.

**Weak.** The Spitters stand back while the Raptors die (seen in the lab films). The Sire is so strong that early
Brood play leans on him.

**Ideas.**
- KEEP the roster; it is full.
- CHANGE the Brood computer's Spitters to step in behind the Raptors (brood-micro's kite rule keeps them back; a
  "close to range" step before kiting would fix the films). S, low risk.

## 7. Research

**How it works.** The Crown has nine researches, eight of them at the Armoury and the Cavalry Charge at the Horse
Breeder. The Clockwork has four: High Leap, Shield Wall and Long Chain at the Escapement, and the Ticking Owl at the
Clock Aviary. The Brood has twelve, spread over the three Sires and the Mother, all paid partly in spoils.

**Strong.** The Brood's research sits on the creature it improves, which reads well. The Crown's lock ladder (matchlock,
flintlock, caplock) tells a story.

**Weak.**
- The Clockwork has a third of the others' research. It has fewer choices and fewer ways to grow mid-game.
- The Crown's Armoury is a single crowded menu; the owner has been thinking about spreading it out since October.
- Brood research costs spoils and stops a Sire's eggs, which together make it rarely worth doing early.

**Ideas.**
- ADD two or three Clockwork researches at the Heavy Works and the Light Works, each tied to a winding or gear idea
  rather than plain damage: a slower run-down away from the field, Winders that mend faster in a fight, a Ballista that
  keeps pace. M, medium risk (new things to balance).
- CHANGE the Crown's research homes as the owner already sketched: Prepared Charges at the Powder Mill, Gunner's Quadrant
  at the Foundry, the locks at the Armoury. S to M, low risk (prices unchanged). It also helps scouting: what a player
  builds shows what he is going for, as section 3 of the principles asks.

## 8. The computer opponent

**How it works.** A large rule-based computer per faction, with plans (Balanced, Economy, Rush, Timing, several named
builds, and OPTIMAL, which scouts and picks), a scout read (GREEDY, NORMAL, AGGRESSIVE, DEFENSIVE, UNKNOWN), and many
coached parts for building, fighting and defending, each behind a match switch.

**Strong.** It is now a real opponent. The mirrors finish, the Crown has caught up with the Brood, no computer sits idle
while its base burns or on a big bank. The AI STORY line, which says what it is thinking, is a great feature for
learning. The measuring culture (blocks of games, switches, seeds) is excellent.

**Weak.**
- Levels do not mean the same for every faction: the Brood computer is about a level stronger at Easy, Normal and Hard.
- Normal beats an average player two games in three. For most players, Normal should be winnable.
- Hard has no readable habit a good player can find and punish.
- Visible silliness remains: the Clockwork's whole army turning round for one raider, guns and wagons stuck, a Crown hall
  dying below a bigger army on its high ground. (Jobs ai-fixes-a and ai-fixes-b are on these now.)
- The code: 64 files, about 180 switches, many of them measured "no change" and left in as off switches. Each new job has
  to understand a stack of rules that sometimes fight each other (the crown rule cleanup found the fight rules hurting
  against the Clockwork).
- Every study runs on the same six parity maps. The other 21 maps and all team maps are barely measured.

**Ideas.**
- CHANGE the level names or add a level: Easy, Normal, Hard become Beginner, Easy, Normal, Hard, with today's Normal as
  the new Normal and a slower one under it. Then tune each faction to the same benchmark at each level. M, low risk.
- CUT the switches that were measured as no gain and are off by default. Keep a short registry (one file listing every
  live switch, what it does and its default) and a rule that a switch measured off twice is removed. M, low risk to the
  game, big gain for every future job.
- ADD one readable habit per faction on Hard (for example the Brood always tests a ramp with Raptors before its main wave,
  the Clockwork always pushes when its Mainsprings are full), written in the AI STORY line. M, low risk.
- MEASURE once on the full map pool and on 2v2, so map problems are not hidden by the parity six. M, no risk.

## 9. Pathfinding and control

**How it works.** Tile paths with group spreading, rim clicks that stay on high ground, drag-a-line formations, attack
move, patrol, hold, Shift queues, control groups, camera tabs, touch controls with long press and pinch.

**Strong.** Drag-a-line is the best control in the game and fits the period. Touch play is thought through. The
pathfinding job fixed the worst clumping at cliffs.

**Weak or confusing.**
- Esc does not open the match menu. Many players press Esc to pause or leave. (Pause/Break and F10 now pause.)
- S (stop) cannot stop a worker: automatic work sends him straight back.
- "Blocked." is the whole message for a refused building spot.
- The view can go far past the map's edge.
- On a phone the HUD takes about 40% of a landscape screen, and keyboard keys (F1 to F10) show on the hotkey bar.
- No game speed in a skirmish against the computer (only the sandbox has it).

**Ideas.**
- CHANGE Esc to open the match menu when nothing is selected and nothing is being placed. S, no risk.
- ADD game speed (x1, x1.5, x2) in single-player skirmish only, never online or ranked. S, low risk.
- CHANGE "Blocked." to say what blocks it (a unit, a building, a cliff, a ring that would clash). S, no risk.
- CHANGE S on workers to stop them until given a new order. S, low risk.
- CHANGE the phone HUD: hide keyboard letters, and a "compact" HUD that folds the command card when nothing is
  selected. M, low risk.

## 10. The campaign engine and mission design

**How it works.** Data-driven missions (JSON) on map-editor maps, with triggers, objectives, choices and flags that carry
forward, scripted sides, more than two sides, stills, voices, a roster ladder that adds one or two pieces a mission, three
hubs, a war map, co-op and versus on the same missions, saves and checkpoints, Ironman. Twenty-one story missions are
built (the prologue, both other prologues, all of Act 1, all of Act 2); Act 3 (twenty missions) is planned and its engine
step has begun.

**Strong.** The ambition and the structure are excellent: every battle playable from both sides, consequences that
carry, a roster ladder like StarCraft's, three storylines that cross. The engine has grown a rich vocabulary and every
mission has a test and a simulation.

**Weak.**
- Every word of text is a placeholder until the owner rewrites the dialogue. Twenty-one missions of placeholder text is
  a lot of rewriting waiting at once, and Act 3 would add twenty more.
- The engine has grown mission by mission: the engine document is a long list of "added by" sections. Some features
  exist for one mission only.
- The playtests found missions that end on a mistake the player could not see coming (The Specimens), idle stretches
  (Specimen One without a clock), mirrors that are too short. The owner's three rules (say it plainly, no waiting, check
  the feel) answer this, but the older missions were built before them.
- A mission is long to build and long to test, and only simulated players have played them end to end.

**Ideas.**
- ADD a "campaign read-through" pass before building Act 3: play Acts 1 and 2 in order as one player, against the three
  rules, and list what to fix. M, no risk. It is cheaper to fix the pattern now than in forty missions.
- CHANGE the order of work: the owner's dialogue rewrite for the prologue and Act 1 first, then Act 3 built on the voice he
  sets, so Act 3's placeholders already sound like him. (The owner's call.)
- ADD an engine reference page grouped by what things do (spawning, objectives, conditions, cinematics, flags), not by
  which mission added them. S, no risk.
- ADD a warning before any "lose on one mistake" moment (one stirring creature, one chance). S per mission.

## 11. World war mode

**How it works.** A turn-based war on a world map of 60 regions, one season a turn. Armies march and sail, one building
a region, regiments of real skirmish units; battles are fought as a skirmish (FIGHT IT) or auto-resolved. Rust, cold,
unrest, heroes and events. Win by capitals, by 8 of 15 key regions, or most land at season 48.

**Strong.** A great addition, like the War of the Ring. The tuning pass brought three-side wars close (39, 28.5, 32.5)
and stopped the runaways.

**Weak.**
- Most wars are still decided by land at season 48, not by a capital falling. That is a long war to reach a points win.
- No online war. No sounds or music on the map.
- The map is drawn in code while the campaign has painted maps.

**Ideas.**
- ADD shorter war lengths (24 and 36 seasons) as a setting, and a "sudden death" key-region count. S, low risk.
- ADD the faction music and a few map sounds (a march, a battle drum, the season's bell). S, no risk.
- Online wars: L. Worth it only after online reconnect works (section 13).

## 12. Tournaments

**How it works.** Single and double elimination, round robin, Swiss, groups and playoffs, best-of, map pools with bans,
online (the organiser's game is the desk, players open friendly rooms from the bracket, results reported by the games)
or offline, and all-computer tournaments to watch.

**Strong.** Complete and well tested; the championship simulation is a fine balance tool too.

**Weak.** The organiser's game must stay open for an online tournament. Results depend on the relay.

**Ideas.**
- KEEP as it is. When the ranked server is live, let it host the desk so the organiser can close his game. M, later.
- ADD a "printable bracket" export (a picture) for sharing. S, no risk.

## 13. Online, ranked and spectators

**How it works.** Friendly online: the host's device runs the match and sends each player a view cut to its own fog,
through a relay. Ranked: a server runs every match, Steam players only, a Glicko-2 ladder, seasons, bans. Up to four
spectators in a friendly room.

**Strong.** Closing the fog leak per side was the right call. A server-run ranked match is the honest way to stop
cheating. Spectators with every side's view are ready for casting.

**Weak.**
- No way back into a match after a dropped connection. On phones this is the most common way an online game ends.
- When the host leaves, the friend's match freezes instead of ending with a result.
- Ranked is a prototype; nothing is live yet.
- Ranked spectating is not built.

**Ideas.**
- ADD reconnect with a grace time (60 to 120 s) where the host keeps the seat and the computer holds the army. M to L,
  medium risk; it is the single biggest thing for online play.
- CHANGE "host left" to end the friend's match as a win for the one who stayed, with a clear line. S, low risk.
- Ranked: go live with one region and the parity maps first, not the whole pool. Decide before launch.

## 14. Replays

**How it works.** FULL (pictures five times a second) or MIXED (commands plus the computers' decisions plus a keyframe
every 10 s, played back from the keyframes). The battle report shows statistics and a timeline chart.

**Strong.** MIXED is small and right for phones. Jumping and pausing pose every unit.

**Weak.** A replay is watched, not studied: no markers for fights, no income or army graph while watching.

**Ideas.**
- ADD fight markers on the replay bar (the game already knows when value is lost fast) and the battle report's chart
  as a strip under the bar. M, no risk.

## 15. Saving

**How it works.** A skirmish autosave every 15 s (one file, CONTINUE on the menu). Campaign missions save themselves,
with SAVE, LOAD SAVE and checkpoints, and Ironman.

**Strong.** The autosave no longer freezes the game. Mission saving was done well.

**Weak.**
- One skirmish slot only: a second match overwrites the first.
- After an update, a save from an older version silently disappears from the menu.

**Ideas.**
- ADD three named skirmish save slots. S to M, low risk.
- CHANGE the old-save case to show the save with a line "made by an older version: cannot be continued". S, no risk.

## 16. The map editor and the map pool

**How it works.** Nine classic maps generated anew each match, eighteen named maps, team maps up to 4v4, and an editor
for painting, start spots and teams that also makes the campaign's maps. A city generator builds towns for missions.

**Strong.** Variety, biomes, rivers, high ground. The editor's safety fixes (no one-tap delete, no silent overwrite)
are in.

**Weak.**
- Only six maps are used for balance; nobody knows how the others play between computers.
- The editor does not grow on a phone, and painting a 256-by-256 map stalls for seconds.
- The ranked map pool is "every 1v1 map".

**Ideas.**
- ADD a map-check report: for each map, run eight computer games per pairing and list start-spot edges and game length.
  M, no risk. Then pick a ranked pool of 7 to 9 maps from it.
- KEEP the variety rule (pocket naturals on some maps, open on others), as the owner decided.

## 17. The tutorial and onboarding

**How it works.** Seven lessons on the mission engine: Basics, one per faction, and an Easy practice game per faction,
with a teacher, steps and a pointer. HOW TO PLAY pages in the menu.

**Strong.** Built on the same engine as the campaign, so it is cheap to extend. The playtest fixes (stuck lessons, keys
on other keyboards) are in.

**Weak.**
- HOW TO PLAY > Clockwork still describes the shelved system: energy, batteries, the Assembly Works, Steam Walkers, Tesla
  Carts. A new Clockwork player reads about units he cannot build. (The Clockwork playtest wrote a replacement draft.)
- No lesson teaches attacking. The Crown lesson only defends, the Clockwork and Brood lessons never fight.
- Not taught: crewing a Farm, supply, the Horse Breeder, powder and reloading, a second hall, research, winding in a
  fight, UPROOT and GROW, attack-move, Shift queues, rally points.
- The practice games are hard on a beginner (an idle player lost everything).

**Ideas.**
- CHANGE HOW TO PLAY > Clockwork to the playtest's draft, now. S, no risk. This is the cheapest fix in this whole review.
- ADD a fourth step to each faction lesson: "attack" (take a small enemy camp with what you built). M, low risk.
- ADD a "Beginner" practice (see section 8) as the first practice game.
- ADD tips on the loading screen drawn from the list of untaught things. S, no risk.

## 18. Audio and music

**How it works.** Twenty pieces per faction in four roles (opening, skirmish, full battle, calm), menu themes, the owner's
ElevenLabs pieces, marching band music that ducks the score, Clockwork sounds from the owner's recordings, campaign voices
made with Chatterbox.

**Strong.** A lot of music with clear faction identities. The band's playlist and ducking are a lovely touch. The voice
pipeline is cheap and the rights are clean.

**Weak.** The music study found flat dynamics, climaxes on the last chord, too much sub-bass in battles, and four
near-identical drum-bed marches. The mix pass is under way (job music-mix-pass). There is no "army" select sound for
mixed Brood and Clockwork selections.

**Ideas.**
- KEEP the mix-pass-first plan.
- ADD the dynamic-arc helper next (the music study's proposal 2): small, and it lifts every generated piece at once. S to
  M, no risk to gameplay.
- ADD God Save the King on a Crown victory (decided) and a short victory sting for the other two. S.

## 19. Performance

**How it works.** A 30-tick game. The late-game cost is the units' own work, growing with army size. The autosave writes
on a worker thread; old pictures are released.

**Strong.** No leaks; nothing gets slower by itself. The earlier fixes halved memory in Brood games.

**Weak.**
- On a mid-range phone a late 1v1 runs at 25 to 40 frames a second, 15 to 25 in a big fight; 2v2 and bigger are not smooth
  on a phone.
- Single freezes remain: the computers' site searches (up to a second on The Sundered Realm), a whole army dying in one
  tick when a player is out.
- The web art pack has grown to 234 MB, plus the engine and music: a long first wait on mobile data.

**Ideas.**
- ADD a light tick for idle units with nothing in sight, and spread the computers' site searches over several frames.
  M, low to medium risk (it changes when the computer decides something: the owner's call, as the perf study said).
- CHANGE the web art pack: campaign paintings as WebP, Portuguese and Spanish voices only for those languages, and the
  campaign's art downloaded only when the campaign is opened. M, low risk. Roughly a third smaller first visit.
- CHANGE a beaten side's units to fall over a few at a time instead of in one tick. S, no risk.

## 20. Code health (not a system the player sees, but every system pays for it)

**How it works.** About 186,000 lines of script. game.gd 12,000 lines, unit.gd 9,600, ai.gd 8,800. 335 test files.

**Weak.**
- The shelved Clockwork "Line" economy, its rails, trains, batteries and nine old units are still in the tables and kept
  alive by tests, though no player can reach them.
- Around 180 match switches, many measured as no gain.
- Several tests are known to fail or flake (rush, rush follow-up, wall versus rush, the Clockwork heavy and army tests),
  so a red result no longer means much.

**Ideas.**
- CUT the shelved Line economy and the old Clockwork roster, after tagging the last commit that has them. M, low risk.
- ADD a "known red" list that the test runner reads, so any new failure stands out, and fix or delete each listed test
  within a month. S to start, low risk.
- CUT the dead switches (section 8).

---

## The top 15 ideas across the whole game, ranked

Ranked by what a player would feel, divided by the work, with risk in mind.

1. **Rewrite HOW TO PLAY > Clockwork** from the playtest's draft. It still teaches units that no longer exist. S, no risk.
2. **Esc opens the match menu.** S, no risk.
3. **Make the difficulty levels fair and honest:** a Beginner level under today's Normal, and every faction tuned to the
   same benchmark at each level. M, low risk. (ai-fixes-a's Normal Brood pace is the first step.)
4. **Clockwork production exits on its own ring, and an amber warning for rally points that do not wind.** S to M, low
   risk.
5. **Online reconnect with a grace time,** and "host left" ends the match with a result. M to L, medium risk.
6. **An "attack" step in each faction lesson,** and loading-screen tips for what the lessons skip. M, low risk.
7. **One-time hints for the silent traps:** a Mill or Farm with no crew, the line running dry, the Mother's laying
   ceiling shown on her card, "Blocked." saying what blocks. S each, no risk.
8. **Cut dead AI switches and the shelved Line economy; add a switch registry and a "known red" test list.** M, low risk.
9. **A RETREAT order,** measured in the battle lab first. M, medium risk.
10. **Two or three Clockwork researches about winding and gears.** M, medium risk.
11. **A job for each weak Clockwork unit** (Springer, Netter, Serpent), battle lab first, numbers after the Rootmaw
    decision. M, medium risk.
12. **Campaign read-through of Acts 1 and 2 against the three rules before Act 3 is built.** M, no risk.
13. **Game speed in single-player skirmish.** S, low risk.
14. **A smaller web first visit:** WebP paintings, voices by language, campaign art on demand. M, low risk.
15. **A map-check report on the whole pool, then a curated ranked pool.** M, no risk.

## Five things I would NOT do

1. **Do not add a fourth faction or more units before the Clockwork's roster pulls its weight.** Three of its ten units
   have no winning job. A new unit adds balance work without fixing that.
2. **Do not add more AI rules on top of the stack for now.** The last ten coaching jobs mostly ended "within noise". The
   gains left are in macro, readability and fairness across levels, and in removing rules, not adding more.
3. **Do not start building Act 3's twenty missions before the dialogue voice of Acts 1 and 2 is set.** Placeholder text
   is cheap to write and expensive to rewrite forty times over.
4. **Do not try lockstep networking.** Host-authority with fog-cut views works; lockstep would need the same results on
   web, Android and desktop down to the last bit, which Godot does not promise. Spend the effort on reconnect.
5. **Do not bring back the ground system or remove the per-hall limits.** Both were measured and reverted for good
   reasons; the per-hall rule is simple and players understand it.

## Decisions you might revisit

These are the owner's standing decisions. I am not proposing to change them in this job; these are only questions worth
asking again, with the reason.

- **No food or gold sink (13 November), and the Brood's useless bank.** The no-sink rule was made for the late game in
  general. The Brood's case is special: its food cannot be spent once laying is the limit, so its bank is not a win
  button, it is dead weight. A poor-rate trade of food for spoils (say 20 to 1) would let a Brood that out-earns turn it
  into growth, without making a bank strong. Worth a measured test after the Rootmaw decision.
- **Research at a Sire stops his eggs (21 November).** It makes Brood research rarely worth doing before the late game.
  If kept, the button should say so before the player presses it.
- **Veterancy as it is.** Up to +50% damage is the largest pro-snowball mechanic in the game, with no brake. The design
  principles ask that every snowball mechanic have one.
- **The Rootmaw number (waiting).** The 26 November games show the nerf (x2.0) makes Crown against Brood even on
  average without changing who wins or leads, and does not help the Clockwork. If the goal was "the Crown can beat the
  Brood", that is already true; the nerf mostly shortens the Brood mirror. The Tyrant Sire's value (1,000 health for 150
  food) may be the better lever for the early fight.
- **The Crown's guns in the field.** The battle labs say a Crown army fights better in the open without them. That is
  against the faction's whole picture. If the owner wants guns to belong in field armies, they need to set faster or the
  limbered march needs to keep up; otherwise say plainly in the game that guns are for sieges and set lines.

## Sources

The studies and reports read for this review, all in docs/: winrate_2026_11_26.md and its four part reports;
battle_matrix.md and battle_matrix_all.md; ai_opponent_review.md; clockwork_late_macro.md (from CLAUDE.md);
playtest_2026_11_21_*.md (eight reports); qa_2026_11_08_*.md; qa_2026_11_08_perf.md; qa_soak.md; world_war_mode.md and
world_war_tune.md; tournament.md; online_ranked.md; campaign_engine.md; tutorial.md; music_study_classical.md;
design_principles.md. The numbers on units, buildings and research are from scripts/defs.gd on 0.38.232; the HOW TO PLAY
text is in scripts/main.gd.
