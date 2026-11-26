# The battle matrix, all matchups

Job battle-matrix-all, 25 November 2026. The owner: "Forget economy for a while and only do a gigantic round of
battles... all possible compositions... I think it's only fair to make this testing to all matchups, not only Crown vs
Brood."

Nothing in the game changed. No number was touched. This is a study, made with the battle lab.

The full tables are in docs/battle_matrix_all/tables.md. The numbers behind them are in docs/battle_matrix_all/data/.

## How it was done, in short

The battle lab (tools/battle_lab.gd) was built by the battle-matrix job for the Crown against the Brood. This job made it
work for any two factions, and for mirrors.

- Two armies of the same value stand facing each other in open ground, away from both bases. Money is turned off.
- Value is counted the game's way: gold, food, powder, spoils, cogs and Tension, one for one. A Crown rider counts his
  horse.
- Each army is fought by its own Hard computer, with its own fighting code. Only the retreat is taken away: if a computer
  pulls back, the lab sends the army in again. These are counted as "pulls".
- The Clockwork army goes out as the computer's own push, with its escort Winders. Its retreat is taken away inside the
  push, and the times it wanted to turn are counted.
- The fight ends when one side has nothing left that fights, or 3 minutes after contact.
- The score is side A's share of the value killed. 50 is an even trade. 100 means side A killed and lost nothing.
- Sizes: 600 (early), 1,500 (mid), 4,000 (late). Research grows with the size.
- Grounds: open field, the set line (the defender formed by hand and ready), a choke, and a ramp with the defender on top.

A fight takes the lab about 3 to 6 seconds. Two cores ran 7,000 fights for this job (6,572 in the tables, 208 Dragoon
fights, 216 with the wind at half), plus the first, faulty runs that were thrown away.

### The comps

The Crown and the Brood comps are the battle-matrix job's own (see its doc). The Clockwork has 14 new ones. A share is a
share of the army's value.

| Code | The Clockwork army |
|---|---|
| K | Clock Soldiers only, no Winders |
| KW | Clock Soldiers, Winders 15% |
| KN | Clock Soldiers, Netters 25%, Winders 15% |
| KP | Clock Soldiers 50%, Pendulums 35%, Winders 15% |
| P | Pendulums, Winders 15% |
| Sp | Springers, Winders 15% |
| KSp | Clock Soldiers and Springers, Winders 15% |
| KB | Clock Soldiers 50%, Spring Ballistas 35%, Winders 15% |
| Se | Brass Serpents, Winders 15% |
| KSe | Clock Soldiers and Brass Serpents, Winders 15% |
| O | The air: Ticking Owls 80%, Swifts 20% |
| CW | The computer's usual push: Soldiers, Pendulums, Ballistas, Netters, a Springer, Winders |
| KGW | Clock Soldiers and the Great Winder, no Winders |
| KPN | Clock Soldiers, Pendulums, Netters, Winders |

Clockwork research by size: early none; mid Shield Wall and High Leap; late also Long Chain and the Ticking Owl.

## The big picture

At equal cost, in a straight fight, the three factions are NOT even.

- **The Crown beats the Clockwork.** If both pick their army blind, each at its best mix, the Crown gets about two thirds
  of every fight in the open (65 early, 68 mid). At 4,000 it is close to even (53).
- **The Brood crushes the Clockwork.** The Clockwork gets 6 early and 30 mid. Venom Challengers and Brutes beat almost
  every Clockwork army.
- **The Brood beats the Crown early and mid** (the battle-matrix job's open-field numbers: the Crown's share 39 early,
  39 mid, 57 late). This is mostly the Tyrant Sire: without him the Crown gets 57 to 61, and wins.

So in fights alone the order is Brood, then Crown, then Clockwork. In real games the Clockwork wins its share on economy
and repair, not in fights at equal cost. The championship study found a circle (Crown beats Clockwork, Clockwork beats
Brood, Brood beats Crown). The fights here agree with two sides of that circle, and not with the third: the Clockwork's
wins over the Brood in real games do not come from straight fights.

## Crown against Clockwork

The Clockwork side's comps are in the columns, the Crown's in the rows. Numbers are the Crown's share.

### What wins

- **Plain Musketeers are the Crown's best army.** Musketeers alone (M) get 93 early and 83 mid. With Officers (MO), 92 and
  87. They beat almost every Clockwork army clearly.
