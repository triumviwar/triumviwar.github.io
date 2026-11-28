# The mix pass, piece by piece

Measured with tools/music/study_audio.py (the study's own measure) on the files before the pass and after it. LRA = loudness range (LU), sub = the energy share below 80 Hz, crest = peak to RMS (dB), k = the fader ride's factor (1 = not ridden), limit = the most the true-peak limiter took off (dB), shelf = the low-shelf at 100 Hz (dB).

| Piece | Title | LRA study | LRA before | LRA after | LUFS before | LUFS after | TP after | sub before | sub after | crest before | crest after | k | limit | shelf |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| brood_battle | Hunger | 4.7 | 4.7 | 11.9 | -14.5 | -16.3 | -1.2 | 0.54 | 0.23 | 12.7 | 17.8 | 2.25 | 1.4 | -5.0 |
| brood_battle_10 | Circling | 10.6 | 10.6 | 10.4 | -13.3 | -16.6 | -5.9 | 0.18 | 0.13 | 14.5 | 16.4 | 0.89 | -0.0 | 0.0 |
| brood_battle_11 | The Swarm at Full Cry | 9.9 | 9.9 | 10.5 | -12.9 | -16.5 | -6.0 | 0.27 | 0.18 | 14.4 | 17.3 | 0.89 | 4.0 | 0.0 |
| brood_battle_12 | The Queen's War-Song | 10.4 | 10.4 | 10.0 | -12.8 | -16.5 | -4.7 | 0.34 | 0.22 | 14.1 | 17.7 | 0.91 | 3.5 | 0.0 |
| brood_battle_13 | Ten Thousand Mouths | 11.0 | 11.0 | 10.1 | -12.7 | -16.5 | -7.9 | 0.22 | 0.14 | 14.3 | 17.2 | 0.83 | 3.7 | 0.0 |
| brood_battle_2 | Teeth in the Reeds | 7.0 | 7.0 | 10.6 | -14.4 | -16.1 | -2.8 | 0.50 | 0.23 | 13.3 | 17.1 | 1.42 | 0.5 | -5.5 |
| brood_battle_3 | The Swarm Rises | 8.4 | 8.4 | 8.5 | -13.3 | -16.2 | -2.8 | 0.43 | 0.25 | 13.6 | 16.2 | 1.00 | -0.0 | -2.5 |
| brood_battle_4 | Blood Moon Rite | 8.6 | 8.6 | 9.3 | -13.2 | -16.4 | -4.1 | 0.42 | 0.24 | 14.5 | 17.6 | 1.38 | 3.4 | -1.5 |
| brood_battle_5 | The Hive Unleashed | 6.9 | 6.9 | 9.1 | -13.6 | -16.5 | -3.4 | 0.46 | 0.24 | 14.1 | 17.6 | 1.00 | 3.2 | -2.0 |
| brood_battle_6 | The Brood Wakes | 14.7 | 14.7 | 10.3 | -12.6 | -16.5 | -6.2 | 0.08 | 0.06 | 15.3 | 16.2 | 0.57 | 0.4 | 0.0 |
| brood_battle_7 | The Hive Gathers | 7.5 | 7.5 | 10.0 | -12.9 | -16.4 | -4.9 | 0.12 | 0.08 | 14.9 | 18.2 | 1.23 | 1.0 | 0.0 |
| brood_battle_8 | Something in the Water | 6.2 | 6.2 | 9.5 | -13.4 | -16.6 | -5.6 | 0.25 | 0.13 | 14.3 | 18.0 | 1.54 | 1.3 | 0.0 |
| brood_battle_9 | The Scent of Blood | 8.1 | 8.1 | 9.6 | -12.8 | -16.4 | -4.3 | 0.07 | 0.05 | 14.5 | 17.2 | 1.00 | 1.9 | 0.0 |
| brood_peace | The Warm Swamp | 6.3 | 6.3 | 9.9 | -12.4 | -15.9 | -4.2 | 0.04 | 0.03 | 13.9 | 17.2 | 1.71 | 0.2 | 0.0 |
| brood_peace_2 | Spawning Pools | 5.5 | 5.5 | 9.2 | -11.9 | -16.3 | -5.9 | 0.00 | 0.00 | 12.1 | 15.0 | 1.69 | -0.0 | 0.0 |
| brood_peace_3 | Moonlit Mudflats | 5.1 | 5.1 | 9.3 | -11.1 | -16.2 | -5.0 | 0.01 | 0.01 | 12.3 | 14.9 | 1.87 | -0.0 | 0.0 |
| brood_peace_4 | The Queen Stirs | 6.0 | 6.0 | 10.3 | -12.0 | -15.9 | -4.2 | 0.13 | 0.09 | 13.7 | 16.9 | 1.70 | 1.7 | 0.0 |
| brood_peace_5 | Mist on the Brood-Mere | 4.8 | 4.8 | 9.0 | -13.0 | -16.1 | -2.8 | 0.01 | 0.01 | 13.7 | 17.0 | 1.93 | -0.0 | 0.0 |
| brood_peace_6 | The Queen's Lullaby | 5.5 | 5.5 | 9.3 | -13.5 | -16.3 | -4.8 | 0.02 | 0.02 | 14.1 | 16.9 | 1.74 | -0.0 | 0.0 |
| brood_peace_7 | Night over the Drowned Wood | 14.0 | 14.0 | 10.0 | -13.1 | -16.2 | -3.5 | 0.03 | 0.02 | 16.5 | 16.1 | 0.66 | -0.0 | 0.0 |
| clock_battle | Brass and Steam | 7.8 | 7.8 | 9.5 | -12.9 | -15.8 | -1.5 | 0.25 | 0.17 | 14.1 | 16.9 | 1.19 | -0.0 | 0.0 |
| clock_battle_10 | Pressure Rising | 8.9 | 8.9 | 9.8 | -12.7 | -16.3 | -5.4 | 0.17 | 0.13 | 14.5 | 17.8 | 0.92 | 2.2 | 0.0 |
| clock_battle_11 | Cathedral of Gears | 9.9 | 9.9 | 9.1 | -12.8 | -16.4 | -6.0 | 0.10 | 0.07 | 14.7 | 17.2 | 0.83 | 4.0 | 0.0 |
| clock_battle_12 | Anvil Chorus of a Thousand Hands | 6.8 | 6.8 | 8.2 | -12.6 | -16.1 | -3.8 | 0.12 | 0.11 | 15.2 | 17.3 | 1.00 | 4.0 | 0.0 |
| clock_battle_13 | The Grand Calculation | 8.7 | 8.7 | 9.2 | -12.7 | -16.3 | -2.2 | 0.20 | 0.15 | 14.7 | 17.7 | 0.87 | 4.0 | 0.0 |
| clock_battle_2 | Overclock | 10.7 | 10.7 | 11.2 | -11.9 | -15.3 | -3.4 | 0.04 | 0.03 | 13.8 | 16.4 | 1.00 | -0.0 | 0.0 |
| clock_battle_3 | Gearstorm | 10.4 | 10.4 | 9.5 | -11.2 | -15.3 | -1.8 | 0.03 | 0.02 | 13.9 | 16.8 | 0.87 | 0.1 | 0.0 |
| clock_battle_4 | The Iron Tide | 7.8 | 7.8 | 8.8 | -13.7 | -16.4 | -1.5 | 0.28 | 0.20 | 14.9 | 17.5 | 1.00 | 3.3 | 0.0 |
| clock_battle_5 | Calibrated Fury | 7.1 | 7.1 | 7.8 | -13.6 | -16.6 | -1.7 | 0.34 | 0.22 | 15.2 | 17.4 | 1.00 | 2.6 | 0.0 |
| clock_battle_6 | The Great Escapement | 11.3 | 11.3 | 9.8 | -12.7 | -16.1 | -3.9 | 0.05 | 0.05 | 15.4 | 17.9 | 0.63 | 2.6 | 0.0 |
| clock_battle_7 | Calibration | 8.6 | 8.6 | 8.5 | -12.8 | -15.9 | -1.8 | 0.01 | 0.01 | 15.0 | 17.5 | 0.64 | 2.4 | 0.0 |
| clock_battle_8 | Tick, Tock, Alarm | 7.6 | 7.6 | 9.0 | -12.4 | -15.8 | -4.7 | 0.02 | 0.01 | 14.7 | 17.5 | 1.00 | 1.1 | 0.0 |
| clock_battle_9 | The Watchful Gear | 6.1 | 6.1 | 7.7 | -12.6 | -16.0 | -5.8 | 0.04 | 0.05 | 15.0 | 17.8 | 1.00 | 2.0 | 0.0 |
| clock_peace | Winding the Spring | 7.3 | 7.3 | 9.0 | -12.2 | -15.7 | -1.2 | 0.00 | 0.00 | 14.7 | 17.7 | 1.23 | 1.2 | 0.0 |
| clock_peace_2 | The Orrery | 3.8 | 3.8 | 9.1 | -12.2 | -15.5 | -1.3 | 0.00 | 0.00 | 14.2 | 18.0 | 3.65 | 3.7 | 0.0 |
| clock_peace_3 | Rust and Rain | 6.5 | 6.5 | 8.9 | -11.9 | -15.6 | -2.6 | 0.00 | 0.00 | 13.6 | 16.6 | 1.30 | 0.4 | 0.0 |
| clock_peace_4 | The Assembly Line | 6.2 | 6.2 | 10.0 | -12.4 | -15.2 | -1.1 | 0.08 | 0.06 | 14.8 | 17.5 | 1.63 | 3.0 | 0.0 |
| clock_peace_5 | The Lantern Waltz | 8.3 | 8.3 | 9.8 | -12.1 | -15.9 | -4.5 | 0.01 | 0.01 | 13.5 | 15.3 | 1.00 | -0.0 | 0.0 |
| clock_peace_6 | The Clockmaker's Lament | 10.7 | 10.7 | 9.1 | -12.4 | -15.8 | -4.1 | 0.03 | 0.03 | 15.4 | 17.8 | 0.72 | 1.5 | 0.0 |
| clock_peace_7 | Canon of Perfect Order | 5.9 | 5.9 | 8.6 | -12.5 | -16.1 | -2.0 | 0.10 | 0.08 | 15.4 | 16.9 | 1.40 | -0.0 | 0.0 |
| crown_battle | Pike and Shot | 3.3 | 3.3 | 8.6 | -13.1 | -16.2 | -3.8 | 0.29 | 0.23 | 13.1 | 16.5 | 2.52 | 0.5 | 0.0 |
| crown_battle_10 | Columns on the March | 7.3 | 7.3 | 9.1 | -14.7 | -16.4 | -1.1 | 0.39 | 0.19 | 15.0 | 17.7 | 1.00 | 1.4 | -3.5 |
| crown_battle_11 | The Grenadiers' March | 3.6 | 3.6 | 7.7 | -12.4 | -15.8 | -5.3 | 0.23 | 0.15 | 14.2 | 17.6 | 1.99 | 4.0 | 0.0 |
| crown_battle_2 | Volley Fire | 7.4 | 7.4 | 9.8 | -13.2 | -16.1 | -2.6 | 0.28 | 0.20 | 13.7 | 16.2 | 1.29 | -0.0 | 0.0 |
| crown_battle_3 | Sabres at the Ford | 5.9 | 5.9 | 7.6 | -12.9 | -16.2 | -3.6 | 0.35 | 0.26 | 13.5 | 16.4 | 1.20 | -0.0 | -0.5 |
| crown_battle_4 | The Forlorn Hope | 7.7 | 7.7 | 9.1 | -14.0 | -16.3 | -4.6 | 0.46 | 0.26 | 14.8 | 17.5 | 1.17 | 4.0 | -0.5 |
| crown_battle_5 | Storm the Breach | 6.5 | 6.5 | 8.9 | -13.5 | -16.3 | -4.8 | 0.34 | 0.16 | 14.5 | 17.5 | 1.55 | 4.0 | 0.0 |
| crown_battle_6 | Fifes at First Light | 5.8 | 5.8 | 9.5 | -12.3 | -15.4 | -5.3 | 0.16 | 0.10 | 14.7 | 17.2 | 1.54 | 4.0 | 0.0 |
| crown_battle_7 | Tattoo at Dusk | 6.2 | 6.2 | 9.5 | -14.9 | -16.4 | -1.2 | 0.45 | 0.25 | 14.8 | 17.7 | 1.50 | 3.8 | -2.5 |
| crown_battle_8 | Over the Parapet | 6.1 | 6.1 | 9.2 | -15.0 | -16.4 | -1.3 | 0.40 | 0.24 | 15.2 | 17.1 | 1.29 | 4.0 | -2.0 |
| crown_battle_9 | Beating to Quarters | 7.0 | 7.0 | 8.9 | -14.2 | -16.5 | -1.0 | 0.40 | 0.25 | 14.3 | 17.7 | 1.11 | 1.5 | -1.5 |
| crown_peace | The King's Muster | 5.8 | 5.8 | 8.5 | -10.5 | -15.1 | -2.3 | 0.00 | 0.00 | 12.4 | 15.7 | 3.04 | -0.0 | 0.0 |
| crown_peace_2 | The Orchard Minuet | 2.6 | 2.6 | 8.2 | -11.6 | -15.5 | -7.7 | 0.00 | 0.00 | 12.0 | 16.0 | 3.11 | 1.5 | 0.0 |
| crown_peace_3 | Ballad of the Lost Regiment | 12.1 | 12.1 | 8.9 | -10.7 | -15.5 | -3.2 | 0.00 | 0.00 | 13.5 | 14.3 | 0.68 | -0.0 | 0.0 |
| crown_peace_4 | Raising the Bastion | 3.9 | 3.9 | 8.3 | -11.5 | -15.7 | -5.7 | 0.03 | 0.03 | 12.9 | 17.5 | 1.86 | -0.0 | 0.0 |
| crown_peace_5 | The Chapel at Dawn | 5.1 | 5.1 | 9.3 | -12.7 | -15.6 | -4.5 | 0.02 | 0.01 | 14.1 | 17.4 | 1.66 | -0.0 | 0.0 |
| crown_peace_6 | The Elector's Waltz | 5.4 | 5.4 | 8.3 | -12.8 | -15.8 | -4.7 | 0.01 | 0.01 | 14.6 | 17.0 | 1.45 | 4.0 | 0.0 |
| crown_peace_7 | Waltz of the Garrison Flowers | 4.0 | 4.0 | 9.4 | -12.2 | -15.4 | -4.1 | 0.01 | 0.01 | 14.9 | 17.5 | 2.69 | 4.0 | 0.0 |
| crown_peace_8 | Court Waltz by Candlelight | 4.4 | 4.4 | 8.4 | -13.1 | -15.9 | -6.0 | 0.05 | 0.05 | 15.6 | 17.7 | 1.71 | 4.0 | 0.0 |
| crown_peace_9 | The Colours Furled | 5.0 | 5.0 | 8.2 | -13.2 | -15.9 | -7.3 | 0.05 | 0.05 | 15.6 | 18.2 | 1.00 | 2.6 | 0.0 |
| defeat | The Field Is Lost | 1.7 | 1.7 | 2.3 | -12.2 | -16.4 | -5.9 | 0.07 | 0.04 | 11.8 | 13.4 | 1.00 | -0.0 | 0.0 |
| menu | Grand Overture | 9.8 | 9.8 | 9.7 | -11.6 | -15.7 | -3.0 | 0.17 | 0.11 | 14.0 | 17.3 | 0.93 | 0.6 | 0.0 |
| menu_10 | Drums for the King | 6.4 | 6.4 | 10.6 | -13.8 | -16.3 | -1.0 | 0.18 | 0.12 | 14.7 | 17.4 | 1.15 | 1.5 | 0.0 |
| menu_2 | The Banners Rise | 7.9 | 7.9 | 10.1 | -12.9 | -16.2 | -5.3 | 0.12 | 0.07 | 15.0 | 17.6 | 0.93 | 3.7 | 0.0 |
| menu_3 | Before the Long Night | 4.6 | 4.6 | 8.9 | -11.4 | -16.3 | -7.6 | 0.14 | 0.13 | 14.1 | 18.6 | 1.30 | 1.6 | 0.0 |
| menu_4 | Over the High Passes | 5.2 | 5.2 | 8.8 | -11.9 | -16.1 | -6.6 | 0.09 | 0.05 | 14.0 | 17.9 | 1.38 | 4.0 | 0.0 |
| menu_5 | The Iron Anthem | 9.0 | 9.0 | 9.9 | -12.2 | -16.1 | -4.2 | 0.16 | 0.12 | 14.5 | 17.9 | 0.89 | 4.0 | 0.0 |
| menu_7 | Banners and Drums | 6.7 | 6.7 | 10.3 | -13.4 | -16.2 | -1.2 | 0.28 | 0.20 | 14.2 | 17.3 | 1.16 | 2.4 | 0.0 |
| menu_8 | Roll of the Regiment | 6.9 | 6.9 | 9.7 | -13.5 | -16.3 | -1.2 | 0.21 | 0.14 | 14.0 | 17.5 | 1.16 | 2.3 | 0.0 |
| menu_9 | The Long Parade | 6.9 | 6.9 | 9.5 | -13.6 | -16.2 | -1.2 | 0.25 | 0.18 | 14.0 | 17.2 | 1.00 | 0.6 | 0.0 |

## Medians by side (the sting left out)

| Group | Pieces | LRA before | LRA after | in 8-10 LU after | LUFS before | LUFS after | pieces sub > 25% before / after | crest before | crest after |
|---|---|---|---|---|---|---|---|---|---|
| all | 69 | 6.9 | 9.3 | 54 | -12.8 | -16.2 | 21 / 3 | 14.3 | 17.4 |
| crown | 20 | 5.8 | 8.9 | 18 | -13.0 | -15.9 | 9 / 3 | 14.4 | 17.4 |
| clock | 20 | 7.8 | 9.1 | 17 | -12.6 | -15.9 | 2 / 0 | 14.7 | 17.5 |
| brood | 20 | 7.2 | 9.9 | 13 | -13.0 | -16.4 | 8 / 0 | 14.1 | 17.1 |
| menu | 9 | 6.9 | 9.7 | 6 | -12.9 | -16.2 | 2 / 0 | 14.1 | 17.5 |
