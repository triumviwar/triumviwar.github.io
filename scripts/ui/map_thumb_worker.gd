class_name MapThumbWorker
extends Node
## Makes MapThumb's queued map pictures, one a frame (no threads: the web build), then goes away
## (docs/map_previews.md).


func _process(_delta: float) -> void:
	if not MapThumb.work_one():
		MapThumb._worker = null
		queue_free()