- **Pendulums are the Clockwork's only good answer.** Pendulums (P) hold Musketeers to about 57 to 60, and beat guns and
  mortars badly (the Crown gets 5 to 9 with Mortars or Cannons in the army, early).
- **Ticking Owls** beat any Crown army that has few Musketeers: Horsemen get 0 to 16 against them, Cannons and Horsemen
  get 3 to 14. Musketeers shoot them down (96 to 97).
- **The Brass Serpent loses to almost everything** the Crown has, except plain Horsemen early.
- **Springers lose** to almost everything (the Crown gets 51 to 93 against them, mid).
- **Spring Ballistas with Clock Soldiers (KB)** are poor early, but become the Clockwork's best army at 4,000 (the Crown
  gets 53 there, mostly because KB holds Musketeers).

### Best answer to each

| Crown army | The Clockwork's best answer (Crown's share, mid) |
|---|---|
| Musketeers | Pendulums (57) |
| Musketeers and Officers | Clock Soldiers and Pendulums (66) |
| Musketeers, Cannons, Horsemen (the computer's wave) | Clock Soldiers and Ballistas (32) |
| Musketeers and Cannons | Owls (41) |
| Horsemen | Owls (16) |
| Cannons and Horsemen | Owls (3) |

| Clockwork army | The Crown's best answer (Crown's share, mid) |
|---|---|
| Pendulums | Musketeers and Officers (71) |
| Clock Soldiers and Pendulums | Horsemen (84) |
| The computer's push | Horsemen (92) |
| Owls | Musketeers (96) |
| Ballistas | Musketeers and Officers (91) |

**Safest armies** (best at their worst, mid): Crown Musketeers and Officers (66 at worst), Musketeers (57). Clockwork
Pendulums (the Crown gets at most 71 against them).

**Each side's best blind mix** (mid): the Crown, Musketeers and Officers 87%, Musketeers and Horsemen 13%; the Clockwork,
Clock Soldiers and Pendulums 60%, Pendulums 40%. The Crown's share: **68**.

### On other ground (mid, 1,500)

The Crown holding, the Clockwork coming at it:

- The set line (the Crown formed by hand): the Crown's share **60**. The choke: **51**. The Crown on a ramp's top: **64**.
- A formed line standing still does WORSE for plain Musketeers than the open field (M: 83 in the open, about 51 set).
  In the open the Crown computer steps back as it shoots; a line on hold cannot. Against melee, moving beats standing.
- Guns gain from standing: Musketeers and Cannons go up from 73 to 81 on a ramp.

The Clockwork holding, the Crown coming at it:

- The set line: the Clockwork's share **0** at best blind play. The choke: **40**. The Clockwork on a ramp's top: **0**.
- The reason is simple: **Horsemen beat every Clockwork army that stands still** (the Crown gets 100 in nearly every
  cell). The riders hit and ride out; slow Pendulums and Clock Soldiers never catch them. Only a choke stops it.
- Against everything but Horsemen, Pendulums and Ballistas hold well on a ramp: the Clockwork gets 74 and 64 on
  average (62 and 54 with the Horsemen counted).

### Late (4,000)

The Crown's share **53**. Musketeers and Officers stay best for the Crown. Clock Soldiers and Ballistas (KB) are the
Clockwork's best by far: they beat every Crown army but Musketeers and Officers.

## Clockwork against Brood

The Clockwork's comps are in the rows. Numbers are the Clockwork's share.

### What wins

- **The Brood wins almost everything.** The Clockwork's share at best blind play: **6** early, **30** mid, **28** late.
- **Venom Challengers** beat every Clockwork army (the Clockwork gets 0 to 19 against them, 48 at best with Ballistas mid).
- **Brutes** beat every Clockwork army but the Owls (the Clockwork gets 0 to 21 early).
- **Owls (O) beat every Brood army that cannot hit flyers**: 100 against Raptors, Spitters, Brutes, Tyrant Challengers.
  They lose everything to Venom and Storm Challengers (0).
- **Pendulums beat Raptors** (100 early) and Tyrant Challengers, and lose to Spitters and Brutes.
- **Brass Serpents, Springers and Netters lose to everything** in this matchup (the Clockwork gets 0 to 30).

### Best answer to each (mid)

