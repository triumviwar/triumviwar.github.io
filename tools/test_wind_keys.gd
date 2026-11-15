extends SceneTree
## The Clockwork army's wind-up keys (docs/wind_keys.md, scripts/wind_key.gd):
## - the table: every strip of every keyed unit but its death strips has a spot per frame, inside its cell, and the key
##   sheets exist with WindKeyData's rows and frames;
## - in a game: each keyed unit carries a key, the Winder, Great Winder, Ballista and Brass Serpent none; it sits at
##   the table's spot of the body's frame; it turns as fast as the wind (a turn per SPIN_T s full, half as fast at half
##   wind) and stands still run down; it is hidden on death and zoomed far out; a west strip shows it mirrored.
##   godot --headless --fixed-fps 30 --script res://tools/test_wind_keys.gd
const U := preload("res://tools/gear_test_util.gd")
const WK := preload("res://scripts/wind_key.gd")
var fails := 0


func check(name: String, ok: bool, detail := "") -> void:
	print("CHECK %-74s %s %s" % [name, "ok" if ok else "FAIL", detail])
	if not ok:
		fails += 1


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	# ---- the table
	for kind in WindKeyData.KEYS:
		var e: Dictionary = WindKeyData.KEYS[kind]
		var art: Dictionary = ArtData.UNITS[kind]
		var cell: Vector2i = art["cell"]
		var missing: Array = []
		var counts: Array = []
		var outside: Array = []
		for strip in art["frames"]:
			if String(strip).begins_with("death_"):
				check("%s %s has no key" % [kind, strip], not e["keys"].has(strip))
				continue
			if not e["keys"].has(strip):
				missing.append(strip)
				continue
			var fr: Array = e["keys"][strip]
			if fr.size() != int(art["frames"][strip]):
				counts.append("%s %d/%d" % [strip, fr.size(), art["frames"][strip]])
			for p in fr:
				if absf(p[2]) > cell.x * 0.5 or p[3] > 0 or -p[3] > cell.y + 50 or int(p[0]) < 0 or int(p[0]) >= WindKeyData.ROWS:
					outside.append(strip)
					break
		check("%s: a spot for every strip" % kind, missing.is_empty(), str(missing))
		check("%s: one spot per frame" % kind, counts.is_empty(), str(counts))
		check("%s: spots on the body (within its cell, a valid view)" % kind, outside.is_empty(), str(outside))
		var tex: Texture2D = load("res://assets/units/_shared/wind_key_%d.png" % int(e["size"]))
		var n: int = WindKeyData.CELL.get(int(e["size"]), 0)
		check("%s: its key sheet (%d px)" % [kind, int(e["size"])], tex != null and n > 0
			and tex.get_width() == n * WindKeyData.FRAMES and tex.get_height() == n * WindKeyData.ROWS)
	# ---- in a game
	var g := U.make(root, ["clockwork", "crown"], "", false)
	await process_frame
	await process_frame
	var spot: Vector2 = U.hall(g, 0).center() + Vector2(0, 260)
	var made := {}
	for kind in WindKeyData.KEYS.keys() + ["winder", Defs.GREAT_WINDER_KIND, "ballista", "brass_serpent"]:
		if not Defs.UNITS.has(kind):
			continue
		var u: Unit = g._add_unit(kind, 0, spot)
		made[kind] = u
	await process_frame
	for kind in made:
		var u: Unit = made[kind]
		var has: bool = u._wkey != null and u.sprite.get_node_or_null("WindKey") != null
		check("%s %s" % [kind, "carries a key" if WindKeyData.KEYS.has(kind) else "carries none"], has == WindKeyData.KEYS.has(kind))
	var cs: Unit = made["clock_soldier"]
	var k: Sprite2D = cs._wkey
	g.camera.zoom = Vector2(1.5, 1.5)
	cs.facing = Vector2(1, 0)
	cs._set_anim("walk", true)
	for f in [0, 3]:
		cs.sprite.frame = f
		k.step(0.0)
		var want: Array = WindKeyData.KEYS["clock_soldier"]["keys"]["walk_e"][f]
		check("on the body's frame %d (walk E)" % f, k.visible and k.position == Vector2(want[2], want[3])
			and k.show_behind_parent == not want[1], "%s v %s" % [k.position, want])
	# the turn
	cs.wind = 1.0
	var t0: float = k._turn
	k.step(0.3)
	var full: float = fposmod(k._turn - t0, 1.0)
	check("full wind: a quarter turn in 0.3 s (a turn per %.1f s)" % WK.SPIN_T, absf(full - 0.3 / WK.SPIN_T) < 1e-4, "%.4f" % full)
	cs.wind = 0.5
	t0 = k._turn
	k.step(0.3)
	var half: float = fposmod(k._turn - t0, 1.0)
	check("half wind: half as fast", absf(half - full * 0.5) < 1e-4, "%.4f" % half)
	cs.wind = 0.0
	var f0: int = k.frame
	t0 = k._turn
	k.step(1.0)
	check("run down: the key stands still", k._turn == t0 and k.frame == f0)
	cs.wind = 1.0
	# the column follows the turn
	k._turn = 0.5
	k.step(0.0)
	check("the frame shows the turn (half a turn = column %d)" % (WindKeyData.FRAMES / 2), k.frame % WindKeyData.FRAMES == WindKeyData.FRAMES / 2)
	# a west strip of its own (the Clock Soldier's): mirrored
	cs.facing = Vector2(-1, 0)
	cs._set_anim("walk", true)
	cs.sprite.frame = 0
	k.step(0.0)
	check("its own west strip: the key mirrored", cs.anim_dir == "w" and k.flip_h, cs.anim_dir)
	# a mirrored east strip (the Springer facing W): the sprite flips, the key with it, not mirrored twice
	var sp: Unit = made["springer"]
	sp.facing = Vector2(-1, 0)
	sp._set_anim("walk", true)
	sp._wkey.step(0.0)
	check("a mirrored strip: the sprite flips it (no second mirror)", sp.anim_dir == "e" and sp.sprite.scale.x < 0.0 and not sp._wkey.flip_h)
	# zoomed far out: hidden
	g.camera.zoom = Vector2(0.6, 0.6)
	k.step(0.0)
	check("zoomed far out: hidden", not k.visible)
	g.camera.zoom = Vector2(1.5, 1.5)
	k.step(0.0)
	check("zoomed back in: shown", k.visible)
	# death
	cs.take_damage(99999.0, null)
	cs.dead = true
	k.step(0.0)
	check("dead: no key", not k.visible)
	print("WIND KEYS: %d failed" % fails)
	quit(1 if fails > 0 else 0)
