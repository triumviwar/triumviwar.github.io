# Deny the scout (job scout-deny)

The owner, 2026-11-18 11:42, watching Crown OPTIMAL v Brood OPTIMAL: "Why is the Brood not killing the labourer scouting?
Denying scouting should also be a priority for all factions." In his game the Crown's scouting Labourer (sent at 0:02) walked
the Brood's base, read it GREEDY at 1:30, and came back for a second look at 4:00, and nothing went after it.

## Why nothing went after it

- **The Brood computer** only ever counted ARMED enemies as a threat at home (every check has `has_attack() and not
  is_worker()`), so a Labourer, a Winder or a Messenger walking round its Mother was invisible to its defence.
- **The Crown and Clockwork computers** had two answers already, both partial: their sized defence (`AI._defend`) sends a
  "lone raider" detachment at anything by their buildings, but only from units at least as quick as the intruder and only
  when it walks within 330 px of a building; and their worker safety sends two workers at an unarmed intruder, but only
  while their army is under 3 units.

## What changed (AI play only, no number of the game changed)

One new part shared by the three computers, `scripts/ai_scout_deny.gd` (`AIScoutDeny`), Normal and up. Switch:
**`scoutdeny:off`** plays as 0.38.61.

1. **It looks for scouts.** Twice a second it looks for an enemy SCOUT in or near its base: within 11 tiles of one of its
   buildings, rooted creatures or its Mother, and in sight (no cheating: what its own side sees). A scout is what it
   looks like from outside:
   - a worker (Labourer, Winder, grub) or an unarmed unit (Messenger, balloon, Missionary) with no armed friend within
     9 tiles (a Winder walking with an army is its escort, not a scout);
   - a quick soldier or a flyer of little worth (speed 88+ or flying, worth 180 or less: a Horseman, a Raptor, a Swift)
     with no armed friend within 16 tiles, and only while no other enemy fighter is in or by its base (the first Raptors
     of a wave, strung out, are the wave's).
   The Brood leaves riders to its own doctrine (no chase: `_nb_defend_riders`). Slow unarmed machines (the Great Winder)
   are no scouts.
2. **It sends the nearest fit hunters.** At most 2 for one scout and 4 in all, never a whole army: units that can hit it
   (a flyer needs anti-air) and catch it (85% of its pace or more, the defence's own rule, or a shooter already in reach),
   at least 50 quick (no Spring Ballista, no Pendulum), and free: not on a wave, in a defence, a harass, a raid, on an
   errand (screen, picket, refill), rooted, moulting, the computer's own scout. Early (before 7:00), when no soldier can,
   1-2 workers within 9 tiles go at a scout on foot (Labourers, Winders, grubs).
3. **It keeps it short.** A hunter gives up when the scout is 6 tiles past the base, after 30 s (10 s for workers), when it
   has been out of sight 3 s, or when enemy fighters worth 60% of the hunters are near the scout. Then it goes back:
   soldiers to where they were taken from (the army's code takes them from there), workers back to work. A scout that got
   away is left alone 20 s.
4. **The army is not held at home for it.** An UNARMED scout the hunters are after no longer counts as a threat
   (`AI._threat`): the army's waves and the workers carry on. An armed one still counts, so the defence's own answer still
   comes if the hunters are not enough.
5. **It tells the story.** The match log and the AI STORY: "P2 Brood sends 2 Raptors after the Crown's scouting
   Labourer", "P2 Brood killed the Crown's scouting Labourer at 4:50", "P1 Crown lets the Brood's scouting Grub go (the chase
   took too long)" (en/pt/es: `tools/i18n/58_scout_deny.txt`).

The hunters are left out of the rest of the computer while they hunt (`AI._on_errand`; the Brood's army, defence, waves and
sacrifices).

## The scout's side (part 3 of the job)

Checked, not changed:
- **A killed scout reads UNKNOWN, not a wrong read.** AIScout (the Crown and the Clockwork) ends a killed trip "killed",
  and a trip that saw too little of the base reads UNKNOWN ("the scout was killed before it saw the base"); the next look
  goes 35 s later, a fast soldier from the second denied trip on. Its GREEDY-by-absence read needs the base seen with no
  army at all, and hunters are army seen, so a scout killed by soldiers can't call the base empty.
- **The Brood reads all the time** from what any of its creatures sees: a dead grub leaves its read where it was (no read
  yet = OPTIMAL's normal game at its deadline). Nothing to change there.
- **Chased scouts still read something:** AIScout backs out of reach of soldiers and stands off where it can still see
  (`_avoid`, the stand-off spot); the Clockwork's flees from workers too. The Brood's watching grub backs off and comes back.

## HIDING TECH (part 2): not built

Claude's choice: skipped. Keeping tech out of a scout's sight means moving or not building buildings while it looks, and the
computers' building placement is shared by many coached rules; denying the scout gives most of the same and is simple.

NUMBERS

## Claude's choices for the owner

CHOICES
