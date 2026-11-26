# The writing pass: Act 3, the hubs and the war map (job writing-act3-hubs, 2026-11-26)

The owner asked for every line of the campaign to be checked for the signs of machine writing, and made as good as it
can be. Four jobs share the work. This one had three parts:

1. Act 3's plan (docs/campaign_act3_plan.md): its spoken and narrated lines.
2. Every hub talk, in every act (campaign/campaign.json and campaign/hubs_grow.json).
3. The war map's lines (campaign/warmap.json).

The story, every choice, every flag and every mission instruction are the same. Nothing new happens in the plot.

## What the tells were

The same few habits came up again and again.

- Lines that end on a neat saying. The King: "Remember that mercy is a weapon too. It cuts the one who holds it,
  sometimes." Tomasz: "In Minas I learnt that a sermon is the easy part. Staying afterwards is the work." Hollweg: "Fear
  is not an argument."
- People saying their feelings out loud. Fairleigh: "It is done. I take no pleasure in it." Tomasz: "I still smell the
  smoke when I close my eyes." Valadares: "I do not sleep well."
- Lines built in matching pairs, two characters in the same shape. The King on Hollweg: "lost his city in a single
  night". The King on Lindqvist, right after: "lost his station in a single night".
- Lists of three. Lindqvist: "The Academy wants specimens. I want a breed. The Crown will want a cavalry."
- Clever turn-arounds. Hollweg: "Every master has a voice, and every voice a wheel." Lindqvist: "Rome calls it a
  monster. I call it a breed."
- Big figures of speech where a plain thing would do: "The fire did not stay in Virginia", "cut the root before the
  branches", "coiled like a question".
- One line gave the Brood a mind: Lindqvist said the Sire "stole her". Now the big male broke her pen and she went into
  the forest with him. That is an animal, not a thief.

## What I did instead

Each person now talks from what he saw and does, in his own way.

- The King is old and warm, and short with himself. He smokes his pipe with Tomasz in the room on purpose. He admits
  what he did and did not do ("I could have had the gates shut on them. I did not give the order.").
- Tomasz is plain and a little dry about himself ("I read the Confessions under an oak and thought myself very
  holy."). He counts what he did: children baptised, men buried.
- Fairleigh writes letters like an English officer: dry, a joke at Ruggieri's expense, the parishes of the dead
  written to.
- Hollweg is proud and blind to it. He thinks a soldier who needs no bread is a bargain. When he pulls the brake, he
  only says the tower went quiet, and that he had never heard it quiet.
- Lindqvist talks like a breeder with a stud book, and is wrong in his own words ("A soldier's superstition. I have held
  the eggs.").
- Valadares is practical and keeps things to himself ("I can still whistle the first call. I do not.").

## Before and after, a few examples

| who | before | after |
| --- | --- | --- |
| the King | "Remember that mercy is a weapon too. It cuts the one who holds it, sometimes." | "We shall see what he does with the years I gave him." |
| the King | "A martyr is harder to fight than a man. I learnt that too late." | "Within a month they were singing about him in every town in France." |
| the King | "Lyon went home without a volley. The Cardinal will tell you it was luck. Do not believe him." | "Lyon went home without a volley fired. Tomasz will tell you it was luck. It was Tomasz." |
| Tomasz | "I still smell the smoke when I close my eyes." | "Tobacco burns sweet. I cannot bear a pipe in a closed room to this day, and His Majesty knows it and lights his anyway." |
| Tomasz | "On the Tapajós I learnt that the swarm does not hate anyone. It eats. That is worse." | "On the Tapajós the swarm went for the granary before the church. It eats. It does not know what a church is." |
| Fairleigh | "It is done. I take no pleasure in it." | "It is done. I have written to the parishes of the dead, theirs as well as ours." |
| Hollweg | "He was afraid of them. Fear is not an argument." | "He was afraid of them. I told him so, and he said yes, he was, and wrote that down too." |
| Lindqvist | "He stole her." | "The big male broke her pen and she went into the forest with him." |
| Valadares | "I burned the book. I would burn it again. I do not sleep well." | "I burned the book, as Rome ordered. I can still whistle the first call. I do not." |
| Fairleigh (old) | "I am old now. I still hear the canister." | "Ruggieri's mortars in that street. I am still deaf in the left ear." |

## Per part

### The hubs

- The King's study: 30 of the King's lines, 8 of Tomasz's, 3 of Fairleigh's letter, 2 of Hollweg in exile, 1 of
  Ruggieri's dispatch.
- The Naturalist's hub: 6 of Lindqvist's lines, the specimen jar, 3 of Valadares' lines (each repeated in his many
  flag versions).
- The Clockmaker's hub: 10 of Hollweg's lines, including one of the King's asides inside it.
- The rooms that grow (hubs_grow.json): old Fairleigh (3), Ruggieri (1), Jakob (1), Father Ferrer (1).
- Everything else read well and was left alone: the clocks, the automaton, the flags in the gallery, the cages, the
  dispatches, most of the Barra lines.

How it is done: tools/campaign/writing_pass_hubs.py holds every old line with its new English, Portuguese and Spanish.
It swaps them in the two files and writes the translations into tools/i18n/campaign/campaign.txt and hubs_grow.txt.
Where an old line's translation sat in a mission's file, that old entry is left there, unused.

Six test checks looked for words that are gone, and now look for the new ones: d01 (Tomasz in Minas), d07 (Hollweg at
the brake), d09 (Tomasz and Ruggieri), d11 (Hollweg on the wall, and the King on the blown spring).

### The war map

The ledger lines are records, short and plain, and the tests check many of them word for word. They were already fine.
Only the two clock lines changed: "Waits: the army is in the north, and the city grows while it waits." is now "Not
yet: the army is in the north, and the city is building." (and the same for the swarm in the south).

### Act 3

Act 3 is a plan, not built. I rewrote every quoted line in it: the King's frame (the act's opening, the night, the
book closing), his last counsel to the heir by each earlier choice, the three ways he tells the heir how strong the
ledger is, both endings' last lines, and the plain instructions inside the missions (the balloon's marked nests, the
frost line, the rain at Goa). I also added a short table of KEY LINES under THE FRAME: drafts for the big moments the
plan named but never wrote (Fairleigh's last ride, Lindqvist at the records, Ferrer at the basilica door, the heir's
first order, Tomasz before the final choice).

