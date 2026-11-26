#!/usr/bin/env python3
"""THE WRITING PASS of 2026-11-26 (job writing-act3-hubs, docs/writing_pass_act3-hubs.md): the hubs' talks.

The owner: "check all dialogue, all writing in the campaign... for AI tells. Make it the best possible writing." This
script swaps the old English of the hub talks (campaign/campaign.json, campaign/hubs_grow.json) for the new, and writes
the new lines' Portuguese and Spanish into tools/i18n/campaign/campaign.txt and hubs_grow.txt (an old line's entry in
those two files is replaced in place; an old line whose translation lives in a mission's file is left there, unused).
Run it once; a second run changes nothing:  python3 tools/campaign/writing_pass_hubs.py && python3 tools/i18n_build.py
The hub lines that make_d10_mission.py appends (its HUB and RUGGIERI_GROW, and the d09 Ruggieri line it anchors on) are
NOT in this table: that generator would append the old ones again.
"""
import json, os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# (old English, new English, Portuguese, Spanish)
KING = [
    ("Sit by me. The map on the table is the world as it was when I was young.",
     "Sit by me. Move the candle, so you can see the map. That is the world as it was when I was young.",
     "Sente-se aqui comigo. Afaste a vela, para ver o mapa. É o mundo como era quando eu era jovem.",
     "Siéntate a mi lado. Aparta la vela, que veas el mapa. Es el mundo tal como era cuando yo era joven."),
    ("Everything I am going to tell you began on one plantation in Virginia.",
     "It begins in Virginia, on a tobacco plantation, in the summer of sixty-seven.",
     "Começa na Virgínia, numa plantação de tabaco, no verão de sessenta e sete.",
     "Empieza en Virginia, en una plantación de tabaco, el verano del sesenta y siete."),
    ("Fairleigh ended it in a single morning, and we called it over.",
     "Fairleigh finished it in one morning, with canister. We drank to him in this room and called it over.",
     "Fairleigh acabou com aquilo numa manhã, a metralha. Brindamos a ele nesta sala e demos o caso por encerrado.",
     "Fairleigh acabó con aquello en una mañana, a metralla. Brindamos por él en esta sala y lo dimos por terminado."),
    ("Look at the map again. The fire did not stay in Virginia.",
     "Now look at the map again, and put your finger on Nuremberg.",
     "Agora olhe o mapa outra vez e ponha o dedo em Nuremberg.",
     "Ahora mira otra vez el mapa y pon el dedo en Núremberg."),
    ("The clockmaker lost his city in a single night. He thought his machine could think.",
     "Hollweg built a clock that would not stop, and in one Advent night it took Nuremberg from him. He believed it could think.",
     "Hollweg construiu um relógio que não parava, e numa noite de Advento o relógio lhe tomou Nuremberg. Ele acreditava que a máquina pensava.",
     "Hollweg construyó un reloj que no se paraba, y en una noche de Adviento le quitó Núremberg. Creía que la máquina pensaba."),
    ("He sits in the east wing now and writes to me every week. I read every letter.",
     "He has rooms in the east wing now. He writes to me every week, long letters in a small hand, and I read them all.",
     "Agora tem aposentos na ala leste. Escreve-me todas as semanas, cartas longas em letra miúda, e eu leio todas.",
     "Ahora tiene habitaciones en el ala este. Me escribe cada semana, cartas largas de letra menuda, y las leo todas."),
    ("The naturalist lost his station in a single night, and thinks it was stolen from him.",
     "Lindqvist's station on the Rio Negro burned on Saint John's Eve. To hear him tell it, he was robbed.",
     "A estação de Lindqvist no Rio Negro ardeu na véspera de São João. Pelo que ele conta, foi roubado.",
     "La estación de Lindqvist en el Río Negro ardió la víspera de San Juan. Según lo cuenta él, le robaron."),
    ("He is held in the palace now. I keep him for what he knows of those creatures, and I hear him out.",
     "He is held in the palace now. No man living knows those animals better, so I listen to him, and I have what he says checked.",
     "Agora está detido no palácio. Ninguém vivo conhece melhor aqueles animais, por isso eu o escuto, e mando verificar o que diz.",
     "Ahora está retenido en palacio. Nadie vivo conoce mejor a esos animales, así que le escucho, y hago comprobar lo que dice."),
    ("Lyon went home without a volley. The Cardinal will tell you it was luck. Do not believe him.",
     "Lyon went home without a volley fired. Tomasz will tell you it was luck. It was Tomasz.",
     "Lyon voltou para casa sem uma descarga. Tomasz vai lhe dizer que foi sorte. Foi Tomasz.",
     "Lyon se volvió a casa sin una descarga. Tomasz te dirá que fue suerte. Fue Tomasz."),
    ("The printer named Paris. We should have listened sooner.",
     "The printer gave us one word, Paris. We were slow to hear it.",
     "O impressor nos deu uma palavra, Paris. Demoramos a ouvi-la.",
     "El impresor nos dio una palabra, París. Tardamos en oírla."),
    ("I sent Varenne to sea on Fairleigh's word and the Cardinal's prayer.",
     "I sent Varenne to sea. Tomasz asked for his life on his knees, and Fairleigh told me an exile does less harm than a martyr.",
     "Mandei Varenne para o mar. Tomasz pediu a vida dele de joelhos, e Fairleigh me disse que um exilado faz menos mal do que um mártir.",
     "Mandé a Varenne al mar. Tomasz pidió su vida de rodillas, y Fairleigh me dijo que un desterrado hace menos daño que un mártir."),
    ("Remember that mercy is a weapon too. It cuts the one who holds it, sometimes.",
     "We shall see what he does with the years I gave him.",
     "Veremos o que ele faz com os anos que lhe dei.",
     "Veremos qué hace con los años que le di."),
    ("Varenne died on the Grève by the King's law, and I signed it.",
     "Varenne died on the Grève. I signed the sentence myself, and Tomasz sat with him the last night.",
     "Varenne morreu na Grève. Eu mesmo assinei a sentença, e Tomasz ficou com ele na última noite.",
     "Varenne murió en la Grève. Firmé yo mismo la sentencia, y Tomasz pasó con él la última noche."),
    ("A martyr is harder to fight than a man. I learnt that too late.",
     "Within a month they were singing about him in every town in France.",
     "Em um mês já cantavam sobre ele em todas as cidades da França.",
     "Al cabo de un mes cantaban sobre él en todos los pueblos de Francia."),
    ("Ferrer's report came before the snow. Machines that take out their own stop-works.",
     "Father Ferrer's report reached me before the first snow. Machines that pull out their own stop-works.",
     "O relatório do Padre Ferrer chegou antes da primeira neve. Máquinas que arrancam as próprias travas.",
     "El informe del Padre Ferrer me llegó antes de la primera nieve. Máquinas que se arrancan sus propios topes."),
    ("He had them melted. Hollweg has not forgiven him. I think Ferrer was right.",
     "He had them melted in Hollweg's own furnace. Hollweg has not forgiven him. I think Ferrer was right.",
     "Mandou derretê-las na própria fornalha de Hollweg. Hollweg não o perdoou. Eu acho que Ferrer tinha razão.",
     "Las hizo fundir en el propio horno de Hollweg. Hollweg no se lo ha perdonado. Creo que Ferrer tenía razón."),
    ("Rome burned for one night and stood in the morning. I walked the bridges at dawn with Tomasz.",
     "Rome burned for one night. In the morning I walked the three bridges with Tomasz, stepping over what was left of the machines.",
     "Roma ardeu uma noite. De manhã atravessei as três pontes com Tomasz, passando por cima do que restava das máquinas.",
     "Roma ardió una noche. Por la mañana recorrí los tres puentes con Tomasz, pasando por encima de lo que quedaba de las máquinas."),
    ("Hollweg and Lindqvist were gone before the bells. I should have held them. I let them go.",
     "Hollweg and Lindqvist were gone before Lauds. I could have had the gates shut on them. I did not give the order.",
     "Hollweg e Lindqvist tinham partido antes das Laudes. Eu podia ter mandado fechar as portas. Não dei a ordem.",
     "Hollweg y Lindqvist se habían ido antes de Laudes. Pude haber mandado cerrarles las puertas. No di la orden."),
    ("Tomasz wrote from Minas: the gold went down to the coast, and he stayed behind with the miners.",
     "Tomasz wrote from Minas. The gold went down to the coast, and he stayed behind with the miners.",
     "Tomasz escreveu de Minas. O ouro desceu para o litoral, e ele ficou para trás com os mineiros.",
     "Tomasz escribió desde Minas. El oro bajó a la costa, y él se quedó atrás con los mineros."),
    ("He sent me the names of the dead of both sides, and asked me to pray for all of them. I did.",
     "He sent me the names of the dead, ours and theirs, and asked me to pray for every one. I have.",
     "Mandou-me os nomes dos mortos, os nossos e os deles, e pediu-me que rezasse por cada um. Rezei.",
     "Me mandó los nombres de los muertos, los nuestros y los suyos, y me pidió que rezara por cada uno. Lo he hecho."),
    ("The lieutenant who led them went south. Remember the city of gears; we will come back to it.",
     "Their lieutenant got away south, to the city of gears. You will hear of him again.",
     "O tenente deles escapou para o sul, para a cidade das engrenagens. Você ainda vai ouvir falar dele.",
     "Su teniente escapó al sur, a la ciudad de los engranajes. Volverás a oír hablar de él."),
    ("Tomasz wrote from the river fort. He brought them out of São Rafael, and asked me for nothing but a priest for the fort.",
     "Tomasz wrote from the river fort. He had brought them out of São Rafael, and all he asked of me was a second priest.",
     "Tomasz escreveu do forte do rio. Tinha tirado o povo de São Rafael, e só me pediu um segundo padre.",
     "Tomasz escribió desde el fuerte del río. Había sacado a la gente de São Rafael, y solo me pidió un segundo cura."),
    ("He left the fields standing. My soldiers paid for that bread for years. I would have done the same.",
     "He left the fields standing for them to come back to. My soldiers paid for that bread for years. I would have done the same.",
     "Deixou os campos de pé para eles voltarem. Os meus soldados pagaram aquele pão durante anos. Eu teria feito o mesmo.",
     "Dejó los campos en pie para que volvieran. Mis soldados pagaron ese pan durante años. Yo habría hecho lo mismo."),
    ("He burned the fields behind them. He confesses it every year. It was hard, and it was his to choose.",
     "He burned the fields behind them, so the swarm would find nothing. He confesses it every Lent. I have told him there is nothing to confess.",
     "Queimou os campos atrás deles, para o enxame não achar nada. Confessa isso todas as Quaresmas. Eu já lhe disse que não há nada a confessar.",
     "Quemó los campos tras ellos, para que el enjambre no encontrara nada. Lo confiesa cada Cuaresma. Ya le he dicho que no hay nada que confesar."),
    ("You chose the swarm first, as Ruggieri did. Valadares had his guns before the floods.",
     "You chose the swarm first, and so did Ruggieri. Valadares had his guns before the floods.",
     "Você escolheu o enxame primeiro, e Ruggieri também. Valadares teve os seus canhões antes das cheias.",
     "Elegiste primero el enjambre, y Ruggieri también. Valadares tuvo sus cañones antes de las crecidas."),
    ("And the city of gears had a year it should not have had.",
     "The city of gears had a quiet year. It used it.",
     "A cidade das engrenagens teve um ano tranquilo. Aproveitou-o.",
     "La ciudad de los engranajes tuvo un año tranquilo. Lo aprovechó."),
    ("You chose the city first, as Ruggieri did. Father Ferrer had his siege lines by the spring.",
     "You chose the city first, and so did Ruggieri. Father Ferrer had his siege lines dug by spring.",
     "Você escolheu a cidade primeiro, e Ruggieri também. O Padre Ferrer tinha as linhas de cerco cavadas na primavera.",
     "Elegiste primero la ciudad, y Ruggieri también. El Padre Ferrer tenía sus líneas de asedio cavadas en primavera."),
    ("And the swarm came down the rivers the whole year we were away.",
     "All that year the swarm came down the rivers, and only Valadares stood in its way.",
     "Durante todo aquele ano o enxame desceu os rios, e só Valadares lhe barrou o caminho.",
     "Todo aquel año el enjambre bajó por los ríos, y solo Valadares le cerró el paso."),
    ("Ferrer blew the great spring from under its own hill. The city limps now. It does not stop.",
     "Ferrer's miners went in under the hill and blew the great spring's tower. The city still runs, slower. They say you can hear it miss a beat.",
     "Os mineiros de Ferrer entraram por baixo do morro e explodiram a torre da grande mola. A cidade ainda anda, mais devagar. Dizem que se ouve quando ela falha uma batida.",
     "Los zapadores de Ferrer entraron bajo la colina y volaron la torre del gran muelle. La ciudad aún marcha, más despacio. Dicen que se la oye saltarse un tiempo."),
    ("Ferrer held the road a whole year before that wall. The city stood whole behind it, and grew.",
     "Ferrer held the road a whole year before that wall. Behind it the city went on building.",
     "Ferrer segurou a estrada um ano inteiro diante daquela muralha. Atrás dela, a cidade continuou a construir.",
     "Ferrer sostuvo el camino un año entero ante aquella muralla. Detrás, la ciudad siguió construyendo."),
]

