class_name MissionHeroes
extends RefCounted
## THE STORY'S PEOPLE WHO MUST LIVE ARE PROTECTED (campaign-fixes-1121, the owner 2026-11-21: "yes"; docs/campaign_fixes_1121.md).
## Lord Fairleigh, Father Tomasz, Meister Hollweg, Father Ferrer, Lindqvist, Valadares, the young King...: a mission's
## must-live people (the units a PRIMARY "protect" objective names, and the mission's own "heroes": [tags]) can't be
## killed by ordinary damage. At a fifth of their health they are WOUNDED: nothing hurts them or aims at them, they
## fall back to their side's nearest building (else where they started), out of the fight, and get their health back
## slowly; at RECOVER they are themselves again. A mission whose story needs a death lists the tag in "mortal".
## Not protected: the Brood's creatures (the Mothers and Sires are the Brood's buildings and army, not people), a hero
## an enemy PERSON hunts (a mirror side played solo, or VERSUS: then the hero is the prey, as written).
## Also (the owner): a protected man is left out of ARMY (F2) and a protected Missionary tends only the wounded close
## by (Father Tomasz walked alone into the fight in Paris). Kept apart from MissionRun to keep its changes small: it
## calls tick() and nothing else.

const WOUND_AT := 0.2          # a share of his health: under it he is wounded (his floor while protected)
const RECOVER := 0.6           # back in the fight once healed to this share
const HEAL := 0.01             # a share of his health back a second while wounded
const FIND_EVERY := 1.0        # seconds between looks for new heroes (one may come later, from a trigger)
const REORDER := 2.0           # seconds between "fall back" orders while wounded

var run: MissionRun
var heroes: Array = []         # [Unit, start position]
var wounded := {}              # Unit -> the game clock of the last fall back order
var _find_t := 0.0
var wounds := 0                # how often a hero was wounded (tests, the match log)


func _init(r: MissionRun) -> void:
	run = r


## The tags whose men are the mission's heroes.
func hero_tags() -> Array:
	var out: Array = []
	for o in run.data.get("objectives", []):
		if String(o.get("kind", "")) == "protect" and bool(o.get("primary", true)) and o.has("tag"):
			out.append(String(o["tag"]))
	for t in run.data.get("heroes", []):
		if not out.has(String(t)):
			out.append(String(t))
	for t in run.data.get("mortal", []):
		out.erase(String(t))
	return out


## Is he protected in this game? Not a creature, not a man an enemy person hunts.
func protects(u: Unit) -> bool:
	if u == null or u.dead or u._k_nb:
		return false
	for pt in run.player_teams:
		if run.game.hostile(int(pt), u.team):
			return false
	return true


func tick(dt: float) -> void:
	_find_t -= dt
	if _find_t <= 0.0:
		_find_t = FIND_EVERY
		_find()
	var g := run.game
	for it in heroes:
		if not is_instance_valid(it[0]):
			continue          # (d06: a hero taken off the map by an exit: Lindqvist in his canoe)
		var u: Unit = it[0]
		if u.dead:
			continue
		if wounded.has(u):
			u.hp = minf(u.max_hp, u.hp + u.max_hp * HEAL * dt)
			if u.hp >= u.max_hp * RECOVER:
				_recover(u)
			elif g.clock - float(wounded[u]) >= REORDER:
				wounded[u] = g.clock
				_fall_back(u, it[1])
		elif u.hp <= u.max_hp * WOUND_AT + 0.5:
			_wound(u, it[1])


func _find() -> void:
	var known := {}
	for it in heroes:
		known[it[0]] = true
	for tg in hero_tags():
		for e in run.tagged(tg):
			if e is Unit and not known.has(e) and protects(e):
				heroes.append([e, e.position])
				known[e] = true
				e.set_meta("story_hero", true)
				e.hp_floor = maxf(e.hp_floor, e.max_hp * WOUND_AT)


func _wound(u: Unit, home: Vector2) -> void:
	wounds += 1
	wounded[u] = run.game.clock
	u.spared = true                        # (nothing hurts him and nobody aims at him while he falls back)
	u.set_meta("mission_wounded", true)
	u.target = null
	_fall_back(u, home)
	if u.team == run.game.human or run.game.allied(u.team, run.game.human):
		var nm := Loc.t(String(u.get_meta("mission_name", ""))) if u.has_meta("mission_name") else Loc.t("A hero")
		run.game.notify(Loc.t("%s is wounded and falls back.") % nm)
	run.note("wounded")


func _recover(u: Unit) -> void:
	wounded.erase(u)
	u.spared = false
	u.remove_meta("mission_wounded")
	u.cmd_stop()


## Back to his side's nearest building with no enemy close to it (else where he started).
func _fall_back(u: Unit, home: Vector2) -> void:
	var g := run.game
	var best := home
	var bd := INF
	var sd := run.side_of_team(u.team)
	for b in g.buildings:
		if b.dead or b.ghost or run.side_of_team(b.team) != sd:
			continue
		if g.near_enemy_building(u.team, b.global_position, 6) or _foes_near(b.global_position, 8 * Defs.TILE, u.team):
			continue
		var d := u.position.distance_to(b.global_position)
		if d < bd:
			bd = d
			best = b.global_position + Vector2(0, Defs.TILE * 2)
	if u.position.distance_to(best) > Defs.TILE * 2:
		u.cmd_move(best)


func _foes_near(p: Vector2, r: float, t: int) -> bool:
	for e in run.game.units_near(p, r):
		if not e.dead and run.game.hostile(e.team, t) and not e.is_worker():
			return true
	return false