| Brood army | The Clockwork's best answer (Clockwork's share) |
|---|---|
| Raptors | Pendulums (100) |
| Raptors and Spitters | Owls (100) |
| Spitters | Owls (100) |
| Brutes | Owls (100) |
| Venom Challengers | Clock Soldiers and Ballistas (48) |
| Storm Challengers (flyers) | Pendulums (78) |

| Clockwork army | The Brood's best answer (Clockwork's share) |
|---|---|
| Pendulums | Brutes (10) |
| Clock Soldiers and Pendulums | Brutes (11) |
| Owls | Venom Challengers (0) |
| Ballistas | Storm Challengers (0) |
| The computer's push | Venom Challengers (4) |

**Each side's best blind mix** (mid): the Clockwork, Ballistas 46%, Pendulums 38%, Owls 16%; the Brood, Venom Challengers
48%, Brutes 30%, Storm Challengers 22%. The Clockwork's share: **30**.

### On other ground (mid, the Clockwork holding)

The set line 32, the choke 33, the ramp's top 34. Standing still helps the Clockwork a little against the Brood (from 30
to about 33), because the Brood has no Horsemen to ride round it.

## Wind

A Clockwork army runs down off its gear ground in about 80 seconds. In these fights it hardly mattered:

- Fights in the open last 20 to 30 seconds. Only 28 run-down constructs were seen in 2,912 open fights.
- **Winders are dead weight in short fights.** Clock Soldiers with no Winders (K) did better than with them (KW): 29
  against 23 v the Crown, 30 against 21 v the Brood. The Great Winder did worse still (18 and 15). In a short fight the
  15% spent on Winders is 15% fewer soldiers.
- Wind matters when the fight is long: the Clockwork holding against Horsemen (long fights) ran down about 1 construct a
  fight.
- **An army that arrives half wound loses a lot.** With the wind at half at the start (as after a long march), the
  Clockwork's share fell: Pendulums v the Crown 54 to 32, Clock Soldiers 25 to 15, Ballistas v the Brood 45 to 30
  (216 fights, docs/battle_matrix_all/data/wind_half.jsonl). Keeping the army wound on the way in matters more than
  Winders in the fight.

## The fighting counts

| Matchup | Fights | Fight length (s) | Pulls a minute, A / B | Run down a fight | Crown guns set at contact | Guns firing in 20 s |
|---|---|---|---|---|---|---|
| Crown v Clockwork (Crown holding or both coming) | 1,960 | 31 | 6.2 / 4.4 | 0.04 | 20% | 75% |
| Clockwork holding v Crown | 432 | 35 | 0 / 3.1 | 1.13 | 0% | 90% |
| Clockwork v Brood | 2,044 | 23 | 4.0 / 1.0 | 0.00 | - | - |
| Crown v Crown | 676 | 40 | 11.1 / 10.2 | - | 0% | 74% |
| Clockwork v Clockwork | 784 | 37 | 5.1 / 4.6 | 0.05 | - | - |
| Brood v Brood | 676 | 23 | 3.2 / 2.7 | - | - | - |

- **Pulls.** The Crown computer wants out of its wave about 6 times a minute (11 in the mirror, against another
  line of muskets). The Clockwork's push wants to turn about 4
  times a minute (the lab keeps it in). The Brood about once.
- **The Crown's guns are never set at contact in the open.** They march limbered and set up only after the fight starts
  (0% set at contact in the open; 20% overall comes from the set grounds, where the lab sets them by hand).
- Own men killed by own splash: about 0.3 a fight when the Crown has guns or mortars.

## Mistakes seen in the computers' fighting

From the debug traces and three filmed fights (pictures in docs/shots/battle_matrix_all/).

1. **The Crown computer cannot keep Dragoons in a wave** (a lab fault, now fixed, and a real computer fault). See below.
2. **The Crown's guns march limbered and come late.** In the film (Crown wave v the Clockwork's push) the two cannons
   stand far behind the line, still packed, when the fight starts.
3. **The Clockwork's Ballista falls behind.** It is slow and the push does not wait for it once a fight starts: in both
   Clockwork films it stood out of the fight while the front died.
4. **The escort Winders do not mend in the fight.** In the traces they walk behind the army; their wind drops; they
   seldom mend a hurt Pendulum while enemies are near.