TOMASZ = [
    ("I was a seminarian then, waiting for my ship to Rome. I read Augustine under an oak.",
     "I was a seminarian then, waiting for my ship to Rome. I read the Confessions under an oak and thought myself very holy.",
     "Eu era seminarista na época, esperando meu navio para Roma. Lia as Confissões debaixo de um carvalho e me achava muito santo.",
     "Entonces yo era seminarista y esperaba mi barco a Roma. Leía las Confesiones bajo un roble y me creía muy santo."),
    ("The men in the fields talked of an Assembly. I did not understand what they wanted.",
     "The men in the fields talked about an Assembly. I did not understand what they wanted until the barns were burning.",
     "Os homens nos campos falavam de uma Assembleia. Só entendi o que queriam quando os celeiros arderam.",
     "Los hombres de los campos hablaban de una Asamblea. No entendí lo que querían hasta que ardieron los secaderos."),
    ("I still smell the smoke when I close my eyes.",
     "Tobacco burns sweet. I cannot bear a pipe in a closed room to this day, and His Majesty knows it and lights his anyway.",
     "O tabaco arde doce. Até hoje não suporto um cachimbo numa sala fechada, e Sua Majestade sabe disso e acende o dele assim mesmo.",
     "El tabaco arde dulce. Todavía hoy no soporto una pipa en un cuarto cerrado, y Su Majestad lo sabe y enciende la suya igual."),
    ("Two letters came for the Governor that week: one from an explorer in the Amazon, one from a clockmaker. He gave them to me to read.",
     "Two letters came for the Governor that week, one from an explorer on the Amazon and one from a clockmaker. He handed them to me. I was the only one in the house with time to read.",
     "Chegaram duas cartas para o Governador naquela semana, uma de um explorador no Amazonas e outra de um relojoeiro. Ele as passou para mim. Eu era o único na casa com tempo para ler.",
     "Llegaron dos cartas para el Gobernador aquella semana, una de un explorador en el Amazonas y otra de un relojero. Me las pasó a mí. Era el único de la casa con tiempo para leer."),
    ("I asked for his life and the Marshal gave it. I still do not know if I asked well.",
     "I knelt to the Marshal and asked for his life, and he wrote to the King for me. I have never been sure it was the right thing to ask.",
     "Ajoelhei-me diante do Marechal e pedi a vida dele, e ele escreveu ao Rei por mim. Nunca tive certeza de que era a coisa certa a pedir.",
     "Me arrodillé ante el Mariscal y le pedí su vida, y él escribió al Rey por mí. Nunca he estado seguro de que fuera lo correcto pedir."),
    ("In Minas I learnt that a sermon is the easy part. Staying afterwards is the work.",
     "After Vila Rica I stayed in the hills until the rains. I baptised eleven children there, and buried more men than that.",
     "Depois de Vila Rica fiquei nos morros até as chuvas. Batizei onze crianças, e enterrei mais homens do que isso.",
     "Después de Vila Rica me quedé en los cerros hasta las lluvias. Bauticé a once niños, y enterré a más hombres que eso."),
    ("On the Tapajós I learnt that the swarm does not hate anyone. It eats. That is worse.",
     "On the Tapajós the swarm went for the granary before the church. It eats. It does not know what a church is.",
     "No Tapajós o enxame foi ao celeiro antes da igreja. Ele come. Não sabe o que é uma igreja.",
     "En el Tapajós el enjambre fue al granero antes que a la iglesia. Come. No sabe lo que es una iglesia."),
    ("At the São Francisco a general asked me what to do, and I told him I did not know. He chose anyway. That is a general.",
     "At the São Francisco Ruggieri asked me which way to march. I told him I did not know, and heard his confession, and in the morning he chose.",
     "No São Francisco Ruggieri me perguntou para onde marchar. Eu disse que não sabia, ouvi a confissão dele, e de manhã ele escolheu.",
     "En el São Francisco Ruggieri me preguntó hacia dónde marchar. Le dije que no lo sabía, le oí en confesión, y por la mañana eligió."),
]

