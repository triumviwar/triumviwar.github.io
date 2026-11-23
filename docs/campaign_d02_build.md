# Act 2, "The Exodus": what was built (job d02-exodus)

Act 2 step 2 (docs/campaign_act2_plan.md "d02_exodus"): the Clockmaker line's first Act 2 mission, after Rome. Fürth in
February 2771, ten months after the Council: the Crown's commissary is coming with Rome's verdict, and the guild leaves
by night with its families and machines, down a frozen valley to the barges on the Main. Hollweg tells it as a rescue;
the King tells it as a desertion. It is also THE ROSTER LADDER's K4: the guild's new pieces are the RATCHET TURRET and
SHIELD WALL.

EVERY LINE OF TEXT IS A PLACEHOLDER for the owner to rewrite (kept short and plain on purpose). The stills are stand-ins.

## Files

| what | where |
| --- | --- |
| the mission | `campaign/missions/d02_exodus.json`, written by `tools/campaign/make_d02_mission.py` (edit the script, run it) |
| the map | `campaign/maps/furth_exodus.json` (`campaign:furth_exodus`), written by `tools/campaign/make_furth_exodus_map.py` FROM a04's `furth_works.json`; opens in the MAP EDITOR |
| the stills (stand-ins) | `campaign/stills/d02_01.jpg` .. `d02_04.jpg`, drawn by `tools/campaign/make_d02_stills.py` |
| texts pt / es | `tools/i18n/campaign/d02_exodus.txt` (written by the mission script; then `python3 tools/i18n_build.py`) |
| the storyline, the hubs | `campaign/campaign.json`: d02 joins the Clockmaker line after a04 (it needs a07: Rome); Hollweg's, the clock's and the automaton's talks after d02 (by side). `campaign/hubs_grow.json`: Jakob, Ferrer, von Rauch and Anselm leave Fürth's barn after d02; Ulrich gets a line about the barge |
| the war map | `campaign/warmap.json`: d02's pin ("The Main", February 2771, after a07), a ship mark, the rules (below) |
| the roster ladder | `tools/campaign/roster_ladder.py`: K4 = d02 (RATCHET TURRET + SHIELD WALL), bound team `guild`, NEW cards at 8 s, side `exodus`, the cards in pt / es |
| roles | `scripts/campaign/rebels.gd`: `spring_cart`, `drawings_cart` (carts that never blow up), `brandt` (Commissary Brandt, on foot), `rauch` (Colonel von Rauch, a Cuirassier) |
| the engine | `scripts/campaign/mission_act2.gd` (the `take` order, two TAKE A CART fixes), `mission_run.gd` / `campaign.gd` (a team's `techs`); docs/campaign_engine.md "Added by Act 2's d02_exodus" |
| tests | `tools/test_campaign_d02.gd` (`godot --headless --path . --script res://tools/test_campaign_d02.gd`); d02 added to `tools/test_campaign_save.gd` and `.sh` |
| balance | `tools/sim_campaign_d02.gd` (`-- active [blob] [side=exodus|commissary] [diff=easy|normal|hard] [bells=rung] [saved=few|some|many] [jakob=lost] [gate=people] [furth=strong|thin|fallen] [broken=melted] [lost=N] [none] [until=s] [save_at=s] [shots=dir] [debug]`) |
| pictures | `docs/shots/d02_exodus/` (the sim's `shots=`, run under xvfb-run) |

## The map: from Fürth to the Main (128 x 80, snow)

a04's Fürth cell for cell on the east half (the works, the town, the Pegnitz, Nuremberg's red walls). The west is new:

- THE REDNITZ BRIDGE west of Hollweg's barn: the only way out of the yard to the west.
- THE VALLEY: the woods west of the Rednitz are cut by one valley. The road runs west from the bridge, then south. Five
  snow-laden thickets lie across it, open at one end then the other, so the road goes down in SWITCHBACKS. The carts
  take the long road; the riders on the slopes see all of it.
- THE WÜRZBURG TRACK comes down into the valley from the north edge: the commissary's riders' way round.
- THE BROOK at the valley's foot (frozen, but water all the same) with ONE BRIDGE: the last bridge.
- THE LANDING on the Main (the west edge, south): the jetty, crates, boats, the bargemen's sheds. Woods close it round.
  Past the brook bridge there is no other way in.

## How it plays: THE EXODUS (the guild; solo, or versus against the commissary)

Opening (the King, then Hollweg): the King signed the commissary's orders himself; Hollweg did not wait.

THE GUILD (BLUE, the player): MEISTER HOLLWEG (a hero: wounded, never killed), 4 Winders, 8 Clock Soldiers (drilled in
SHIELD WALL), 2 Springers, 2 Netters, a Pendulum, and the SPRING CART: a cart that lays brass plates round itself, and
every guild machine on them is wound. No Clocktower and no building: the works are being left (the plan's choice 3).
THE FAMILIES (scripted): one CART at each family's barn: 3 carts if few were saved at Nuremberg, 5 with some, 7 with
many. With c01's `gate` pattern, THE DRAWINGS CART by Hollweg's barn. JAKOB if he is alive.

PART 1, THE NIGHT BELL (until the riders come: 5:00 NORMAL, 6:15 EASY, 4:30 HARD, 1:30 more if Fürth fell):
- LOAD THE CARTS: send any guild unit to a cart's barn; after 3 s there, the family climbs in. The barns are marked.
- THE DRAWINGS (pattern): Hollweg himself must stand 4 s at his own barn.
- JAKOB (alive): he asks Hollweg to come to him. He will not go: he tells why, and walks to the Crown's camp. It is
  always so; the flag `jakob` stayed.
- FÜRTH FALLEN (a02 won by the Machine): a RECLAIM part first. The machine's seed sits on the Honest One's place with a
  guard. Burn it before any cart can leave.
- Everything loaded and Jakob's goodbye done: the convoy sets off at once. The riders coming first: whatever is not
  loaded stays (the family stays in Fürth, counted).

PART 2, THE ROAD:
- The carts go on a ROUTE over the bridge and down the switchbacks at a walking pace every escort keeps up with.
- The commissary's RIDERS come down the Würzburg track in three waves: when the column sets off, at the second bend,
  and THE DOGS at the fourth. A rider TAKES a cart by standing by it with no guild fighter near for 5 s (a bar fills
  under the cart). A taken cart turns back for Fürth. Drive them off it and get round it before it reaches their camp:
  it is the guild's again.
- The commissary's COLUMN (Brandt, von Rauch, Musketeers, a Field Cannon) comes through the yard behind and follows.
  With a04's `broken` melted: more nets than guns (no cannon, two more riders).
- THE MACHINE sees Fürth empty: a SORTIE from Nuremberg (6 Clock Soldiers, 2 Springers; 3 more with a04's
  `lost_to_machine` 2 or more) into the works and down the road. It fights whoever it meets, the Crown too.
- VON RAUCH'S MINUTE (c01's `bells` rung): 30 s after the column comes, the Colonel halts his men for one minute.
  "Let them go, God help them." Brandt protests. Then they come on again.

PART 3, THE BRIDGE (a cart at the landing):
- The guild's TRAVELLING CLOCK is set up by the brook (a Clocktower: its field winds anything near). FIVE JOURNEYMEN
  who came on the first barge join the player there (4 Clock Soldiers, a Netter).
- THE TURRET: a site at the bridge's foot; a Winder builds it with 200 gold the guild gets (K4).
- Every cart that reaches the barges goes aboard (counted). HOLD THE BRIDGE until the last barge is loaded (3:00).
- NO WAITING: when no Crown or machine fighter is near the landing, the bargemen hurry (the clock runs five times as
  fast).
- The barge loaded: Hollweg must walk aboard within a minute. Aboard: the win.
- THE REARGUARD BROKEN (no guild fighter at the landing and three of the Crown's men there 8 s): Hollweg can be taken.

LOSSES: Hollweg taken alive (brought down to a quarter of his health with a Crown man by him), the barge gone without
him, or every cart taken on the road (nothing left to save).

## How it plays: THE COMMISSARY (the solo mirror, or versus)

The narrator is FATHER FERRER, who rode with the commissary as Rome's witness. The player is the CROWN (PURPLE):
Commissary Brandt, Colonel von Rauch and the column (by a02's `furth`), from the second part on. The guild is scripted
(it loads its own carts, Hollweg says his goodbye, the convoy sets off at 0:30). Its size is the mirror's difficulty:
5 Clock Soldiers at EASY, 7 at NORMAL, 9 at HARD. The orders are to TAKE: carts are taken by standing round them, never
shot (the carts can't be hurt). WIN: take Hollweg alive (bring him down, a man by him). Objectives on the way: ride
three men into the valley, take two carts. The reserve (3 Musketeers and a rider) comes down the track when the barges
start loading. LOSS: Hollweg aboard the last barge.

## The flags read and set

| read | what it does in d02 |
| --- | --- |
| c01 `saved` few / some (canon) / many | the families' carts: 3 / 5 / 7 |
| c01 `gate` pattern (canon) / people | the drawings cart (Hollweg loads it at his barn) / none, and Hollweg says why |
| c01 `bells` rung / quiet (canon) | von Rauch's minute in Part 2 / none |
| c01, a02, a04 `jakob` alive (canon) / lost | Jakob's goodbye at the gate (always stays) / Hollweg alone, a line about it |
| a02 `furth` strong (canon) / thin / fallen | the commissary's men 4-3-2-1 / 3-2-2-1 (musketeers, first riders, second riders, guns) / a reclaim part in Part 1 and 1:30 more before the riders |
| a04 `broken` kept (canon) / melted | "seize or destroy": a cannon in the column / "seize": no cannon, two more riders, Ulrich says so |
| a04 `lost_to_machine` 2 or more | the machine's sortie +3 Clock Soldiers |

| set | values |
| --- | --- |
| `exodus` | few / some / many: the share of the carts that left by barge (under 40% / 40-75% / 75% and more); `exodus_n` the number |
| `drawings` | carried (aboard) / taken (left at the barn, or the cart taken); not set with `gate` people |
| `jakob` | stayed (he was alive) / lost (as before) |
| `hollweg` | taken (the commissary won: a broken seal on the war map) |

The war map after d02 (campaign/warmap.json): the pin on the Main; won by the guild, the ledger line "N families left
Fürth with the guild" (exodus_n) and a ship mark on the Main; the drawings carried or taken; Jakob stayed in Fürth; won
by the commissary, the seal BROKEN ("that is not how it went"). `next` is empty for both sides until d04_concordia is
built (then: exodus -> d04).

No CHOICE in d02 (the plan: "d01, d02, d03, d04, d06, d10 and d11 have none: counts and heroes carry").

## The engine (docs/campaign_engine.md "Added by Act 2's d02_exodus")

- ORDER `take`: scripted riders go for the nearest cart held by an enemy and stand by it, so TAKE A CART can work for a
  scripted side (the act2-engine0 take rule needs men round the cart; nothing sent them there).
- TEAM `techs`: a team starts with researches done (the guild's SHIELD WALL).
- TAKE A CART fixes: a cart taken in one tick can't be taken back in the same tick by a later rule (the rules shared
  their progress); cage carts never take or guard.

## Balance (tools/sim_campaign_d02.gd; the last runs)

The bot (guild): one fighter to each barn, Hollweg to his own, then the army round the carts (each fighter near the
cart that most needs it), riders hunted off carts, taken carts chased, Winders to the turret site in Part 3, shields up
in Part 3, Hollweg to the barges when it is time.

| run | result |
| --- | --- |
| NORMAL x10 (last two batches) | won 10 of 10, 4:00-4:35, 4-5 of 5 carts out, longest idle 13-16 s |
| HARD x4 | won 3, lost 1 (Hollweg taken at 4:04), idle 13-28 s |
| EASY x4 | won 4 of 4, idle 10-15 s |
| furth=fallen / thin, NORMAL | won (the reclaim first), 4:52, idle 37 s / won, 4:00 |
| bells=rung (von Rauch's minute), NORMAL | won, 4:03, idle 25 s |
| broken=melted lost=3, NORMAL | won, 4:01 |
| saved=few jakob=lost, NORMAL | won, 3 of 3 carts |
| gate=people, NORMAL | won, no drawings |
| blob (all fighters on one cart) | won, 3 of 5 carts out (2 taken) |
| passive (no orders) | LOST: nothing loaded, taken at 5:05 |
| commissary bot NORMAL / HARD / EASY | won 4 of 4 / 2 of 4 / 4 of 4 (Hollweg taken in 1:14-3:04) |
| commissary passive | LOST: Hollweg aboard at 3:04-3:07 |

The longest idle at NORMAL is 13-16 s (NO WAITING: under 45 s). The passive player's idle is long, as it should be.

## Stills: the prompts for the owner (ChatGPT, one request each, at most 3 reference images; each prompt stands alone)

- d02_01 THE NIGHT BELL. "Oil painting, 18th-century history painting style. Night in a snowy German workshop yard;
  families in dark blue coats load carts by lantern light; tall brass clockwork soldiers, wound by keys on their backs,
  carry chests; a grey-bearded master clockmaker in a long coat directs them from a cart's step. Snow falling. 3:2
  landscape, no text." (References: nuremberg_hollweg.png, a02_01.jpg, a04_02.jpg.)
- d02_02 JAKOB STAYS. "Oil painting, 18th-century history painting style. At a snowy works gate at night a young
  journeyman clockmaker with a leather apron turns away from a line of carts and walks towards distant soldiers in
  purple coats with lanterns; behind him an old master clockmaker watches, hand half raised. 3:2 landscape, no text."
  (References: nuremberg_hollweg.png, c01_08.jpg.)
- d02_03 THE ROAD. "Oil painting, 18th-century history painting style. A frozen valley road at dawn; a column of
  carts and brass automata hurries west down a winding road between snowy woods; horsemen in purple coats with nets
  ride down from a snowy slope; far off to the east a walled city glows red. 3:2 landscape, no text." (References:
  a02_03.jpg, c01_02.jpg.)
- d02_04 THE SHIPS. "Oil painting, 18th-century history painting style. A grey northern harbour; families in blue coats
  and crated brass machines go up the gangways of two tall sailing ships; an old clockmaker stands at the rail looking
  back. Gulls, cold light. 3:2 landscape, no text." (References: nuremberg_hollweg.png, a05_04.jpg for the crates.)

The commissary's opening and ending reuse d02_03 and d02_02 (Claude's choice 14).

## The voice lines

The table is in docs/chatterbox_todo.md ("d02_exodus"), with each dramatic line's feeling. New voices to design:
Commissary Brandt (a dry chancery official, German), Colonel von Rauch, Ulrich (the guild's foreman). Jakob is already
on the list from Act 1; Ferrer's voice was designed on 2026-11-22.

## What is placeholder

Every line of text (en, pt, es). The four stills. The roles' art (Brandt is a dismounted Cuirassier, von Rauch a
Cuirassier, the carts are powder wagons). The sounds (none new).

## Claude's choices for the owner

1. THE CARTS CAN'T BE HURT: the commissary's orders are to take, not to kill, so the carts are spared (no family dies on
   screen). A cart is lost only by being TAKEN.
2. THE WORKS ON A TEAM OF THEIR OWN: the guild's old presses and workshops are left standing on a scripted team
   (`works`), so the guild's Winders don't wander off to work them.
3. SOLO AND VERSUS ONLY, no co-op: the guild has one army; a second player would have nothing of his own.
4. THE TRAVELLING CLOCK: the plan says no Clocktower; Part 3 still gets one, set up by the bargemen at the landing (not
   built by the player), so the rearguard is wound and the K4 turret has its gear field. The spring cart winds on the road.
5. THE TURRET is a site a Winder builds with 200 gold given at the landing (the ladder's reactive turret, the owner's
   rule: static defence only as a last stand).
6. FIVE JOURNEYMEN at the landing (4 Clock Soldiers, a Netter): the player's rearguard is never only what survived the
   valley. Without them the bot lost every HARD run in the valley fights.
7. THE COMMISSARY'S COLUMN comes in Part 2, not before: in Part 1 the riders are "a day's ride off" (the countdown).
8. THE SCRIPTED CROWN can take Hollweg only once the rearguard is broken (no guild fighter at the landing and three of
   theirs on it 8 s). Before that it fights; only a commissary PLAYER can go for Hollweg at any time from Part 2.
9. A SHORT MISSION: 4-5 minutes for the bot, about 6-10 for a person (the loading, the road and the bridge are each a
   couple of minutes). The commissary's mirror can end in about a minute and a quarter when the player rides straight at
   Hollweg on the road.
10. `next` is EMPTY until d04_concordia is built; d02 NEEDS a07 (Rome).
11. THE QUIET BANK: with no enemy near the landing the last barge loads five times as fast (NO WAITING).
12. TAKEN CARTS go to a team of their own (`seized`, scripted), so they drive back to Fürth on their own and a guild
    player can tell them apart.
13. THE DOGS are the third rider wave (two riders at the fourth bend); there are no dog units.
14. THE COMMISSARY'S PAGES reuse the guild's stills (THE ROAD for the opening, JAKOB STAYS for the end), until the owner
    wants stills of their own.
15. JAKOB ALWAYS STAYS (the plan): there is no way to make him come.
16. THE CAPTURE: Hollweg below a quarter of his health with a Crown man within 3 tiles (as a06's Varenne).
17. THE `take` ORDER is a new engine order; the act2-engine0 take rule had nothing to send scripted men to the carts.
18. THE MIRROR'S DIFFICULTY is the guild's size (5 / 7 / 9 Clock Soldiers), not the spawns: the scripted guild is
    placed at the start, and the Machine's smaller EASY sortie had made EASY the hardest.
19. HARD here is spawns x1.1 and clocks x0.9 (not the default x1.25 / x0.85): at x1.25 the bot lost every HARD run.

## What is left

- The owner's texts, stills and voices.
- d04_concordia: then d02's `next` (exodus -> d04) and the hub after d02 (the barge cabin painting, optional).
- The commissary's mirror bot is crude (it rides at Hollweg); a person playing the commissary will find it longer.
- A barge-cabin hub painting (the plan's optional one) was not made.
- CHECK THE FEEL notes (docs/shots/d02_exodus/): carts bunched on the road stack their name labels; the engine shows
  "Checkpoint." the moment the last primary objective is met, a few seconds before the end screen (every mission does).

## Tests run

- tools/test_campaign_d02.gd: 0 failures (the data, every flag path, a played-through win, take and retake, the minute,
  the losses, the mirror, save and load in each part, ironman, the hubs and the war map after d02).
- The campaign tests: test_campaign, test_campaign_a01..a07, b01, c01, heroes, ironman, test_act2_engine0,
  test_hubs_grow, test_roster_ladder, test_war_map: 0 failures; test_campaign_a07's "line ends at Rome" became "reaches
  Rome (Act 2 after it)". test_campaign_m1 has one failure that is older than this job (Tomasz's recordings came in
  0.38.164: "no recording yet for Tomasz" no longer holds).
- test_campaign_save (d02 saved and loaded the same in every part); tools/test_campaign_save.sh d02 (the sim with a
  save half way: SIM LOAD SAME yes).
- The boot check: no SCRIPT ERROR, no Parse Error.
