# UI design review, 28 November 2026 (job qa-ui-review)

The owner asked (2026-11-28) for "an analysis of everything clickable, including ideas to add or change UI". This is a
DESIGN review, not a bug hunt (the job qa-click-sweep hunts bugs). No game code was changed. Version looked at:
**0.38.232**.

**How:** every screen was pictured on a computer (1600 x 900) and on a phone held sideways (2400 x 1080, Settings'
device "phone"), in English: the menus and setup (`tools/qa_ui_audit.gd`, the November QA tool), a match of each
faction set up by a new picture tool `tools/shot_qa_ui_review.gd` (a base with every building, an army of ~30, the
command card of each main unit and building, MAKE, a zoomed-out view, a big battle against the Brood or the Crown,
the in-game menu, the end screen), the campaign (three hubs, the war table, the war map in its three skins, a pin's
card, a briefing, the opening still, p01 and c01 a few seconds in with their dialogue and objectives, the tutorial list
and two lessons), the online and ranked pages, replays, the map editor, and the world war and tournaments through their
own picture tools (`tools/shot_world_war.gd`, `tools/shot_tournament.gd`). The pictures are in
`docs/shots/qa_ui_review/` (`pc_...` computer, `mobile_...` phone; `..._audit_...` from qa_ui_audit, `ww_...` world
war, `tour_...` tournaments). They were then looked at as an experienced RTS player and a UI designer, against
StarCraft II, Age of Empires IV, Warcraft III and Beyond All Reason.

Effort: **S** = an afternoon, **M** = a few days, **L** = a week or more. ⚡ = a quick win (S and clearly worth it).

## The verdict, short

The game **looks like one game**: the dark-wood-and-brass panels, the gold serif titles and the painted backdrops are
the same on every page, the three factions' command cards each have their own icon style yet sit in the same grid,
and the campaign's painted hub, briefing and war map are the best-looking screens in it. The HUD has the right RTS
pieces in the right places (resources top left, clock top middle, minimap bottom left, selection in the middle,
4 x 3 command card bottom right, IDLE / ARMY / MAKE and ten control groups as buttons, camera tabs), which is more
than most indie RTSs ship with.

