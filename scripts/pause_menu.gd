extends Control

var inventory_visibility : bool = false

# Setter???
var _is_paused : bool = false:
	set = set_paused
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		self._is_paused = !_is_paused
		
	
func set_paused(value : bool) -> void:
	_is_paused = value
	get_tree().paused = _is_paused
	visible = _is_paused
	if visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif inventory_visibility:
		pass
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func receive_inventory_visibility(visibility : bool) -> void:
	self.inventory_visibility = visibility


func _on_resume_btn_pressed() -> void:
	_is_paused = false


func _on_settings_btn_pressed() -> void:
	pass # Replace with function body.


func _on_quit_btn_pressed() -> void:
	get_tree().quit()
