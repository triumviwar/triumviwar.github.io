class_name WWRules
extends RefCounted
## THE WORLD WAR mode's rules and numbers (docs/world_war_mode.md). Nothing here changes; WWWar plays by them.
## A war is three sides on the world map (campaign/worldwar/regions.json): the Crown (Rome), the Clockwork (Nuremberg)
## and the Brood (its Queen in the Amazon). One turn = one season; every side moves in turn.

const REGIONS := "res://campaign/worldwar/regions.json"
const LAND := "res://campaign/worldwar/land.json"

const FACTIONS := ["crown", "clockwork", "brood"]
const NAME := {"crown": "The Crown", "clockwork": "The Clockwork", "brood": "The Brood", "": "Free lands"}
const COLOUR := {"crown": Color("#7b4bb8"), "clockwork": Color("#c0392b"), "brood": Color("#3f9c3a"), "": Color("#b9a98a")}
const CAPITAL := {"crown": "rome", "clockwork": "nuremberg", "brood": "amazon"}
## The lands each side holds when the war begins (the capital first). The same worth for each (8).
## (the Crown's fourth region, Lyon, only in a three-side war: it stands between the other two: START_THIRD)
const START := {"crown": ["rome", "naples", "milan"], "clockwork": ["nuremberg", "saxony", "poland"],
	"brood": ["amazon", "para", "new_granada"]}
const START_THIRD := {"crown": ["lyon", "lisbon"], "clockwork": ["vienna"], "brood": []}
## In a TWO-SIDE war a side may start with more (START_TWO[side][its enemy]): the free land round each start decides a
## two-side war, and the Crown's (Europe, Africa, the sea from Lisbon) is the widest (docs/world_war_tune.md).
const START_TWO := {"brood": {"crown": ["mato_grosso", "minas"]}}
## A side NOT in the war: its home lands (START) are free countries with ABSENT_GUARD times the usual militia (the
## Clockwork's: the free cities of the Empire, walled; the others' homes stand as any free land).
const ABSENT_GUARD := {"clockwork": 3.0}
const START_GOLD := 600

const SEASONS := ["Spring", "Summer", "Autumn", "Winter"]
const FIRST_YEAR := 2771

## REGIMENTS: what each side recruits (a package of real units of the skirmish; their price is their worth).
## On the world map an army is these units counted; a fought battle puts exactly them on the field.
const REGIMENTS := {
	"crown": [{"id": "foot", "name": "Musketeers", "units": {"musketeer": 6}},
		{"id": "horse", "name": "Horsemen", "units": {"cuirassier": 3}},
		{"id": "guns", "name": "Field Cannons", "units": {"cannon": 2}}],
	"clockwork": [{"id": "soldiers", "name": "Clock Soldiers", "units": {"clock_soldier": 6}},
		{"id": "springers", "name": "Springers", "units": {"springer": 3}},
		{"id": "pendulums", "name": "Pendulums", "units": {"pendulum": 2}}],
	"brood": [{"id": "raptors", "name": "Raptors", "units": {"raptor": 12}},
		{"id": "spitters", "name": "Spitters", "units": {"spitter": 6}},
		{"id": "brutes", "name": "Brutes", "units": {"brute": 2}}],
}
## Each unit's worth in gold (and in strength): its price in the skirmish (a horse counted in the Horseman's; the Brood's
## two-from-an-egg creatures at half an egg each).
const UNIT_VALUE := {"musketeer": 60, "cuirassier": 100, "cannon": 170,
	"clock_soldier": 70, "springer": 100, "pendulum": 200,
	"raptor": 25, "spitter": 45, "brute": 150}
const UNIT_NAME := {"musketeer": "Musketeers", "cuirassier": "Horsemen", "cannon": "Field Cannons",
	"clock_soldier": "Clock Soldiers", "springer": "Springers", "pendulum": "Pendulums",
	"raptor": "Raptors", "spitter": "Spitters", "brute": "Brutes"}
