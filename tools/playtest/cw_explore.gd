extends SceneTree
## First look: menu -> skirmish -> a Clockwork match; pictures and the card of every start entity.
##   xvfb-run -s "-screen 0 1280x720x24" godot --path . --script res://tools/playtest/cw_explore.gd -- out=DIR [phone] [lang=pt]

const IN := preload("res://tools/playtest/cw_input.gd")
const SETUP := preload("res://tools/playtest/cw_setup.gd")

var io
var main: Node


func _initialize() -> void:
	_run.call_deferred()


func arg(k: String, d: String) -> String:
	for a in OS.get_cmdline_user_args():
		if a.begins_with(k + "="):
			return a.substr(k.length() + 1)
		if a == k:
			return "1"
	return d


func _run() -> void:
	io = IN.new(self)
	io.shots_dir = arg("out", "/tmp/claude-0/pt")
	DirAccess.make_dir_recursive_absolute(io.shots_dir)
	var phone := arg("phone", "") != ""
	if arg("fresh", "") != "":
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://settings.cfg"))
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await io.frames(10)
	await io.shot("first")
	var su = SETUP.new(io, main, phone)
	await su.to_menu()
	if arg("lang", "") != "":
		await su.language(arg("lang", "en"))
	await io.shot("menu")
	await su.skirmish({"foe": arg("foe", "CROWN"), "map": arg("map", "")} if arg("map", "") != "" else {"foe": arg("foe", "CROWN")})
	var g: Game = await su.start()
	if g == null:
		quit(1)
		return
	await io.wait(1.0)
	await io.shot("match_start")
	var hud = g.hud
	for e in g.buildings + g.units:
		if e.team != g.human:
			continue
		g.set_selection([e])
		await io.frames(3)
		var labels: Array = []
		for b in hud._card_buttons:
			labels.append("%s%s" % [b["item"][1], "" if b["item"][3] else "(x:%s)" % b["item"][4]])
		io.note("%s card: %s" % [e.kind, ", ".join(labels)])
	quit(0)