FAIRLEIGH = [
    ("Study the war table. Then we wait for the night.",
     "Look over the war table. They will come after dark.",
     "Examine a mesa de guerra. Eles virão depois de escurecer.",
     "Repasa la mesa de guerra. Vendrán cuando oscurezca."),
    ("It is done. I take no pleasure in it.",
     "It is done. I have written to the parishes of the dead, theirs as well as ours.",
     "Está feito. Escrevi às paróquias dos mortos, às deles e às nossas.",
     "Está hecho. He escrito a las parroquias de los muertos, las suyas y las nuestras."),
    ("Ruggieri has his pipe, and I have the King's leaf. Rome will hear of this.",
     "Ruggieri is smoking Your Majesty's leaf on my porch as I write. I trust Your Majesty will forgive him.",
     "Ruggieri está fumando o fumo de Vossa Majestade na minha varanda enquanto escrevo. Confio que Vossa Majestade o perdoará.",
     "Ruggieri fuma la hoja de Vuestra Majestad en mi porche mientras escribo. Confío en que Vuestra Majestad le perdonará."),
]

HOLLWEG_EXILE = [
    ("Ferrer came to Fürth with a notebook and left with a verdict.",
     "Ferrer came to Fürth with a lay brother and a notebook, and wrote down everything he saw.",
     "Ferrer veio a Fürth com um irmão leigo e um caderno, e anotou tudo o que viu.",
     "Ferrer vino a Fürth con un hermano lego y un cuaderno, y lo apuntó todo."),
    ("Then they woke in the smoke and walked out of the hall without me. I have had a long time to think about that night.",
     "That night they woke in the smoke and walked out of the hall. I was not with them. I was still arguing.",
     "Naquela noite elas acordaram no fumo e saíram do salão. Eu não estava com elas. Ainda estava discutindo.",
     "Aquella noche despertaron en el humo y salieron de la sala. Yo no iba con ellas. Seguía discutiendo."),
]