## The army each side starts with at its capital (worth about 1,300 each).
const START_ARMY := {"crown": {"musketeer": 12, "cuirassier": 3, "cannon": 2},
	"clockwork": {"clock_soldier": 12, "springer": 3, "pendulum": 1},
	"brood": {"raptor": 24, "spitter": 8, "brute": 2}}
const ARMY_CAP := 80               # units in one army at most (a fought battle stays playable)

## BUILDINGS: one a region. "muster" = armies are recruited there (and at the capital); "defence" = strength added to
## whoever defends the region; "calm" = unrest taken off every season; "income" = its income x (1 + this).
const BUILDINGS := {
	"crown": [{"id": "fort", "name": "Fort", "cost": 250, "muster": true, "defence": 400, "calm": 6},
		{"id": "church", "name": "Church", "cost": 200, "calm": 20, "income": 0.1},
		{"id": "market", "name": "Market", "cost": 250, "income": 0.5}],
	"clockwork": [{"id": "works", "name": "Works", "cost": 250, "muster": true, "defence": 400},
		{"id": "trade_post", "name": "Trade Post", "cost": 250, "income": 0.4, "trade": true},
		{"id": "regulator", "name": "Regulator", "cost": 200, "calm": 18, "defence": 150}],
	"brood": [{"id": "nest", "name": "Nest", "cost": 250, "muster": true, "defence": 400, "calm": 10},
		{"id": "swamp", "name": "Swamp", "cost": 150, "income": 0.5, "swamp": true}],
}
const TRADE_LINK := 0.1            # a Trade Post's income +10% for each neighbouring (land or sea) Trade Post of its side

## INCOME a season: a region's worth x 50, times how well the side lives there (the climate), all summed and then
## bent: total = raw x K / (raw + K) (the more land, the less each new land adds: anti-snowball).
const WORTH_GOLD := 50
const INCOME_K := 1800.0
const BIOME_INCOME := {
	"crown": {"temperate": 1.0, "wet": 1.0, "cold": 0.85, "desert": 0.75, "jungle": 0.6},
	"clockwork": {"temperate": 1.0, "wet": 0.6, "cold": 1.0, "desert": 0.8, "jungle": 0.5},
	"brood": {"temperate": 0.9, "wet": 1.0, "cold": 0.0, "desert": 0.8, "jungle": 1.0},
}
const UPKEEP := 0.08               # an army costs 8% of its worth a season (veterans 2% more a rank)
const UPKEEP_SIDE := {"clockwork": 0.08}    # (the Clockwork must be wound: 9%)
const UPKEEP_VET := 0.02
const FAR_HOPS := 3                # regions more than 3 steps from the capital cost FAR_GOLD a season for each step more
const FAR_GOLD := 15
const SEA_HOP := 2                 # a sea lane counts as 2 steps from the capital (for far lands' upkeep and unrest)
## SUPPLY LINES: an army fights at x (1 - SUPPLY_STEP a step from its capital past SUPPLY_FROM), at least SUPPLY_FLOOR.
const SUPPLY_STEP := 0.05
const SUPPLY_FROM := 3
const SUPPLY_FLOOR := 0.7
const DEBT_LOSS := 0.15            # a side that can't pay its armies loses 15% of every army that season

## CLIMATE: an army that ends its side's turn in a region of this biome loses this share (rust, cold).
const ATTRITION := {
	"clockwork": {"wet": 0.10, "jungle": 0.10},       # the Clockwork RUSTS in the wet
	"brood": {"cold": 0.30},                           # the Brood can't live in the cold (winter: x1.5)
}
const WINTER_COLD := 1.5
const SEA_LOSS := {"clockwork": 0.05, "brood": 0.1}   # an army loses this at each sea crossing (the Clockwork rusts, the Brood dies in the holds)
const STORM := 0.10                # a sea crossing meets a storm one time in ten...
const STORM_LOSS := 0.20           # ...and loses a fifth of the army
## MENDING: an army on its side's capital or a region with one of these buildings gets back 10% a season (up to the
## most it ever had): the Crown raises its own (a Church, a Fort), the Clockwork's Winders mend (a Works), the Brood
## lays again (a Nest, a Swamp).
const MEND := 0.10
const MEND_AT := {"crown": ["church", "fort"], "clockwork": ["works"], "brood": ["nest", "swamp"]}

