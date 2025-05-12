extends NavigationRegion3D

@onready var player : CharacterBody3D = $Player
@onready var pause_menu : Control = $UI/PauseMenu

@onready var player_interaction : Area3D = $Player/InteractionArea
@onready var bed_sleeping : MeshInstance3D = $Bed/MeshInstance3D

@onready var time_system : TimeSystem = $TimeSystem

func _ready() -> void:
	player.inv_vis_to_main.connect(pause_menu.receive_inventory_visibility)
	
	player_interaction.HonkShooo.connect(bed_sleeping.honk_shooo_time)
	
	time_system.sleep_update.connect(bed_sleeping.honk_shooo_time)
	
	self.bake_navigation_mesh(true)
