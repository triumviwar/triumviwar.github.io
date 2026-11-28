# The mix pass, piece by piece

Measured with tools/music/study_audio.py (the study's own measure) on the files before the pass and after it. LRA = loudness range (LU), sub = the energy share below 80 Hz, crest = peak to RMS (dB), k = the fader ride's factor (1 = not ridden), limit = the most the true-peak limiter took off (dB), shelf = the low-shelf at 100 Hz (dB).

| Piece | Title | LRA study | LRA before | LRA after | LUFS before | LUFS after | TP after | sub before | sub after | crest before | crest after | k | limit | shelf |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| brood_battle | Hunger | 4.7 | 4.7 | 9.8 | -14.5 | -12.9 | -1.1 | 0.54 | 0.23 | 12.7 | 14.6 | 1.93 | 4.0 | -5.5 |
| brood_battle_10 | Circling | 10.6 | 10.6 | 9.4 | -13.3 | -13.0 | -2.2 | 0.18 | 0.14 | 14.5 | 14.1 | 0.84 | 3.6 | 0.0 |
| brood_battle_11 | The Swarm at Full Cry | 9.9 | 9.9 | 8.7 | -12.9 | -13.0 | -2.1 | 0.27 | 0.19 | 14.4 | 14.0 | 0.91 | 4.0 | 0.0 |
| brood_battle_12 | The Queen's War-Song | 10.4 | 10.4 | 8.8 | -12.8 | -13.0 | -1.9 | 0.34 | 0.21 | 14.1 | 14.1 | 0.87 | 4.0 | -0.5 |
| brood_battle_13 | Ten Thousand Mouths | 11.0 | 11.0 | 8.8 | -12.7 | -13.0 | -3.6 | 0.22 | 0.13 | 14.3 | 14.3 | 0.86 | 4.0 | 0.0 |
| brood_battle_2 | Teeth in the Reeds | 7.0 | 7.0 | 9.2 | -14.4 | -13.0 | -1.4 | 0.50 | 0.22 | 13.3 | 14.0 | 1.40 | 4.0 | -6.0 |
| brood_battle_3 | The Swarm Rises | 8.4 | 8.4 | 8.9 | -13.3 | -12.9 | -1.3 | 0.43 | 0.24 | 13.6 | 14.4 | 1.11 | 3.1 | -2.5 |
| brood_battle_4 | Blood Moon Rite | 8.6 | 8.6 | 8.6 | -13.2 | -12.9 | -1.6 | 0.42 | 0.22 | 14.5 | 14.6 | 1.16 | 4.0 | -2.5 |
| brood_battle_5 | The Hive Unleashed | 6.9 | 6.9 | 9.5 | -13.6 | -12.9 | -2.2 | 0.46 | 0.22 | 14.1 | 14.0 | 1.48 | 4.0 | -3.0 |
| brood_battle_6 | The Brood Wakes | 14.7 | 14.7 | 9.6 | -12.6 | -12.9 | -2.5 | 0.08 | 0.06 | 15.3 | 15.3 | 0.54 | 4.0 | 0.0 |
| brood_battle_7 | The Hive Gathers | 7.5 | 7.5 | 8.6 | -12.9 | -12.9 | -1.8 | 0.12 | 0.08 | 14.9 | 15.0 | 1.17 | 4.0 | 0.0 |
| brood_battle_8 | Something in the Water | 6.2 | 6.2 | 9.1 | -13.4 | -13.0 | -2.0 | 0.25 | 0.13 | 14.3 | 14.2 | 1.61 | 4.0 | 0.0 |
| brood_battle_9 | The Scent of Blood | 8.1 | 8.1 | 8.7 | -12.8 | -12.9 | -1.6 | 0.07 | 0.05 | 14.5 | 14.2 | 1.28 | 4.0 | 0.0 |
| brood_peace | The Warm Swamp | 6.3 | 6.3 | 8.7 | -12.4 | -12.9 | -1.1 | 0.04 | 0.03 | 13.9 | 15.5 | 1.43 | 3.1 | 0.0 |
| brood_peace_2 | Spawning Pools | 5.5 | 5.5 | 8.6 | -11.9 | -12.8 | -2.4 | 0.00 | 0.00 | 12.1 | 14.6 | 1.54 | 1.1 | 0.0 |
| brood_peace_3 | Moonlit Mudflats | 5.1 | 5.1 | 9.1 | -11.1 | -12.8 | -1.7 | 0.01 | 0.01 | 12.3 | 15.1 | 1.80 | 1.4 | 0.0 |
| brood_peace_4 | The Queen Stirs | 6.0 | 6.0 | 8.7 | -12.0 | -12.9 | -1.6 | 0.13 | 0.09 | 13.7 | 15.1 | 1.34 | 4.0 | 0.0 |
| brood_peace_5 | Mist on the Brood-Mere | 4.8 | 4.8 | 9.0 | -13.0 | -12.9 | -1.2 | 0.01 | 0.01 | 13.7 | 15.4 | 1.96 | 2.2 | 0.0 |
| brood_peace_6 | The Queen's Lullaby | 5.5 | 5.5 | 8.6 | -13.5 | -13.0 | -1.5 | 0.02 | 0.02 | 14.1 | 14.8 | 1.69 | 3.3 | 0.0 |
| brood_peace_7 | Night over the Drowned Wood | 14.0 | 14.0 | 9.4 | -13.1 | -12.9 | -1.7 | 0.03 | 0.02 | 16.5 | 15.8 | 0.63 | 2.6 | 0.0 |
| clock_battle | Brass and Steam | 7.8 | 7.8 | 9.6 | -12.9 | -12.9 | -1.1 | 0.25 | 0.17 | 14.1 | 15.3 | 1.24 | 2.8 | 0.0 |
| clock_battle_10 | Pressure Rising | 8.9 | 8.9 | 8.6 | -12.7 | -13.0 | -1.4 | 0.17 | 0.12 | 14.5 | 14.0 | 1.01 | 4.0 | 0.0 |
| clock_battle_11 | Cathedral of Gears | 9.9 | 9.9 | 8.6 | -12.8 | -13.0 | -2.4 | 0.10 | 0.08 | 14.7 | 14.4 | 0.81 | 4.0 | 0.0 |
| clock_battle_12 | Anvil Chorus of a Thousand Hands | 6.8 | 6.8 | 8.6 | -12.6 | -13.0 | -2.2 | 0.12 | 0.11 | 15.2 | 14.4 | 1.42 | 4.0 | 0.0 |
| clock_battle_13 | The Grand Calculation | 8.7 | 8.7 | 10.1 | -12.7 | -13.4 | -2.8 | 0.20 | 0.15 | 14.7 | 14.4 | 1.28 | 4.0 | 0.0 |
| clock_battle_2 | Overclock | 10.7 | 10.7 | 9.5 | -11.9 | -12.9 | -1.4 | 0.04 | 0.03 | 13.8 | 15.1 | 0.85 | 1.0 | 0.0 |
| clock_battle_3 | Gearstorm | 10.4 | 10.4 | 9.9 | -11.2 | -12.9 | -1.2 | 0.03 | 0.02 | 13.9 | 15.5 | 0.92 | 2.9 | 0.0 |
| clock_battle_4 | The Iron Tide | 7.8 | 7.8 | 9.4 | -13.7 | -12.9 | -1.5 | 0.28 | 0.20 | 14.9 | 14.2 | 1.23 | 4.0 | 0.0 |
| clock_battle_5 | Calibrated Fury | 7.1 | 7.1 | 8.8 | -13.6 | -13.0 | -1.9 | 0.34 | 0.21 | 15.2 | 14.0 | 1.19 | 4.0 | -0.5 |
| clock_battle_6 | The Great Escapement | 11.3 | 11.3 | 9.3 | -12.7 | -13.0 | -1.9 | 0.05 | 0.05 | 15.4 | 14.7 | 0.73 | 4.0 | 0.0 |
| clock_battle_7 | Calibration | 8.6 | 8.6 | 8.3 | -12.8 | -12.9 | -2.0 | 0.01 | 0.01 | 15.0 | 14.8 | 0.88 | 4.0 | 0.0 |
| clock_battle_8 | Tick, Tock, Alarm | 7.6 | 7.6 | 8.8 | -12.4 | -13.0 | -1.9 | 0.02 | 0.01 | 14.7 | 14.7 | 1.10 | 4.0 | 0.0 |
| clock_battle_9 | The Watchful Gear | 6.1 | 6.1 | 8.7 | -12.6 | -12.9 | -3.6 | 0.04 | 0.05 | 15.0 | 14.8 | 1.55 | 4.0 | 0.0 |
| clock_peace | Winding the Spring | 7.3 | 7.3 | 8.6 | -12.2 | -12.9 | -1.4 | 0.00 | 0.00 | 14.7 | 14.8 | 1.36 | 4.0 | 0.0 |
| clock_peace_2 | The Orrery | 3.8 | 3.8 | 8.6 | -12.2 | -12.9 | -1.2 | 0.00 | 0.00 | 14.2 | 15.7 | 3.32 | 4.0 | 0.0 |
| clock_peace_3 | Rust and Rain | 6.5 | 6.5 | 8.9 | -11.9 | -12.9 | -1.3 | 0.00 | 0.00 | 13.6 | 15.4 | 1.43 | 3.4 | 0.0 |
| clock_peace_4 | The Assembly Line | 6.2 | 6.2 | 8.4 | -12.4 | -13.0 | -2.0 | 0.08 | 0.06 | 14.8 | 15.1 | 1.75 | 4.0 | 0.0 |
| clock_peace_5 | The Lantern Waltz | 8.3 | 8.3 | 9.5 | -12.1 | -12.8 | -1.6 | 0.01 | 0.01 | 13.5 | 15.1 | 0.98 | 0.9 | 0.0 |
| clock_peace_6 | The Clockmaker's Lament | 10.7 | 10.7 | 8.7 | -12.4 | -12.9 | -1.7 | 0.03 | 0.03 | 15.4 | 15.5 | 0.75 | 4.0 | 0.0 |
| clock_peace_7 | Canon of Perfect Order | 5.9 | 5.9 | 8.6 | -12.5 | -13.0 | -1.4 | 0.10 | 0.08 | 15.4 | 15.0 | 1.47 | 3.2 | 0.0 |
| crown_battle | Pike and Shot | 3.3 | 3.3 | 8.5 | -13.1 | -12.9 | -1.3 | 0.29 | 0.22 | 13.1 | 14.8 | 2.73 | 4.0 | 0.0 |
| crown_battle_10 | Columns on the March | 7.3 | 7.3 | 8.5 | -14.7 | -12.9 | -1.0 | 0.39 | 0.19 | 15.0 | 14.4 | 1.32 | 4.0 | -3.5 |
| crown_battle_11 | The Grenadiers' March | 3.6 | 3.6 | 9.0 | -12.4 | -13.0 | -2.4 | 0.23 | 0.15 | 14.2 | 14.5 | 3.83 | 4.0 | 0.0 |
| crown_battle_2 | Volley Fire | 7.4 | 7.4 | 8.9 | -13.2 | -12.9 | -1.2 | 0.28 | 0.20 | 13.7 | 14.3 | 1.16 | 2.1 | 0.0 |
| crown_battle_3 | Sabres at the Ford | 5.9 | 5.9 | 8.9 | -12.9 | -12.9 | -1.4 | 0.35 | 0.24 | 13.5 | 14.4 | 1.57 | 3.7 | -1.0 |
| crown_battle_4 | The Forlorn Hope | 7.7 | 7.7 | 9.0 | -14.0 | -12.9 | -2.0 | 0.46 | 0.23 | 14.8 | 14.6 | 1.27 | 4.0 | -1.5 |
| crown_battle_5 | Storm the Breach | 6.5 | 6.5 | 8.9 | -13.5 | -12.9 | -2.1 | 0.34 | 0.17 | 14.5 | 14.1 | 1.76 | 4.0 | 0.0 |
| crown_battle_6 | Fifes at First Light | 5.8 | 5.8 | 8.9 | -12.3 | -12.9 | -2.3 | 0.16 | 0.11 | 14.7 | 15.0 | 1.61 | 4.0 | 0.0 |
| crown_battle_7 | Tattoo at Dusk | 6.2 | 6.2 | 8.8 | -14.9 | -13.0 | -1.5 | 0.45 | 0.24 | 14.8 | 13.4 | 2.33 | 4.0 | -2.5 |
| crown_battle_8 | Over the Parapet | 6.1 | 6.1 | 9.0 | -15.0 | -13.0 | -1.1 | 0.40 | 0.22 | 15.2 | 14.7 | 1.95 | 4.0 | -2.5 |
| crown_battle_9 | Beating to Quarters | 7.0 | 7.0 | 8.9 | -14.2 | -13.0 | -1.1 | 0.40 | 0.24 | 14.3 | 14.1 | 1.64 | 4.0 | -1.5 |
| crown_peace | The King's Muster | 5.8 | 5.8 | 8.7 | -10.5 | -12.8 | -1.1 | 0.00 | 0.00 | 12.4 | 16.0 | 2.64 | 2.2 | 0.0 |
| crown_peace_2 | The Orchard Minuet | 2.6 | 2.6 | 8.7 | -11.6 | -12.8 | -4.4 | 0.00 | 0.00 | 12.0 | 15.4 | 4.24 | 3.9 | 0.0 |
| crown_peace_3 | Ballad of the Lost Regiment | 12.1 | 12.1 | 9.6 | -10.7 | -12.8 | -1.1 | 0.00 | 0.00 | 13.5 | 14.2 | 0.73 | 0.6 | 0.0 |
| crown_peace_4 | Raising the Bastion | 3.9 | 3.9 | 8.6 | -11.5 | -12.9 | -2.2 | 0.03 | 0.02 | 12.9 | 14.9 | 2.37 | 3.9 | 0.0 |
| crown_peace_5 | The Chapel at Dawn | 5.1 | 5.1 | 8.8 | -12.7 | -12.9 | -1.5 | 0.02 | 0.01 | 14.1 | 15.0 | 1.55 | 2.5 | 0.0 |
| crown_peace_6 | The Elector's Waltz | 5.4 | 5.4 | 8.9 | -12.8 | -14.1 | -3.0 | 0.01 | 0.01 | 14.6 | 15.0 | 1.60 | 4.0 | 0.0 |
| crown_peace_7 | Waltz of the Garrison Flowers | 4.0 | 4.0 | 9.0 | -12.2 | -12.9 | -2.6 | 0.01 | 0.01 | 14.9 | 15.1 | 2.14 | 4.0 | 0.0 |
| crown_peace_8 | Court Waltz by Candlelight | 4.4 | 4.4 | 8.7 | -13.1 | -12.9 | -2.5 | 0.05 | 0.04 | 15.6 | 14.5 | 2.32 | 4.0 | 0.0 |
| crown_peace_9 | The Colours Furled | 5.0 | 5.0 | 9.0 | -13.2 | -13.0 | -3.1 | 0.05 | 0.04 | 15.6 | 15.0 | 2.26 | 4.0 | 0.0 |
| defeat | The Field Is Lost | 1.7 | 1.7 | 2.3 | -12.2 | -12.8 | -2.3 | 0.07 | 0.04 | 11.8 | 13.3 | 1.00 | -0.0 | 0.0 |
| menu | Grand Overture | 9.8 | 9.8 | 9.3 | -11.6 | -12.9 | -1.5 | 0.17 | 0.11 | 14.0 | 15.6 | 0.91 | 3.8 | 0.0 |
| menu_10 | Drums for the King | 6.4 | 6.4 | 9.0 | -13.8 | -12.9 | -1.1 | 0.18 | 0.12 | 14.7 | 14.3 | 1.81 | 4.0 | 0.0 |
| menu_2 | The Banners Rise | 7.9 | 7.9 | 8.7 | -12.9 | -12.9 | -2.1 | 0.12 | 0.07 | 15.0 | 14.3 | 1.18 | 4.0 | 0.0 |
| menu_3 | Before the Long Night | 4.6 | 4.6 | 8.9 | -11.4 | -12.9 | -4.4 | 0.14 | 0.11 | 14.1 | 14.8 | 2.54 | 4.0 | 0.0 |
| menu_4 | Over the High Passes | 5.2 | 5.2 | 8.8 | -11.9 | -12.9 | -3.0 | 0.09 | 0.06 | 14.0 | 14.5 | 1.71 | 4.0 | 0.0 |
| menu_5 | The Iron Anthem | 9.0 | 9.0 | 8.7 | -12.2 | -13.0 | -1.7 | 0.16 | 0.12 | 14.5 | 14.6 | 0.85 | 4.0 | 0.0 |
| menu_7 | Banners and Drums | 6.7 | 6.7 | 8.9 | -13.4 | -12.9 | -1.0 | 0.28 | 0.19 | 14.2 | 14.5 | 1.67 | 4.0 | 0.0 |
| menu_8 | Roll of the Regiment | 6.9 | 6.9 | 9.2 | -13.5 | -12.9 | -1.1 | 0.21 | 0.15 | 14.0 | 14.6 | 1.86 | 4.0 | 0.0 |
| menu_9 | The Long Parade | 6.9 | 6.9 | 9.0 | -13.6 | -13.0 | -1.1 | 0.25 | 0.18 | 14.0 | 14.5 | 1.66 | 4.0 | 0.0 |

## Medians by side (the sting left out)

| Group | Pieces | LRA before | LRA after | in 8-10 LU after | LUFS before | LUFS after | pieces sub > 25% before / after | crest before | crest after |
|---|---|---|---|---|---|---|---|---|---|
| all | 69 | 6.9 | 8.9 | 68 | -12.8 | -12.9 | 21 / 0 | 14.3 | 14.6 |
| crown | 20 | 5.8 | 8.9 | 20 | -13.0 | -12.9 | 9 / 0 | 14.4 | 14.6 |
| clock | 20 | 7.8 | 8.8 | 19 | -12.6 | -12.9 | 2 / 0 | 14.7 | 14.8 |
| brood | 20 | 7.2 | 8.9 | 20 | -13.0 | -12.9 | 8 / 0 | 14.1 | 14.6 |
| menu | 9 | 6.9 | 8.9 | 9 | -12.9 | -12.9 | 2 / 0 | 14.1 | 14.5 |
