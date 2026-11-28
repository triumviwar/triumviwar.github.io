class_name CampaignCredits
extends Control
## THE CREDITS (act3-engine0, docs/act3_engine0.md; owner question 15, answered "as recommended"): at the campaign's
## end, a roll of names over THE WAR MAP's last state (the world as the campaign left it: every colony's holder), then
## THE KING'S STUDY (the Rome hub's layered painting) with his pipe smoking, the ending's last line under it, and his
## pipe knocked out. The names come from campaign.json "credits": {"sections": [{"title", "names"}], "last": {ending:
## line}, "end": line}. A first tap rolls the names four times as fast, a second goes to the study, one there ends it;
## a key goes to the study, Esc ends it. `done` is called once at the end.
##   CampaignCredits.play(parent, ending, func() -> void: ...)
## Shown after e20's ending (MissionRun's mission key "credits": true) and from the hub's THE CREDITS once the campaign
## has an ending (Campaign.ending()).

const SPEED := 46.0             # the roll, pixels a second
const STUDY_SECS := 11.0        # the King's study, seconds
const FADE := 1.2

var ending := ""
var done: Callable
var phase := "roll"             # roll -> study -> end
var _t := 0.0
var _fast := false
var _map: Control = null
var _study: Control = null
var _roll: VBoxContainer = null
var _veil: ColorRect = null
var _line: Label = null
var _ended := false


static func play(parent: Node, end_id: String, on_done: Callable) -> CampaignCredits:
	var c := CampaignCredits.new()
	c.ending = end_id
	c.done = on_done
	c.name = "CampaignCredits"
	parent.add_child(c)
	return c


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	theme = UiStyle.theme()
	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.025, 0.02)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	# the war map's last state (the parchment skin, the whole world, nothing to press)
	var wm := WarMap.make("parchment")
	wm.name = "CreditsMap"
	wm.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wm.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wm.modulate = Color(0.75, 0.72, 0.68)
	add_child(wm)
	_map = wm
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.45)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	# the names
	_roll = VBoxContainer.new()
	_roll.name = "Roll"
	_roll.alignment = BoxContainer.ALIGNMENT_BEGIN
	_roll.add_theme_constant_override("separation", 6)
	_roll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_roll)
	var cr := Campaign.credits()
	var ph := not Settings.pc()
	for sec in cr.get("sections", []):
		var t := UiStyle.text(Loc.t(String(sec.get("title", ""))), 30 if ph else 24, UiStyle.TRIM, HORIZONTAL_ALIGNMENT_CENTER, true)
		_roll.add_child(t)
		for nm in sec.get("names", []):
			var l := UiStyle.text(String(nm), 24 if ph else 19, Color(0.92, 0.88, 0.80), HORIZONTAL_ALIGNMENT_CENTER)
			l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED      # (names are names)
			_roll.add_child(l)
		var gap := Control.new()
		gap.custom_minimum_size.y = 40
		_roll.add_child(gap)
	_veil = ColorRect.new()
	_veil.color = Color(0, 0, 0, 1)
	_veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_veil)
	_place_roll.call_deferred()


func _place_roll() -> void:
	var vs := get_viewport_rect().size
	_roll.custom_minimum_size.x = vs.x
	_roll.reset_size()
	_roll.position = Vector2(0, vs.y)


## The roll's whole way: from under the screen until its last name is gone over the top.
func roll_len() -> float:
	return get_viewport_rect().size.y + _roll.size.y


func _process(dt: float) -> void:
	if _ended:
		return
	_t += dt
	match phase:
		"roll":
			_veil.color.a = maxf(0.0, 1.0 - _t / FADE)
			_roll.position.y -= SPEED * dt * (4.0 if _fast else 1.0)
			if _roll.position.y < -_roll.size.y:
				to_study()
		"study":
			var k := _t
			_veil.color.a = maxf(0.0, 1.0 - k / FADE) if k < STUDY_SECS - FADE else clampf((k - (STUDY_SECS - FADE)) / FADE, 0.0, 1.0)
			if k > STUDY_SECS * 0.62 and _line and _line.text != Loc.t(String(Campaign.credits().get("end", ""))):
				_line.text = Loc.t(String(Campaign.credits().get("end", "")))
			if k >= STUDY_SECS:
				finish()


## The King's study (the Rome hub's painting, the pipe smoking) and the ending's last line.
func to_study() -> void:
	if phase != "roll":
		return
	phase = "study"
	_t = 0.0
	_roll.visible = false
	_map.visible = false
	var path := "res://campaign/hub/rome.json"
	if FileAccess.file_exists(path):
		var hs: Control = HubScene.make(path)
		hs.name = "CreditsStudy"
		hs.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		hs.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(hs)
		move_child(hs, _veil.get_index())
		_study = hs
	var ph := not Settings.pc()
	_line = UiStyle.text(Loc.t(String(Campaign.credits().get("last", {}).get(ending, ""))), 24 if ph else 20, Color(0.95, 0.90, 0.78), HORIZONTAL_ALIGNMENT_CENTER)
	_line.name = "LastLine"
	_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_line.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_line.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_line.add_theme_constant_override("outline_size", 6)
	var vs := get_viewport_rect().size
	_line.position = Vector2(vs.x * 0.12, vs.y * 0.82)
	_line.custom_minimum_size = Vector2(vs.x * 0.76, 0)
	add_child(_line)
	move_child(_line, _veil.get_index())


func finish() -> void:
	if _ended:
		return
	_ended = true
	phase = "end"
	if done.is_valid():
		done.call()
	queue_free()


func _gui_input(e: InputEvent) -> void:
	var press := (e is InputEventMouseButton and (e as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT) \
			or e is InputEventScreenTouch
	if not press:
		return
	accept_event()
	if not e.is_pressed():
		return
	if phase == "roll":
		if _fast:
			to_study()
		_fast = true
	elif phase == "study" and _t > 1.0:
		finish()


func _unhandled_key_input(e: InputEvent) -> void:
	if not e.is_pressed():
		return
	if e.is_action_pressed("ui_cancel"):
		finish()
	elif phase == "roll":
		to_study()
	elif _t > 1.0:
		finish()
	get_viewport().set_input_as_handled()
