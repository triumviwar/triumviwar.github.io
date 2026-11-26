# Writing pass, Act 1 (job writing-act1, 2026-11-26)

The owner asked for every line in the campaign to be checked for AI tells and made as good as it can be. This job did
Act 1's seven missions: a01 to a07. Three other jobs do the prologues and Acts 2 and 3.

## What I found

Act 1 was in better shape than I expected. Most lines were already short and plain. The tells I found were these:

1. Tidy "not this, but that" lines. Varenne at his capture: "You have taken a man, Marshal. You have not taken an
   idea." The King on Paris: "Not a riot: a city behind its own walls." Ferrer at the river: "Nobody built this. They
   built it."
2. Lines that end on a little moral. "A mapmaker who hides a road is no mapmaker." "Quiet is not the same as calm."
   "Mercy from the victor is still victory." "Rome was black with smoke, and it was still Rome."
3. The same shape in every mission. When you play the other side and win, the King always said "That is not how it
   went", then "But it could have gone that way. I have thought of that." Five missions ended this way.
4. The creatures given a mind, against the owner's rule. "She knows her home." "She was never his." "Among her own."
   "They want the cages!" "He has come for the last cart." "They are frightened." And the King: "the mountain was
   theirs", "the nest was theirs, and the young were theirs", "He took a mother's young in the night."
5. Tidy threes and neat word games. "He believes it. I believe he believes it." "It was the law. I have read the order
   a hundred times since. It is still the law." "It was the enemy then. It is the enemy now."
6. Hedging the King would not do. "My mercy, or my mistake: I still don't know."
7. A few lines that were simply unclear. Hollweg's "No drawings. Only our hands. The people of Nuremberg send theirs."
   did not tell the player that four Winders had just arrived.

I found no dashes, and none of the stock words (echoes, whispers, testament, tapestry and the rest).

## What I changed

56 lines across the seven missions. Every story fact, choice, option, flag, objective and trigger is the same. I
added no new plot. Two examples of each kind of fix:

- Varenne, taken: "You will want me alive, Marshal. Kill me and I am a martyr, and your Church knows what martyrs are
  worth." Spared: "Exile. How very Christian of you, Marshal. Write to me when you regret it." He sneers now, like a
  clever man who has lost, instead of making a speech.
- Valadares, on the map: "I drew it for the Crown. That is what the Crown pays me for." He is a practical man.
- Valadares on the creature: "I saw her, Majesty: the doctor's creature, grown, rooted among the others in the hollow.
  He never tamed her. He only caged her." This keeps his distrust of Lindqvist and gives her no mind.
- The King's closing lines for the other side now each say something about that place. Lyon: "Had it risen, Paris
  would not have stood alone that summer." Fürth: "If the line had broken, the Machine would have had the Regnitz by
  midsummer." The doctor's cages: "If the cages had broken, the doctor would have come home with nothing, and I would
  have slept better since." Rome: "If they had, the Swiss would have died on the steps of Saint Peter's, and the people
  behind them."
- More of the faith and the period: Tomasz, for the families left on the road in Virginia: "I have confessed it. I will
  not do it twice." Ferrer, told the works rest at night: "Then I will say Matins and not go to bed." The old Cardinal
  in the frame: "I was proud of that spring, God forgive me. I was also lucky."
- Lindqvist now makes his own mistake out loud, as the lore wants: "a living fossil, a branch of nature that went its
  own way in the forest", and about the grown young: "A new species, and the fastest I have ever described." The
  Cardinal Dean answers him in the verdict (see choice 1).

Every changed line has new Portuguese and Spanish, in the same style as the rest of each mission's file.

## Lines to record again

