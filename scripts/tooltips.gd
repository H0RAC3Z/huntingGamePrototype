extends Control
class_name Tooltips

@export var displayName : Label

func set_display_name(newName : String) -> void:
	displayName.text = newName