## UNREST (0-100) in a held region (never the capital): it grows with distance from the capital (4 a step past 2) and
## in a climate the side hates (8), falls with an army there (8), a calming building and by 4 a season by itself.
## From 40 up a region may REBEL: the chance a season is (unrest - 40) / 120; it becomes free land again.
const UNREST_FAR := 4.0
const SEATS := true               # ...counted from the nearest SEAT (the capital or a muster building), not only the capital
const UNREST_CLIMATE := 8.0
const UNREST_ARMY := 8.0
const UNREST_FALL := 4.0
const UNREST_SIZE := 0.5           # an empire stretched thin: +0.5 a season in every region for each region held past 6
const UNREST_SIZE_FROM := 6
const REBEL_FROM := 40.0
const REBEL_DIV := 120.0
const HATED := {"crown": ["jungle", "desert"], "clockwork": ["wet", "jungle"], "brood": ["cold"]}

## BATTLES (auto-resolve): strength = the army's worth x (1 + 0.1 a veteran rank) x 1.1 with a hero; the defender adds
## the region's guard (its worth x 100, free lands x 250 + 150), its building's defence, a capital 1,500, and x1.2
## (defender's advantage; a capital x1.35); the climate: the Brood x1.15 in jungle and wet, x0.75 in the cold; the
## Clockwork x0.85 in the wet. Each side then x a roll of 0.85-1.15. The stronger wins; it loses
## 0.05 + 0.55 x (weaker / stronger)^2 of its army; the loser's army loses 60% and falls back to a free neighbouring
## region of its own (the one it came from, for an attacker), or is lost.
const VET_STEP := 0.1
const VET_MAX := 3
## ONE SIDE AGAINST ANOTHER: an army of VS[side][enemy] fights at this against that enemy's armies (the Brood's creatures
## hunt men: x1.25 against the Crown, x1.05 against the Clockwork's automata). The guard of a region is not touched.
const VS := {"brood": {"crown": 1.25, "clockwork": 1.05}}
const HERO_BONUS := 1.1
const GUARD := 250
const FREE_GUARD := 180
const FREE_GUARD_BASE := 150
const CAPITAL_GUARD := 1500
const CAPITAL_FADE := 40.0         # ...that fades: x (1 - season / 40), never under 40% (defender's advantage early, a winner can finish)
const CAPITAL_FLOOR := 0.4
## THE SPOILS: the side that takes a capital takes the fallen side's other lands too (unrest SPOILS_UNREST in each).
const SPOILS := false
const SPOILS_UNREST := 35.0
const DEFEND := 1.2
const DEFEND_CAPITAL := 1.35
const LUCK := 0.15
const LOSER_LOSS := 0.6
const WIN_LOSS_BASE := 0.05       # the winner loses WIN_LOSS_BASE + WIN_LOSS_K x (weaker / stronger)^2
const WIN_LOSS_K := 0.55
const FREE_LOSS := 0.5             # ...times this against a free land's militia (no army there)
const BIOME_FIGHT := {"crown": {"temperate": 1.05}, "brood": {"jungle": 1.15, "wet": 1.1, "temperate": 1.0, "desert": 0.95, "cold": 0.75}, "clockwork": {"temperate": 1.05, "wet": 0.85, "jungle": 0.85}}