What holds it back is **information density and noise**: the battlefield carries a lot of floating text (FARMERS 0/8
0%, HAULERS 0/1, POWDER MAKERS, "+5%" over every soldier near a drummer, GRUBS 1/6, ROOTMAW SPOT, OPTIMAL EXPANSION
SPOT), while things a player needs every second are missing or hidden (income per minute, an idle-worker count you
can see at a glance, a jump to the last alert, production progress on the buildings, what an enemy unit is). The
**command card hotkeys follow the names** by default, so the same letter means different things on different cards
(on MAKE, A trains a Musketeer; on the army, A attacks). The **phone** layout is usable but its tap targets are small
(command buttons ~5 mm, selection portraits ~3.5 mm on a 6.5" phone), and it still shows keyboard labels (F4..F9).
The **tutorial's first screen** asks a lot of a newcomer at once. The fixes are mostly small; the top 15 is at the end.

## Findings per screen

### 1. Main menu (`pc_menu.jpg`, `mobile_menu.jpg`, `pc_audit_menu_continue.jpg`)

- Strong painting, clear title, flags for language. The grid of buttons is 4 + 4 + 2 with WORLD WAR and TOURNAMENTS
  hanging under the second and third columns: it reads as unfinished, and TOURNAMENTS is drawn in a much smaller
  font than its neighbours (it auto-shrinks to fit). **Proposal:** group the buttons by purpose: PLAY (CAMPAIGN,
  SKIRMISH, WORLD WAR, ONLINE, TOURNAMENTS) as one row of big buttons, then a row of small ones (TUTORIAL, REPLAYS,
  EDITOR, SETTINGS, EXIT); give all labels one font size (shorten "TOURNAMENTS" to "CUPS" or widen that row). **S**
- SKIRMISH is highlighted green (the "primary" colour) though the owner's "start here" is the campaign / tutorial.
  For a first launch, highlight TUTORIAL (or CAMPAIGN · Start here, as the hub already does). After the first match,
  CONTINUE (when there is an autosave) should be the green one. **S** ⚡
- The version line and "Made by Salgarellius Catholic Games with the help of AI" are fine; "playing on computer"
  belongs in Settings, not on the front page. **S**

### 2. Device page (`pc_device.jpg`, `mobile_device.jpg`)

- A good idea (big honest choice). Make sure it only comes on the very first launch and remembers; offer "change it
  later in Settings > Gameplay" under it. **S**

### 3. Settings (`pc_settings_gameplay.jpg`, `pc_audit_settings_display.jpg`, `pc_audit_settings_other.jpg`)

- Clean and consistent. Five tabs; GAMEPLAY mixes the device, keys, tooltips, the build grid, replays and the relay
  address. **Proposals:**
  - The ONLINE RELAY ADDRESS (`wss://pocketrts-relay.salgarel...`, the old name, cut off) is a developer setting: move
    it to OTHER behind "advanced", and show the game's name. **S** ⚡
  - COMMAND KEYS: "BY NAME" is the default; "GRID (QWER/ASDF/ZXCV)" exists. See finding 7.3: make GRID the default for
    new players, or at least say on the row what the difference is. **S** ⚡
  - **Accessibility is thin.** There is IN-GAME INTERFACE SIZE (good). Missing: a **colour-blind mode** (team colours
    blue / red / green / yellow, the Brood is green, the minimap dots and the health bars are red/green; the end
    screen's numbers are green/red), a **text size** for menus and the campaign (the hub's "NEW IN THE HUB" line and
    the selection panel's description are small), and **reduce screen shake / smoke** in one place. Proposal: a
    DISPLAY > ACCESSIBILITY group: team colour set (default / colour-blind safe: blue, orange, purple, white with
    shapes on the minimap), text size (100/115/130%), health bars by thickness + colour. **M**
- The settings page is a narrow column on a 1600-wide screen: fine on PC, on the phone it is OK too. No change.

### 4. Skirmish setup (`pc_skirmish.jpg`, `pc_audit_lobby_1v1.jpg`, `pc_audit_lobby_4v4.jpg`)

- Clear rows (PLAYER, FACTION, COLOUR, PLAN, TEAM), mode tabs across the top, the map on the right, START big and green.
  Close to AoE IV's lobby. **Proposals:**
  - The map preview with "RANDOM 1V1 MAPS" is a grey square with a "?": show the pool's thumbnails small, or the last
    map played. **S**
  - FACTION "RANDOM" for the human by default: a new player should get THE CROWN (the tutorial's faction) and see the
    faction's crest, a one-line "how it plays" ("Musket lines and cannon; farms and powder") under the dropdown. **S** ⚡
  - The difficulty (HARD AI) and the PLAN dropdowns use internal words; add one-line hints ("Hard: plays well, no
    cheats"; "Rush: attacks early"). The bottom line already explains BRUTAL: good, do the same for each. **S**
  - Big empty middle space on PC: a "MATCH OPTIONS" box could live there (starting resources, speed, fog, victory
    condition, time limit) instead of hiding them. **M**

### 5. The in-match HUD, all factions (`pc_crown_base_hall.jpg`, `pc_crown_army_selected.jpg`, `pc_clockwork_base_hall.jpg`, `pc_brood_card_brood_mother.jpg`, `pc_audit_hud_*`)

The layout is right. The detail is where it loses the player.

- **5.1 Resource bar.** Gold, powder, supply, horses (Crown) / cogs, tension, supply (Clockwork) / biomass, spoils,
  supply (Brood). Missing: **income per minute** (the spectator line already computes "income 354/min": show it under
  or beside each resource, or in its tooltip); **worker count**; and a **supply-block warning** (today the number only
  turns red; SC2 and AoE IV say "Supply blocked" / "Build more houses" once, with a sound, and the number flashes).
  **S** ⚡ for income and the warning, **S** for workers.
- **5.2 APM 0** is shown to every player next to the clock. It is a spectator / replay number; for most players it is
  noise and some feel judged. Show it only when watching, or behind a setting. **S** ⚡
- **5.3 The speed slider (x1.5)** top middle is barely visible (grey on dark). In a skirmish against the computer it is
  useful; label it "SPEED" and give it the same pill style as the resources. **S** ⚡
- **5.4 Floating labels on buildings** (FARMERS 4/8 50%, HAULERS 0/1, POWDER MAKERS 0/6 0%, WINDERS 3/5, GRUBS 0/6,
  "100%" bars over every Clockwork building): they repeat what the selection panel says and fill the screen in a full
  base (`pc_crown_make.jpg`, `pc_clockwork_base_hall.jpg`). AoE IV shows a small worker-count chip on the building and
  only full text on hover/selection. **Proposal:** a small icon chip ("👤4/8") always, the full label only on hover,
  selection or when the building is short of workers (amber). A Settings switch "Building labels: full / small / off".
  **M**
- **5.5 "+5%" over every soldier** in a drummer's ring (`pc_crown_army_selected.jpg`, `pc_crown_battle.jpg`): 25
  identical marks. Show the band's ring once (it is drawn) and one "+5% speed" tag at the band, or a tiny glyph without
  the number. Overlay opacity already exists; this is about count, not opacity. **S** ⚡
- **5.6 Health bars in a battle** (`pc_clockwork_battle.jpg`): Clockwork bars are two-tone and stacked over each other.
  Option: show bars only for hurt units and the selection (a common setting: "Health bars: always / damaged /
  selected"). **S**
- **5.7 The selection panel.** Good: portraits with health, the type tabs (16, 4, 3, 1...) like SC2's subgroups, stats
  as icons, the description line. Weak: the description line is ~11 px and gets cut ("Makes Clock Soldiers; Spri..." on
  the Light Works, `pc_clockwork_card_movement_works.jpg`), the stat icons have no labels (hover tooltips only), and
  for a building there is **no production queue or progress shown** in the panel in these pictures. Proposals: wrap
  the description to two lines; show a building's queue (icons with a progress bar, click to cancel) in the panel's
  empty space, as every reference RTS does. **M** (if the queue exists already and only hid in these pictures, at
  least make it bigger).
- **5.8 Empty selection** shows the faction name huge and faint in the panel ("CROWN", `pc_tut_lesson1.jpg`). Use the
  space: show the faction's production at a glance (what each building is making), or the idle-worker and army counts.
  **M**
- **5.9 The minimap** (all HUD pictures) is small and dark: the terrain is a dark green-brown, own units are blue dots
  and the camera box is a thin white line. Missing: buttons beside it (SC2/AoE IV/BAR have: ping/flare, show terrain,
  ally colours, toggle creeps/resources). Proposals: lighten the terrain; draw buildings as squares, units as dots;
  add a PING button (online and co-op) and a "colours: team / player" toggle. The alert's flashing spot is good; add a
  **jump to the last alert** key (Space in SC2: here Space centres on the selection; use Backspace or a click on an
  ALERT button beside the minimap). **M**, the jump alone **S** ⚡
- **5.10 IDLE / ARMY / MAKE + groups** (bottom bar): the best part of the HUD. IDLE shows a count ("0"): make it
  **glow or pulse when not 0**, the most useful signal for a new player (AoE IV's idle villager button). **S** ⚡
- **5.11 The camera tabs F4-F9** sit above the groups like folder tabs; they are tiny and few players will find them.
  Fine for experts; on the phone (`mobile_crown_army_selected.jpg`) they still say "F4..F9", which means nothing on a
  touch screen. Hide the key names on the phone (keep the tabs). **S** ⚡
- **5.12 The MENU** in a match (`pc_crown_menu.jpg`) puts the music player beside PAUSE / SURRENDER / QUIT. It is
  charming but makes the menu twice as busy as it needs to be; and MINIMAP 60% is a display setting. Move the music
  list to Settings > SOUND (keep NEXT and the volume sliders). SURRENDER should sit apart from the other buttons
  (it is red: good) so it is not hit by mistake. **S**
- **5.13 Tooltips are walls of text** (`pc_crown_make.jpg`: the Haulers tooltip is 12 lines; the Musketeer's is 5 in
  the tutorial). SC2/AoE IV use: name, cost, one line of what it does, then a "more" line. Proposal: first two lines
  only; hold Shift (or a long press) for the whole text. **M**

### 6. Faction specifics

- **Crown** (`pc_crown_card_*.jpg`): the Barracks has the toggle ARM WITH POWDER as a card button among the units:
  it is a state, show it as a switch with ON/OFF on the button face. The Foundry card shows costs top right and the key
  top left: good. The army card mixes unit and band orders (DRUMS SOLO, SELECT BAND) with the artillery's (UNLIMBER,
  DEPLOY, CANISTER): 12 buttons, fine. Supply shows 51/18 in red when over cap in the sandbox: the real game should
  never put the player there, only a note.
- **Clockwork** (`pc_clockwork_*.jpg`): the gear floor is beautiful but busy: rings, plates, the "100%" bars and the
  spring icons on every building. The resource pill "0/200 tension" mixes a word into the number pills; make it an
  icon like the others ("⟳ 0/200"). A mixed army with Winders (`pc_clockwork_battle.jpg`) shows BUILD, LOAD CREW, REPAIR,
  WORK on the same card as the soldiers' orders: let Tab cycle the card between the subgroups (as SC2 does) instead of
  merging them. **M**
- **Brood** (`pc_brood_card_brood_mother.jpg`, `pc_brood_army_selected.jpg`): the Mother's card is 12 buttons with
  production (GRUB, RAPTORS, BRUTE...), the economy (ROOTMAWS 1/3), research (LAYING +20%, QUICK ROOTS, SWAMP MENDING),
  growth (GROW) and UPROOT all in one page; the keys are scattered (O grow, W laying, U quick roots, M swamp). Split
  into two pages (EGGS / NEST) or put research on a sub-page like SC2's "build advanced". The dark buttons (can't
  afford vs locked vs not researched) look the same: draw "locked" with a padlock and "can't afford" with the cost in
  red. The army card's **SACRIFICE (+720)** sits beside HOLD: a costly, irreversible order one key away; ask for a
  second press (or Ctrl+key) on a group. **S** ⚡

### 7. Command cards and hotkeys (all `..._card_...` pictures, `pc_crown_make.jpg`)

- **7.1** The 4 x 3 grid and its look are good: icon, name under it, key top left, cost top right.
- **7.2 Labels are tiny** on long names ("OBSERVATION BALLOON", "FIELD CANNON", "SWAMP MENDING" shrink to ~7 px).
  Two-line labels at a fixed readable size, or the name only in the tooltip and a bigger icon. **S**
- **7.3 The keys follow the names** (Settings COMMAND KEYS: BY NAME, the default). Result: the same letter does
  different things on different cards and the same unit has different keys in different places: on MAKE (all
  production) **A = Musketeer, F = Dragoon, E = Field Cannon**; on the Foundry **F = Field Cannon**; on the army **A =
  Attack**. A player who pressed MAKE then A expecting attack-move trains a Musketeer. SC2's grid keys (QWER/ASDF/ZXCV
  by position) avoid this and work in every language; the game already has them. **Proposal:** GRID by default for new
  players; on MAKE, never re-letter units, use the grid. **S** ⚡
- **7.4** Orders that are a state (ARM WITH POWDER, WORK auto, HOLD FIRE, AI / gear view toggles) should look like
  switches (a light or ON/OFF), not like buttons. Today some glow gold, some do not. **S**
- **7.5** The card scrolls with Tab when it has more than 12 items: show a "1/2 ▸" page tab on the card so the player
  knows there is more (on the phone: a visible arrow). **S** ⚡
- **7.6** Seen once in the picture tool (computer only, after selecting the whole army then a Barracks within 0.4 s):
  the Barracks showed the army's card. It did not happen on the phone run. Passed to qa-click-sweep to check.

### 8. Big battle (`pc_crown_battle.jpg`, `pc_clockwork_battle.jpg`, `pc_brood_battle.jpg`)

- Readable at this scale; powder smoke and the Brood's red spines carry the drama. Problems: the selection circles of
  30 units plus the "+5%" marks plus stacked bars make a green-white mesh over the fight; the enemy is told apart only
  by colour (red vs blue). Proposals: thinner selection circles when more than ~12 are selected (SC2 draws them
  fainter); enemy health bars red-framed; a short "DAMAGE TAKEN" vignette at the screen edge when your army takes
  heavy losses off-screen. **S/M**

### 9. End screen (`pc_crown_end.jpg`, `pc_audit_report.jpg`)

- VICTORY title, a table you vs them, a graph with ARMY / INCOME / WORKERS, and five buttons. Good basis. Missing: the
  **graph's time axis** has only "0m" (no ticks); no **production / build order tab** (when each building and unit
  came: the most-asked-for screen by players who want to improve); no **APM** (put it here, not in the match); no
  "best moment" link into the replay. Five equal buttons: make WATCH REPLAY and MENU the two clear ones, PLAY AGAIN
  green; COPY LOG belongs under a small "…" (it is a playtest tool). **S** for the axis and buttons ⚡, **M** for the
  build-order tab.

### 10. Spectating (`pc_audit_spectate.jpg`)

- AI STORY, PRODUCTION, ARMY & STRUCTURES and the top lines per player are rich, like a caster's screen. On 1600 x 900
  they cover 60% of the view. Let each panel collapse to its title bar (the ▼ is there: make the default for AI STORY
  "collapsed to 3 lines") and allow the panels at 80% opacity. **S**

### 11. Campaign: hubs (`pc_camp_hub_*.jpg`, `mobile_camp_hub_prologue.jpg`)

- The painted rooms are lovely. Problems: the **GO TO** list has 9+ entries and the last are cut off (THE ARMOURY
  NEW, and one more below) without a visible scroll bar; the room tabs (THE STUDY, THE ARMOURY · NEW, THE CHAPEL ·
  NEW) repeat entries of GO TO; the "NEW IN THE HUB" line is one long green paragraph. Proposals: GO TO as a short
  list of *people* (talk) with the WAR TABLE apart and big; rooms only as the tabs; NEW as small badges on the tabs
  (as done); the news paragraph as two bullet lines, dismissable. Make the people **clickable in the painting**
  (hotspots exist in the data: highlight them on hover with the name). **M**
- The storyline buttons top right ("The Crown · Start here", "The Naturalist", "The Clockmaker") look like
  ordinary buttons; they are the most important choice on the page for a first-timer. A "THE STORYLINES" label and the
  three faction crests. **S**

### 12. Campaign: war table, war map, briefing (`pc_camp_war_table.jpg`, `pc_camp_warmap_*.jpg`, `pc_camp_briefing.jpg`)

- The painted parchment, the brass map and the specimen chart are the visual highlight of the game. Problems: in
  Europe (Fürth) and in Brazil the seals **pile on top of each other** at the world view; the title says "ACT 1"
  while Act 2 seals and dates (2777-2780) show; the brass skin's grey seals are hard to tell apart (planned vs open
  vs done). Proposals: cluster seals into one with a number at low zoom (opens on click/zoom); the title follows the
  latest act reached; give the seal states shapes, not only tint (a ring for open, a tick for done, a padlock for
  locked). **M**
- The briefing (`pc_camp_briefing.jpg`) is excellent: painting, "You lead", the story, objectives, difficulty with a
  line about it, START. Only: make "(optional)" objectives look different (a hollow bullet) and put the reward or
  consequence ("affects: the city's temper") on the line. **S**

### 13. Campaign: in the mission (`pc_camp_mission_p01_*.jpg`, `pc_camp_mission_c01_15s.jpg`, `mobile_camp_mission_p01_20s.jpg`)

- The dialogue box with a portrait, NEXT and SKIP is clear; the objectives box top left with check boxes and a timer
  is clear. Problems: the night of p01 is **very dark** (the units are hard to see without the selection); the dialogue
  box covers the top right, where the minimap is in SC2 but here the MENU and resources live; the dialogue and the
  objectives together take ~25% of the screen on the phone. Proposals: a brightness floor at night (or a "night
  visibility" setting); the dialogue to the bottom middle over the selection panel while it talks (as in SC2/WC3),
  fading to a one-line subtitle after its first page; objectives fold to their count ("OBJECTIVES 0/4 ▸") after 10 s
  without change. **M**
- An objective's place on the map: add a small map marker / minimap ping when an objective is added or updated (the
  engine has `ping`; use it every time). **S** ⚡

### 14. Tutorial (`pc_tut_list.jpg`, `pc_tut_lesson1.jpg`, `pc_tut_lesson3.jpg`)

- The list of lessons by faction is clear. Lesson 1's first screen has: a 3-line dialogue, the LESSON box, a big
  "OPTIMAL EXPANSION SPOT" golden square, **supply "5/0" in red**, a Musketeer tooltip, an empty HUD with "CROWN" in it.
  For a first-time player, hide everything the lesson has not taught yet: the expansion spot, the hotbar groups, the
  camera tabs, APM, the speed slider, the supply until the supply lesson (progressive disclosure, as SC2's
  "Wings of Liberty" missions and AoE IV's Art of War do). **M**
- The lesson's instruction ("Move the view (screen edge, arrow keys or middle button)") should show an arrow / hand
  animation and say the phone's gesture on a phone. **S**

### 15. World war (`ww_pc_*.jpg`, `ww_mobile_*.jpg`)

- The top bar gives the season, whose turn, gold, income, upkeep, lands and key regions in one line: good, but dense
  text; turn the numbers into pills with icons like the match HUD. The map is a plain flat parchment with hatched
  regions; next to the campaign's painted maps it looks like a prototype. Use the campaign war map's painted world (or
  its parchment texture and seals) for the world war: one art direction. **M/L**
- The battle question (`ww_mobile_8_battle_question.jpg`) shows "your side wins about 0 times in 100" and offers only
  AUTO-RESOLVE and FIGHT IT: add **CALL IT OFF / RETREAT**. Also "1 Pendulums", "1 Field Cannons", "guard 0" read as
  machine text. **S** ⚡
- The region card (`ww_pc_5_region_card.jpg`) is clear: what it is, what to build, cost. The hint at the bottom left
  ("Your armies are the discs with a gold ring...") is good onboarding; keep it until the first turn ends.
- −/+ buttons next to HELP and LOG in the top bar are zoom buttons with no label: put them on the map's corner as on
  the war map (+/- top left). **S** ⚡

### 16. Tournaments (`tour_pc_*.jpg`, `tour_mobile_*.jpg`)

- Bracket, standings, schedule, players, rules as tabs, zoom and FIT: solid. The bracket's text is ~10 px at FIT on
  1600 x 900 and unreadable on the phone at FIT; highlight the **next match** (and "your" match online) with the gold
  frame and centre on it by default instead of FIT. Faction colour bars on each row are good. **S**

### 17. Online, ranked, replays (`pc_online.jpg`, `pc_ranked.jpg`, `pc_replays.jpg`, `mobile_replays.jpg`)

- ONLINE: a paragraph of explanation, the RELAY ADDRESS field shown to every player (with the old "pocketrts" name),
  HOST A GAME, ROOM CODE + JOIN + WATCH. Hide the relay field (Settings > OTHER); write the explanation as three short
  lines with icons ("1. One player hosts. 2. Send the code. 3. The host's device runs the match."). A **RECENT ROOMS /
  FRIENDS** row (codes used before) would save typing. **S** ⚡ for hiding the field.
- REPLAYS: each row has WATCH (green) + KEEP + EXPORT + DELETE: a column of green buttons; campaign replays show the
  map id ("nuremberg_advent", "virginia_leaf") instead of the mission's title. Proposals: the row itself opens the
  replay (one green WATCH only on hover/selected), the mission title for campaign replays, DELETE in the red "danger"
  style and asking first, a filter (faction / mode / result). **S** for titles ⚡, **M** for the rest.
- In a replay: the replay bar (not pictured in this run, see `docs/replay_mixed.md`) should get the SC2 "production"
  and "army value" overlays the spectator mode already has. **M**

### 18. Map editor (`pc_map_editor.jpg`, `mobile_map_editor.jpg`)

- Tools as buttons on the left, file actions on top, PLAY green: clear. The 12 tool buttons are words only; icons
  would make the palette faster to scan. A minimap of the whole map, and the **mirror** status (TURN 180) shown as a
  live preview line across the canvas, would help symmetric maps. **M**

### 19. Phone usability, all screens (`mobile_...`)

- At 2400 x 1080 on a 6.5" phone (~16.5 px a millimetre), the **command buttons are ~85 px (~5 mm)** and the
  **selection portraits ~60 px (~3.5 mm)**: below the usual 7-9 mm thumb target. The group buttons (~95 x 60 px) and
  IDLE/ARMY/MAKE are fine. Proposals: on the phone, the card 3 x 4 instead of 4 x 3 with bigger buttons, or a
  two-page card; portraits bigger with fewer per row (a "16 ×" type tile per kind, as the type tabs already do, is
  enough on a phone). **M**
- DRAG: BOX, the chat and the "?" sit top right in thumb reach: good. The minimap at the bottom left is under the left
  thumb: good.
- Keyboard words on the phone: F4..F9 on the camera tabs, "Ctrl+A" on ATTACK GROUND in some cards, "Left click paints
  · right drag or WASD" in the editor. Replace them on the phone with gestures. **S** ⚡

### 20. Art direction consistency

- Consistent: panels, fonts, the gold serif titles, the painted backdrops, the campaign art, the three card icon sets.
- Inconsistent: the **world war's flat map** (see 15); the **map editor's** plain look; the **team colours**: in a
  skirmish the human Crown is BLUE (colour slot 0) while the Crown's identity colour is PURPLE (menu painting, campaign,
  war map seals): a new player who picked the Crown sees blue soldiers. Proposal: "colour: FACTION" as the default slot
  colour when it does not clash (purple Crown, red Clockwork, green Brood), FITS MAP / team colours otherwise. **S**
- The floating labels (5.4) use a plain dark box and a sans font that is not used anywhere else in the HUD.

## Top 15 ideas to add or change (ranked by value for effort)

| # | idea | why | effort |
|---|---|---|---|
| 1 | ⚡ **GRID hotkeys by default** (and on MAKE never re-letter units) | the same letter attacks on one card and trains a Musketeer on another; grid keys work in every language and on every card (7.3) | S |
| 2 | ⚡ **Income per minute + supply-block warning** in the resource bar | the two numbers every RTS player watches; the spectator line already computes income (5.1) | S |
| 3 | ⚡ **IDLE glows when not 0**, and a **jump to the last alert** key/button | the commonest new-player mistake is idle workers; the alarm sounds but there is no way to go there (5.9, 5.10) | S |
| 4 | ⚡ **Fewer floating marks**: one "+5%" per band, labels small or on hover | the battlefield and the base are covered in text (5.4, 5.5) | S-M |
| 5 | **Production queue and progress** on the selected building (and a faint bar on the building itself) | the player cannot see what a building is making or how far (5.7) | M |
| 6 | **Colour-blind team colours + text size** in Settings | red/green/blue/yellow teams, red/green bars and a green faction; no text size for menus (3) | M |
| 7 | **Bigger tap targets on the phone** (card 3 x 4 or two pages, bigger portraits) and no keyboard words there | buttons ~5 mm, portraits ~3.5 mm (19) | M |
| 8 | **Tutorial: show only what was taught** (hide expansion spots, groups, camera tabs, APM, speed, supply at first) | lesson 1's first screen asks too much at once (14) | M |
| 9 | ⚡ **Hide APM in matches** (end screen only), label the speed slider, move the relay address to advanced settings | small noise removed from every match and the online page (5.2, 5.3, 3, 17) | S |
| 10 | **Short tooltips** (name, cost, one line; Shift / long press for more) | tooltips are paragraphs (5.13) | M |
| 11 | **End screen: build-order / production tab + time axis + APM** | how players learn from a game; the graph has no time marks (9) | M |
| 12 | **Brood Mother's card split** (eggs / nest+research) and locked vs can't-afford looks | 12 mixed buttons, scattered keys (6) | S-M |
| 13 | ⚡ **World war: CALL IT OFF on the battle question**, plural/zero fixes, zoom buttons on the map | a 0-in-100 battle can't be declined (15) | S |
| 14 | **Campaign war map: cluster seals, act-aware title, seal shapes by state**; hub GO TO list shorter, people clickable in the painting | seals pile up in Europe and Brazil; GO TO is cut off (11, 12) | M |
| 15 | **Default team colour = the faction's colour** (purple Crown, red Clockwork, green Brood) when no clash | the Crown is purple everywhere except in the player's own skirmish (20) | S |

Quick wins in one list (each about an afternoon): 1, 2, 3, 9, 13, 15, the main menu's green button (1), the
skirmish's default faction hint (4), page tab on long cards (7.5), objective pings (13), replay titles (17), the
SACRIFICE confirm (6), the camera tabs' key names on the phone (5.11).

## For the owner

- Nothing here was built; every item is a proposal. Pick the numbers you want and a job can do the quick wins in one go.
- The one thing that may be a real bug (7.6, a stale command card once on the computer) went to qa-click-sweep.
- The picture tool `tools/shot_qa_ui_review.gd` can be run again after changes to compare (parts `camp`,
  `match_crown`, `match_clockwork`, `match_brood`, `misc`; usage in its header).
