extends CharacterBody3D

signal inv_vis_to_main(visibility : bool)

@onready var timer : Timer = $Timer
@onready var player_camera : Camera3D = get_node("/root/Main/Player/Camera3D")
@onready var player_model : MeshInstance3D= get_node("/root/Main/Player/MeshInstance3D")
@onready var player_collision : CollisionShape3D= get_node("/root/Main/Player/CollisionShape3D")
var mouse_sensitivity : float = 0.001
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var default_speed : int = 5
var sprint_speed : int = 10
var speed : int = default_speed
var jump_speed : int = 5
var inventory_visibility : bool = false
var sprint_counter : int = 0
var crouch_counter : int = 0
var money : float = 200.5

# stats
var health : float = 100.0
var max_stamina : float = 250.0
var stamina : float = max_stamina
var hunger : float = 100.0
var thirst : float = 100.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Character movement
	velocity.y += -gravity * delta
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var movement_dir = transform.basis * Vector3(input.x, 0, input.y)
	velocity.x = movement_dir.x * speed
	velocity.z = movement_dir.z * speed
	move_and_slide()
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_speed
	

func _on_hunger_timer_timeout() -> void:
	hunger -= 0.1
	thirst -= 0.2
	if stamina != max_stamina and !Input.is_action_pressed("sprint"):
		stamina += 2
		if stamina > max_stamina:
			stamina = max_stamina
	print(str(hunger) + " " + str(thirst) + " " + str(stamina) + " " )

func _unhandled_input(event: InputEvent) -> void:
	# camera input catching
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(80), deg_to_rad(80))

func _unhandled_key_input(event: InputEvent) -> void:
	# sprinting mechanics : speed is set once
	if event is InputEventKey and Input.is_action_pressed("sprint") and stamina != 0:
		stamina -= 1
	if event is InputEventKey and Input.is_action_pressed("sprint") and sprint_counter == 0 and stamina != 0 and !Input.is_action_pressed("crouch"):
		speed = sprint_speed
		sprint_counter += 1
	elif event is InputEventKey and !Input.is_action_pressed("sprint") and sprint_counter == 1:
		speed = default_speed
		sprint_counter = 0
	# crouching mechanics
	if event is InputEventKey and Input.is_action_pressed("crouch") and crouch_counter == 0 and !Input.is_action_pressed("sprint"):
		player_camera.position.y -= 0.5
		player_model.mesh.height = 1.0
		player_collision.shape.height = 1.0
		speed = default_speed / 2
		crouch_counter += 1
	elif event is InputEventKey and !Input.is_action_pressed("crouch") and crouch_counter == 1:
		player_camera.position.y += 0.5
		player_model.mesh.height = 2.0
		player_collision.shape.height = 2.0
		speed = default_speed
		crouch_counter = 0

func setVisibility(visibility : bool) -> void:
	self.inventory_visibility = visibility
	emit_signal("inv_vis_to_main", self.inventory_visibility)
