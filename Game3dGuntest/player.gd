extends CharacterBody3D

var shotguncooldown = 0
var guntype = 1
var bullet = preload("res://bullet.tscn")
const SPEED = 25
@onready var gunanim = $glock19/AnimationPlayer
@onready var barrel = $glock19/RayCast3D
@onready var gun = $glock19  # Reference to the gun node
@onready var shotgun = $shotgun
@onready var shotgunanim = $shotgun/AnimationPlayer

const JUMP_VELOCITY = 6.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") + 4

@export var mouse_sensitivity: float = 0.2

var yaw: float = 0.0
var pitch: float = 0.0
var camera: Camera3D

# Shotgun settings
var shotgun_pellets: int = 5
var spread_angle: float = 5.0 # degrees (tighter spread)

func _ready():
	camera = $Camera3D
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player")
	shotgun.visible = false

func _input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, -90, 90)

		# Apply the rotation to the camera
		camera.rotation.x = deg_to_rad(pitch)
		rotation.y = deg_to_rad(yaw)

		# Update the gun's rotation to match the camera's
		update_gun_rotation()

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle shooting
	if Input.is_action_just_pressed("semiauto"):
		guntype = 1
		gun.visible = true
		shotgun.visible = false
		if not gunanim.is_playing():
			gunanim.play("swaptogun")
	if Input.is_action_just_pressed("shotgun"):
		guntype = 2
		shotgun.visible = true
		gun.visible = false
		if not shotgunanim.is_playing():
			shotgunanim.play("swaptoshotgun")
	if Input.is_action_just_pressed("shoot"):
		shoot()
	
	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle movement
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()  # Ensure to specify the up direction

func update_gun_rotation():
	# Align the gun or shotgun with the camera's rotation
	if guntype == 1:
		gun.rotation_degrees.x = camera.rotation_degrees.x
		gun.rotation_degrees.y = camera.rotation_degrees.y
	elif guntype == 2:
		shotgun.rotation_degrees.x = gun.rotation_degrees.x
		shotgun.rotation_degrees.y = gun.rotation_degrees.y
		shotgun.global_position = gun.global_position

func shoot():
	if guntype == 1:
		var instance = bullet.instantiate()
		instance.global_transform.origin = barrel.global_transform.origin
		instance.position = barrel.global_position
		instance.transform.basis = barrel.global_transform.basis
		if not gunanim.is_playing():
			gunanim.play("gun_anim")


		get_parent().add_child(instance)
	elif guntype == 2:
		if shotguncooldown == 0:
			for i in range(shotgun_pellets):
				var instance = bullet.instantiate()
				instance.global_transform.origin = barrel.global_transform.origin
				instance.position = barrel.global_position
				
				# Calculate spread for each pellet
				var spread_rotation = barrel.global_transform.basis.rotated(Vector3.UP, deg_to_rad(randf_range(-spread_angle, spread_angle)))
				spread_rotation = spread_rotation.rotated(Vector3.LEFT, deg_to_rad(randf_range(-spread_angle, spread_angle)))
				instance.transform.basis = spread_rotation
				
				get_parent().add_child(instance)
				shotguncooldown = 1
				
			if not shotgunanim.is_playing():
				shotgunanim.play("shotgun_anim")
			await get_tree().create_timer(0.75).timeout
			shotguncooldown = 0