54 of the changed lines had been recorded with Chatterbox. They are listed under "RE-RECORD (writing pass
2026-11-26)" in docs/chatterbox_todo.md, with the mission, the line id, the speaker and the new text. The ids did not
change, so a new file simply replaces the old one in campaign/voice/<mission>/. Until then the old recording plays
under the new words. The two lines not recorded were screen texts (a still's caption and a debrief line). I did not
change emotions.json: each rewritten line keeps the feeling it had.

## Claude's choices (for the owner to check)

1. In a07 the Cardinal Dean now corrects Lindqvist in the verdict: "They are no branch of nature, Doctor. The apostasy
   made such things in its laboratories." The lore says the Church corrects him as Ferrer corrects Hollweg, and that
   the Church knows the old tales. If you want that truth to come out later, put the old line back.
2. Mère Gautier calls Tomasz "the little Father". It sounds like an old weaver woman to me. "The young Father" was the
   old text.
3. The King's line after Paris spared: "Tomasz asked for a life, and he was right to ask." The old line was about mercy
   being victory. I kept the King owning the order, as before, though the choice is made in Fairleigh's camp.
4. Fairleigh's last line in Paris no longer has the bells ringing for Lauds, because Tomasz says that at the end of
   Lyon and again in Rome. Now someone rings the great bell of Notre-Dame "and I did not ask who".
5. I kept some lines that look like tells but carry the story. The King's "A stop-work is a wheel like any other. A
   wheel can be taken out." sets up a04. Hollweg's "The stop-work holds! It must hold. Why does it not hold?" is a man
   breaking, and the repeats are the point.
6. I left the NEW cards alone. They live in tools/campaign/roster_ladder.py, which serves every act. One has a small
   tell: the Mortar's "the barricades are its work, not the line's".
7. The Machine still speaks to the player who plays it ("Tick. Tock."), though the King says it has no voice. Those are
   instructions, not story, so I left them.

## Files

- tools/campaign/make_a01_mission.py to make_a07_mission.py (the English), and the seven missions' JSON written by them.
- tools/i18n/campaign/a01_presses.txt to a07_council.txt (Portuguese and Spanish), and the built scripts/lang files.
- The build docs' voice tables (docs/campaign_a0N_build.md) now show the new text.
- docs/chatterbox_todo.md (the RE-RECORD list) and a patch note under 0.38.999.

Tests: every Act 1 mission's test (tools/test_campaign_a01.gd to a07.gd), tools/test_campaign.gd and tools/test_campaign_save.gd pass with 0 failures; the boot check shows no script error.

## Every change, line by line

### a01, The Printing Houses (Lyon)

- k_open_a (king, recorded)
  - was: The Assembly kept no record of that spring. Here is what it would have done, if it could.
  - now: The Assembly left no account of that spring. Here is what it set out to do.
- t_saved (tomasz, recorded)
  - was: In Virginia we saved the families. Here, too, it is the people we must save, not only the walls.
  - now: We went back for the families in Virginia, Captain. I mean to do as well by these people.
- t_left (tomasz, recorded)
  - was: In Virginia we left the families on the road. I will not leave this city to the fire.
  - now: We left the families on the road in Virginia. I have confessed it. I will not do it twice.
- d_temper15 (delorme, recorded)
  - was: Father, they are close to the edge. Stop the runners or we lose the city.
  - now: Father, they are throwing stones on the bridges. Stop the runners or we lose the city.
- wv_spoken (weaver, recorded)
  - was: Go home, all of you. The young Father is right. Go home.
  - now: That's enough. Home, all of you, and at the looms by first light. The little Father is right.
- pr_taken (printer, recorded)
  - was: Take me, then. The paper is made in Paris. So is everything else.
  - now: Take me, then. The paper comes from Paris. Ask there.
- t_end1 (tomasz, recorded)
  - was: Rouvière went to Rome in chains. He never said who paid him. He said Paris, again and again.
  - now: Rouvière went to Rome in chains. He never named the man who paid him. Only Paris, whenever they asked.
- t_end_sullen (tomasz, recorded)
  - was: The city stayed quiet. Quiet is not the same as calm. I heard them stop talking when I passed.
  - now: The city stayed quiet. When I crossed a square, the talk stopped until I had gone by.
- c_end (cardinal, recorded)
  - was: I was proud of that spring. I am still. I was also lucky.
  - now: I was proud of that spring, God forgive me. I was also lucky.
- k_end1 (king, recorded)
  - was: He was more than lucky. He made a city go home without a volley.
  - now: Lucky. He talked a city home without a shot fired, and he calls it luck.
- k_end_a2 (king, recorded)
  - was: But if it had, Paris would have had a sister. I have thought of that.
  - now: Had it risen, Paris would not have stood alone that summer.

### a02, The Fürth Line

- h_open2 (hollweg, recorded)
  - was: Every wheel in it was cut by a hand I knew. Every machine it made would have a stop-work. I swore it.
  - now: Every wheel in it was cut by a hand I knew, and every machine it made would carry a stop-work. I gave my word on that.
- k_open_m (king, recorded)
  - was: The Machine has no voice. It left no account of that spring. Only what it did.
  - now: The Machine has no voice and kept no account. We know that spring by what it did.
- h_people (hollweg, recorded)
  - was: No drawings. Only our hands. The people of Nuremberg send theirs.
  - now: No drawings, so no Pendulum. But the families I brought out lend us their hands: four more Winders.
- col_tide (colonel, recorded)
  - was: The mill has grown a tide. Burn it, Meister, before it sends another.
  - now: The mill is sending a second wave. Burn it, Meister, before there is a third.
- h_end2 (hollweg, recorded)
  - was: Our machines were honest. Every one had its stop-work. I would swear it still.
  - now: Every machine we built at Fürth had its stop-work. I would swear to it still, before God.
- k_end1 (king, recorded)
  - was: He believes it. I believe he believes it.
  - now: He believes it. I have never taken him for a liar.
- k_end_m2 (king, recorded)
  - was: But it could have gone that way. I have thought so, many nights.
  - now: If the line had broken, the Machine would have had the Regnitz by midsummer.

### a03, The Lost Plateau

- k_open_n (king, recorded)
  - was: No creature wrote a report. But the mountain was theirs before it was anyone's.
  - now: Beasts keep no records. What follows is the nest as Valadares found it, and what it did.
- k_open_n2 (king, recorded)
  - was: That September strangers came up their cliff in the mist, while the nest slept.
  - now: That September strangers came up the cliff in the mist, while the nest slept.
- v_open3 (valadares, recorded)
  - was: We came to its foot in September, five men and the river trader, to map what no map had.
  - now: We came to its foot in September: five men and the river trader, a compass, a chain, and a book of empty pages.
- v_linnea (valadares, recorded)
  - was: And there, among them. The creature from the pen. Twice the size. She knows her home.
  - now: And there, among them. The creature from the pen, twice the size now, rooted in the swamp with the rest.
- v_drawn (valadares, recorded)
  - was: I drew it for the Crown. A mapmaker who hides a road is no mapmaker.
  - now: I drew it for the Crown. That is what the Crown pays me for.
- v_end1 (valadares, recorded)
  - was: We came down to the river with what we had. The mountain kept the rest.
  - now: We came down to the river with what we had. The rest is still up there.
- v_end_linnea (valadares, recorded)
  - was: I saw her, Majesty. The doctor's creature, grown, among her own. She was never his.
  - now: I saw her, Majesty: the doctor's creature, grown, rooted among the others in the hollow. He never tamed her. He only caged her.
- k_end_n2 (king, recorded)
  - was: But it could have gone that way. Then no one would have known what waited in the cloud.
  - now: Had the nest caught him, we would have known nothing of that mountain until it came down to us.
- text (screen text)
  - was: Valadares came down from the plateau with his survey, and saw the creature from the pen among her own.
  - now: Valadares came down from the plateau with his survey. He saw the creature from the pen up there, grown, among the others.

### a04, Father Ferrer's Visit

- f_night (ferrer, recorded)
  - was: Then I will not sleep. Brothers, we stay up.
  - now: Then I will say Matins and not go to bed. Brothers, stay up with me.
- f_mesh (ferrer, recorded)
  - was: Nobody built this. They built it.
  - now: They are building, Brother. And there is nobody at the bench.
- f_pattern (ferrer, recorded)
  - was: Look at them. The Perpetual's pattern, every wheel, with a stop-work bolted on. They took it off themselves.
  - now: The Perpetual's pattern, wheel for wheel. The stop-work was bolted on after, and they have taken it off.
- k_end_kept (king, recorded)
  - was: Hollweg brought his mended machines to Rome. I let him. That was my mistake, not his.
  - now: Hollweg brought his mended machines to Rome, and I let him. That mistake was mine.

### a05, The Specimens

- k_open_c (king, recorded)
  - was: No creature told me this. But the nest was theirs, and the young were theirs.
  - now: Nothing in that nest can tell a story. Here is what it did when the doctor came.
- l_raid1 (lindqvist, recorded)
  - was: In the trees! They want the cages!
  - now: In the trees! They are coming at the cages!
- l_grown (lindqvist, recorded)
  - was: Those are not hatchlings. Last year's young, grown. Look at them.
  - now: Last year's young, full grown in one season. Look at them. A new species, and the fastest I have ever described.
- l_sire_comes (lindqvist, recorded)
  - was: The Sire. He has come for the last cart. Hold him off!
  - now: The Sire, on the last cart! Hold him off!
- k_end1 (king, recorded)
  - was: His finest hour, he calls it. He took a mother's young in the night.
  - now: His finest hour, he calls it. He crept into a nest by night and brought the danger home in cages.
- k_end_c2 (king, recorded)
  - was: But it could have gone that way. Then the doctor would have come home with empty cages.
  - now: If the cages had broken, the doctor would have come home with nothing, and I would have slept better since.
- text (screen text)
  - was: The Sire comes for the last cart.
  - now: The Sire falls on the last cart.

### a06, The Barricades of Paris

- k_open1 (king, recorded)
  - was: Paris rose in the summer of 2769. Not a riot: a city behind its own walls, with a government in its hall.
  - now: Paris rose in the summer of 2769. They walled their streets with carts and paving stones and sat a government in the Hôtel de Ville.
- va_taken (varenne, recorded)
  - was: You have taken a man, Marshal. You have not taken an idea.
  - now: You will want me alive, Marshal. Kill me and I am a martyr, and your Church knows what martyrs are worth.
- va_spared (varenne, recorded)
  - was: You will regret your mercy, Marshal. Or I will make you glad of it. We shall see.
  - now: Exile. How very Christian of you, Marshal. Write to me when you regret it.
- va_exec (varenne, recorded)
  - was: Do it in daylight. Let them all see what the Crown is.
  - now: At noon, then, when the square is full. Let Paris watch the Crown at work.
- f_won (fairleigh, recorded)
  - was: Paris was the King's again by morning. The bells of Notre-Dame rang for Lauds.
  - now: Paris was the King's again by morning. Someone rang the great bell of Notre-Dame, and I did not ask who.
- k_end_spared (king, recorded)
  - was: Mercy from the victor is still victory. I have never regretted that order.
  - now: I have never regretted that order. Tomasz asked for a life, and he was right to ask.
- k_end_exec (king, recorded)
  - was: It was the law. I have read the order a hundred times since. It is still the law.
  - now: It was the law. I have read that order more often than I care to say.

### a07, The Council of Rome

- f_quarrel (ferrer, recorded)
  - was: I told him the night before the gift. The ghost in the machine destroyed the apostasy once. It was the enemy then. It is the enemy now.
  - now: I told him so the night before the gift, Eminences. A thinking machine brought the apostasy down. I see no reason one should spare us.
- v_drawn (valadares, recorded)
  - was: I drew the way up the plateau for the Crown. I saw her there, the creature from the station, grown, among her own.
  - now: I drew the way up the plateau for the Crown. I saw her up there, the creature from the station, grown, rooted with the others.
- v_withheld (valadares, recorded)
  - was: I gave my map to the Church alone, sealed. But I saw her there, the creature from the station, grown, among her own.
  - now: I gave my map to the Church alone, sealed. But I saw her up there, the creature from the station, grown, rooted with the others.
- l_oldest (lindqvist, recorded)
  - was: They are not monsters, Eminences. They are the oldest things alive. Study them, and you read a page of creation no one has read.
  - now: Eminences, these are no monsters. They are a living fossil, a branch of nature that went its own way in the forest. Study them, and you read a page of creation nobody has read.
- c_verdict2 (cardinal, recorded)
  - was: The specimens are to be destroyed, and their eggs with them.
  - now: They are no branch of nature, Doctor. The apostasy made such things in its laboratories. The specimens are to be destroyed, and their eggs with them.
- k_letgo (king, recorded)
  - was: They both walked out of the hall. I let them go. My mercy, or my mistake: I still don't know.
  - now: They both walked out of the hall, and I let them go. I have had twenty-five years to decide whether that was mercy.
- k_1 (king, recorded)
  - was: I sent my guard to the bridges that evening. I did not know why. I only knew the city was angry.
  - now: I sent my guard to the bridges that evening. I could not have told you why, except that the city was angry.
- l_loose (lindqvist, recorded)
  - was: Not like this! They are frightened. Let them be!
  - now: Not like this! Don't shoot them! Drive them back into the stables!
- k_dawn (king, recorded)
  - was: Dawn. The bridges held. Rome was black with smoke, and it was still Rome.
  - now: Dawn. The bridges held. The smoke lay so thick on the river I could not see the far bank.
- k_end_lost2 (king, recorded)
  - was: But if they had, there would have been no council, and no Church to hold one.
  - now: If they had, the Swiss would have died on the steps of Saint Peter's, and the people behind them.
- k_end2 (king, recorded)
  - was: That was the first time I met them both. It was not the last.
  - now: That was the first time I met them both. I would see each of them again, in worse years.