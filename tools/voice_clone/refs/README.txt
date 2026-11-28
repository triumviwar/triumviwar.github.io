Chatterbox reference recordings for the campaign's characters (about 20 s each, 24 kHz mono), spoken by voices
DESIGNED in the owner's ElevenLabs account (Voice Design, 2026-11-14; no real person's voice). Use with
clone_lines.py --ref refs/<name>_ref.wav.
hollweg   Meister Hollweg, the clockmaker (Clockwork narrator): older German, precise, proud.
explorer  The Catholic explorer (Brood storyline): weathered Portuguese baritone, devout.
varenne   Etienne Varenne, rebel leader of the Free Assembly: fiery French tenor, sly.
fairleigh Lord Edmund Fairleigh, Governor of Virginia: cold, clipped English aristocrat.
ruggieri  Captain Matteo Ruggieri, the guns: loud, gruff Italian gunner.
lindqvist Dr. Lindqvist, the scientist (Brood storyline): elderly Oxford-educated Scandinavian professor, a condescending
          atheist lecturer (v2, 2026-11-14; the first design was "flat").
ferrer_ref.wav: Father Ferrer, designed 2026-11-22 (a calm, measured Spanish Jesuit of about fifty, light Castilian accent; 13.5 s).
Designed 2026-11-22 in the second ElevenLabs account (Voice Design previews, 12-20 s, 24 kHz mono here):
delorme   Captain Delorme of the Lyon watch: French captain in his forties, practical, dry, steady.
jakob     Jakob, Hollweg's journeyman: young Franconian German, earnest, quick, a little breathless.
cardinal  Cardinal Tomasz (old): elderly Polish cardinal, gentle, grave, slow, a slight rasp (the frame's old Tomasz).
captain   The Captain of the Watch of Nuremberg: German, weary, blunt, dutiful, voice rough from the cold.
sergeant  The Crown's sergeant: old West Country English soldier, gruff, hearty, old-fashioned oaths.
pieter    Pieter, Lindqvist's assistant: young Dutch clerk, nervous, careful, eager to please.
machine   The Machine (Clockwork): cold, flat, every word on a beat like a clock's tick, faintly metallic.
brother   Brother Anselm, Ferrer's lay brother: elderly German, gentle, hushed, humble.
colonel   Colonel von Rauch of the Fürth line: Bavarian colonel, hard, clipped, commanding.
benedito  Benedito the riverman: Brazilian canoe guide in his fifties, calm, wary, soft and husky.
Designed 2026-11-22, second batch (the second account; the first of the three previews kept each time):
tomasz         young Tomasz Wierzbicki: Polish seminarian, early twenties, gentle, sincere, soft-spoken.
cardinal_dean  the Cardinal Dean of the council of Rome (a07): elderly Italian, solemn, slow, deep.
printer        Rouviere the printer (a01): French pamphleteer in his fifties, proud, sardonic, raspy.
weaver         Mere Gautier (a01): old Lyon silk weaver woman, tired, motherly, low alto.
commissary     the Commissary (a02): Bavarian official, cold, precise, thin nasal tenor.
guide          the guide from Nazare (a03): Amazon forest guide, quiet, low, grainy.
teles          Lieutenant Teles (b01): young Portuguese officer, quick, decisive, orders over gunfire.
joaquim        Frei Joaquim (b01): Portuguese Franciscan in his sixties, fatherly, urgent.
volunteer      Will Hollins (a06): Virginia farm lad of nineteen, earnest, shy, brave.
assembly       the Free Assembly's adviser (a01, a06 versus): French woman agitator, sharp, smoky mezzo.
tomasz_angry_ref.wav: young Tomasz SHOUTING (2026-11-28, the owner's pick of two ElevenLabs v4 takes in the second
          account, "Out! All of you, out of the church, now!..."; 15.5 s). make_big_lines.py uses it for his shout and
          angry lines (ANGRY_REFS); `python make_big_lines.py --angry` writes lines_angry.txt (his 7 such lines again).
Designed 2026-11-28 (Voice Design previews, the first of three kept, cut at a pause near 18 s; owner's third ElevenLabs
account for ulrich/meneses/ramos/arruda/inacio, a FREE account for officer/tiago/rider/fonseca/morel: no commercial
licence on those five, redo them in the paid account before a sale):
ulrich    Ulrich, the guild's foreman (d02, d04, d07): Franconian, fifties, gruff, shouts over machines.
meneses   Captain Luis de Meneses (d01): Portuguese dragoon captain, forties, blunt and brisk.
ramos     Lieutenant Inacio Ramos (d01): Brazilian orator, thirties, warm and dangerous.
arruda    Captain Bento Arruda (d04, d07, d11): southern Brazilian cattleman-officer, forties, plain and stubborn.
inacio    Father Inacio Lourenco (d10): Brazilian priest-aeronaut, forties, bright and quick.
tiago     Brother Tiago (d05): young Brazilian catechist, gentle and grave.
fonseca   Desembargador Fonseca (d03): Portuguese-Brazilian judge, fifties, pompous.
morel     Citizen Morel (d04, d07): French Assembly man, thirties, cold and clipped.
rider     the frontier's rider (d09): young dragoon, breathless.
officer   Captain Sobral (d05) and the captain of Obidos (d10); pitched down 0.8 for Major Teixeira (d09).
Voices made from others by pitch (make_big_lines.py VOICES): Brandt = commissary, Padre Anselmo = joaquim, Ortlieb =
captain, the d07 master = brother, the townsman = tiago, the Barra's sergeant = sergeant, Tomasz grown, Pieter grown,
Jakob old, Matthias = jakob higher, Sergeant Hollins = volunteer lower. Valadares' angry reference is made by
Chatterbox itself as the first line of lines_all.txt (out_all/valadares_angry_seed.wav; keep it here as
refs/valadares_angry_ref.wav if it sounds right).
