extends RefCounted
class_name AICwLate
## THE CLOCKWORK COMPUTER'S LATE GAME (job clockwork-late-macro, docs/clockwork_late_macro.md). The owner, 2026-11-27:
## "Why does the Clockwork stop expanding?" In the 30 Crown v Clockwork games of 2026-11-26 the Clockwork lost its halls
## from 15:00 on while its bank grew (430 cogs at 12:00, 2,800 at 16:00, 6,500 at 20:00) and its supply stayed far under
## 200. Traced (tools/cw_trace.gd): the computer was not waiting on any plan or saving rule. Its FIVE Light Works stood
## with full queues all the late game (the shared rule stops at five: AI._build_up), so the cogs had nowhere to go; it kept
## TWO Mainsprings on five to seven Clocktowers (a new one only when the old ones were fatigued), so Tension sat at 0-80 and
## its one Heavy Works waited on Tension most of the time: the army it remade after each lost fight was Clock Soldiers
## only, at five Works' pace. No balance number changes here: only what the computer builds.
## Parts (each `-- cwlate<name>:off`; `-- cwlate:off` plays as before):
##   works   more Light Works (up to WORKS_MAX) when every one is busy and the bank floats
##   springs a Mainspring by every standing Clocktower with spring life left that has none (any enemy; v the Brood the
##           wr1000 `springs` rule did this already)
##   heavy   a second Heavy Works once three Mainsprings stand and the first one is busy
##   supply  Regulators ahead of need while the bank floats, toward the 200 cap
## The parts KEPT are on by default (KEPT); the rest were measured and left off (the doc says what each did).

const KEPT: Array[String] = ["works", "springs", "heavy", "supply"]
const FROM := 360.0             # (s) none of it before 6:00: the opening and the written builds keep their own pace
const LOOK := 2.0               # (s) a look every this often
const WORKS_MAX := 9            # Light Works at most (the shared rule stops at 5)
const WORKS_BANK := 450         # cogs in the bank before another Works (its 150 and a Clock Soldier or two left over)
const WORKS_BUSY := 2           # a Works with this many queued counts as busy
const HEAVY_MAX := 2
const HEAVY_FROM := 540.0
const HEAVY_SPRINGS := 3        # Mainsprings standing before the second Heavy Works (it needs their Tension)
const HEAVY_BANK := 600
const SPRING_LIFE := 0.3        # a Clocktower with at least this share of its spring life still wants a Mainspring
const SUP_BANK := 500           # cogs in the bank before Regulators go up ahead of need
const SUP_AHEAD := 24           # supply kept free ahead (the shared margin: 4 + halls + 3 a Works, met only when tight)
const SUP_RICH := 1200          # with this much banked: two Regulators at once, whatever the margin, to the cap

static var _args: PackedStringArray = OS.get_cmdline_user_args()
static var _next := {}          # ai -> next look
static var notes := {}            # ai -> [[clock, part, text]] (tests, the study)


static func on(name: String) -> bool:
	if _args.has("cwlate:off") or _args.has("cwlate%s:off" % name):
		return false
	return KEPT.has(name) or _args.has("cwlate%s:on" % name)


static func _note(ai, part: String, s: String) -> void:
	if not notes.has(ai):
		notes[ai] = []
	(notes[ai] as Array).append([ai.game.clock, part, s])
	if ai.game.mlog:
		ai.game.mlog.add("%s %s [cwlate%s]" % [ai.game.mlog.who(ai.team), s, part])


## Called from AIClockwork._build_up once the opening build is over (Normal and up, gear mode).
static func tick(ai) -> void:
	if ai == null or ai.difficulty < 1 or not Defs.gear_mode or ai.game.faction_of(ai.team) != "clockwork":
		return
	var g = ai.game
	if g.clock < FROM or g.clock < float(_next.get(ai, 0.0)):
		return
	_next[ai] = g.clock + LOOK
	if on("springs"):
		_springs(ai)
	if on("supply"):
		_supply(ai)
	if on("works"):
		_works(ai)
	if on("heavy"):
		_heavy(ai)


