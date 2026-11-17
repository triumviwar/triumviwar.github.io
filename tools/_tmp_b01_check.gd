extends SceneTree
var main
func _initialize() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()
func _run() -> void:
	await process_frame
	main.start(Campaign.make_cfg("b01_specimen", "solo"))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	var r: MissionRun = g.mission
	for i in 120:
		await physics_frame
	var l: Unit = r.tagged("linnea")[0]
	print("meta ", l.get_meta("role_scale", -1), " art_scale ", l.d.get("art_scale"), " sprite ", l.sprite.scale if l.sprite else null, " radius ", l.radius, " anim ", l.anim, " art ", l.art)
	for c in l.get_children():
		print(" child ", c.name, " ", c.get_class(), " ", c.scale if c is Node2D else "")
	quit(0)