DISPATCH = [
    ("Concórdia, the siege. The great spring's tower blown from the old mine. The city crippled, not taken.",
     "Concórdia, the siege. The great spring's tower blown from the old mine. The city crippled. Not taken.",
     "Concórdia, o cerco. A torre da grande mola explodida a partir da velha mina. A cidade aleijada. Não tomada.",
     "Concórdia, el asedio. La torre del gran muelle volada desde la vieja mina. La ciudad tullida. No tomada."),
]

NATURALIST = [
    ("The Academy wants specimens. I want a breed. The Crown will want a cavalry.",
     "The Academy wants her stuffed for the cabinet. I mean to breed her, and sell the line to the Crown.",
     "A Academia quer que ela vá empalhada para o gabinete. Eu pretendo criá-la, e vender a linhagem à Coroa.",
     "La Academia la quiere disecada para el gabinete. Yo pienso criarla, y vender la línea a la Corona."),
    ("A warehouse at the Barra, crates and charts, and the people who came down the river with me.",
     "We sleep in the Academy's warehouse at the Barra, among the crates, those of us who came down the river.",
     "Dormimos no armazém da Academia na Barra, entre os caixotes, os que descemos o rio.",
     "Dormimos en el almacén de la Academia en la Barra, entre las cajas, los que bajamos por el río."),
    ("He stole her. I will have her line again, whatever the Academy says.",
     "The big male broke her pen and she went into the forest with him. I will have her line again, whatever the Academy says.",
     "O macho grande arrombou o cercado e ela foi para a floresta com ele. Hei de ter a linhagem dela outra vez, diga a Academia o que disser.",
     "El macho grande rompió su cercado y ella se fue al bosque con él. Volveré a tener su línea, diga lo que diga la Academia."),
    ("They grow. They know my whistle already. This is how it begins, properly this time.",
     "They grow. They come to the bars when I whistle. I have started a stud book.",
     "Crescem. Vêm às grades quando eu assobio. Comecei um livro de registo.",
     "Crecen. Vienen a los barrotes cuando silbo. He empezado un libro genealógico."),
    ("Rome calls it a monster. I call it a breed, the first of its line. Every breed needs patience and a good fence.",
     "Rome has a word for it. I have a page in the stud book, with its sire and its dam and the hour it broke the shell.",
     "Roma tem uma palavra para ele. Eu tenho uma página no livro de registo, com o pai, a mãe e a hora em que rompeu a casca.",
     "Roma tiene una palabra para él. Yo tengo una página en el libro genealógico, con su padre, su madre y la hora en que rompió el cascarón."),
    ("Valadares said it was made, not born. A Crown man's superstition. Everything that lives was born.",
     "Valadares says they were made, not born, in some old workshop, like a clock. A soldier's superstition. I have held the eggs.",
     "Valadares diz que foram feitos, não nascidos, numa oficina antiga, como um relógio. Superstição de soldado. Eu segurei os ovos.",
     "Valadares dice que fueron hechos, no nacidos, en algún taller antiguo, como un reloj. Superstición de soldado. Yo he tenido los huevos en la mano."),
]