## HEROES (optional, the setup's STORY HEROES): story generals, each with one army; +10% strength and a gift.
## A hero whose army is destroyed is wounded, never killed: back at the capital after 2 seasons. The Brood has none
## (it is no person): its armies grow back in its own swamps and nests instead (MEND), and its raptors are cheap.
const HEROES := {
	"crown": [{"id": "fairleigh", "name": "Lord Fairleigh", "gift": "Never falls back in disorder: loses only half as much when beaten."},
		{"id": "ruggieri", "name": "Captain Ruggieri", "gift": "His guns: +15% more when attacking a region with a building or a capital."},
		{"id": "valadares", "name": "Lieutenant Valadares", "gift": "Knows the sea and the jungle: no storms, no jungle penalty, +10% in the jungle."}],
	"clockwork": [{"id": "hollweg", "name": "Meister Hollweg", "gift": "His army never rusts, at sea or in the wet."}],
}
const HERO_BACK := 2

## WINNING: "capitals" = the last side holding its capital; "keys" = hold KEYS_NEEDED of the 15 key regions at the
## end of a season (or be the last). In every war, once the LAST SEASON is reached (the setup's choice, 48 = twelve
## years by default; 0 = none) the side with the most worth of land wins. "seasons" = only that.
const WIN_KINDS := ["capitals", "keys", "seasons"]
const KEYS_NEEDED := 8
const SEASON_LIMIT := 48
const SEASON_CHOICES := [24, 48, 80, 0]

const LEVELS := ["easy", "normal", "hard"]
const AI_MARGIN := {"easy": 1.6, "normal": 1.25, "hard": 1.05}
const AI_INCOME := {"easy": 0.9, "normal": 1.0, "hard": 1.1}
## The computer raises soldiers until its armies are worth AI_WANT_BASE + AI_WANT_REGION for each region it holds; it
## prefers to attack the side with the most land (+AI_LEADER to a target's score: everyone's first enemy).
const AI_WANT_BASE := 1400.0
const AI_WANT_REGION := 260.0
const AI_LEADER := 3.0
const AI_BUILD_AT := 0.7           # it builds once its armies reach this share of what it wants (then raises the rest)
const AI_LEADER_REAL := true       # ...only while that side really holds more land than the one choosing
## THE COALITION: while the leader holds AI_TRUCE_GAP times the land of another side, a third side's attack on that one
## scores AI_TRUCE less (they leave each other be and turn on the leader; its capital is still fair game).
const AI_TRUCE := 8.0
const AI_TRUCE_GAP := 1.1
const AI_CAPITAL_MARGIN := 1.0    # ...and a capital at this times its margin (it dares more for a capital)
const AI_MARCH := 2500.0           # THE MARCH ON A CAPITAL: an army worth this much heads for the nearest enemy capital...
const AI_MARCH_FROM := 12          # ...from this season on
const AI_FAR := 0.4                # an attack's score falls by this for each step from the capital past 3

## SEASONAL EVENTS: at the start of a new season, one time in five.
const EVENTS := ["plague", "council", "storms", "harvest"]
const EVENT_CHANCE := 0.2

## THE RULES' VERSION (docs/world_war_tune.md): 1 = the first numbers (0.38.x, kept in V1), 2 = the tuning pass. A war
## remembers its version (a war saved before the tuning plays on to its end with the old numbers); a new war takes the
## newest. WWWar.num() reads every tuned number through this.
const RULES_VERSION := 2
const V1 := {"SEA_HOP": 1, "SUPPLY_STEP": 0.0, "AI_LEADER_REAL": false, "AI_TRUCE": 0.0, "SEATS": false, "FREE_LOSS": 1.0, "START_TWO": {}, "START_THIRD": {"crown": ["lyon"], "clockwork": [], "brood": []}, "AI_BUILD_AT": 1.0, "VS": {}, "SEA_LOSS": {"clockwork": 0.05}, "AI_MARCH": 999999.0, "ABSENT_GUARD": {}, "GUARD": 100, "FREE_GUARD": 250, "UPKEEP_SIDE": {"clockwork": 0.09},
	"BIOME_FIGHT": {"crown": {"temperate": 1.05}, "brood": {"jungle": 1.15, "wet": 1.1, "temperate": 0.9, "desert": 0.85, "cold": 0.75}, "clockwork": {"wet": 0.85, "jungle": 0.85}},
	"BIOME_INCOME": {"crown": {"temperate": 1.0, "wet": 1.0, "cold": 0.85, "desert": 0.9, "jungle": 0.8},
		"clockwork": {"temperate": 1.0, "wet": 0.6, "cold": 0.8, "desert": 0.8, "jungle": 0.5},
		"brood": {"temperate": 0.75, "wet": 1.0, "cold": 0.0, "desert": 0.6, "jungle": 1.0}},
	"HATED": {"crown": [], "clockwork": ["wet", "jungle"], "brood": ["cold", "desert"]}}

