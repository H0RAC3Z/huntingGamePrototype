extends Node3D

const PROJECTILE = preload("res://scenes/Projectile.tscn")
@onready var timer: Timer = $"../Timer"

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if timer.is_stopped() and self.get_parent().get_parent() == get_node("/root/Main/Player/Camera3D"):
		if Input.is_action_pressed("left_click"):
			timer.start(0.5)
			var attack = PROJECTILE.instantiate()
			add_child(attack)
			attack.global_transform = global_transform
			#attack.rotate_y(deg_to_rad(-90))
