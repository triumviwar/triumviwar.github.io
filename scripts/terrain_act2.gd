class_name TerrainAct2
## Act 2's Brazilian ground looks (VÁRZEA, HIGHLANDS, SERTÃO): written by
## tools/make_act2_terrain.py (stand-ins) and tools/import_act2_terrain.py (the owner's
## pictures). Read beside TerrainData / TerrainData2 / PropData (docs/act2_terrain_art.md).

## Ground sets and how many variants each has (the plain grounds are 64 x 64, laid
## over 2 x 2 cells; faces and tops 32 x 32).
const COUNTS := {
	"varzea": 6,
	"varzea_mud": 6,
	"varzea_water": 6,
	"highland": 6,
	"highland_earth": 6,
	"highland_rock": 6,
	"sertao": 6,
	"sertao_dust": 6,
	"sertao_rock": 6,
	"varzea_face": 2,
	"varzea_top": 2,
	"highland_face": 2,
	"highland_top": 2,
	"sertao_face": 2,
	"sertao_top": 2,
}

## The variants that tile best, best first.
const GOOD := {
	"varzea": [4, 1, 0, 2, 3, 5],
	"varzea_mud": [0, 3, 2, 4, 1, 5],
	"varzea_water": [2, 0, 3, 1, 5, 4],
	"highland": [0, 3, 2, 1, 4, 5],
	"highland_earth": [1, 3, 5, 0, 4, 2],
	"highland_rock": [0, 2, 4, 3, 5, 1],
	"sertao": [3, 0, 2, 1, 4, 5],
	"sertao_dust": [5, 0, 2, 3, 1, 4],
	"sertao_rock": [2, 5, 4, 0, 3, 1],
	"varzea_face": [0, 1],
	"varzea_top": [0, 1],
	"highland_face": [0, 1],
	"highland_top": [0, 1],
	"sertao_face": [0, 1],
	"sertao_top": [0, 1],
}

## Average colour of each ground set (minimap, lobby preview).
const COLOURS := {
	"varzea": Color(0.279, 0.330, 0.121),
	"varzea_mud": Color(0.328, 0.245, 0.126),
	"varzea_water": Color(0.517, 0.416, 0.193),
	"highland": Color(0.456, 0.442, 0.236),
	"highland_earth": Color(0.354, 0.194, 0.137),
	"highland_rock": Color(0.391, 0.383, 0.344),
	"sertao": Color(0.667, 0.351, 0.177),
	"sertao_dust": Color(0.836, 0.628, 0.390),
	"sertao_rock": Color(0.802, 0.304, 0.165),
}

## The decorations: [width px, height px, cells their foot blocks (0 = walked through)].
const PROPS := {
	"varzea_tree": [67, 82, 1],
	"buriti": [48, 86, 1],
	"aninga": [26, 28, 0],
	"floating_grass": [34, 12, 0],
	"varzea_snag": [36, 16, 0],
	"araucaria": [67, 88, 1],
	"araucaria_young": [29, 52, 1],
	"highland_boulder": [47, 30, 1],
	"cold_tussock": [23, 18, 0],
	"mist_wisp": [64, 18, 0],
	"mandacaru": [24, 64, 1],
	"caatinga_tree": [70, 70, 1],
	"caatinga_bush": [49, 28, 0],
	"xique_xique": [31, 18, 0],
	"ox_skull": [17, 11, 0],
	"sertao_stones": [30, 14, 0],
}

## The map editor's palette group of each decoration.
const KIND := {
	"varzea_tree": "trees",
	"buriti": "trees",
	"aninga": "plants",
	"floating_grass": "plants",
	"varzea_snag": "trees",
	"araucaria": "trees",
	"araucaria_young": "trees",
	"highland_boulder": "rocks",
	"cold_tussock": "plants",
	"mist_wisp": "plants",
	"mandacaru": "trees",
	"caatinga_tree": "trees",
	"caatinga_bush": "plants",
	"xique_xique": "plants",
	"ox_skull": "plants",
	"sertao_stones": "rocks",
}


## A ground set of this file is laid over 2 x 2 cells (its plain grounds, not faces or tops).
static func is_macro(set_name: String) -> bool:
	return COUNTS.has(set_name) and not set_name.ends_with("_face") and not set_name.ends_with("_top")