Two of the endings' lines, as examples:

- ROME HOLDS, the King: "They will come over the Alps again next spring, and the marsh will hatch again in the heat.
  Tomorrow I write to Lisbon for powder." (It was "the war is not over, but the Crown endures. It is a victory, not a
  peace.")
- ROME FALLS, the King on the bridge, to Tomasz: "Peter was a fisherman. He will know what to do with a boat. Say Mass
  the moment you are past the bar." (It was "Rome is a city; the Church is not.")

## Lines to record again

None. The hub talks and the war map have no voice files, and Act 3 is not recorded. docs/chatterbox_todo.md says so
under "RE-RECORD (writing pass 2026-11-26)".

## Lines I left alone on purpose

make_d10_mission.py writes its own hub lines into campaign.json and hubs_grow.json, and it would add its old lines
back if they were changed (and it would stop with an error on the Ruggieri line it looks for). So these stay as they
are, for the d10 writing job or the owner. My suggestions:

- Valadares: "We burned the old ground on Lindqvist's island. The ruin is ash. I did not feel what I thought I would."
  (he says his feeling). Suggest: "We burned the old ground on Lindqvist's island. I stood in the ash where his study
  was and found the hinge of the stud book."
- Valadares: "In that telling the river stayed green. In mine we broke the nests, and I was there." (fine).
- The King: "Valadares broke every nest on the lower river before the rains. A priest in a basket showed him where."
  (fine, keep).
- Ruggieri: "The fort held, Highness. Two sieges in a week and a council in an evening. I chose, and I have not slept
  well since." (says his feeling). Suggest: "The fort held, Highness. Two sieges in a week and a council in an evening.
  I chose at dawn, and I have chosen it again every night since."

## Claude's choices (for the owner)

1. The King calls the year "sixty-seven" when he opens the story, as an old man would.
2. Tomasz minds the King's pipe. A small joke between two old friends, new detail, no plot.
3. Fairleigh is deaf in the left ear from the Paris mortars. Small new detail.
4. Valadares can still whistle the first call from the lure book he burned. This says he read it. It changes nothing
   in play.
5. Hollweg's aside after the machine wins the council hall was the King saying the machine "had all the nights it
   wanted". The King now says the hall fell later and slowly, which fits the canon (the city turned on Hollweg later).
6. In the Act 3 plan, Hollweg's line in e09 was given to the wrong reading of the Nuremberg gate: "I chose the drawings
   once" was set for the player who chose the PEOPLE. Now each reading has its own line: pattern, "At Nuremberg I took
   the drawings and left people at the gate. Do not let me choose like that twice."; people, "At Nuremberg I left the
   drawings in the snow and took the people. I have never been sorry."
7. The KEY LINES table in Act 3 is new writing. It is there so the owner has something to cut from, not as a decision.
8. The old King's counsel for RING says "I would have rung them too." The old one said the same in other words; I kept
   the King taking a side there, because he is speaking after the fact, not choosing for the heir.
9. In Portuguese the King speaks to the heir as "você", and in Spanish as "tú", as the existing hub lines do.

## Tests

Run on this branch after the import: test_campaign, test_hubs_grow, test_war_map and the mission tests a01-a06, c01,
d01-d11 (d06 and d10 too) all pass with 0 failures. test_campaign_m1 has 1 failure that has nothing to do with this
pass: "no recording yet for Tomasz" fails because Tomasz's Prologue lines were recorded on 2026-11-22 and the check was
never updated. The game boots to the main menu. tools/i18n_build.py and tools/i18n_patch_build.py build clean ([]).