5. **The Brood's Spitters stand back.** In the film (Clockwork push v Raptors and Spitters) the Raptors went in and died
   while the Spitters stood in a block out of their reach.
6. **The Clockwork's push wants to turn about 4 times a minute.** In a real game that would break almost every fight
   off half way.
7. **A melee line set by hand on HOLD is helpless** (a lab lesson, see below): it only strikes what walks into it.

## Lab faults found and fixed

### Dragoons never fired (Crown v Brood)

In the battle-matrix data, Dragoon armies scored 0 in every fight. This was a real fault, in the lab and in the computer.

- The Crown computer's wave counts only the men ready to fight. A Dragoon getting off his horse to fire drops out of that
  count. The wave falls under 6 supply, the computer ends it, and sends everyone home.
- The lab then sent them in again. They rode to and fro, getting on and off, and never fired: a pull every 1.7 seconds.
- **Fix (lab only):** Dragoons are kept out of the computer's wave and driven as a player would, with an attack-move.
  They now ride in, get off, and fire.
- **New numbers** (208 fights, docs/battle_matrix_all/data/dragoons_crown_brood.jsonl): Dragoons alone get 21 early and
  24 mid against the Brood (was 0 and 8). Musketeers and Dragoons are unchanged (23 and 36). Dragoons are still weak
  against the Brood, but they fight now.
- **For the game:** the Crown computer uses Dragoons only in its Dragoon raid, never in a wave. If it ever trains them for
  the army, its wave code will send them home as soon as they get off their horses.

### "Raptors and Spitters with the Tyrant Sire" beat every Crown army

This is **real by the game's numbers, not a lab fault**. The Sire is counted at his price, 150 food, the same as the
game. But he has 1,000 health, 2 armour and hits for 42. For 150 he is by far the cheapest fighting value in the game.
He is a father (the tech), one a Brood, not an army unit to buy, and losing him costs the Brood its eggs of that line. Yet
in a real fight he is there, and he wins it. Without him the Crown's share at equal cost goes from 39 to 57 early. **This
is a balance question for the owner**: the Sire's price, his health, or whether he should join fights.

### The Clockwork's set line stood on HOLD

The first run of the Clockwork holding the set line gave it 0 of 432. A melee line on HOLD only strikes what walks into
its blade; Musketeers shot it from out of reach. Those rows were thrown away. Now a melee line set by hand goes out
together at anything within 8 tiles of it, never chasing more than 14 tiles from its place, and walks back after. It
still does badly against Horsemen, but that is the game: a slow army cannot catch riders.

### The Clockwork's push retreated every half second

The lab sent the push in again after each retreat, and it turned back again at once (26 retreats in 24 seconds: a man
walking home does not fight). Now the lab uses the push with its retreat switched off inside it, and counts the times it
wanted to turn.

### The lab is not exactly the same each run

The same fight run twice can give a slightly different result (the old Crown v Brood lab too: one fight gave 0.303 one
run and 0.341 the next). This is why every pairing has several seeds. The new lab was checked against the old: on the
same fights it gives the same rows, or rows the old lab also gives on another run.

## What this means (for the owner to weigh)

These are observations, not changes. No number was changed.

1. **The Clockwork is weak in straight fights** against both other factions at equal cost. Its strength must come from
   elsewhere (economy, repair, gear ground). If the owner wants fights to matter more evenly, the Clockwork's fighters are
   the place to look: Springers, Netters and the Brass Serpent lose to nearly everything.
2. **Pendulums and Owls are the Clockwork's real fighters.** Pendulums against the Crown and Raptors; Owls against any
   army with no anti-air.
3. **Horsemen beat any army that stands still and cannot catch them.**
4. **Venom Challengers and the Tyrant Sire** are the Brood's strongest value. Venom Challengers beat every Clockwork army
   and most Crown ones.
5. **Plain Musketeers** (with Officers) are the Crown's best army against both other factions; guns and mortars in the
   army make it worse in the open, not better (they are slow, set late, and hit their own men).
6. **Winders do not pay in a short fight;** arriving wound does.
7. **Inside each faction one army is best:** the Crown's Musketeers with Officers or the band, the Clockwork's
   Pendulums. Only the Brood has a true circle (flyers, Venom Challengers, the Sire).

## The mirrors

