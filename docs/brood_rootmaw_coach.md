# Brood Rootmaw coach: new ground sooner (job brood-rootmaw-coach)

The owner's decision (2026-11-15 21:34, "yes", on docs/brood_rootmaw_spots.md section 4): coach the Brood COMPUTER to lay
its 4th, 5th and later Rootmaws on NEW GROUND sooner. **Only the computer's play changed** (scripts/ai_brood_new.gd):
no unit, price, yield, count or rule number was touched, nor the Crown's or the Clockwork's computers. Design rules
followed (docs/design_principles.md): 2 (the economy forces expansion and is depletable: take fresh ground as the old
runs dry), 4 (mastery of the economy: every choice an opportunity cost; a change kept only if the income rises without
the plan's character or its defence falling apart).

Measuring switch: **`maweco:off`** plays the old way (every change below is behind it).

__SUMMARY__

## 1. Where it lost (before)

Measured with the computer alone (tools/econ_ai_alone_brood.gd: the bench's setup, an idle dummy on the other side;
Greenhold, Dune Sea, Hollowfen; OPTIMAL, Balanced and Economy; 12 minutes; BEFORE = main at 0.38.20). Followed look
by look on Greenhold (OPTIMAL, which picks the Spitter timing alone):

1. **The turtle that makes room came last.** In `_nb_morphs` the "no room for a Rootmaw: a turtle on new ground" rule
   ran only when nothing else was chosen (no supply turtle, no Sire, no Rootmaw), not within 45 s of the last turtle
   sent out, and never past 6 turtles out there (spent ones counted). From 8:00 the plan wanted 8 Rootmaws and had 7.
2. **A refused supply turtle ended the think.** With 500 food or more the supply rule keeps 12 more supply ahead, so a
   supply turtle was asked for on most thinks; when the whole-map layout check refused its spot at home ("It would shut
   59 of its own in") the think ended there, and from 8:00 to 9:30 neither a turtle nor a Rootmaw came.
3. **The turtle sites run out.** A side has its own handful of turtle sites (the base sites rated for a hall,
   ExpansionSpots.nb_rate; Greenhold: 5 for a side). By 7:00 its 3 own were taken and the other 2 lay past the enemy's
   natural (61-64 tiles out), so nothing was left inside the 40-tile reach.
4. **Far Rootmaws run dry in about six minutes** (a far Rootmaw drinks x2.2 faster: Game.food_mult), so the ones laid
   at the natural and the third at 4:00-5:30 were spent by 10:00-11:00 and walked about with no room anywhere: 6 rooted
   and 2 walking from 10:15 to 12:00, while 6,000 food piled up.
5. **The grubs stood at the plan's cap** (50-58) from 7:00 while the posts grew (68 for 50 grubs at 8:00); with the
   Rootmaws its income is drink-bound, with more Rootmaws it becomes grub-bound. Its bank (1,000-2,000 from 8:00, then
   5,000-8,000 at the 200 supply cap) had nothing to go into.

## 2. What changed

| change | what | why |
|---|---|---|
| **new ground when due** (`_maw_expand_due`, `_maw_need_room`) | every 2 s: the Rootmaws that will want a spot within a turtle's walk (EXP_LEAD 50 s ahead on the plan's own Rootmaw curve, and every Rootmaw walking for a spot or about to run dry, under MAW_DRY 900 food left; one up to fight keeps its spot and does not count) against the room on FRESH ground the swamps have now (RootmawSpots' marks, `_nb_spot_ok`) and the room the turtles on their way to new ground bring (2 each). Short = a turtle on new ground now, as a morph of its own, after the first Sire, the supply turtle and the later Sires, before Rootmaws | 1 |
| **a refused home turtle goes out** | a supply turtle the layout refuses at home goes to the new-ground spot instead of ending the think | 2 |
| **no cap of 6 out there** | the old "no room: a turtle on new ground" rule no longer stops at 6 turtles out (spent ground counted); the need above decides | 1, 4 |
| **fresh ground off the sites** (`_nb_fresh_turtle_spot`, `_fresh_room`) | once the side's turtle sites are taken or spent, any spot a turtle may root on 18-40 tiles from the Mother (the distance pay peaks at 24), on its own side of the map (`_toward_foe`), with fresh ground, where at least one Rootmaw circle fits on its level clear of every circle of the side's (rooted, planned or spent ground); looked for at most every 5 s | 3, 4 |
| **safety** | no new ground while the alarm is on (an enemy army seen out of its main in the last 75 s), an enemy is at the Mother, a rush it is short against is on, it rebuilds after a rush, or it is under-armed with under 30 army supply; a site with an enemy building seen within 16 tiles is skipped (`_site_unsafe`); its own side's sites before those nearer the enemy's start; the reach drops from 40 to 30 tiles while its scout read a rush, riders are read or riders were seen in the last 90 s (`_exp_reach`); the old checks stay (no visible enemy within 12 tiles, a site a grub died going to is left 3 minutes) | the owner's "not into the enemy's army" |
| **the banked food into grubs** (`_extra_grubs`) | while rich (500 food over her growth's savings), with posts for 4 more grubs than the plan's cap, supply to spare and no danger (under-armed, the alarm, an enemy at the Mother), the plan's grub cap rises a grub every 3 s, up to EXTRA_GRUBS 10 more; kept once raised; never in the Rush or Extreme rush | 5 |
| **the plan's own timing kept** | not before 5:00 (EXP_FROM: the opening is the plan's own, section 5), not while her growth is due (`_nb_growth_keep`), not within a minute of the plan's own next expansion (EXP_PLAN_NEAR 60 s: that one, not one more); the Rush and Extreme rush never before their wave | measured (sections 3 and 5) |

Not changed: the plan's own Rootmaw curve (`maws`), its expansions list (`far`), the rush plans' grub holds before their
wave, the under-armed rule, the rider defence, which plan OPTIMAL picks.

## 3. The computer alone (before / after)

`tools/econ_ai_alone_brood.gd`, 12 minutes, Greenhold, Dune Sea and Hollowfen, three plans (OPTIMAL, which alone picks
the Spitter timing, Balanced and Economy): 9 runs a side. BEFORE = main 0.38.20; AFTER = this branch. Food earned,
cumulative, the mean of the 9 (the alone games are deterministic: one run a map and plan):

| | 5:00 | 8:00 | 9:00 | 10:00 | 12:00 |
|---|---|---|---|---|---|
| earned, before | 3,086 | 9,167 | 11,536 | 13,850 | 18,675 |
| earned, after | 3,005 | 9,494 | 12,259 | 15,213 | **20,989** |
| change | -2.6% | +3.6% | +6.3% | +9.8% | **+12.4%** |
| Rootmaws rooted, before / after | 4.8 / 5.0 | 7.1 / 7.3 | 7.2 / 8.3 | 7.0 / 9.1 | 6.3 / **9.8** |
| turtles on new ground, before / after | 1.4 / 2.1 | 2.7 / 4.7 | 3.8 / 7.2 | 6.8 / 9.6 | 7.7 / 9.7 |
| grubs, before / after | 32 / 32 | 53 / 58 | 54 / 61 | 54 / 62 | 54 / 62 |
| food banked, before / after | 70 / 107 | 875 / 727 | 1,438 / 1,116 | 2,260 / 2,758 | 7,038 / 8,404 |

Per run (earned at 5:00 / 8:00 / 10:00 / 12:00, before -> after; Rootmaws rooted at 12:00):

| plan, map | 5:00 | 8:00 | 10:00 | 12:00 | Rootmaws 12:00 |
|---|---|---|---|---|---|
| OPTIMAL, Greenhold | 2,622 -> 2,674 | 8,437 -> 8,906 | 13,102 -> 14,311 | 17,379 -> 19,889 | 6 -> 10 |
| OPTIMAL, Dune Sea | 2,641 -> 2,674 | 8,076 -> 8,996 | 12,377 -> 14,475 | 17,105 -> 20,073 | 6 -> 9 |
| OPTIMAL, Hollowfen | 3,124 -> 3,055 | 8,958 -> 9,090 | 12,995 -> 14,242 | 17,285 -> 19,836 | 7 -> 10 |
| Balanced, Greenhold | 3,282 -> 3,174 | 9,507 -> 9,877 | 14,478 -> 15,105 | 19,310 -> 20,414 | 6 -> 10 |
| Balanced, Dune Sea | 3,260 -> 3,174 | 9,399 -> 9,876 | 13,910 -> 15,598 | 18,808 -> 21,130 | 7 -> 10 |
| Balanced, Hollowfen | 3,977 -> 3,943 | 9,774 -> 10,252 | 14,118 -> 15,480 | 18,508 -> 20,909 | 6 -> 9 |
| Economy, Greenhold | 2,760 -> 2,532 | 9,311 -> 9,094 | 14,500 -> 15,674 | 19,663 -> 21,947 | 7 -> 9 |
| Economy, Dune Sea | 2,659 -> 2,532 | 9,176 -> 9,168 | 14,496 -> 15,562 | 20,060 -> 22,180 | 6 -> 11 |
| Economy, Hollowfen | 3,452 -> 3,283 | 9,863 -> 10,189 | 14,676 -> 16,466 | 19,955 -> 22,526 | 6 -> 10 |

- **From 8:00 on it earns more in every run** (+6% to +17% at 12:00); the gain grows as the plan's own expansions run
  out: at 12:00 it has 9-11 Rootmaws rooted where it had 6-7 (two of them walking about with no room) and 62 grubs where
  it had 54.
- **OPTIMAL gains most** (+15% at 12:00, +6% at 8:00): alone it picks the Spitter timing, whose plan holds the fewest
  grubs (50) and expands least; its third base came at 3:45 instead of 4:50.
- **The Economy plan loses 5% at 5:00** (its eggs go into the turtle at 3:15 the rule asks for instead of into grubs)
  and is level by 8:00 and +11% at 12:00. A gate measured at 3:30 or 5:00 spared it that but cost OPTIMAL 5-7% at 8:00
  (choice 2): the games are played by OPTIMAL.
- **The bank** is no smaller at 12:00 alone: from about 10:00 the computer stands at the 200 supply cap (an idle dummy
  never kills its army), so whatever it earns piles up. Before the cap it banks less (9:00: 1,116, was 1,438) with 7
  more grubs and 3 more turtles on new ground.
- Per minute at 12:00 (the 2 minutes before), OPTIMAL alone: 2,795 food (was 2,215); the Clockwork computer alone made
  2,796 cogs a minute and the Crown 2,367 gold in the same setup (docs/brood_rootmaw_spots.md section 3; their computers
  changed little since). The Brood's bench (its design, the scripted build) is 2,176 a minute at 12:00: the computer
  now earns more than the bench, as it did before the count (the bench stops at 7 Rootmaws and banks).
- **`maweco:off` plays the old way**: Greenhold and Dune Sea OPTIMAL alone give main's numbers to the food until 8:00
  and within 0.4% at 12:00 (the measuring tool's own look at the room the computer counts).

__GAMES__
