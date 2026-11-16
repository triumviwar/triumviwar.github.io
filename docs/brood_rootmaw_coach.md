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
| **new ground when due** (`_maw_expand_due`, `_maw_need_room`) | every 2 s from 5:00: the Rootmaws that will want a spot within a turtle's walk (EXP_LEAD 50 s: the plan's own curve, and every Rootmaw walking for a spot or about to run dry, under MAW_DRY 900 food left) against the room on FRESH ground the swamps have now (RootmawSpots' marks, `_nb_spot_ok`) and the room the turtles on their way to new ground bring (2 each). Short = a turtle on new ground now, as a morph of its own, after the first Sire, the supply turtle and the later Sires, before Rootmaws | 1 |
| **the supply turtle goes out** | a supply turtle asked for while new ground is due roots on new ground (it gives the same 12 supply and 2 Rootmaw places) | 1 |
| **a refused home turtle goes out** | a supply turtle the layout refuses at home goes to the new-ground spot instead of ending the think | 2 |
| **fresh ground off the sites** (`_nb_fresh_turtle_spot`, `_fresh_room`) | once the side's turtle sites are taken or spent, any spot a turtle may root on 18-40 tiles from the Mother (the distance pay peaks at 24), on its own side of the map (`_toward_foe`), with fresh ground, where at least one Rootmaw circle fits on its level clear of every circle of the side's (rooted, planned or spent ground); looked for at most every 5 s | 3, 4 |
| **safety** | a new-ground site with an enemy building seen within 16 tiles, or where the alarm saw an army within 14 tiles lately, is skipped (`_site_unsafe`); its own side's sites before those nearer the enemy's start; the reach drops from 40 to 30 tiles while its scout read a rush or riders are about (`_exp_reach`); the old checks stay (no visible enemy within 12 tiles) | the owner's "not into the enemy's army" |
| **the banked food into grubs** (`_extra_grubs`) | while rich (500 food over her growth's savings), with posts for 4 more grubs than the plan's cap, supply to spare and no danger (under-armed, the alarm, an enemy at the Mother), the plan's grub cap rises a grub every 3 s, up to EXTRA_GRUBS 10 more; kept once raised; never in the Rush or Extreme rush | 5 |
| **not before 5:00, not while saving for her growth** (EXP_FROM) | before 5:00 the plan's own expansions (its "far" list); new ground sent for at 3:15 cost 3-5% of the income at 5:00 and her stage 3 a minute | measured (section 3) |

Not changed: the plan's own Rootmaw curve (`maws`), its expansions list (`far`), the rush plans' grub holds before their
wave, the under-armed rule, the rider defence, which plan OPTIMAL picks.

__RESULTS__
