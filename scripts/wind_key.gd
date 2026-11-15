extends Sprite2D
## A Clockwork construct's wind-up KEY on its back (wind-keys, the owner 2026-11-15 20:15: "most of the Clockwork army
## should have a wind-up key on its back like the Winder has"). One painted key (art/redraws/wind_key/, turned at import
## by tools/clockwork/import_wind_key.py into assets/units/_shared/wind_key_<size>.png) fixed on the back: a child of the
## unit's body sprite, so it flips, bobs, leaps and hovers with it and shares its material. Every frame it goes to the
## spot WindKeyData.KEYS gives for the body's animation frame (measured from the sprites), shows the view of the key
## for that strip, hangs in front of or behind the body, and TURNS with the unit's charge: a full turn per SPIN_T
## seconds fully wound, slower as `wind` runs down, still when it is run down: the wind readable at a glance.
## docs/wind_keys.md.

const SPIN_T := 1.2             # seconds per turn at full wind (wind 1.0); speed is wind / SPIN_T turns a second
const CROWD_STEP := 0.1         # a big battle on screen (game.anim_crowd): the key moves on 10 times a second

var unit: Unit
var _keys: Dictionary
var _turn := 0.0                # turns so far (0..1)
var _step_t := 0.0
var _col := -1


## A key for this unit? (its kind has a table)
static func wants(u: Unit) -> bool:
	return WindKeyData.KEYS.has(u.kind)


func _ready() -> void:
	var e: Dictionary = WindKeyData.KEYS[unit.kind]
	_keys = e["keys"]
	texture = Game.tex("res://assets/units/_shared/wind_key_%d.png" % int(e["size"]))
	hframes = WindKeyData.FRAMES
	vframes = WindKeyData.ROWS
	centered = true
	use_parent_material = true
	_turn = fposmod(float(unit.get_instance_id() % 97) / 97.0, 1.0)    # (not every key of a squad in step)


func _process(delta: float) -> void:
	if unit.dead:
		visible = false        # the construct falls apart; its key with it
		set_process(false)
		return
	var frames: Array = _keys.get(unit.anim + "_" + unit.anim_dir, [])
	# a west strip drawn unflipped (the Clock Soldier's own): the key's picture mirrored; with no spots of its own, its
	# east twin's mirrored too (Unit.EAST_OF)
	var west := Unit.EAST_OF.has(unit.anim_dir)
	var twin := false
	if frames.is_empty() and west:
		frames = _keys.get(unit.anim + "_" + unit.view_dir(), [])
		twin = true
	if frames.is_empty():
		visible = false
		return
	var body := get_parent() as Sprite2D
	var e: Array = frames[mini(body.frame, frames.size() - 1)]
	visible = true
	flip_h = west
	show_behind_parent = not e[1]
	position = Vector2(-float(e[2]) if twin else float(e[2]), float(e[3]))
	# the turn: as fast as the charge (still when run down)
	var w := clampf(unit.wind, 0.0, 1.0)
	if w > 0.0:
		_turn = fposmod(_turn + delta * w / SPIN_T, 1.0)
	var crowd: bool = unit.game != null and unit.game.anim_crowd
	_step_t += delta
	var col := int(_turn * WindKeyData.FRAMES) % WindKeyData.FRAMES
	if crowd and _step_t < CROWD_STEP and _col >= 0:
		col = _col
	else:
		_step_t = 0.0
	var f := int(e[0]) * WindKeyData.FRAMES + col
	if f != frame:
		frame = f
	_col = col