NATURALIST_THINGS = [
    ("A young creature in spirits, coiled like a question. The label says only: Plateau, specimen four.",
     "A young creature in spirits, coiled tight against the glass. The label says only: Plateau, specimen four.",
     "Uma criatura jovem em álcool, enrolada contra o vidro. O rótulo diz apenas: Planalto, espécime quatro.",
     "Una criatura joven en alcohol, enroscada contra el cristal. La etiqueta dice solo: Meseta, espécimen cuatro."),
]

VALADARES = [
    ("The floods are going down. Their ground does not.",
     "The water is going down. Their swamp is staying.",
     "A água está baixando. O pântano deles fica.",
     "El agua está bajando. Su ciénaga se queda."),
    ("I burned the book. I would burn it again. I do not sleep well.",
     "I burned the book, as Rome ordered. I can still whistle the first call. I do not.",
     "Queimei o livro, como Roma mandou. Ainda sei assobiar o primeiro chamado. Não assobio.",
     "Quemé el libro, como mandó Roma. Todavía sé silbar la primera llamada. No la silbo."),
    ("Every forward Mother roots a little nearer each season. A mile a week, in the floods.",
     "The forward Mothers root a little nearer every week. In the floods, a mile a week.",
     "As Mães da frente enraízam um pouco mais perto a cada semana. Nas cheias, uma milha por semana.",
     "Las Madres de vanguardia arraigan un poco más cerca cada semana. En las crecidas, una milla por semana."),
]

