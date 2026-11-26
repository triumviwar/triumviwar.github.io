# Writing pass, Act 2 (job writing-act2, 2026-11-26)

The owner asked for every line of the campaign to be checked for AI tells and made as good as it can be. This job did
Act 2: the eleven missions d01_minas to d11_siege. Other jobs did Acts 1 and 3.

## What was checked

Every spoken line, every narrator line, the briefings, the debriefs and the objectives of the eleven missions. That is
about 920 spoken and narrator lines. 72 of them were rewritten. The objectives and briefings were already plain and
short, so they were left alone.

Act 2's writing was in better shape than expected. Most people already sounded like themselves: Meneses is a blunt
soldier, Father Inácio is a joyful priest in a basket, Pieter is practical, Varenne talks like an orator. So this pass
cut the tells and left the good lines standing, instead of rewriting everything into a new voice.

## The tells found

1. Lines that end on a neat saying or a moral. The most common one. For example Tomasz in d01: "The town was quiet.
   Quiet is not the same as at peace." Now: "The town was quiet. The Captain said that was what worried him."
2. Tidy mirrored pairs. Tomasz in d01: "In Lyon I had learnt to speak to a crowd. In Minas I learnt to stay with it
   afterwards." Now: "I baptised forty children in Vila Rica that year, and buried eleven of the men who had come up
   those stairs."
3. "Not this, but that" turns. Tomasz in d01: "Not because of the bayonets. Because someone had come to their churches."
   Now: "The brotherhoods remembered who had come to their churches before the bell rang."
4. The same phrase used as a motif until it wears out. In d09 "one army, two fires" came three times; the King's last
   line was "That is what a crown is, in the end: choosing which fire burns longer." Now the King says: "Ruggieri wrote
   to me after, to ask if he had chosen right. I told him the truth: I did not know either."
5. Stock phrases. "The valley is quiet. Too quiet." (d04) is now "No smoke rises from the valley's chimneys." "Do not
   look back" (d02, d06) is gone; Hollweg now says "Cast off. Mind the ice by the piers."
6. A name said twice for drama. "Jakob would have known which wheels to leave. Jakob is not here." Now: "Jakob would
   have known which wheels to leave behind. I shall have to guess."
7. Stating the obvious instead of showing a detail. Tomasz hearing Ramos' confession, d01: "What he said is between him
   and God. What he did is between him and the King." Now he heard it "sitting on a cart wheel, with a dragoon standing
   off out of earshot. That is all I will say of it."
8. The same closing line used in two missions. Tomasz's "I counted twice to be sure" was in d05 and d09. d09 now has
   its own ending lines.
9. Facts that were slightly off. The King called Lindqvist's lure book "a dead man's book" in d08, but Lindqvist is
   alive. Now it is "Lindqvist's book".

## The Brood is not a person

Three lines gave a creature family or a name in the narrator's mouth:

- d03, Lindqvist: "And among them her daughter." Now: "a young Mother, out of the clutch we carried from the station.
  Linnea's get." (A breeder's word: a person speaking of an animal.)
- d06, Lindqvist: "I named her Linnea, like her mother." Now "after her dam".
- d06, narrator: "Linnea is dead." Now "Your Mother is dead." Only people call her Linnea.
- d08, the King: "It waited in the flooded forest for the next floods." Waiting sounds like a plan. Now: "It stayed in
  the flooded forest, and came again with the next floods."

## What changed, mission by mission

- d01_minas (14 lines): the King's opening, Tomasz's arrival, the calm, the ledger, the miners, the confession, his
  endings, the King's two endings; Meneses' warning made blunter.
- d02_exodus (9 lines): Hollweg's opening and his drawings, the cast-off, the manifest ending, the King's verdict
  ("The law calls it desertion, and so do I").
- d03_fazenda (6 lines): Lindqvist's belief that they are a new species said in his own proud way, Pieter's tip, the
  King's two corrections (Valadares' report "runs to forty pages").
- d04_concordia (10 lines): Varenne on crowds, Hollweg on Father Anselmo, the dawn, Arruda's apology, Hollweg's
  "Concord." at the end of the fight is now "Count our dead, Ulrich. And theirs.", his foreshadowing ending, the King.
- d05_aldeia (3 lines): the King's opening, Tomasz and the catechism (the children laugh at his accent), the fields.
- d06_queen (5 lines): Linnea's naming, the narrator, the escape, the King's ending.
- d07_spring (7 lines): the broken ones under their sheets, the brake, Matthias, the King's four endings (the machine's "all the nights it wanted" is gone).
- d08_rivers (3 lines): the King's endings.
- d09_crossroads (6 lines): Tomasz's counsel, Ruggieri's decision, Tomasz's endings, the King's endings.
- d10_jungle (2 lines): Valadares hurt, Father Inácio's ending.
- d11_siege (7 lines): Jakob's burial, the spring stopped, the long stand-off, the King's opening (Ferrer "never wrote down a thing he had not seen with his own eyes") and three endings.

Every change has new Portuguese and Spanish in the same style as the rest of each file. Line ids, triggers, choices,
flags and objectives are untouched. The tests of all eleven missions (tools/test_campaign_d01.gd to d11) and tools/test_campaign.gd pass, 0 failures each. Run them one at a time: run side by side they share the save folder and fail on the flags.

## Lines to re-record

None. No Act 2 line has been recorded in Chatterbox yet. The tables for d01 to d11 in docs/chatterbox_todo.md now hold
the new texts. The emotion presets in tools/voice_clone/emotions.json only name a feeling, not the words, so the three
rewritten lines with a preset (d03 p_still, d09 t_end_few, d11 f_jakob_down) keep theirs.

## Claude's choices (for the owner to check)

1. Light touch. Lines that already worked were kept, even when they had some wit (Varenne's "Paris burned keeping time.
   I watched it from a boat.", "As if, Meister."). The owner may want a second, harder pass on the King.
2. New small details were added where a line needed something real instead of a saying: Ferrer's diary in "that small
   Catalan hand of his", forty children baptised and eleven men buried in Vila Rica, the fort's cook handing out bread,
   Valadares' forty-page report, the ice by the piers on the Main. None changes the plot. Ferrer as a Catalan is a
   guess from his name.
3. The King's d09 ending now admits he did not know if Ruggieri chose right. That fits the choice having no canon, and
   the King still tells the truth.
4. Hollweg's last word at the end of the d04 fight was "Concord." (the city's name, as irony). It is now an order about
   the dead. If the owner liked the irony, it can come back.
5. The hub lines after these missions (campaign/campaign.json) were not touched: that file is shared with the other
   writing jobs. Some of them still carry the old sayings ("In Minas I learnt that a sermon is the easy part").
6. The narrator's one-word show cards in d06 ("The flood." "The pens." "The Queen.") were left as they are.
