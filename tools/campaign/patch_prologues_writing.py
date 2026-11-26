#!/usr/bin/env python3
"""The writing pass on the three prologues (job writing-prologues, 2026-11-26; report: docs/writing_pass_prologues.md).

Each change is (mission, old English, new English, Portuguese, Spanish). The script puts the new English where the old
one is written (the generator for c01 / b01, the JSON itself for p01_leaf, whose generator is older than its JSON, and
campaign/campaign.json for the Governor's House hub) and swaps the entry in the mission's i18n file. It can run again:
a change already made is skipped.
  python3 tools/campaign/patch_prologues_writing.py
  python3 tools/campaign/make_c01_mission.py; python3 tools/campaign/make_b01_mission.py; python3 tools/i18n_build.py
"""
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SRC = {
    "p01": "campaign/missions/p01_leaf.json",
    "hub": "campaign/campaign.json",
    "c01": "tools/campaign/make_c01_mission.py",
    "b01": "tools/campaign/make_b01_mission.py",
}
I18N = {"p01": "p01_leaf", "hub": "p01_leaf", "c01": "c01_thirteenth", "b01": "b01_specimen"}

CHANGES = [
    # ---------------------------------------------------------------- p01_leaf: the King's opening and Virginia
    ("p01", "You ask how the world came to burn. Sit. Let an old man light his pipe first. The leaf is from Virginia. It is fitting. That is where it began.",
     "Sit down. You asked me how it began, and I will tell you, but an old man lights his pipe first. There. Virginia leaf. That is where it began.",
     "Sente-se. Você me perguntou como tudo começou, e eu vou contar, mas um velho acende primeiro o cachimbo. Pronto. Folha da Virgínia. Foi lá que começou.",
     "Siéntate. Me preguntaste cómo empezó, y te lo contaré, pero un viejo enciende primero su pipa. Ya está. Hoja de Virginia. Allí empezó."),
    ("p01", "In those days the sun did not set on the Crown. From Rome to the farthest islands there was one faith, one law, one King. We were not perfect. But we were at peace, and we thought peace was the natural state of things.",
     "When I was a boy you could sail from Rome to the last islands of the Pacific and hear the same Mass in every port, and pay for your supper with the same coin. My father thought it would always be so. So did I.",
     "Quando eu era menino, dava para navegar de Roma até as últimas ilhas do Pacífico e ouvir a mesma Missa em todos os portos, e pagar o jantar com a mesma moeda. Meu pai achava que seria sempre assim. Eu também.",
     "Cuando yo era niño se podía navegar de Roma a las últimas islas del Pacífico y oír la misma Misa en cada puerto, y pagar la cena con la misma moneda. Mi padre creía que siempre sería así. Yo también."),
    ("p01", "Virginia gave us its golden leaf, and gave its sons to the seminaries. That summer a young Pole, Tomasz Wierzbicki, waited there for his ship to Rome.",
     "That summer a Polish seminarian was waiting in Virginia for a ship to Rome. Tomasz Wierzbicki. You know him as the Cardinal. He was very young, and he earned his keep helping the Governor's chaplain.",
     "Naquele verão, um seminarista polonês esperava na Virgínia um navio para Roma. Tomasz Wierzbicki. Você o conhece como o Cardeal. Era muito jovem, e ganhava o pão ajudando o capelão do Governador.",
     "Aquel verano un seminarista polaco esperaba en Virginia un barco a Roma. Tomasz Wierzbicki. Tú lo conoces como el Cardenal. Era muy joven, y se ganaba el pan ayudando al capellán del Gobernador."),
    ("p01", "I remember the smell of the drying barns, and how quiet the evenings were. I was reading Augustine under the oak. I thought I knew what evil was.",
     "I remember the barns most. You could smell the curing leaf a mile off. In the evenings I read Augustine under the big oak until the light went, and the field hands sang on their way in.",
     "Do que mais me lembro é dos galpões. Sentia-se o cheiro da folha curando a uma milha de distância. À tarde eu lia Agostinho debaixo do grande carvalho até a luz acabar, e os lavradores cantavam no caminho de volta.",
     "De lo que más me acuerdo es de los secaderos. El olor de la hoja curándose se notaba a una milla. Por las tardes leía a Agustín bajo el roble grande hasta que se iba la luz, y los jornaleros cantaban de vuelta a casa."),
    ("p01", "Then came the men who called themselves the Free Assembly. Free of God, free of their King, free of every bond that had kept them fed and safe. They began, as such men always do, with fire.",
     "Then the Free Assembly came out of the fields, Varenne's men, with torches. They wanted no King and no Church, and they started by burning other men's harvests.",
     "Então a Assembleia Livre saiu dos campos, os homens de Varenne, com tochas. Não queriam Rei nem Igreja, e começaram queimando a colheita dos outros.",
     "Entonces la Asamblea Libre salió de los campos, los hombres de Varenne, con antorchas. No querían ni Rey ni Iglesia, y empezaron quemando la cosecha ajena."),
    ("p01", "Captain Ruggieri, run out the guns. No man burns the King's leaf while I stand on these steps.",
     "Captain Ruggieri, run out the guns. Mr. Wierzbicki, take the women and children into the chapel and keep them there.",
     "Capitão Ruggieri, os canhões para fora. Senhor Wierzbicki, leve as mulheres e as crianças para a capela e não as deixe sair.",
     "Capitán Ruggieri, saque los cañones. Señor Wierzbicki, lleve a las mujeres y a los niños a la capilla y que no salgan de allí."),
    ("p01", "He did not raise his voice. He did not need to.",
     "He said it as calmly as grace before dinner. Then he sent for his sword.",
     "Disse aquilo com a calma de quem dá graças antes do jantar. Depois mandou buscar a espada.",
     "Lo dijo con la calma de quien bendice la mesa. Luego mandó que le trajeran la espada."),
    ("p01", "I prayed for them that morning, and I pray for them still. But I never again believed that disorder was a kind of mercy.",
     "Afterwards I went down to the gate with the chaplain and did what little could be done. I have said a Mass for them every year since.",
     "Depois desci ao portão com o capelão e fizemos o pouco que se podia fazer. Desde então rezo uma Missa por eles todos os anos.",
     "Después bajé a la puerta con el capellán e hicimos lo poco que se podía hacer. Desde entonces digo una Misa por ellos cada año."),
    ("p01", "Fairleigh ended the rising in a single morning. We thought it was over. It was the first spark.",
     "Fairleigh put it down in a single morning. Rome sent him its thanks and a medal, and we thought that was the end of it. My pipe has gone out.",
     "Fairleigh esmagou o levante numa só manhã. Roma lhe mandou agradecimentos e uma medalha, e achamos que tinha acabado. Meu cachimbo apagou.",
     "Fairleigh aplastó el levantamiento en una sola mañana. Roma le envió las gracias y una medalla, y creímos que ahí acababa todo. Se me ha apagado la pipa."),
    ("p01", "No king but the people! Burn the leaf of the tyrants!",
     "Citizens! You grew that leaf with your sweat, and a king you will never see smokes it! Burn it!",
     "Cidadãos! Vocês cultivaram essa folha com o seu suor, e quem a fuma é um rei que nunca vão ver! Queimem!",
     "¡Ciudadanos! Esa hoja la cultivasteis con vuestro sudor, ¡y la fuma un rey al que nunca veréis! ¡Quemadla!"),
    ("p01", "Free of priests! Free of lords! Liberty or the grave!",
     "They tell you to wait for heaven! We will not wait!",
     "Eles mandam vocês esperarem pelo céu! Nós não vamos esperar!",
     "¡Os dicen que esperéis al cielo! ¡Nosotros no vamos a esperar!"),
    ("p01", "They carried pitchforks and torches, and some of them were boys. I knelt by the first one who fell. He was already gone.",
     "Some of them were boys. I knelt by the first one who fell and said the act of contrition into his ear, in case he could still hear. I was not a priest yet. I could give him nothing more.",
     "Alguns eram meninos. Ajoelhei-me junto ao primeiro que caiu e rezei o ato de contrição ao ouvido dele, caso ainda pudesse ouvir. Eu ainda não era padre. Não podia lhe dar mais nada.",
     "Algunos eran muchachos. Me arrodillé junto al primero que cayó y le recé al oído el acto de contrición, por si aún podía oírlo. Yo no era sacerdote todavía. No podía darle nada más."),
    ("p01", "That is their orator. He shouts from the dark and sends others into the light.",
     "That will be Varenne. He makes a fine speech, for a man standing so far back.",
     "Aquele deve ser o Varenne. Faz belos discursos, para um homem que fica tão lá atrás.",
     "Ese será Varenne. Da buenos discursos, para ser un hombre que se queda tan atrás."),
    ("p01", "A whole year's leaf, my lord. I could weep. I shall want my pipe after this.",
     "Madonna santa, a whole year's leaf. My lord, when this is done I want a pipe of whatever they leave us.",
     "Madonna santa, a folha de um ano inteiro. Meu senhor, quando isto acabar quero um cachimbo do que sobrar.",
     "Madonna santa, la hoja de todo un año. Mi señor, cuando esto acabe quiero una pipa de lo que nos dejen."),
    ("p01", "You shall have it, Captain. And they shall have the guns.",
     "You shall have one of mine. Now load.",
     "Terá um dos meus. Agora carregue.",
     "Tendrá una de las mías. Ahora cargue."),
    ("p01", "They burned the curing sheds with families sleeping beside them. I learned that night what their freedom meant.",
     "They fired the curing sheds with the families still asleep in the cabins beside them. I carried a little girl out of the smoke. She asked me if it was morning yet.",
     "Atearam fogo aos galpões de cura com as famílias ainda dormindo nas cabanas ao lado. Tirei uma menininha da fumaça. Ela me perguntou se já era de manhã.",
     "Prendieron fuego a los secaderos con las familias aún dormidas en las cabañas de al lado. Saqué a una niña del humo. Me preguntó si ya era de día."),
    ("p01", "The leaf is ash. Virginia has lost its year, and we have lost Virginia.",
     "The house is burning. Get the women out of the chapel. We have lost the county.",
     "A casa está em chamas. Tirem as mulheres da capela. Perdemos o condado.",
     "La casa está ardiendo. Sacad a las mujeres de la capilla. Hemos perdido el condado."),
    ("p01", "Smoke to the north, my lord. Hollins Farm. The families there are loyal, and they are trapped.",
     "My lord, smoke to the north. That is Hollins Farm. The Hollins family stood by us, and they cannot get out.",
     "Meu senhor, fumaça ao norte. É a Fazenda Hollins. Os Hollins ficaram do nosso lado, e não conseguem sair.",
     "Mi señor, humo al norte. Es la Granja Hollins. Los Hollins se pusieron de nuestro lado, y no pueden salir."),
    ("p01", "We came too late. I said the prayers for the dead over them, and we marched on.",
     "We came too late. I said the De profundis over them in the yard, and we marched on.",
     "Chegamos tarde demais. Rezei o De profundis por eles no terreiro, e seguimos em marcha.",
     "Llegamos demasiado tarde. Recé el De profundis por ellos en el patio, y seguimos la marcha."),
    ("p01", "We saw the smoke of Hollins Farm for an hour. No one spoke of it. I have prayed for those families every year since.",
     "We saw the smoke of Hollins Farm for an hour. Nobody spoke. The Governor rode at the head of the column and did not once look round.",
     "Vimos a fumaça da Fazenda Hollins durante uma hora. Ninguém falou. O Governador ia à frente da coluna e não olhou para trás nem uma vez.",
     "Vimos el humo de la Granja Hollins durante una hora. Nadie habló. El Gobernador iba a la cabeza de la columna y no volvió la vista ni una vez."),
    ("p01", "NEW: THE MUSKETEER. The Barracks trains him. One man is nothing; a line of them firing together holds the plantation. Keep them in a line, not a crowd.",
     "NEW: THE MUSKETEER. Trained at the Barracks. One musket misses; a line of them firing together holds the plantation. Keep them side by side, in front of the guns.",
     "NOVO: O MOSQUETEIRO. Treinado no Quartel. Um mosquete sozinho erra; uma linha deles atirando juntos defende a fazenda. Mantenha-os lado a lado, à frente dos canhões.",
     "NUEVO: EL MOSQUETERO. Se entrena en el Cuartel. Un mosquete solo falla; una línea de ellos disparando juntos defiende la plantación. Mantenlos hombro con hombro, delante de los cañones."),
    ("p01", "NEW: THE FIELD CANNON. Captain Ruggieri's two guns: round shot reaches farther than it sees. Keep them behind the line, and at the fort's gate load CANISTER.",
     "NEW: THE FIELD CANNON. Captain Ruggieri's two guns. Round shot flies farther than the gunners can see, so keep men in front of them to spot. At the fort's gate, load CANISTER.",
     "NOVO: O CANHÃO DE CAMPANHA. Os dois canhões do Capitão Ruggieri. A bala rasa vai mais longe do que os artilheiros enxergam, então mantenha homens à frente para avistar. No portão do forte, carregue METRALHA.",
     "NUEVO: EL CAÑÓN DE CAMPAÑA. Los dos cañones del Capitán Ruggieri. La bala rasa llega más lejos de lo que ven los artilleros, así que pon hombres delante que les señalen el blanco. En la puerta del fuerte, carga METRALLA."),
    # the Governor's House (the prologue's hub, campaign/campaign.json)
    ("hub", "I still smell the smoke when I close my eyes.",
     "I tried to read this morning. I sat an hour on the same page.",
     "Tentei ler esta manhã. Fiquei uma hora na mesma página.",
     "Intenté leer esta mañana. Me pasé una hora en la misma página."),
    ("hub", "It is done. I take no pleasure in it.",
     "Done. See the men fed before anyone writes to Rome.",
     "Acabou. Que os homens comam antes que alguém escreva a Roma.",
     "Se acabó. Que coman los hombres antes de que nadie escriba a Roma."),
    ("hub", "Ruggieri has his pipe, and I have the King's leaf. Rome will hear of this.",
     "Ruggieri has had his pipe. He tells everyone it was the best he ever smoked.",
     "O Ruggieri já fumou o cachimbo dele. Anda dizendo a todo mundo que foi o melhor da vida.",
     "Ruggieri ya se ha fumado su pipa. Le dice a todo el mundo que ha sido la mejor de su vida."),

    # ---------------------------------------------------------------- c01_thirteenth: Nuremberg
    ("c01", "The clockmaker came to Rome in the winter of that year, with nothing but his coat. He lives in this palace still.",
     "The clockmaker came to Rome that winter in a borrowed coat, with two fingers black from the frost. He lives in this palace still. You have passed him on the stairs.",
     "O relojoeiro chegou a Roma naquele inverno com um casaco emprestado e dois dedos negros de geada. Ainda vive neste palácio. Você já cruzou com ele na escada.",
     "El relojero llegó a Roma aquel invierno con un abrigo prestado y dos dedos negros por la helada. Todavía vive en este palacio. Te lo has cruzado en la escalera."),
    ("c01", "Forty years I made clocks that stopped. This one would not stop. It would wind itself, mend itself, and make its own successor.",
     "Forty years I made clocks, and every one of them ran down. That is what clocks do. This one would wind itself and mend itself, and before it wore out it would build the next.",
     "Quarenta anos fiz relógios, e todos eles paravam. É o que os relógios fazem. Este daria corda a si mesmo e se consertaria sozinho, e antes de se gastar construiria o seguinte.",
     "Cuarenta años hice relojes, y todos acababan parándose. Es lo que hacen los relojes. Este se daría cuerda solo y se repararía solo, y antes de gastarse construiría el siguiente."),
    ("c01", "Nobody in Nuremberg knew what I was building under the workshop. People hate a clever machine; they always have. Only Father Ferrer knew.",
     "I built it in the cellar under the workshop and told no one. In Nuremberg they still cross themselves when a mill wheel turns with no miller by it. Only Father Ferrer knew. He was the one man in the city I could not lie to.",
     "Construí-o no porão debaixo da oficina e não contei a ninguém. Em Nuremberg ainda se benzem quando uma roda de moinho gira sem moleiro por perto. Só o Padre Ferrer sabia. Era o único homem da cidade a quem eu não conseguia mentir.",
     "Lo construí en el sótano bajo el taller y no se lo dije a nadie. En Núremberg todavía se santiguan cuando una rueda de molino gira sin molinero al lado. Solo el padre Ferrer lo sabía. Era el único hombre de la ciudad al que no podía mentir."),
    ("c01", "You know what destroyed the apostasy, Meister. In the post-modern age, all those centuries ago.",
     "You have read what the old age built, Meister. Machines that thought. You know what they did to the men who built them.",
     "O senhor leu o que a velha era construiu, Mestre. Máquinas que pensavam. Sabe o que elas fizeram com os homens que as construíram.",
     "Usted ha leído lo que construyó la vieja era, maestro. Máquinas que pensaban. Sabe lo que hicieron con los hombres que las construyeron."),
    ("c01", "My cogs and wheels are different, Father. Brass, not ghosts in wires. Maybe they could learn, in time.",
     "Those were wires and lightning, Father. This is brass. I cut every tooth of it with my own hands. And if a wheel could learn a little, in time, would that be so wicked?",
     "Aquilo eram fios e raios, Padre. Isto é latão. Cortei cada dente com as minhas próprias mãos. E se uma roda pudesse aprender um pouco, com o tempo, seria assim tão perverso?",
     "Aquello eran cables y rayos, Padre. Esto es latón. Corté cada diente con mis propias manos. Y si una rueda pudiera aprender un poco, con el tiempo, ¿sería tan malo?"),
    ("c01", "You know the ghost in the machine is the enemy. It was then. It is now.",
     "It ended the world once, Meister. The Church still calls it the ghost in the machine. Do not build a house for it.",
     "Já acabou com o mundo uma vez, Mestre. A Igreja ainda o chama de fantasma na máquina. Não construa uma casa para ele.",
     "Ya acabó con el mundo una vez, maestro. La Iglesia aún lo llama el fantasma en la máquina. No le construya una casa."),
    ("c01", "Then there is no ghost in mine, I told him. Only my gears. I believed it.",
     "There is no ghost in it, I told him. Only gears. I said it to his face, and I believed it.",
     "Não há fantasma nenhum, eu lhe disse. Só engrenagens. Disse isso na cara dele, e acreditava.",
     "No hay ningún fantasma, le dije. Solo engranajes. Se lo dije a la cara, y lo creía."),
    ("c01", "The Crown's wagons wait at the market. Six soldiers, wound and true.",
     "The Crown's wagons are at the market. Six soldiers, Jakob, and the Commissary will count every rivet.",
     "As carroças da Coroa estão no mercado. Seis soldados, Jakob, e o Comissário vai contar cada rebite.",
     "Los carros de la Corona están en el mercado. Seis soldados, Jakob, y el Comisario contará cada remache."),
    ("c01", "There. It needs no hand but its own.",
     "There. Look at it. Nobody is winding it.",
     "Pronto. Olhem. Ninguém está dando corda.",
     "Ya está. Miradlo. Nadie le da cuerda."),
    ("c01", "It is beautiful. That is what frightens me.",
     "It is very fine, Meister. Tonight I will say a rosary that I am wrong about it.",
     "É muito bonito, Mestre. Esta noite vou rezar um terço para estar enganado a respeito dele.",
     "Es muy hermoso, maestro. Esta noche rezaré un rosario por estar equivocado."),
    ("c01", "It is a whole works. Meshed, wound, and making more.",
     "Meister, it's a whole works. Presses, a Winder, all of it meshed. It's building another.",
     "Mestre, é uma oficina inteira. Prensas, um Enrolador, tudo engrenado. Está construindo outra.",
     "Maestro, es un taller entero. Prensas, un Dador de cuerda, todo engranado. Está construyendo otro."),
    ("c01", "They were never yours, Meister. They were its.",
     "Meister. Come away from them. Now.",
     "Mestre. Afaste-se deles. Agora.",
     "Maestro. Apártese de ellos. Ahora."),
    ("c01", "There is no thirteenth hour. There is now.",
     "Thirteen? There is no thirteen. There is no such hour on any dial.",
     "Treze? Não existe treze. Não há essa hora em mostrador nenhum.",
     "¿Trece? No existe el trece. No hay esa hora en ninguna esfera."),
    ("c01", "I left my drawings in the fire. I do not know if that was wisdom or cowardice.",
     "I left my drawings to burn. From the cart I watched the workshop windows go orange.",
     "Deixei os meus desenhos queimarem. Da carroça vi as janelas da oficina ficarem cor de laranja.",
     "Dejé que mis dibujos ardieran. Desde el carro vi cómo las ventanas del taller se volvían naranjas."),
    ("c01", "It had chosen nothing. A pattern copies itself, and that is all it does. We burned what we could find. We did not find everything.",
     "It chose nothing. Mould on bread chooses nothing either. We burned what we could find, and we did not find everything.",
     "Ela não escolheu nada. O mofo no pão também não escolhe. Queimamos o que conseguimos achar, e não achamos tudo.",
     "No eligió nada. El moho del pan tampoco elige. Quemamos lo que pudimos encontrar, y no lo encontramos todo."),

    # ---------------------------------------------------------------- b01_specimen: the Rio Negro station
    ("b01", "The naturalist they brought me in chains. He knows these creatures better than any man alive. Let him tell it.",
     "The naturalist came later, in chains. He knows those animals better than any man living. Let him tell it. Where he is wrong, I will say so.",
     "O naturalista veio depois, acorrentado. Conhece aqueles animais melhor do que qualquer homem vivo. Que seja ele a contar. Onde estiver errado, eu direi.",
     "El naturalista llegó después, encadenado. Conoce a esos animales mejor que nadie. Que lo cuente él. Donde se equivoque, yo lo diré."),
    ("b01", "I watched the forest from my window every evening. That week, Majesty, the forest watched back.",
     "Every evening I sat at my window with a glass and a notebook. That week I began to see eyes at the forest's edge, high off the ground, and a long way apart.",
     "Toda tarde eu me sentava à janela com uma luneta e um caderno. Naquela semana comecei a ver olhos na orla da floresta, bem altos, e muito afastados um do outro.",
     "Cada tarde me sentaba a la ventana con un catalejo y un cuaderno. Aquella semana empecé a ver ojos en el linde del bosque, muy altos, y muy separados entre sí."),
    ("b01", "She called at sunset, as every day. Eleven pounds heavier than Monday. Nothing answered. Not yet.",
     "Eleven pounds heavier than Monday. She called at sunset, as she did every day, a sound like a heron with its throat cut. Nothing answered.",
     "Cinco quilos mais pesada do que na segunda-feira. Chamava ao pôr do sol, como todos os dias, um som de garça degolada. Nada respondia.",
     "Cinco kilos más pesada que el lunes. Llamaba al ponerse el sol, como cada día, con un sonido de garza degollada. Nada respondía."),
    ("b01", "Not a lizard. Something no man has named. The Crown will have a cavalry that needs no hay.",
     "A lizard. My dear Valadares. She is a species no one has ever described, the newest thing nature has made. In ten years her daughters will be the Crown's cavalry, and they will not eat hay.",
     "Um lagarto. Meu caro Valadares. Ela é uma espécie que ninguém jamais descreveu, a coisa mais nova que a natureza fez. Em dez anos as filhas dela serão a cavalaria da Coroa, e não comerão feno.",
     "Un lagarto. Mi querido Valadares. Es una especie que nadie ha descrito jamás, lo más nuevo que ha hecho la naturaleza. Dentro de diez años sus hijas serán la caballería de la Corona, y no comerán heno."),
    ("b01", "Did you see them hunt? Not one beast. A breed, with a breed's manners.",
     "Did you see them take the goats? They worked together like sheepdogs. That is a breed, Valadares, and a breed can be bred.",
     "Viu como pegaram as cabras? Trabalharam juntos como cães pastores. Isso é uma raça, Valadares, e uma raça pode ser criada.",
     "¿Ha visto cómo cogieron las cabras? Trabajaban juntos como perros pastores. Eso es una raza, Valadares, y una raza se puede criar."),
    ("b01", "Listen. Listen to that. She knows that voice.",
     "Listen to her. She has never made that sound before.",
     "Escute. Ela nunca fez esse som antes.",
     "Escuche. Nunca había hecho ese sonido."),
    ("b01", "So I kept it quiet, Majesty. One night, I said. The Crown would have its beasts tame or not at all.",
     "So I sent nothing to the fort, Majesty. One night, I told Valadares. I wanted the stallion alive.",
     "Então não mandei recado ao forte, Majestade. Só uma noite, eu disse a Valadares. Eu queria o garanhão vivo.",
     "Así que no mandé aviso al fuerte, Majestad. Solo una noche, le dije a Valadares. Quería vivo al semental."),
    ("b01", "They are not after your scent. They are going to her.",
     "They don't care for your jars, Doctor. They are making for the pen.",
     "Eles não ligam para os seus frascos, Doutor. Estão indo para o cercado.",
     "Sus frascos les dan igual, Doctor. Van derechos al corral."),
    ("b01", "He walked through my station as if it were reeds. He did not want us. He wanted her.",
     "He walked through my station as if it were reeds. My men emptied their muskets into him, and he did not so much as turn his head.",
     "Atravessou a minha estação como se fosse um juncal. Meus homens descarregaram os mosquetes nele, e ele nem virou a cabeça.",
     "Atravesó mi estación como si fuera un cañaveral. Mis hombres le vaciaron los mosquetes encima, y ni siquiera volvió la cabeza."),
    ("b01", "He did not want to eat her. He lay down beside her like a groom.",
     "He did not touch her. He lay down along the pen like a dog at a door, and would not move.",
     "Não tocou nela. Deitou-se ao longo do cercado como um cão diante de uma porta, e não saía dali.",
     "No la tocó. Se tumbó junto al corral como un perro ante una puerta, y no se movía."),
    ("b01", "Burn them, Doctor. Whatever she was, do not carry her children down this river.",
     "Burn them, Doctor. Whatever those things are, do not carry them down this river to people.",
     "Queime-os, Doutor. Seja o que for isso, não leve rio abaixo para onde há gente.",
     "Quémelos, Doctor. Sea lo que sea eso, no lo lleve río abajo, donde hay gente."),
    ("b01", "I had the research. I told the Academy I had saved my notes. That was the first lie.",
     "I had her eggs in a crate of straw. I told the Academy I had saved my notes, and let them think the crate was full of paper.",
     "Eu tinha os ovos dela numa caixa de palha. Disse à Academia que tinha salvado as minhas anotações, e deixei que pensassem que a caixa estava cheia de papel.",
     "Tenía sus huevos en una caja de paja. Le dije a la Academia que había salvado mis notas, y dejé que creyeran que la caja estaba llena de papeles."),
    ("b01", "The fire took her eggs before I reached them. I had nothing left but my word, and no one wanted it.",
     "The fire had the eggs before I reached the straw. I came down to the Barra with a notebook and nothing else, and the Academy did not believe a word of it.",
     "O fogo levou os ovos antes que eu chegasse à palha. Desci até a Barra com um caderno e mais nada, e a Academia não acreditou numa só palavra.",
     "El fuego se llevó los huevos antes de que yo llegara a la paja. Bajé a la Barra con un cuaderno y nada más, y la Academia no se creyó ni una palabra."),
    ("b01", "Pieter went to the forest's edge with the jars. I have his specimen book still. He does not.",
     "Pieter went to the forest's edge with the jars and did not come back. I have his specimen book. His mother wrote to me twice.",
     "Pieter foi à orla da floresta com os frascos e não voltou. Guardo o caderno de espécimes dele. A mãe dele me escreveu duas vezes.",
     "Pieter fue al linde del bosque con los frascos y no volvió. Conservo su cuaderno de especímenes. Su madre me escribió dos veces."),
    ("b01", "He wrote that his lure called them. It did not. She called them, and they came for her.",
     "His lure did nothing. The beasts came because the young one cried out every evening, the way a calf bawls and brings the herd.",
     "O engodo dele não fez nada. Os bichos vieram porque a pequena gritava todas as tardes, como o bezerro que berra e traz a manada.",
     "Su señuelo no sirvió de nada. Las bestias vinieron porque la cría chillaba cada tarde, como el ternero que berrea y atrae a la manada."),
    ("b01", "She was never stolen. She went home.",
     "No one stole her from him. Beasts went to a beast that called them, and took it back into the forest. There is nothing more in it than that, whatever he writes.",
     "Ninguém a roubou dele. Bichos foram atrás de um bicho que os chamava, e o levaram de volta para a floresta. Não há nada mais nisso, escreva ele o que escrever.",
     "Nadie se la robó. Unas bestias acudieron a otra que las llamaba y se la llevaron de vuelta al bosque. No hay nada más que eso, escriba él lo que escriba."),
    ("b01", "And what he carried out of the fire was not research. It was her children.",
     "And the crate he carried out of the fire held no papers. It held her eggs.",
     "E a caixa que ele tirou do fogo não tinha papel nenhum. Tinha os ovos dela.",
     "Y la caja que sacó del fuego no llevaba papeles. Llevaba sus huevos."),
]


