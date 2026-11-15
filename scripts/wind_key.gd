extends Sprite2D
## A Clockwork construct's wind-up KEY on its back (wind-keys, the owner 2026-11-15 20:15: "most of the Clockwork army
## should have a wind-up key on its back like the Winder has"). One painted key (art/redraws/wind_key/, turned at import
## by tools/clockwork/import_wind_key.py into assets/units/_shared/wind_key_<size>.png) fixed on the back: a child of the
## unit's body sprite, so it flips, bobs, leaps and hovers with it and shares its material. Every frame it goes to the
## spot WindKeyData.KEYS gives for the body's animation frame (measured from the sprites), shows the view of the key
## for that strip, hangs in front of or behind the body, and TURNS with the unit's charge: a full turn per SPIN_T
## seconds fully wound, slower as `wind` runs down, still when it is run down: the wind readable at a glance.
## No _process of its own: the unit's _animate steps it with the body's frames (15 times a second, 10 in a big battle
## on screen, never off screen: Unit._animate's own rules). docs/wind_keys.md.

const SPIN_T := 1.2             # seconds per turn at full wind (wind 1.0); speed is wind / SPIN_T turns a second

var unit: Unit
var _keys: Dictionary
var _turn := 0.0                # turns so far (0..1)
var _sa := ""                   # (the strip last looked up, and what it gave: a lookup only when the strip changes)
var _sd := ""
var _frames: Array = []
var _west := false
var _twin := false


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
	set_process(false)
	step(0.0)


## To the body's frame, and on with the turn (delta: the time since the last step).
func step(delta: float) -> void:
	if unit.dead:
		if visible:
			visible = false    # the construct falls apart; its key with it
		return
	if unit.anim != _sa or unit.anim_dir != _sd:
		_sa = unit.anim
		_sd = unit.anim_dir
		_frames = _keys.get(_sa + "_" + _sd, [])
		# a west strip drawn unflipped (the Clock Soldier's own): the key's picture mirrored; with no spots of its own,
		# its east twin's mirrored too (Unit.EAST_OF)
		_west = Unit.EAST_OF.has(_sd)
		_twin = false
		if _frames.is_empty() and _west:
			_frames = _keys.get(_sa + "_" + unit.view_dir(), [])
			_twin = true
	var frames := _frames
	var west := _west
	var twin := _twin
	if frames.is_empty():
		if visible:
			visible = false
		return
	var body := get_parent() as Sprite2D
	var e: Array = frames[mini(body.frame, frames.size() - 1)]
	# (each setter redraws even for the same value: only what changes is set, as Unit._set_anim)
	if not visible:
		visible = true
	if flip_h != west:
		flip_h = west
	if show_behind_parent == bool(e[1]):
		show_behind_parent = not e[1]
	var at := Vector2(-float(e[2]) if twin else float(e[2]), float(e[3]))
	if position != at:
		position = at
	# the turn: as fast as the charge (still when run down)
	var w := clampf(unit.wind, 0.0, 1.0)
	if w > 0.0:
		_turn = fposmod(_turn + delta * w / SPIN_T, 1.0)
	var f := int(e[0]) * WindKeyData.FRAMES + int(_turn * WindKeyData.FRAMES) % WindKeyData.FRAMES
	if f != frame:
		frame = f
