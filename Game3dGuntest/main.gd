extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	await get_tree().create_timer(2.5).timeout





func _process(delta):
	if Input.is_action_just_pressed("pause"):
		get_tree().quit()

