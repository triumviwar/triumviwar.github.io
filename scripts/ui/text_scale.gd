class_name TextScale
## TEXT SIZE (job ui-access-phone, docs/ui_access_phone.md; Settings > DISPLAY > TEXT SIZE, Settings.text_size 90-150%).
## Menus are built from Labels, Buttons and text boxes with their own font sizes in a hundred places; rather than
## touch each, every text Control that enters the tree has its font size multiplied once (its own size kept in the
## meta "_ts": a change of the setting scales again from it). Containers grow with the text, so pages keep their shape;
## a Control that must not grow sets the meta "no_text_scale". The HUD draws its words itself: Hud._text multiplies
## by hud_k() (a softer share of the setting: the HUD's boxes have fixed sizes; IN-GAME INTERFACE SIZE grows all of it).

const META := "_ts"
const SKIP := "no_text_scale"
const HUD_SHARE := 0.6            # the HUD's words grow by this share of the setting (150% -> 130%)

static var _queue: Array = []
static var _installed := false


static func k() -> float:
	return clampf(Settings.text_size / 100.0, Settings.TEXT_MIN / 100.0, Settings.TEXT_MAX / 100.0)


## The HUD's factor (Hud._text, the hotkey bar, the card's labels).
static func hud_k() -> float:
	return 1.0 + (k() - 1.0) * HUD_SHARE


## A HUD font size scaled.
static func hud(sz: int) -> int:
	return sz if is_equal_approx(k(), 1.0) else maxi(1, int(round(sz * hud_k())))


## Once, at start (UiStyle.install): watch every node that enters the tree.
static func install() -> void:
	if _installed:
		return
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	_installed = true
	tree.node_added.connect(_added)


static func _added(n: Node) -> void:
	if not (n is Control) or is_equal_approx(k(), 1.0) and not n.has_meta(META):
		return
	if not _texty(n):
		return
	if _queue.is_empty():
		_flush.call_deferred()          # (after the code that made it has set its sizes)
	_queue.append(n)


static func _flush() -> void:
	var q := _queue
	_queue = []
	for n in q:
		if is_instance_valid(n) and (n as Node).is_inside_tree():
			apply(n)


static func _texty(n: Node) -> bool:
	return n is Label or n is Button or n is LineEdit or n is TextEdit or n is RichTextLabel


## The node's font size(s) as the setting says now.
static func apply(n: Control) -> void:
	if n.has_meta(SKIP) or not _texty(n):
		return
	var names := ["normal_font_size", "bold_font_size", "italics_font_size", "mono_font_size"] if n is RichTextLabel else ["font_size"]
	var base: Dictionary = n.get_meta(META, {})
	if base.is_empty():
		for nm in names:
			base[nm] = n.get_theme_font_size(nm)
		n.set_meta(META, base)
	for nm in names:
		var b := int(base.get(nm, 0))
		if b <= 0:
			continue
		n.add_theme_font_size_override(nm, maxi(1, int(round(b * k()))))


## The setting changed: every text Control in the tree again (from its kept size).
static func apply_all() -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	_walk(tree.root)


static func _walk(n: Node) -> void:
	if n is Control and _texty(n):
		apply(n)
	for c in n.get_children():
		_walk(c)
