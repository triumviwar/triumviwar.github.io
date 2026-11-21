# Playtest, 21 November 2026: skirmish played as the Clockwork

Job playtest-skirmish-clockwork, one of the eight playtest jobs the owner asked for at 02:45 ("simulations of players,
buttons pressed, actually play the game"). Played on 0.38.107 (main), fixes on the branch `playtest-skirmish-clockwork`.
Pictures: `docs/shots/playtest_2026_11_21/skirmish_clockwork/`. The drivers are in `tools/playtest/cw_*.gd` and can be
run again (how, at the top of each file).

## How it was played

Every action went through real input, as an operating system sends it: mouse buttons and motion (the engine then makes
its own emulated touches from them, as on a real computer), keys with Shift, Ctrl and Alt held around them, and real
screen touches for the phone runs. The drivers start at the very first screen (the device page on a fresh settings file,
or the crash page when a previous run was killed), pick the language by its flag, press SKIRMISH or EDITOR > SANDBOX,
open each dropdown of the skirmish page and pick its row, and press START. In the match the "player" reads the game's
state to decide what to do (where things are, what the card shows, what it can pay for) but acts only by input: the
minimap and the arrow keys move the camera, clicks and box drags select, card buttons are clicked or their hotkeys
pressed, right clicks give orders. The only thing set directly is the clock speed (Engine.time_scale, 1.2 to 3).

The drivers:

- `cw_match.gd`: a whole skirmish as a Clockwork player with a build order, Winders sent to the presses and the
  Mainspring, production at every building, rally points, defence when the enemy reaches a building, attack waves with
  Winders escorting, retreat. Styles: careful (clicks the buttons), fast (hotkeys, F1/F2, double-clicks), phone (taps).
- `cw_tour.gd`: every Clockwork button and control in a SANDBOX match (the panel's +1000 COGS and +200 TENSION pay for
  the whole tree, the other side's computer switched off): every building with its gear pick, the turret circles, the
  gear view, every unit and research, every ability, the controls (groups, double-click, Ctrl-click, box, Shift queues,
  drag-a-line, hold, stop, patrol, attack ground, F1-F3, camera views, zoom, arrows, Space, Tab), the match menu (pause,
  settings, quit and CONTINUE, surrender), the end screen (COPY LOG, VIEW MAP, WATCH REPLAY).
- `cw_lobby.gd`: every option of the skirmish page, Esc with a list open, a resized window, and a confused player
  clicking at random and pressing Esc.
- `cw_breaker.gd`: a player trying to break things: placing off the map, on buildings, on cliffs; Shift-queued sites
  then Esc; a site cancelled; five Winders queued then cancelled; DEMOLISH; a hotkey storm with nothing selected; box
  drags from the HUD and out of the window; the window resized three times mid-match; QUIT TO MENU while placing.
- `cw_card_shots.gd`: a check tool (not a player): every Clockwork card pictured in a language, with every label that
  does not fit its button even at the smallest size listed.

What was played:

| run | where | opponent | size, input, language | result |
|---|---|---|---|---|
| 7 full matches | Greenhold (4), Kestrel Rise (2), Cinder Steps (1) | Crown Hard OPTIMAL (4), Brood Hard OPTIMAL (2), Clockwork Hard OPTIMAL (1) | 1280x720, mouse and keys, careful and fast | all lost, between 10:00 and 15:30 (one dragged to 20:45: finding 1) |
| 1 match | Cinder Steps | Crown Normal BALANCED | phone 844x390, touch | ahead at 9:00 (37 units to the Crown's), stopped there |
| 4 short matches | Greenhold | Crown Hard OPTIMAL | 1280x720 | 4 to 8 minutes, to tune the player |
| 5 tours | Greenhold sandbox | Crown, computer off | 1280x720 English (3), Portuguese with hotkeys (1), phone 844x390 touch (1) | about 60 checks each |
| lobby, breaker x2 | menus, Redrock Canyon sandbox | | 1280x720, 1024x600, 800x600, 1600x900 | |
| card pictures | sandbox | | English, Portuguese, Spanish | 19 cards each |

I did not win against Hard. That says more about my scripted player than about the game: a script reacts slowly (it
spends 3,000 cogs too late, rarely uses the army well), and when two matches ran on the machine at once it played at
the APM of a beginner. The one run alone on the machine against a Normal Crown was ahead at 9:00. Against the Hard
OPTIMAL computers the Clockwork's army at 8:00 was 15-35 supply, and a Crown cannon-and-musket push or a Brood swarm
took the base at 10-15 minutes. A real "decent player" would do better; please read the balance notes at the end as
what a slow player feels, not as numbers.

## Findings

Severity: CRASH (none found), BUG, UX, DESIGN, ART, DOC. "Fixed" names the commit on the branch.

### Fixed on the branch

1. **BUG: a beaten Clockwork stayed in the match 7 minutes.** Lost v Crown Hard on Greenhold: at 13:40 I had no
   Winder, no unit, no Clocktower and no Mainspring, only a Light Works cut off from the gear field ("UNLINKED", 0%),
   and 2,200 cogs. The 60-second "nothing left to fight with" rule (Game.helpless) counted the Light Works as able to
   train a Clock Soldier, though it trains nothing unlinked (and there was no supply either). The match only ended at
   20:45 when the Crown happened on it. Picture `before_lone_unlinked_light_works_17min.jpg`. Fixed (4c7f7d18): a
   building that cannot work (GearNet.speed_mult 0) does not count, and a unit needs the supply to come out.
   `tools/test_rules_fixes.gd` [helpless] checks both cases.
2. **BUG: the Ticking Owl could not be clicked on its body.** Every unit was picked 12 px over its feet; the Owl is
   drawn 52 px over its shadow (the Swift 34, just inside). Clicking where the bird is picked nothing, or the Winder under
   it. Fixed (36a4938b): a flyer is picked on its body (Unit.center) or its shadow. `tools/test_flyer_pick.gd`.
3. **BUG: the end screen said "Gold spent" for every side.** The rows are shared by all the columns: a Clockwork or
   Brood player read "Gold spent" for cogs or biomass. Picture `before_end_screen_gold_spent.jpg`. Now "Spent" (pt
   Gasto, es Gastado; 6dabae5d).
4. **BUG: "would clash with a Escapement's ring".** The gear-clash refusal put "a" before every name. Now "the %s's
   ring"; the pt/es texts had no article (0c3f0e4b).
5. **UX: command-card labels cut off.** At the smallest size some labels still overflowed their button and were cut:
   on the Clockwork's cards alone 15 in Portuguese (VISTA DAS ENGRENAGENS, SERPENTE DE LATÃO, ENGRENAGEM PEQUENA,
   CORUJA TIQUE-TAQUE, ATACAR O CHÃO, EMBARCAR EQUIPE...), 14 in Spanish (DADOR DE CUERDA, SOLDADO RELOJ, GRAN DADOR DE
   CUERDA...) and 4 in English (SPRING BALLISTA, GREAT WINDER, BRASS SERPENT, ATTACK GROUND on a flyer's card). Fixed
   (4af8dd98): such a label goes on two lines. Picture `after_card_labels_two_lines.png` (pt and es).
6. **UX: Esc with a skirmish dropdown open left the whole page.** The list stayed for a moment and the page went back
   to the main menu. Now Esc closes the list first (475b8b96).
7. **UX: every Winder's card carried a greyed LEAD button** ("No free horse of yours within 8 tiles"), a Crown horse
   command the Clockwork almost never has a use for, taking a card slot. It now shows on a Winders-only selection only
   when a loose horse is near or he already leads one (475b8b96). Picture `before_lead_on_winder_card.jpg`.

### Not fixed: proposals for the owner

8. **UX: two different things are called SMALL GEAR / BIG GEAR.** While placing any Clockwork building, SMALL GEAR /
   BIG GEAR (G) picks the building's ring. On the Heavy Works' own card, SMALL GEAR (15) and BIG GEAR (35+10) are the
   Brass Serpent's gears it builds into its store. A player who wants a big Heavy Works ring presses BIG GEAR on its card
   and buys a serpent gear instead. Picture `heavy_works_gear_items_vs_gear_pick.jpg`. Proposal: rename the store items
   SERPENT GEAR S / SERPENT GEAR B (or SMALL LINK / BIG LINK), with new pt/es texts.
9. **DOC: HOW TO PLAY > CLOCKWORK is out of date.** It still explains ENERGY and batteries, the Assembly Works with
   Wind-up Soldiers, Threshers, Bulwarks and Arc Throwers, the Engine Hall's Steam Walkers, Tesla Carts, Stormcallers and
   Ornithopters, Boilers, Charging Pylons and Spring Towers: none of these are in the game a player plays (gear mode).
   It says nothing of the Light Works, the Escapement and its three researches, the Heavy Works, the Clock Aviary, the
   Regulator, the Ratchet Turret, or the units: Clock Soldier (SHIELD FORWARD), Springer (JUMP, HIGH LEAP), Netter (LONG
   CHAIN), Pendulum, Spring Ballista, Great Winder (SWEEP, MEND), Brass Serpent (COLLECT, GROW, LINK, UNLINK), Swift and
   Ticking Owl. The gear, Tension and Winder paragraphs are good. Not changed here because each paragraph is the key of
   its pt/es translation: a rewrite needs the translations redone with it. A draft is at the end of this report.
10. **DESIGN / UX: new units run down while they wait at their own Light Works.** A unit winds up only standing on
    connected gear ground (inside a ring). The Light Works sends its units out beside its ring, and my rally points in
    front of the base were off the rings too, so the army waiting at home ran down; a Springer standing next to the
    Mainspring at 9% charge refused JUMP ("It has run down: wind it up first."). Picture
    `springer_run_down_off_the_field_pt.jpg`. Nothing on the screen says "this spot does not wind". Proposals: the
    default exit point of a Clockwork production building on its own ring; and a rally point off the gear field drawn
    in amber with a tooltip "units here run down".
11. **UX: Tension above its cap shows as "140/0 tension".** When the Mainsprings are lost the Tension held stays and
    the bar reads e.g. 140/0 or 2085/400 (the sandbox's +200 TENSION goes past the cap too). Proposal: show the cap in
    amber when held > cap, and say in the tooltip that held Tension stays spendable.
12. **UX: hover tooltips cover the ghost while placing.** Placing a turret, the "Drive · Efficiency 100%" tooltip of a
    building's label popped up over the ghost and its red circle. Picture `turret_overlap_feedback.jpg` (the turret
    circle feedback itself is very clear: TOO NEAR A TURRET over a red circle). Proposal: no world tooltips in place mode.
13. **UX (phone): the HUD takes about 40% of a 844x390 screen** and the 8-px card labels are hard to read at that
    size. Pictures `phone_844x390_gear_view.jpg`, `phone_844x390_building.jpg`. Settings has a UI size; on a small phone
    a "compact HUD" (no hotkey-bar row, a smaller panel) may be needed. On the plus side, touch played a whole match:
    taps select, double-tap picks the kind, a tap on a press's WINDERS label picks its crew, pinch zooms, BOX/PAN works,
    the ghost moves with a tap and a second tap (or PLACE) builds.
14. **UX (pt/es): the Swift and the Clock Aviary keep their old names** ("Cuco", "Casa do Cuco" / "Casa del Cuco")
    while the English is Swift and Clock Aviary. Consistent inside each language, so it may be a choice; if not:
    pt "Andorinhão" and "Aviário de Relógio", es "Vencejo" and "Aviario de Relojería". Picture
    `aviary_called_casa_do_cuco_pt.jpg`.
15. **UX: a building's one-line info is cut with "..."** in the selection panel (Light Works: "Makes Clock Soldiers,
    Spri..."). Picture `light_works_info_cut.jpg`. Proposal: let it wrap to two lines or show it in the tooltip.
16. **DESIGN: no game speed in a skirmish.** Only the sandbox has SPEED x2/x4. Many single-player RTS let you play a
    skirmish against computers slower or faster; a slow speed would help new players most with the Clockwork's many
    rules. A question for the owner.
17. **UX (sandbox only): after the match, VIEW MAP's MENU button lies under the open SANDBOX panel.** Picture
    `sandbox_panel_over_view_map_menu.jpg`. Close the panel at the end of a sandbox match, or draw the bar above it.
18. **DESIGN, what a slow player feels.** The Clockwork's opening is long: 4 Winders, the first Light Works at about
    3:00 if the Mainspring and the second press go first; the first Clock Soldier at about 3:30. Tension is the brake on
    everything past the Clock Soldier (a small Mainspring 2 a second, Pendulum 75, Great Winder 75, Netter 50), so cogs
    pile up while the Tension units wait; the big Mainspring (6 Winders) is the obvious pick once one knows it. The gear
    rings take a lot of room: on Kestrel Rise (84x84) my main was full after about eight buildings and the next ones had
    to chain out ring by ring. None of this is a bug; it is the learning curve the HOW TO PLAY text (9) should carry.

### Checked and fine

- The skirmish page: the seven quick set-ups, + ADD PLAYER up to 8 and ×, every slot's lists, a colour taken by another
  slot greyed, everyone on one team refused ("Everyone is on one team."), RANDOM faction, the map arrows and list, the
  Clockwork computer's 10 plans (BALANCED, RUSH, ECONOMY, TIMING ATTACK, PENDULUMS, HEAVY WORKS PUSH, SPRINGER TIMING,
  CLOCK SOLDIER RUSH, OWL RAIDS, OPTIMAL), the page at 1024x600; 40 random clicks and Esc never started a match.
- Building: BUILD, every building button with its requirement in red ("Needs a Light Works first.", "The Escapement
  stands idle: its gear network has no Mainspring."), G and the SMALL/BIG GEAR button on the ghost (with a toast saying
  what the big ring changes), the Heavy Works only on a big ring, Esc and right-click cancel, refusals on bad spots keep
  the ghost, Shift-click keeps placing while Shift is held, the crate carried by a Winder who then goes back to his press,
  DEMOLISH asks twice, the Clocktower has no DEMOLISH. The turret circles refuse a second turret with a clear message.
- Winders: right-click a press or the Mainspring (crews, "fully crewed" toast), the WINDERS n/m label picks the crew,
  WIND UP then a click on a soldier, Winders selected with soldiers ESCORT the army.
- Every unit trained, every research done (SHIELD WALL, HIGH LEAP, LONG CHAIN, TICKING OWL) with its toast; SHIELD
  FORWARD, JUMP (a Springer hopped about 4 tiles), MORPH TO OWL, COLLECT and GROW (refusals "No Heavy Works has gears in
  store.", "Not enough supply for another gear."), LINK and UNLINK appear on a two-Serpent selection, Great Winder MEND,
  SWEEP and SCATTER COGS, Ballista LOAD CREW / UNLOAD CREW, the gear view (` or GEAR VIEW on the card).
- Controls: box select, Ctrl+1 / 1 / 1 twice, Esc clears, arrows pan, wheel zoom, Shift+F5 / F5, F1 / F2 / F3, three
  Shift-queued moves, the right-button drag-a-line spreads the army, H, S, P, Ctrl+A, Ctrl-click, double-click, Space,
  Tab pages a long card. All five card pages read in English, Portuguese and Spanish.
- The match menu: PAUSE and RESUME, SETTINGS over the match and Esc, QUIT TO MENU then CONTINUE (units and clock came
  back the same, also after quitting while placing), SURRENDER with its YES / NO, the end screen, COPY LOG (the match
  log on the clipboard, 62,637 characters, starting "Triumviwar v0.38.107 match log"), VIEW MAP. The window resized
  to 800x600, 1600x900 and back mid-match kept the HUD whole.
- No SCRIPT ERROR, no "Invalid call" and no crash in any run (the engine's own Mesa and audio warnings aside).
- Existing tests run after the fixes: test_rules_fixes, test_flyer_pick (new), test_hotkeys, test_selection_panel,
  test_card_keys, test_cw_air, test_brass_serpent, test_winder_escort, test_gear_rules, test_ratchet_turret,
  test_horse_leash, test_mount_select, test_spectator, test_menu_grid: all pass. test_i18n fails on main too (the Nitre
  Beds' three study texts have no pt/es).

## A draft for HOW TO PLAY > CLOCKWORK (finding 9)

Kept: the first three paragraphs (THE GEAR FIELD, COGS AND TENSION, WINDERS WITH THE ARMY), BUILDING and "Brass and
spring life". Replace ENERGY, Assembly Works and the constructs paragraph with:

> THE BUILDINGS: the Regulator gives 10 supply. The LIGHT WORKS makes Clock Soldiers, and with a working Escapement
> Springers and Netters. The ESCAPEMENT (needs a Light Works) researches SHIELD WALL, HIGH LEAP and LONG CHAIN. The
> HEAVY WORKS (big ring only, needs the Escapement) makes Pendulums, Spring Ballistas, Great Winders and Brass Serpents,
> and the Serpents' gears. The CLOCK AVIARY makes Swifts and researches TICKING OWL. The RATCHET TURRET fires screws at
> ground and air. Everything that costs Tension is made only at a building a Mainspring feeds through the gear network.
>
> THE ARMY: Clock Soldiers fight hand to hand (SHIELD FORWARD with SHIELD WALL: slower, half the damage of shots from
> the front). Springers shoot screws and JUMP over a gap (HIGH LEAP: onto high ground they can see). Netters throw nets
> that hold units and pull flyers down (LONG CHAIN: from far behind the line). Pendulums sweep everything in their arc,
> flyers too. Spring Ballistas shoot through a line. The Great Winder MENDS and winds the army and SWEEPS wrecks for
> cogs. The Brass Serpent grows with every gear (COLLECT at a Heavy Works, GROW: a Winder carries one out) and LINKS
> with others into a Hydra. Swifts hunt flyers; MORPH TO OWL turns one into a Ticking Owl that bombs buildings.
>
> WIND: your machines wind up standing on connected gear ground; away from it they run down, slower and weaker, until a
> Winder cranks them (Winders with the army do it by themselves). Supply cap 200.
