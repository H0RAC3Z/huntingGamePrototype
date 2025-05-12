extends Node
class_name TimeSystem

signal updated(date_time : DateTime)
signal sleep_update(sleeping : bool)

@export var date_time : DateTime = DateTime.new()
@export var ticks_per_second : int = 6

func _process(delta: float) -> void:
	date_time.increase_by_sec(delta * ticks_per_second)
	updated.emit(date_time)
	if date_time.hours == 5:
		sleep_update.emit(false)
