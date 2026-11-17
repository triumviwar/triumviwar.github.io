class_name AICrownGuns
extends RefCounted
## THE CROWN'S GUNS AND LINE, COACHED (crown-guns-coach, the owner 2026-11-15 22:20 / 2026-11-16 23:25: "focus on wall
## making and microing the army, screening with Horsemen, setting cannon before the engagement is very important, it doesn't
## help if the enemy is on top of you and the cannon is still unlimbering, that is why Horseman screening is so important";
## docs/crown_guns_coach.md). The Crown computer's FIGHTING only (no unit, price or rule number changed):
##  1. THE LINE KEEPS ITS GUNS (`gkeep:off`): the guns the line placed are the line's while it stands (forming, stepping,
##     holding, fighting, falling back): the wave's shared order loop no longer sends a gun of the line on toward the enemy's
##     base. It did every think the line handed back (a fight, or a held line waiting by its guns): an idle gun, set up or
##     setting up but with no target yet, got an attack-move on, limbered again and rolled after the wave (filmed Highmoor
##     1104 7:21 and 10:43: three guns limbered behind a formed line, the enemy 350 px off).
##  2. (more rules below as the coaching finds them)
## Plus THE COUNT (read only, always on): every fight of the Crown's army (an armed enemy within CONTACT of one of its
## soldiers after QUIET s of none there), its guns near it, how many stood set up at contact and how many fired in its first
## FIRST s, whether it began formed, and what it killed and lost (result.json "crown_ai" via tools/qa_match.gd).
## Design: docs/design_principles.md 1 (the computer plays the player's own tools well, nothing it could not do by hand), 4
## (battles that carry the weight of the match). Switch `gunscoach:off` (all of it but the count).

const CONTACT := 260.0          # (px) an armed enemy this near a Crown soldier: a fight
const QUIET := 20.0             # (s) no contact there this long: the fight is over
const SAME := 1200.0            # (px) contact this near the fight's place is the same fight
const NEAR_GUN := 1000.0        # (px) a Crown gun this near the fight's place is one of its guns
const FIRST := 10.0             # (s) the guns firing in a fight's first FIRST s
const EVERY := 0.5              # (s) between two counts

var ai = null
var game: Game = null
var _args := OS.get_cmdline_user_args()
var off := _args.has("gunscoach:off")
var keep_on := not off and not _args.has("gkeep:off")

# THE COUNT
var fights: Array = []          # [t0, home, formed, guns, set_at_contact, fired_first, killed, lost, x, y] per fight
var _cur := {}                  # the fight on: t0, p, last, guns, set, k0, l0, formed, home, done_first, fired
var _next := 0.0
var kept := 0                   # (tests) times the shared loop was kept off a line gun


func _init(owner) -> void:
	ai = owner
	game = owner.game


func _say(s: String) -> void:
	if game.mlog:
		game.mlog.add("%s%s" % [game.mlog.who(ai.team), s])


static func _mmss(c: float) -> String:
	return "%d:%02d" % [int(c) / 60, int(c) % 60]


# ------------------------------------------------------------------ 1. the line keeps its guns

## The wave's shared loop asks before it sends a man on: true = leave him be (a gun of the line while the line stands).
func keeps(u: Unit) -> bool:
	if not keep_on or ai.ln == null or not ai.ln.active():
		return false
	if not AICrownLine.is_gun(u) or ai.ln.st == "":
		return false
	if not ai.ln._spot.has(u):
		return false
	kept += 1
	return true


# ------------------------------------------------------------------ the count

