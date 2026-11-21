extends SceneTree
## A whole skirmish played as the Clockwork by a "human" (job playtest-skirmish-clockwork): from the main menu, through
## the skirmish page, then a build order and an army, by real mouse, key and touch input only (cw_input / cw_player).
## It writes what it did and every refusal and oddity to the console ("PT ..." lines) and pictures to out=.
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --resolution 1280x720 \
##       --script res://tools/playtest/cw_match.gd -- out=DIR foe=CROWN who="HARD AI" plan=OPTIMAL map="GREENHOLD" \
##       style=careful|fast|phone speed=3 minutes=20 [lang=pt] [phone]
## (phone: run with --resolution 844x390; style=phone taps.)

const IN := preload("res://tools/playtest/cw_input.gd")
const SETUP := preload("res://tools/playtest/cw_setup.gd")
const PLAYER := preload("res://tools/playtest/cw_player.gd")

var io
var main: Node
var g: Game
var p
var last_msg := ""
var next_shot := 30.0
var attacked_at := -1.0
var waves := 0
var done_steps := {}
var start_real := 0
var tried := {}          # what was tried and refused (once each in the log)


func _initialize() -> void:
	_run.call_deferred()


func arg(k: String, d: String) -> String:
	for a in OS.get_cmdline_user_args():
		if a.begins_with(k + "="):
			return a.substr(k.length() + 1)
		if a == k:
			return "1"
	return d


func _process(_d: float) -> bool:
	if g != null and is_instance_valid(g) and g.hud != null:
		var m: String = g.hud._msg
		if m != last_msg and m != "" and g.hud._msg_t > 0.0:
			last_msg = m
			print("PT  TOAST [%s] %s" % [clock(), m])
	return false


func clock() -> String:
	if g == null or not is_instance_valid(g):
		return "-"
	return "%d:%02d" % [int(g.clock) / 60, int(g.clock) % 60]


func _run() -> void:
	io = IN.new(self)
	io.shots_dir = arg("out", "/tmp/claude-0/pt/m")
	DirAccess.make_dir_recursive_absolute(io.shots_dir)
	var style := arg("style", "careful")
	var phone := style == "phone"
	if arg("fresh", "") != "":
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://settings.cfg"))
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await io.frames(10)
	var su = SETUP.new(io, main, phone)
	await su.to_menu()
	if phone and Settings.device != "mobile":
		Settings.set_device("mobile")        # (a phone run on a computer's settings: the device page is only seen once)
		main.show_menu()
		await io.frames(3)
	elif not phone and Settings.device != "pc":
		Settings.set_device("pc")
		main.show_menu()
		await io.frames(3)
	await su.language(arg("lang", "en"))
	await io.shot("menu")
	var cfg := {"foe": arg("foe", "CROWN"), "who": arg("who", "HARD AI"), "plan": arg("plan", "OPTIMAL")}
	if arg("map", "") != "":
		cfg["map"] = arg("map", "")
	await su.skirmish(cfg)
	g = await su.start()
	if g == null:
		quit(1)
		return
	print("PT  MATCH %s v %s %s %s on %s, style %s, %s, lang %s" % ["clockwork", cfg["foe"], cfg["who"], cfg["plan"],
		g.map_name if "map_name" in g else "?", style, io.vs(), Settings.language])
	Engine.time_scale = float(arg("speed", "3"))
	p = PLAYER.new(io, g, style)
	start_real = Time.get_ticks_msec()
	await io.shot("start")
	var minutes := float(arg("minutes", "20"))
	while is_instance_valid(g) and not g.over and g.clock < minutes * 60.0:
		await think()
		if g.clock >= next_shot:
			next_shot += 60.0
			await io.shot("t%d" % int(g.clock))
		await io.frames(2)
	await end_of_match(minutes)
	print("PT  ISSUES %d" % p.issues.size())
	for it in p.issues:
		print("PT  ISSUE-LIST %s | %s" % it)
	Engine.time_scale = 1.0
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	quit(0)


func say(s: String) -> void:
	io.note("[%s] %s" % [clock(), s])


func refused(what: String, why: String) -> void:
	if why == "":
		return
	var k := what + "|" + why.substr(0, 40)
	tried[k] = int(tried.get(k, 0)) + 1
	if int(tried[k]) == 1 or int(tried[k]) % 10 == 0:
		say("REFUSED %s: %s (x%d)" % [what, why, tried[k]])


# ------------------------------------------------------------------ the brain

func hall() -> Building:
	var hs: Array = p.mine("clocktower")
	return hs[0] if not hs.is_empty() else null