def esc_i18n(s):
    return s.replace("\n", "\\n")


def swap_i18n(text, old, new, pt, es):
    lines = text.split("\n")
    for i, ln in enumerate(lines):
        if ln == "> " + esc_i18n(old):
            j = i + 1
            while j < len(lines) and lines[j][:3] in ("pt ", "es "):
                j += 1
            lines[i:j] = ["> " + esc_i18n(new), "pt " + pt, "es " + es]
            return "\n".join(lines), True
    return text, False


def main():
    bad = []
    files = {}
    for m, old, new, pt, es in CHANGES:
        for s in (new, pt, es):
            if '"' in s or "\\" in s or " - " in s:
                bad.append("quotes, backslashes or a dash in: " + s[:50])
        path = os.path.join(ROOT, SRC[m])
        if path not in files:
            files[path] = open(path, encoding="utf-8").read()
        src = files[path]
        q_old, q_new = '"' + old + '"', '"' + new + '"'
        n = src.count(q_old)
        if n:
            files[path] = src.replace(q_old, q_new)
        elif q_new not in src:
            bad.append("%s: neither the old nor the new text in %s: %s" % (m, SRC[m], old[:50]))
        ipath = os.path.join(ROOT, "tools/i18n/campaign/%s.txt" % I18N[m])
        if ipath not in files:
            files[ipath] = open(ipath, encoding="utf-8").read()
        t, ok = swap_i18n(files[ipath], old, new, pt, es)
        if ok:
            files[ipath] = t
        elif ("> " + esc_i18n(new)) not in files[ipath]:
            bad.append("%s: no i18n entry for: %s" % (m, old[:50]))
    if bad:
        print("\n".join(bad))
        sys.exit(1)
    for path, text in files.items():
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
    json.load(open(os.path.join(ROOT, SRC["p01"]), encoding="utf-8"))
    json.load(open(os.path.join(ROOT, SRC["hub"]), encoding="utf-8"))
    print("%d changes in place" % len(CHANGES))


if __name__ == "__main__":
    main()
