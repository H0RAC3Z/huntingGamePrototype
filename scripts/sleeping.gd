extends Node3D

@onready var time_system : TimeSystem = get_node("/root/Main/TimeSystem")
@onready var player_camera : Camera3D = get_node("/root/Main/Player/Camera3D")


func honk_shooo_time(sleeping : bool) -> void:
	if sleeping and (time_system.date_time.hours >= 23 or time_system.date_time.hours < 5):
		#player_camera.FOV = 40
		time_system.ticks_per_second = 100000
		# add saving mechanism here / emit to saving node
	else:
		#player_camera.FOV = 90
		time_system.ticks_per_second = 100