func count(kind: String) -> int:
	var n := 0
	for e in g.buildings + g.units:
		if is_instance_valid(e) and not e.dead and e.team == g.human and e.kind == kind:
			n += 1
	return n


func supply_room() -> int:
	return int(g.players[g.human]["cap"]) - g.supply_used(g.human)


func can_pay(kind: String) -> bool:
	var d: Dictionary = Defs.BUILDINGS[kind] if Defs.BUILDINGS.has(kind) else Defs.UNITS[kind]
	return p.cogs() >= int(d.get("cost", 0)) and p.tension() >= float(d.get("tension", 0))


var next_status := 0.0


func think() -> void:
	var h := hall()
	if h == null:
		return
	if g.clock >= next_status:
		next_status = g.clock + 30.0
		var qs: Array = []
		for b in g.buildings:
			if b.team == g.human and not b.dead and not b.queue.is_empty():
				qs.append("%s:%d" % [b.kind, b.queue.size()])
		say("STATUS cogs %d tension %d supply %d/%d winders %d army %d (%d sup) towers %d queues %s" % [p.cogs(), int(p.tension()),
			g.supply_used(g.human), int(g.players[g.human]["cap"]), count("winder"), army_units().size(), army_supply(army_units()),
			p.mine("clocktower").size(), qs])
	await workers_to_work()
	await produce()
	await build_order(h)
	await army()


## Winders that stand idle go to a press or Mainspring with room (a player's routine: F1, then right-click the press).
func workers_to_work() -> void:
	var idle: Array = []
	for u in p.mine("winder"):
		if u.order in ["", "idle"]:
			idle.append(u)
	if idle.is_empty():
		return
	for k in ["mainspring", Defs.GEAR_PRESS]:
		for b in p.mine(k):
			var room: int = b.crew_max() - b.crew.filter(func(x) -> bool: return is_instance_valid(x) and not x.dead).size()
			if room <= 0 or b.barren():
				continue
			var take: Array = idle.slice(0, room)
			if take.is_empty():
				return
			if p.style == "fast":
				# F1 picks every idle worker, then right-click
				await io.key(KEY_F1)
				var p2: Vector2 = await p.look_at(p.where(b))
				await io.rclick(p2)
			else:
				await p.work(take, b)
			say("%d Winder(s) sent to %s (%d/%d)" % [take.size(), b.kind, b.working_crew(), b.crew_max()])
			idle = idle.slice(take.size())
			await io.frames(4)


## What a decent Clockwork player wants standing, by the clock: [kind, from second, how many, big gear]. The counts
## grow with the Clocktowers (presses and Mainsprings are per tower).
func wants() -> Array:
	var towers: int = maxi(1, p.mine("clocktower").size())
	var lws := 2 + int(p.cogs() > 600) + int(g.clock > 420.0) + int(g.clock > 600.0)
	return [
		["mainspring", 25.0, towers, true],
		[Defs.GEAR_PRESS, 50.0, 2 * towers, true],
		["movement_works", 80.0, 1, false],
		["escapement", 140.0, 1, false],
		["movement_works", 150.0, 2, false],
		["clocktower", 270.0, 2, false],
		["movement_works", 240.0, lws, false],
		["heavy_works", 330.0, 1, true],
		["ratchet_turret", 420.0, 1, false],
		["cuckoo_house", 480.0, 1, false],
		["heavy_works", 600.0, 2, true],
		["clocktower", 660.0, 3, false],
	]


func going_up(kind: String) -> bool:
	for b in g.buildings:
		if is_instance_valid(b) and not b.dead and b.team == g.human and b.kind == kind and not b.built:
			return true
	return false


func build_order(h: Building) -> void:
	# supply first
	if supply_room() <= 4 + 2 * p.mine("movement_works").size() and not going_up("regulator") \
			and int(g.players[g.human]["cap"]) < 200 and can_pay("regulator"):
		var why: String = await p.build("regulator", h.center(), false, 6)
		refused("build Regulator", why)
		return
	for st in wants():
		var kind: String = st[0]
		if g.clock < float(st[1]) or count(kind) >= int(st[2]) or going_up(kind):
			continue
		if g.requirement_text(g.human, kind) != "":
			refused("build " + kind, g.requirement_text(g.human, kind))
			continue
		if not can_pay(kind):
			if kind == "clocktower" and p.cogs() < 400:
				return      # (save up for the expansion)
			continue
		var anchor: Vector2 = h.center()
		var rmin := 5
		if kind == "clocktower":
			anchor = expansion_spot()
			rmin = 0
		elif kind in [Defs.GEAR_PRESS, "mainspring"]:
			# next to a Clocktower whose own count is not full
			for t in p.mine("clocktower"):
				if g.econ_full_at(g.human, kind, t.center()) == "":
					anchor = t.center()
					break
		var why: String = await p.build(kind, anchor, bool(st[3]), rmin)
		refused("build " + kind, why)
		if why == "" or p.cogs() < 300:
			return