CLOCKMAKER = [
    ("Mind your sleeve near the table. The map turns, and every ring of it is a road, a river or a sea.",
     "Mind your sleeve near the table. The map turns, and every ring of it is a river or a road.",
     "Cuidado com a manga perto da mesa. O mapa gira, e cada anel dele é um rio ou uma estrada.",
     "Cuidado con la manga cerca de la mesa. El mapa gira, y cada anillo es un río o un camino."),
    ("The Crown pays the Guild for patience. My machines have more of it than any soldier.",
     "The Crown pays the Guild by the year. My soldiers want no bread and no sleep. A good bargain for the Crown.",
     "A Coroa paga à Guilda por ano. Os meus soldados não pedem pão nem sono. Um bom negócio para a Coroa.",
     "La Corona paga al Gremio por años. Mis soldados no piden pan ni sueño. Buen negocio para la Corona."),
    ("A barn, a forge and the Crown's goodwill. It is more than we had in December.",
     "A barn and a forge, and the Crown's goodwill for now. More than we had in December.",
     "Um celeiro e uma forja, e a boa vontade da Coroa por enquanto. Mais do que tínhamos em dezembro.",
     "Un granero y una fragua, y la buena voluntad de la Corona por ahora. Más de lo que teníamos en diciembre."),
    ("The Father has gone to Rome with his report. Let him.",
     "The Father has gone to Rome with his notebook.",
     "O Padre foi para Roma com o caderno dele.",
     "El Padre se ha ido a Roma con su cuaderno."),
    ("He was afraid of them. Fear is not an argument.",
     "He was afraid of them. I told him so, and he said yes, he was, and wrote that down too.",
     "Ele tinha medo delas. Eu lhe disse isso, e ele respondeu que sim, tinha, e anotou isso também.",
     "Les tenía miedo. Se lo dije, y él contestó que sí, que lo tenía, y lo apuntó también."),
    ("No machine may govern itself. Very well: mine will not be governed by Rome either.",
     "No machine may govern itself, says the council. I did not build mine to be governed by cardinals.",
     "Nenhuma máquina pode governar-se a si mesma, diz o concílio. Não construí as minhas para serem governadas por cardeais.",
     "Ninguna máquina puede gobernarse a sí misma, dice el concilio. No construí las mías para que las gobiernen cardenales."),
    ("The council meets at noon, when the tower strikes. Every master has a voice, and every voice a wheel.",
     "The council meets at noon, when the tower strikes. Each master has a vote, and a wheel on the great table to cast it with.",
     "O conselho se reúne ao meio-dia, quando a torre bate. Cada mestre tem um voto, e uma roda na grande mesa para lançá-lo.",
     "El consejo se reúne a mediodía, cuando da la torre. Cada maestro tiene un voto, y una rueda en la gran mesa para emitirlo."),
    ("I pulled the brake. Every machine I ever made stood still at once, the honest ones too. It was the first thing I ever stopped.",
     "I pulled the brake. Every machine I had made stood still, the honest ones with the rest. The tower went quiet. I had never heard it quiet.",
     "Puxei o travão. Todas as máquinas que eu tinha feito pararam, as honestas com as outras. A torre ficou em silêncio. Eu nunca a tinha ouvido em silêncio.",
     "Tiré del freno. Todas las máquinas que había hecho se pararon, las honradas con las demás. La torre se quedó callada. Nunca la había oído callada."),
    ("They brought the Crown's guns up the plateau. I stood on the wall by the spring and listened. The city did not tick any faster. It was not afraid.",
     "They brought the Crown's guns up the plateau. I stood on the wall by the spring and listened. The city's tick did not change. Not by a beat.",
     "Trouxeram os canhões da Coroa para cima do planalto. Fiquei na muralha junto à mola, escutando. O tique da cidade não mudou. Nem por uma batida.",
     "Subieron los cañones de la Corona a la meseta. Me quedé en la muralla junto al muelle, escuchando. El tic de la ciudad no cambió. Ni un tiempo."),
]

