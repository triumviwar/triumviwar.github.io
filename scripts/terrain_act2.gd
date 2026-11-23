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
	"varzea": [0, 2, 1, 5, 3, 4],
	"varzea_mud": [5, 2, 3, 4, 1, 0],
	"varzea_water": [4, 5, 1, 3, 0, 2],
	"highland": [5, 4, 0, 2, 1, 3],
	"highland_earth": [5, 1, 4, 0, 3, 2],
	"highland_rock": [4, 2, 0, 3, 5, 1],
	"sertao": [4, 0, 3, 2, 5, 1],
	"sertao_dust": [2, 3, 1, 0, 5, 4],
	"sertao_rock": [5, 4, 3, 1, 2, 0],
	"varzea_face": [0, 1],
	"varzea_top": [0, 1],
	"highland_face": [0, 1],
	"highland_top": [0, 1],
	"sertao_face": [0, 1],
	"sertao_top": [0, 1],
}

## Average colour of each ground set (minimap, lobby preview).
const COLOURS := {
	"varzea": Color(0.318, 0.364, 0.166),
	"varzea_mud": Color(0.288, 0.217, 0.143),
	"varzea_water": Color(0.544, 0.469, 0.282),
	"highland": Color(0.457, 0.477, 0.287),
	"highland_earth": Color(0.457, 0.281, 0.197),
	"highland_rock": Color(0.458, 0.463, 0.439),
	"sertao": Color(0.605, 0.386, 0.244),
	"sertao_dust": Color(0.744, 0.628, 0.469),
	"sertao_rock": Color(0.604, 0.355, 0.219),
}

## The decorations: [width px, height px, cells their foot blocks (0 = walked through)].
const PROPS := {
	"varzea_tree": [60, 82, 1],
	"buriti": [50, 86, 1],
	"aninga": [22, 28, 0],
	"floating_grass": [30, 12, 0],
	"varzea_snag": [32, 16, 0],
	"araucaria": [56, 88, 1],
	"araucaria_young": [34, 52, 1],
	"highland_boulder": [38, 30, 1],
	"cold_tussock": [22, 18, 0],
	"mist_wisp": [64, 18, 0],
	"mandacaru": [34, 64, 1],
	"caatinga_tree": [52, 70, 1],
	"caatinga_bush": [36, 28, 0],
	"xique_xique": [28, 18, 0],
	"ox_skull": [18, 11, 0],
	"sertao_stones": [22, 14, 0],
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