func expansion_spot() -> Vector2:
	# the gold expansion spots on the ground (ExpansionSpots) are what a player looks at
	var es = g.exp_spots
	if es != null:
		for s in es.shown:
			if int(s.get("team", g.human)) == g.human or not s.has("team"):
				return (Vector2(s["c"]) + Vector2(MapGen.HALL) * 0.5) * Defs.TILE
	return hall().global_position + Vector2(18 * Defs.TILE, 0)


func jobs() -> void:
	pass


func queued(b: Building) -> int:
	return b.queue.size()


func produce() -> void:
	var h := hall()
	# Winders: 2 presses x 5 + 3 on the Mainspring + 2 builders, more with a 2nd Clocktower
	var want: int = 0
	for b in p.mine(Defs.GEAR_PRESS) + p.mine("mainspring"):
		want += b.crew_max()
	want = clampi(want + 2, 8, 50)
	if count("winder") < want and queued(h) < 2 and supply_room() >= 1 and p.cogs() >= 60:
		var why: String = await p.train(h, "WINDER")
		refused("train Winder", why)
	# Light Works: Clock Soldiers, then Springers and Netters
	for lw in p.mine("movement_works"):
		if queued(lw) >= 3 or supply_room() < 2 or p.cogs() < 70:
			continue
		var pick := "CLOCK SOLDIER"
		if has_built("escapement") and p.tension() >= 40:
			pick = ["SPRINGER", "NETTER", "CLOCK SOLDIER"][randi() % 3]
		var why: String = await p.train(lw, pick)
		refused("train " + pick, why)
	for hw in p.mine("heavy_works"):
		if queued(hw) >= 1 or supply_room() < 4:
			continue
		var pick2: String = ["PENDULUM", "PENDULUM", "SPRING BALLISTA", "GREAT WINDER", "BRASS SERPENT"][randi() % 5]
		var why2: String = await p.train(hw, pick2)
		refused("train " + pick2, why2)
	for av in p.mine("cuckoo_house"):
		if queued(av) >= 1 or supply_room() < 2:
			continue
		var why3: String = await p.train(av, "SWIFT")
		refused("train SWIFT", why3)
	for es in p.mine("escapement"):
		if es.queue.size() > 0:
			continue
		for r in ["SHIELD WALL", "HIGH LEAP", "LONG CHAIN"]:
			if tried.has("research " + r) and typeof(tried["research " + r]) == TYPE_BOOL:
				continue
			if not await p.select(es):
				break
			var why4: String = await p.press(r)
			if why4 == "":
				tried["research " + r] = true
				say("research " + r)
				break
			refused("research " + r, why4)


func has_built(k: String) -> bool:
	return not p.mine(k).is_empty()


func army_units() -> Array:
	var out: Array = []
	for u in g.units:
		if is_instance_valid(u) and not u.dead and u.team == g.human and not u.is_worker():
			out.append(u)
	return out


func enemy_target() -> Vector2:
	for b in g.buildings:
		if is_instance_valid(b) and not b.dead and b.team != g.human and b.team >= 0:
			if g.explored.size() > 0:
				return b.global_position
	return Vector2(Game.W, Game.H) * Game.T - hall().global_position


func threat_home() -> Unit:
	var best: Unit = null
	var bd := INF
	for u in g.units:
		if not is_instance_valid(u) or u.dead or u.team == g.human or u.team < 0 or u.is_worker():
			continue
		if not g.is_visible_to(g.human, u.position):
			continue
		for b in g.buildings:
			if is_instance_valid(b) and not b.dead and b.team == g.human:
				var d: float = u.global_position.distance_to(b.center())
				if d < 12 * Defs.TILE and d < bd:
					bd = d
					best = u
	return best


func army_supply(a: Array) -> int:
	var sup := 0
	for u in a:
		sup += int(u.d["supply"])
	return sup


## Where the army waits: in front of the main Clocktower, toward the enemy.
func rally_point() -> Vector2:
	var h := hall()
	var toward := (enemy_target() - h.center()).normalized()
	return h.center() + toward * 9.0 * Defs.TILE


var out := false             # the army is out on an attack
var out_sup := 0
var rallied := {}