## The bank the hall plan and the tech's saving do not hold back.
static func _spare(ai) -> int:
	var gold: int = ai._gold()
	if ai._keeping():
		gold -= ai._hall_keep()
	gold -= int(ai._reserve)        # (the tech's and the heavy machines' saved cogs: the Heavy Works, a Mainspring, the Escapement)
	return gold


static func _works(ai) -> void:
	var kind: String = ai._works()
	var ws: Array = ai._mine(kind)
	if ws.is_empty() or ws.size() >= WORKS_MAX or ai._busy_building(kind):
		return
	for w in ws:
		if not w.built or (w.queue as Array).size() < WORKS_BUSY:
			return          # (a Works with room in its queue: the bank goes there first)
	if _spare(ai) < WORKS_BANK:
		return
	if ai.game.supply_used(ai.team) >= int(ai.game.players[ai.team]["cap"]) - 4:
		return              # (supply-blocked: the queues are full for want of supply, not of Works: the Regulators first)
	ai._construct(kind)
	if ai._busy_building(kind):
		_note(ai, "works", "lays Light Works %d: every one busy, %d cogs banked" % [ws.size() + 1, ai._gold()])


static func _springs(ai) -> void:
	if not ai._spring_ok() or ai._busy_building("mainspring"):
		return
	var g = ai.game
	var cost := int(Defs.BUILDINGS["mainspring"]["cost"])
	if _spare(ai) < cost + 20:
		return
	var drawn := {}
	for sp in ai._mine("mainspring"):
		var h = g.soil_hall(sp)
		if h != null:
			drawn[h] = true
	for h in ai._halls():
		if not h.built or drawn.has(h) or h.soil_left() < SPRING_LIFE or ai._enemy_near(h.center(), 360.0):
			continue
		var c: Vector2i = GearEcon.room_spot(g, ai.team, "mainspring", [h])
		if c.x < 0:
			continue
		ai._construct("mainspring", c)
		if ai._busy_building("mainspring"):
			_note(ai, "springs", "builds a Mainspring by a Clocktower that had none (%d standing)" % ai._mine("mainspring").size())
		return


static func _heavy(ai) -> void:
	var g = ai.game
	var hk: String = Defs.CW_HEAVY
	var hs: Array = ai._mine(hk)
	if g.clock < HEAVY_FROM or hs.is_empty() or hs.size() >= HEAVY_MAX or ai._busy_building(hk):
		return
	var springs: int = ai._mine("mainspring").filter(func(b) -> bool: return b.built and not b.fatigued()).size()
	if springs < HEAVY_SPRINGS:
		return
	for h in hs:
		if not h.built or (h.queue as Array).is_empty():
			return
	if _spare(ai) < HEAVY_BANK:
		return
	var c: Vector2i = ai._heavy_spot()
	if c.x < 0:
		return
	ai._construct(hk, c)
	if ai._busy_building(hk):
		_note(ai, "heavy", "lays a second Heavy Works (%d Mainsprings winding)" % springs)


static func _supply(ai) -> void:
	var g = ai.game
	var cap: int = g.players[ai.team]["cap"]
	if cap >= g.max_supply(ai.team):
		return
	var spare := _spare(ai)
	if spare < SUP_BANK:
		return
	var sup: String = ai._sup()
	var going: int = ai._mine(sup).filter(func(b) -> bool: return not b.built).size()
	var free: int = cap + going * int(Defs.BUILDINGS[sup]["supply"]) - g.supply_used(ai.team)
	var rich := spare >= SUP_RICH
	if going >= (2 if rich else 1):
		return
	if free >= SUP_AHEAD and not rich:
		return
	if cap + going * int(Defs.BUILDINGS[sup]["supply"]) >= g.max_supply(ai.team):
		return
	ai._construct(sup)
	if ai._mine(sup).filter(func(b) -> bool: return not b.built).size() > going:
		_note(ai, "supply", "a Regulator ahead of need (%d/%d, %d cogs)" % [g.supply_used(ai.team), cap, ai._gold()])
