# Mission 1 voice lines (p01_leaf, "The Leaf and the Fire")

Recorded lines drop in as files, one per line: `campaign/voice/p01/<line id>.ogg` (`.wav` or `.mp3` work too). The game plays
a line's file when it is there and stays silent when not (scripts/campaign/campaign_voice.gd); the line waits for its
recording to finish before the next one. Godot must import the files once (open the project in the editor, or
`godot --headless --import`). Voices: the KING (the owner records him in ElevenLabs: an old man, warm, unhurried, a
pipe in his hand), TOMASZ (young, Polish, quiet; the same man years later as a priest), LORD FAIRLEIGH (English,
stern, never raises his voice), CAPTAIN RUGGIERI (Italian, a gunner), VARENNE (French orator, shouting).

Lines marked *to crown* / *to rebels* are heard only by that side (tips, versus lines). `tip_canister` has a phone
version of its words (the same recording can serve both).

| # | line id | speaker | where | text |
| --- | --- | --- | --- | --- |
| 1 | `k_open1` | THE KING | opening | Sit down. You asked me how it began, and I will tell you, but an old man lights his pipe first. There. Virginia leaf. That is where it began. |
| 2 | `k_open2` | THE KING | opening | When I was a boy you could sail from Rome to the last islands of the Pacific and hear the same Mass in every port, and pay for your supper with the same coin. My father thought it would always be so. So did I. |
| 3 | `k_open3` | THE KING | opening | That summer a Polish seminarian was waiting in Virginia for a ship to Rome. Tomasz Wierzbicki. You know him as the Cardinal. He was very young, and he earned his keep helping the Governor's chaplain. |
| 4 | `t_open3` | TOMASZ | opening | I remember the barns most. You could smell the curing leaf a mile off. In the evenings I read Augustine under the big oak until the light went, and the field hands sang on their way in. |
| 5 | `k_open4` | THE KING | opening | Then the Free Assembly came out of the fields, Varenne's men, with torches. They wanted no King and no Church, and they started by burning other men's harvests. |
| 6 | `f_open5` | LORD FAIRLEIGH | opening | Captain Ruggieri, run out the guns. Mr. Wierzbicki, take the women and children into the chapel and keep them there. |
| 7 | `t_open5` | TOMASZ | opening | He said it as calmly as grace before dinner. Then he sent for his sword. |
| 8 | `p1_fair` | LORD FAIRLEIGH | part | Musketeers to the barns. Captain, your guns on the lawn. We hold until the sun comes up. |
| 9 | `p1_rugg` | CAPTAIN RUGGIERI | part | The guns are run out, my lord. Let them come into the light. |
| 10 | `p1_tip` | CAPTAIN RUGGIERI | part *to crown* | Train more men at the Barracks, my lord. Kill the torch-bearers first: a barn they reach will burn. |
| 11 | `r_intro` | VARENNE | part *to rebels* | Tonight we burn their leaf and their manor. Out of the fields, brothers! |
| 12 | `v_1` | VARENNE | part | Citizens! You grew that leaf with your sweat, and a king you will never see smokes it! Burn it! |
| 13 | `r_1` | CAPTAIN RUGGIERI | part | Give fire! |
| 14 | `t_1` | TOMASZ | part | Some of them were boys. I knelt by the first one who fell and said the act of contrition into his ear, in case he could still hear. I was not a priest yet. I could give him nothing more. |
| 15 | `v_2` | VARENNE | part | They tell you to wait for heaven! We will not wait! |
| 16 | `f_1` | LORD FAIRLEIGH | part | That will be Varenne. He makes a fine speech, for a man standing so far back. |
| 17 | `r_2` | CAPTAIN RUGGIERI | part | Steady, gentlemen. Let them close. Then give it to them. |
| 18 | `v_3` | VARENNE | part | Every barn that burns is a chain broken! |
| 19 | `r_leaf` | CAPTAIN RUGGIERI | part | Madonna santa, a whole year's leaf. My lord, when this is done I want a pipe of whatever they leave us. |
| 20 | `f_leaf` | LORD FAIRLEIGH | part | You shall have one of mine. Now load. |
| 21 | `v_4` | VARENNE | part | Now, brothers! All of you! Let it burn! |
| 22 | `t_2` | TOMASZ | part | They fired the curing sheds with the families still asleep in the cabins beside them. I carried a little girl out of the smoke. She asked me if it was morning yet. |
| 23 | `r_3` | CAPTAIN RUGGIERI | part | Fewer of them now. Keep firing. |
| 24 | `t_lauds` | TOMASZ | part | Then the sky went grey over the woods, and the chapel bell rang for Lauds. |
| 25 | `f_barn` | LORD FAIRLEIGH | part | A barn is alight. Drive them off it! |
| 26 | `t_barn` | TOMASZ | part | The first barn fell in. The leaf went up like incense, and the smell was everywhere. |
| 27 | `f_manor` | LORD FAIRLEIGH | part | They are at the house. To the manor! |
| 28 | `f_ash` | LORD FAIRLEIGH | part | The house is burning. Get the women out of the chapel. We have lost the county. |
| 29 | `f_dawn` | LORD FAIRLEIGH | part | Dawn. They are falling back to the fort. We follow. |
| 30 | `r_dawn` | CAPTAIN RUGGIERI | part | Limber the guns! Down the road! |
| 31 | `p2_tip` | CAPTAIN RUGGIERI | part *to crown* | Two camps lie on the road to the fort. A cannon must be limbered to march and set up again to fire. |
| 32 | `r_dawn_v` | VARENNE | part *to rebels* | Back to the fort! Let them come to our walls. |
| 33 | `t_smoke` | TOMASZ | part | My lord, smoke to the north. That is Hollins Farm. The Hollins family stood by us, and they cannot get out. |
| 34 | `f_choice` | LORD FAIRLEIGH | part | Every hour we spend there, they dig in at the fort. |
| 35 | `f_save` | LORD FAIRLEIGH | part | We do not leave the King's people to burn. North. |
| 36 | `f_leave` | LORD FAIRLEIGH | part | The fort first. God keep them. |
| 37 | `t_saved` | TOMASZ | part | They came out of the smoke carrying their children. A woman kissed the Governor's hand. He did not know where to look. |
| 38 | `f_late` | LORD FAIRLEIGH | part | To the road again. We are late. |
| 39 | `t_toolate` | TOMASZ | part | We came too late. I said the De profundis over them in the yard, and we marched on. |
| 40 | `t_left` | TOMASZ | part | We saw the smoke of Hollins Farm for an hour. Nobody spoke. The Governor rode at the head of the column and did not once look round. |
| 41 | `f_fort` | LORD FAIRLEIGH | part | The road is clear. The fort. |
| 42 | `r_mass` | CAPTAIN RUGGIERI | part | They are massing behind the gate, my lord. Hundreds of them. |
| 43 | `f_canister_load` | LORD FAIRLEIGH | part | Bring the guns up. Load canister. |
| 44 | `tip_canister` | CAPTAIN RUGGIERI | part *to crown* | Select a cannon and press CANISTER on its card. Canister reaches short and cuts down a crowd. |
| 45 | `r_dug` | CAPTAIN RUGGIERI | part | They have had time to dig in. More of them than I would like. |
| 46 | `v_5` | VARENNE | part | Brothers! Their guns are few! One charge and Virginia is free! |
| 47 | `f_word` | LORD FAIRLEIGH | part | Canister. On my word. |
| 48 | `v_charge` | VARENNE | part | Forward! For the people! |
| 49 | `f_fire` | LORD FAIRLEIGH | part | Fire. |
| 50 | `r_varenne` | CAPTAIN RUGGIERI | part | Their orator is down. |
| 51 | `t_end` | TOMASZ | ending | Afterwards I went down to the gate with the chaplain and did what little could be done. I have said a Mass for them every year since. |
| 52 | `k_end` | THE KING | ending | Fairleigh put it down in a single morning. Rome sent him its thanks and a medal, and we thought that was the end of it. My pipe has gone out. |