Open field, 600 and 1,500. Every comp against every comp, each pairing played from both sides of the field (2 seeds each
way, so 4 fights a cell). The question here is which army beats which inside one faction. No side of the field had an
edge: side A's share was 49, 48 and 50.

### Crown against Crown (676 fights)

- **Musketeers with Officers (MO) and Musketeers with the band (MB) are the best.** Early nothing beats the band army
  (MB is the best blind pick, 100%). Mid, nothing beats Musketeers and Officers (MO is the best blind pick, 100%).
- **Plain Musketeers** are third: they beat almost every army with guns, mortars or riders, but lose to MO and MB, and
  mid to Musketeers with a Missionary (25).
- **Horsemen alone, Dragoons alone and Cannons with Horsemen are the worst** (19 to 37 on average). Horsemen lose to
  almost everything (Musketeers get 95 against them).
- **Guns and mortars do not pay in the open** in the mirror either: no army with them gets more than 56 on average.
- There is no real circle here: one army (MO or MB) simply beats the rest.

### Clockwork against Clockwork (784 fights)

- **Pendulums (P) beat everything.** Early they beat 11 of the 13 other armies clearly and are ahead of the last two; mid
  they beat 12 of 13 clearly. The best blind pick is
  Pendulums, 100%, at both sizes.
- **Owls (O)** are second (73 on average). They beat every army with no anti-air (Clock Soldiers, Ballistas, Serpents),
  and lose to Netters, Pendulums and Springers, which can hit flyers.
- **The computer's push (CW), Clock Soldiers with Pendulums (KP) and with Pendulums and Netters (KPN)** come next (57 to
  65). These all have Pendulums in them.
- **Clock Soldiers with Brass Serpents (KSe) are the worst** (15 and 18 on average): they beat nothing. Serpents alone are
  little better (28 to 32).
- Clock Soldiers without Winders (K) beat Clock Soldiers with them (KW): 74 early, 66 mid. Winders do not pay in a short
  fight, again.

### Brood against Brood (676 fights)

This one is a real **rock, paper, scissors**:

- **Storm Challengers (the flyers) beat every ground army** (100 against all of them, even the Tyrant Sire).
- **Venom Challengers beat the Storm Challengers** (84 early, 90 mid) and almost every ground army.
- **The Tyrant Sire's army (RSy) beats the Venom Challengers** (75 early, 65 mid) and every other ground army.
- So: flyers beat the Sire, Venom beats flyers, the Sire beats Venom.
- The best blind mix: Venom Challengers 46 to 48%, the Sire's army 31 to 38%, Storm Challengers 14 to 23%.
- **Raptors, Spitters and Mist Toads (RSTd) are the worst** (23 and 24 on average): they beat nothing. The Mist Toads'
  fog and miasma do not help in a straight fight.
- Plain Raptors (R) are the best of the cheap armies: they beat every Raptor and Spitter mix.

## What was not done

- The mirrors were run only in the open field, at 600 and 1,500, with 4 fights a cell. No set lines or ramps there.
- The late size (4,000) is a sample: 6 by 6 or 6 by 7 armies, 2 seeds, open field only.
- "A ramp, side B on top" was not run for the new matchups.
- The Crown v Brood grounds were not run again with the Dragoon fix (the Dragoons were only on the open field there).
- The filmed fights are three, with three pictures each. More can be made with the lab's `shots:<dir>` (it needs a
  screen: `xvfb-run`, not `--headless`).

## Files

- tools/battle_lab.gd: the lab (any two factions; a job line `<faction A> <comp A> <faction B> <comp B> <size> <ground>
  <seed>`; the old five-word Crown v Brood line still works). `wind:<0..1>` starts the Clockwork part wound.
- tools/study/battle_lab.py: makes the jobs (`jobs --fa crown --fb clockwork`), runs them on every core (`run`,
  `--extra` for more lab arguments).
- tools/study/battle_matrix_all_report.py: the tables (docs/battle_matrix_all/tables.md, data/analysis.json).
- docs/battle_matrix_all/data/rows_<a>_<b>.jsonl: one line a fight. In a row, "fa"/"ca" are side A's faction and
  army, "fb"/"cb" side B's; the "c_" fields are side A's, the "b_" fields side B's, and "crown_n"/"brood_n" are side A's
  and side B's counts (the old names, kept). "wind_down" counts Clockwork constructs that ran down, per side.