func tick() -> void:
	if game.clock < _next:
		return
	_next = game.clock + EVERY
	var army: Array = game.army(ai.team)
	var hit := Vector2.INF
	var hit_d := INF
	for u in army:
		if u.dead or u.off_field or u.is_worker() or not u.has_attack() or u.is_air() or u.aboard != null:
			continue
		if AICrownLine.is_gun(u):
			continue
		for o in game.units_near(u.position, CONTACT):
			if o.dead or o.off_field or not game.hostile(o.team, ai.team) or o.is_worker() or not o.has_attack():
				continue
			if not game.is_visible_to(ai.team, o.position):
				continue
			var d: float = 0.0 if _cur.is_empty() else (o.position as Vector2).distance_to(_cur["p"])
			if d < hit_d:
				hit_d = d
				hit = (u.position + o.position) * 0.5
			break
	if not _cur.is_empty():
		if hit != Vector2.INF and hit_d < SAME:
			_cur["last"] = game.clock
		if not _cur["done_first"] and game.clock - float(_cur["t0"]) >= FIRST:
			_cur["done_first"] = true
			var f := 0
			for gun in _cur["guns"]:
				if is_instance_valid(gun) and float(gun.fired_t) >= float(_cur["t0"]) - 0.5:
					f += 1
			_cur["fired"] = f
		if game.clock - float(_cur["last"]) > QUIET:
			_end()
		elif hit != Vector2.INF and hit_d >= SAME:
			_end()
	if _cur.is_empty() and hit != Vector2.INF:
		_begin(hit, army)


func _begin(p: Vector2, army: Array) -> void:
	var guns: Array = []
	var set_n := 0
	for u in army:
		if u.dead or u.off_field or u.aboard != null or not AICrownLine.is_gun(u):
			continue
		if u.position.distance_to(p) < NEAR_GUN:
			guns.append(u)
			if u.tesla_mode == "deployed":
				set_n += 1
	var home := false
	for h in ai._halls():
		if h.center().distance_to(p) < 900.0:
			home = true
			break
	var formed := false
	if ai.ln != null:
		formed = ai.ln.st in ["form", "step", "set", "await", "advance", "back"] or not ai.ln._def_spot.is_empty()
	_cur = {"t0": game.clock, "p": p, "last": game.clock, "guns": guns, "set": set_n, "home": home, "formed": formed,
		"k0": float(game.stats[ai.team]["value_killed"]), "l0": float(ai._lost_value()), "done_first": false, "fired": 0}


func _end() -> void:
	var k: float = float(game.stats[ai.team]["value_killed"]) - float(_cur["k0"])
	var l: float = float(ai._lost_value()) - float(_cur["l0"])
	if not _cur["done_first"]:
		var f := 0
		for gun in _cur["guns"]:
			if is_instance_valid(gun) and float(gun.fired_t) >= float(_cur["t0"]) - 0.5 and float(gun.fired_t) <= float(_cur["t0"]) + FIRST:
				f += 1
		_cur["fired"] = f
	if k + l >= 60.0:           # (a skirmish worth nothing is not a fight)
		var p: Vector2 = _cur["p"]
		fights.append([snappedf(float(_cur["t0"]), 0.1), _cur["home"], _cur["formed"], (_cur["guns"] as Array).size(),
				_cur["set"], _cur["fired"], int(k), int(l), int(p.x), int(p.y)])
		_say("'s fight at %s %s (%s): %d gun%s near, %d set at contact, %d fired in its first %d s; killed %d, lost %d" % [
			_mmss(float(_cur["t0"])), "at home" if _cur["home"] else "out", "formed" if _cur["formed"] else "unformed",
			(_cur["guns"] as Array).size(), "" if (_cur["guns"] as Array).size() == 1 else "s", _cur["set"], _cur["fired"],
			int(FIRST), int(k), int(l)])
	_cur = {}


## The count so far (tools/qa_match.gd "crown_ai").
func counters() -> Dictionary:
	if not _cur.is_empty():
		_end()
	var o := {"fights": fights.duplicate(), "kept": kept}
	var n := 0
	var withg := 0
	var fired := 0
	var formed := 0
	for f in fights:
		n += 1
		if int(f[3]) > 0:
			withg += 1
			if int(f[5]) > 0:
				fired += 1
		if f[2]:
			formed += 1
	o["n"] = n
	o["with_guns"] = withg
	o["guns_fired"] = fired
	o["formed"] = formed
	return o
