extends RayCast3D

@export var speed : float = 20.0
@export var gravity : float = -2

@onready var remote_transform : RemoteTransform3D = RemoteTransform3D.new()
@onready var npc : CharacterBody3D = get_node("/root/Main/NavigationNPC")
const meat = preload("res://scenes/Meat.tscn")

func _ready() -> void:
	pass
	

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += global_basis * Vector3.FORWARD * speed * delta
	target_position = Vector3.FORWARD * speed * delta
	# Realism for arrows, should replace to mimic real life
	rotation.x += (-deg_to_rad(9))
	rotation.x = clampf(rotation.x, -deg_to_rad(90), deg_to_rad(90))
	
	force_raycast_update()
	var collider = get_collider()
	if is_colliding():
		global_position = get_collision_point()
		set_physics_process(false)
		collider.add_child(remote_transform)
		remote_transform.global_transform = global_transform
		remote_transform.remote_path = remote_transform.get_path_to(self)
		remote_transform.tree_exited.connect(cleanUp)
		if collider == npc and npc.health > 20:
			npc.health -= 20
		elif collider == npc: # simulate death + drop items
			npc.queue_free()
			var newMeat = meat.instantiate()
			get_node("/root/Main").add_child(newMeat)
			newMeat.global_transform = global_transform
func cleanUp() -> void:
	queue_free()