func army() -> void:
	var a := army_units()
	# new production buildings rally to the front (select it, right-click the ground)
	for k in ["movement_works", "heavy_works", "cuckoo_house"]:
		for b in p.mine(k):
			if rallied.has(b):
				continue
			rallied[b] = true
			if await p.select(b):
				var rp: Vector2 = await p.look_at(rally_point())
				if p.phone:
					var why: String = await p.press("RALLY")
					refused("RALLY", why)
					await io.tap(rp)
				else:
					await io.rclick(rp)
				say("rally of %s set" % b.kind)
	if a.is_empty():
		return
	var sup := army_supply(a)
	var foe := threat_home()
	if foe != null and (not out or sup < out_sup / 2):
		if attacked_at < 0.0 or g.clock - attacked_at > 12.0:
			attacked_at = g.clock
			out = false
			say("DEFEND: enemy %s by my buildings; army (%d units, %d supply) attack-moves there" % [foe.kind, a.size(), sup])
			await amove_army(foe.global_position, false)
			await shields_up()
		return
	if out:
		if sup < out_sup * 0.45:
			out = false
			attacked_at = g.clock
			say("RETREAT: the wave is down to %d supply of %d" % [sup, out_sup])
			await move_army(rally_point())
		elif g.clock - attacked_at > 25.0:
			attacked_at = g.clock
			await amove_army(enemy_target(), true)
			await shields_up()
		return
	if sup >= 30 + 12 * waves and g.clock - attacked_at > 30.0:
		waves += 1
		attacked_at = g.clock
		out = true
		out_sup = sup
		say("ATTACK wave %d: %d units (%d supply), with Winders to escort" % [waves, a.size(), sup])
		await amove_army(enemy_target(), true)
	elif g.clock - attacked_at > 45.0:
		attacked_at = g.clock
		await move_army(rally_point())


## The Clock Soldiers raise their shields (SHIELD WALL) when the enemy is close.
func shields_up() -> void:
	if not g.has_tech(g.human, "shield_wall"):
		return
	var cs: Array = p.mine("clock_soldier")
	if cs.is_empty():
		return
	if p.phone:
		return
	await io.key(KEY_F2)
	await io.frames(2)
	var why: String = await p.press("SHIELD FORWARD")
	refused("SHIELD FORWARD", why)


func select_army() -> void:
	if p.phone:
		var bar: Rect2 = p.hs(g.hud.bar.rect())
		await io.tap(bar.position + Vector2(bar.size.y * 1.9, bar.size.y * 0.5))
	else:
		await io.key(KEY_F2)
	await io.frames(2)


## F2 (all the army) [+ Shift-click two Winders: they escort], then A and a click on the minimap.
func amove_army(w: Vector2, escort: bool) -> void:
	await select_army()
	if escort and not p.phone:
		var n := 0
		for u in p.mine("winder"):
			if n >= 3:
				break
			if u.off_field or not u.visible or u.work == "manning" or u.order == "build":
				continue
			if await p.select(u, true):
				n += 1
	var m: Rect2 = p.hs(g.hud.mini_rect())
	var mp := m.position + (w / (Vector2(Game.W, Game.H) * Game.T)).clamp(Vector2(0.02, 0.02), Vector2(0.98, 0.98)) * m.size
	if p.phone:
		var why: String = await p.press("ATTACK")
		refused("ATTACK button", why)
		await io.tap(mp)
	else:
		await io.key(KEY_A)
		await io.click(mp)
	await io.frames(2)
	var esc := 0
	for u in p.mine("winder"):
		if u.order == "escort":
			esc += 1
	if escort and esc == 0 and not p.phone:
		refused("escort", "no Winder escorts the army after A + minimap with Winders selected")


func move_army(w: Vector2) -> void:
	await select_army()
	var m: Rect2 = p.hs(g.hud.mini_rect())
	var mp := m.position + (w / (Vector2(Game.W, Game.H) * Game.T)).clamp(Vector2(0.02, 0.02), Vector2(0.98, 0.98)) * m.size
	if p.phone:
		await io.tap(mp)     # (a tap on the minimap with units selected: they move there)
	else:
		await io.rclick(mp)
	await io.frames(2)


func end_of_match(minutes: float) -> void:
	var real := (Time.get_ticks_msec() - start_real) / 1000.0
	var res := "running"
	if g.over:
		res = "WON" if g.winner == g.human or (g.winner >= 0 and g.players[g.winner].get("side", -1) == g.players[g.human].get("side", -2)) else "LOST"
	say("END %s at %s after %.0f real s; army %d, winders %d, buildings %d, cogs %d, tension %d" % [res, clock(), real,
		army_units().size(), count("winder"), p.mine("clocktower").size(), p.cogs(), int(p.tension())])
	await io.shot("end")
