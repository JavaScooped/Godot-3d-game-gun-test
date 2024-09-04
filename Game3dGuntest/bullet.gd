extends RigidBody3D

const SPEED = 65
@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D

func _ready():
	add_to_group("bullets")
	await get_tree().create_timer(2.5).timeout
	queue_free()

func _physics_process(delta):
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider:
			print("Collider detected: ", collider.name)
			if collider.is_in_group("enemy"):
				collider.handle_hit(self)
				mesh.visible = false
				ray.enabled = false
				await get_tree().create_timer(1.0).timeout
				queue_free()