GROW = [
    ("I am old now. I still hear the canister.",
     "Ruggieri's mortars in that street. I am still deaf in the left ear.",
     "Os morteiros de Ruggieri naquela rua. Ainda sou surdo do ouvido esquerdo.",
     "Los morteros de Ruggieri en aquella calle. Todavía estoy sordo del oído izquierdo."),
    ("Varenne went to the scaffold. The Assembly made a saint of him by morning.",
     "Varenne went to the scaffold. Within the week the Assembly was selling his picture on every quay in Paris.",
     "Varenne subiu ao cadafalso. Em uma semana a Assembleia vendia o retrato dele em todos os cais de Paris.",
     "Varenne subió al cadalso. En una semana la Asamblea vendía su retrato en todos los muelles de París."),
    ("Rome burned one night, and held. I was not there. The young King was.",
     "Rome burned one night, and held. I was not there. Your Majesty was, and very young.",
     "Roma ardeu uma noite, e aguentou. Eu não estava lá. Vossa Majestade estava, e muito jovem.",
     "Roma ardió una noche, y resistió. Yo no estaba. Vuestra Majestad sí, y muy joven."),
    ("The guns, Highness. In Virginia they were two. In Rome there are more.",
     "The guns, Highness. In Virginia I had two, and one of them had a cracked trail.",
     "Os canhões, Alteza. Na Virgínia eu tinha dois, e um deles com a flecha rachada.",
     "Los cañones, Alteza. En Virginia tenía dos, y uno con la contera rajada."),
    ("I kept the drawings, Meister. Every part of it. We can do better with honest work.",
     "I kept the drawings, Meister. Every sheet. We can build an honest one from them.",
     "Guardei os desenhos, Meister. Todas as folhas. Podemos construir uma honesta a partir deles.",
     "Guardé los planos, Meister. Todas las hojas. Podemos construir una honrada con ellos."),
    ("I came to see the guild's work. I stay because someone must.",
     "I came to look at your workshops. The Holy Office has asked me to go on looking.",
     "Vim ver as vossas oficinas. O Santo Ofício pediu-me que continue a ver.",
     "Vine a ver vuestros talleres. El Santo Oficio me ha pedido que siga mirando."),
]

