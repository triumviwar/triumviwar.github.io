class_name ColourAccess
## COLOUR-BLIND HELP (job ui-access-phone, docs/ui_access_phone.md; Settings > DISPLAY > COLOUR-BLIND HELP).
## Settings.cb_mode: 0 OFF (the game's own colours, untouched), 1 RED-GREEN (protanopia / deuteranopia, the common
## ones), 2 BLUE-YELLOW (tritanopia). The 8 team colours (Defs.PALETTE, by index: a player's colour keeps its slot)
## are shown as another set, picked so two are told apart under that kind of colour blindness
## (tools/ui_access/cb_check.py measures them); the factions' map colours (world war, the war map's territory) the
## same way; health bars take a second cue (blue / yellow / orange, and stripes when low).
## Only what is SHOWN changes: saves, replays, online rooms and the computers keep the colour indexes.

const RED_GREEN := [
	["Blue", "#2a64ff"], ["Orange", "#ff9a1a"], ["White", "#f0f0f0"], ["Brown", "#6b4a1c"],
	["Pink", "#e060c0"], ["Yellow", "#fff04a"], ["Sky", "#7fd8ff"], ["Black", "#383848"],
]
const BLUE_YELLOW := [
	["Blue", "#3a86ff"], ["Red", "#e02828"], ["White", "#f2f2f2"], ["Amber", "#ffb000"],
	["Black", "#383848"], ["Brown", "#8a5a2a"], ["Cyan", "#3ae0e0"], ["Magenta", "#d040b0"],
]
## The three factions on the maps (WWRules.COLOUR keys): red-green puts the machine orange and the Brood sky blue;
## blue-yellow keeps the game's own (purple, red, green are told apart there).
const FACTION_RG := {"crown": Color("#7b4bb8"), "clockwork": Color("#e08a1a"), "brood": Color("#4ab0e8")}
const FACTION_BASE := {"crown": Color("#7b4bb8"), "clockwork": Color("#c0392b"), "brood": Color("#3f9c3a")}

const MODES := ["OFF", "RED-GREEN", "BLUE-YELLOW"]

static var _cache := {}


static func mode() -> int:
	return Settings.cb_mode


static func _shown_set() -> Array:
	match mode():
		1:
			return RED_GREEN
		2:
			return BLUE_YELLOW
	return []


## The team colour shown for palette slot `i` (Defs.PALETTE's colour when OFF).
static func team(i: int) -> Color:
	var s := _shown_set()
	if s.is_empty() or i < 0 or i >= s.size():
		return Defs.PALETTE[i][1] if i >= 0 and i < Defs.PALETTE.size() else Color.RED
	var k := "%d|%d" % [mode(), i]
	if not _cache.has(k):
		_cache[k] = Color(String(s[i][1]))
	return _cache[k]


## Its name as shown ("Orange" for the RED slot under RED-GREEN).
static func team_name(i: int) -> String:
	var s := _shown_set()
	if s.is_empty() or i < 0 or i >= s.size():
		return Defs.PALETTE[i][0] if i >= 0 and i < Defs.PALETTE.size() else ""
	return String(s[i][0])


## A faction's map colour (`c` = the colour the game would draw, a shade of FACTION_BASE[f]): the same shade of the
## colour-blind one. Unknown factions and OFF: `c` as it is.
static func faction(f: String, c: Color) -> Color:
	if mode() != 1 or not FACTION_RG.has(f):
		return c
	return shade(c, FACTION_BASE[f], FACTION_RG[f])


## `c` is a shade of `base` (lighter, darker, see-through): the same shade of `to`.
static func shade(c: Color, base: Color, to: Color) -> Color:
	var vk := c.v / maxf(base.v, 0.01)
	var sk := c.s / maxf(base.s, 0.01)
	return Color.from_hsv(to.h, clampf(to.s * sk, 0.0, 1.0), clampf(to.v * vk, 0.0, 1.0), c.a)


## The war map's holders (WarMap.SKINS "holders"): machine and Brood remapped like the factions.
const HOLDER_FACTION := {"machine": "clockwork", "brood": "brood", "unrest": "brood"}
static func holder(h: String, c: Color) -> Color:
	if mode() != 1 or not HOLDER_FACTION.has(h):
		return c
	var f: String = HOLDER_FACTION[h]
	return shade(c, FACTION_BASE[f], FACTION_RG[f])


## THE HEALTH BAR's colour at share `f` (over half, a quarter, below): green / yellow / red as the game had it; with
## colour-blind help on, blue / yellow / orange-red: three brightnesses as well as three hues. `a`: its alpha.
static func hp(f: float, a := 1.0) -> Color:
	if mode() == 0:
		return Color(0.3, 0.9, 0.3, a) if f > 0.5 else (Color(0.95, 0.8, 0.2, a) if f > 0.25 else Color(0.95, 0.3, 0.2, a))
	return Color(0.35, 0.7, 1.0, a) if f > 0.5 else (Color(1.0, 0.88, 0.3, a) if f > 0.25 else Color(1.0, 0.42, 0.1, a))


## Two-step bars (the HUD's small portrait bars: healthy / hurt).
static func hp2(f: float) -> Color:
	if mode() == 0:
		return Color(0.3, 0.9, 0.3) if f > 0.5 else Color(0.95, 0.4, 0.2)
	return Color(0.35, 0.7, 1.0) if f > 0.5 else Color(1.0, 0.42, 0.1)


## The second cue: a low bar (a quarter or less) gets dark slanted stripes over its fill, so "about to die" reads
## without the colour. Drawn only with colour-blind help on (OFF: the game as it was).
static func low_stripes(ci: CanvasItem, fill: Rect2, f: float, a := 1.0) -> void:
	if mode() == 0 or f > 0.25 or fill.size.x < 2.0 or fill.size.y < 2.0:
		return
	var step := 4.0
	var x := fill.position.x
	var pts := PackedVector2Array()
	while x < fill.end.x:
		var x2 := minf(x + fill.size.y, fill.end.x)
		pts.append(Vector2(x, fill.end.y))
		pts.append(Vector2(x2, fill.end.y - (x2 - x)))
		x += step
	ci.draw_multiline(pts, Color(0, 0, 0, 0.55 * a), 1.0)


## (a setting changed)
static func changed() -> void:
	_cache.clear()
