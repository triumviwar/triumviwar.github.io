# crown-micro-2 bench arms (tools/bench_crown_micro.gd)

Make a table: `python3 tools/study/crown_micro_2_table.py "NAME=BASE1+BASE2:ARM;BASE15:ARM15"` (docs/crown_micro_2.md).
Compare one arm with the crown-micro tool: `CMP_DIR=docs/crown_micro_2/bench python3 tools/study/crown_micro_bench_cmp.py cwbase1+cwbase2 cwgp`.

| file | set | switches |
|---|---|---|
| cwbase1, cwbase2 | cwcore runs:3 (seeds 0-2, 50-52) | cmic:off |
| cw15base1, cw15base2 | cwcore ratio:1.5 | cmic:off |
| cwrbase1 | cwreal tech:1 dry:0.3 | cmic:off |
| cwrid, cwbrace, cwkite, cwgp, cwback, cwwind, cwcount, cwshield, cwcan, cwhurt, cwfocus | cwcore | one part on (focus: cmicspit:0) |
| cw15gp, cw15wind, cw15hurt, cw15kite | cwcore ratio:1.5 | one part on |
| cwcrcline, cwcrcguns, cwcrccav, cwcrcscreen | cwcore | cmic:off and a rule the cleanup cut brought back (crcline / crcgunscoach / crccavmicro / crcscreen+crcline) |
| cw15line, cw15cav | cwcore ratio:1.5 | crcline:on / crccavmicro:on |
| cwfield1, cwfield2, cw15field, cwrfield | cwcore / ratio 1.5 / cwreal | cmicfieldline:on |
| cwcombo1, cwcombo2, cw15combo, cwrcombo | cwcore / ratio 1.5 / cwreal | the parts kept against the Clockwork (gunpick, kite, hurt, winders) |
| cwfcombo1, cw15fcombo | cwcore / ratio 1.5 | the kept parts and fieldline |
| crbase1-4 | crcore (seeds 0, 50, 100, 150) | cmic:off |
| crrbase1 | crreal tech:1 dry:0.3 | cmic:off |
| crrid, crbrace, crkite, crgp, crback, crwind, crcount, crcan, crhurt, crfocus | crcore | one part on |
| crbrace2, crgp2 | crcore seed:50 | brace / gunpick |
| crbg1-4 | crcore (seeds 0, 50, 100, 150) | brace and gunpick (kept in the mirror) |