TABLE = KING + TOMASZ + FAIRLEIGH + HOLLWEG_EXILE + DISPATCH + NATURALIST + NATURALIST_THINGS + VALADARES + CLOCKMAKER
TABLE_GROW = GROW


def swap(obj, table):
    m = {o: n for (o, n, _p, _e) in table}
    n_done = [0]

    def walk(x):
        if isinstance(x, dict):
            return {k: walk(v) for k, v in x.items()}
        if isinstance(x, list):
            return [walk(v) for v in x]
        if isinstance(x, str) and x in m:
            n_done[0] += 1
            return m[x]
        return x
    return walk(obj), n_done[0]


def fix_txt(path, table, header):
    """Old entries in this file are replaced in place; new lines not yet in it are added at the end."""
    lines = open(path, encoding="utf-8").read().split("\n")
    out, i, have = [], 0, set()
    old = {o: (n, p, e) for (o, n, p, e) in table}
    while i < len(lines):
        l = lines[i]
        if l.startswith("> ") and l[2:] in old:
            n, p, e = old[l[2:]]
            out += ["> " + n, "pt " + p, "es " + e]
            have.add(n)
            i += 1
            while i < len(lines) and lines[i][:3] in ("pt ", "es "):
                i += 1
            continue
        if l.startswith("> "):
            have.add(l[2:])
        out.append(l)
        i += 1
    add = [(n, p, e) for (_o, n, p, e) in table if n not in have]
    if add:
        while out and out[-1] == "":
            out.pop()
        out += ["", header]
        for (n, p, e) in add:
            out += ["", "> " + n, "pt " + p, "es " + e]
        out.append("")
    open(path, "w", encoding="utf-8").write("\n".join(out))


def main():
    p = os.path.join(ROOT, "campaign", "campaign.json")
    c, n1 = swap(json.load(open(p, encoding="utf-8")), TABLE)
    with open(p, "w", encoding="utf-8") as f:
        json.dump(c, f, indent="\t", ensure_ascii=False)
        f.write("\n")
    p2 = os.path.join(ROOT, "campaign", "hubs_grow.json")
    raw = open(p2, encoding="utf-8").read()
    n2 = 0
    for (o, n, _p, _e) in TABLE_GROW:      # (a text swap: hubs_grow.json keeps its hand layout)
        q = json.dumps(o, ensure_ascii=False)
        if q in raw:
            raw = raw.replace(q, json.dumps(n, ensure_ascii=False))
            n2 += 1
    open(p2, "w", encoding="utf-8").write(raw)
    hdr = "# THE WRITING PASS of 2026-11-26 (tools/campaign/writing_pass_hubs.py, docs/writing_pass_act3-hubs.md)"
    fix_txt(os.path.join(ROOT, "tools", "i18n", "campaign", "campaign.txt"), TABLE, hdr)
    fix_txt(os.path.join(ROOT, "tools", "i18n", "campaign", "hubs_grow.txt"), TABLE_GROW, hdr)
    print("campaign.json: %d strings swapped; hubs_grow.json: %d" % (n1, n2))


if __name__ == "__main__":
    main()