static var _regions := {}
static var _consts := {}
static var _list: Array = []


static func regions() -> Dictionary:
	if _regions.is_empty():
		var f := FileAccess.open(REGIONS, FileAccess.READ)
		var d: Variant = JSON.parse_string(f.get_as_text()) if f else null
		_list = d["regions"] if d is Dictionary else []
		for r in _list:
			_regions[String(r["id"])] = r
	return _regions


static func region_list() -> Array:
	regions()
	return _list


static func region(id: String) -> Dictionary:
	return regions().get(id, {})


static func land_nb(id: String) -> Array:
	return region(id).get("land", [])


static func sea_nb(id: String) -> Array:
	return region(id).get("sea", [])


static func neighbours(id: String) -> Array:
	return land_nb(id) + sea_nb(id)


static func biome(id: String) -> String:
	return String(region(id).get("biome", "temperate"))


static func worth(id: String) -> int:
	return int(region(id).get("worth", 1))


static func is_key(id: String) -> bool:
	return bool(region(id).get("key", false))


static func key_regions() -> Array:
	return region_list().filter(func(r) -> bool: return bool(r.get("key", false))).map(func(r) -> String: return String(r["id"]))


static func regiment(f: String, id: String) -> Dictionary:
	for r in REGIMENTS.get(f, []):
		if String(r["id"]) == id:
			return r
	return {}


static func regiment_cost(r: Dictionary) -> int:
	var c := 0
	for k in r.get("units", {}):
		c += int(UNIT_VALUE.get(k, 0)) * int(r["units"][k])
	return c


static func building(f: String, id: String) -> Dictionary:
	for b in BUILDINGS.get(f, []):
		if String(b["id"]) == id:
			return b
	return {}


static func building_any(id: String) -> Dictionary:
	for f in BUILDINGS:
		var b := building(f, id)
		if not b.is_empty():
			return b
	return {}


static func units_value(units: Dictionary) -> int:
	var v := 0
	for k in units:
		v += int(UNIT_VALUE.get(k, 0)) * int(units[k])
	return v


static func units_count(units: Dictionary) -> int:
	var n := 0
	for k in units:
		n += int(units[k])
	return n


static func season_name(s: int) -> String:
	return "%s %d" % [Loc.t(SEASONS[s % 4]), FIRST_YEAR + s / 4]


static func hero(id: String) -> Dictionary:
	for f in HEROES:
		for h in HEROES[f]:
			if String(h["id"]) == id:
				return h
	return {}


## A rule's base value by name for a rules version (V1's old number for a version-1 war).
static func value(k: String, rv: int) -> Variant:
	if rv < 2 and V1.has(k):
		return V1[k]
	if _consts.is_empty():
		_consts = (WWRules as Script).get_script_constant_map()
	return _consts.get(k, null)


## A tuning override from a setup: a dictionary as is, or text "NAME:1.2,BIOME_INCOME.brood.temperate:0.9,COALITION:0"
## (the simulation's tune= argument). "v1" alone plays the first numbers (see WWWar.make's "rv").
static func parse_tune(t: Variant) -> Dictionary:
	if t is Dictionary:
		return (t as Dictionary).duplicate()
	var out := {}
	for part in String(t).split(",", false):
		var kv := part.split(":")
		if kv.size() == 2:
			out[kv[0]] = float(kv[1])
	return out
