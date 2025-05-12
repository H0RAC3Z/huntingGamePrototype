extends DirectionalLight3D

@export var day_color : Color
@export var night_color : Color
@export var day_start : DateTime = DateTime.new()
@export var night_start : DateTime = DateTime.new()
@export var transition_time : int = 30 # in minutes
@export var time_system : TimeSystem

var in_transition : bool = false

@onready var time_map : Dictionary = {
	DayState.DAY: day_start,
	DayState.NIGHT: night_start
}
@onready var transition_map : Dictionary = {
	DayState.DAY: DayState.NIGHT,
	DayState.NIGHT: DayState.DAY
}
@onready var color_map : Dictionary = {
	DayState.DAY: day_color,
	DayState.NIGHT: night_color
}
enum DayState {DAY, NIGHT}
var current_state: DayState = DayState.DAY

func _ready() -> void:
	day_start.hours = 5
	night_start.hours = 22
	night_start.minutes = 30
	var diff_day_start = time_system.date_time.diff_without_days(day_start)
	var diff_night_start = time_system.date_time.diff_without_days(night_start)
	if diff_day_start < 0 or diff_night_start > 0:
		current_state = DayState.NIGHT
	
func update(game_time : DateTime) -> void:
	var next_state = transition_map[current_state]
	var change_time = time_map[next_state]
	var time_diff = change_time.diff_without_days(game_time)
	
	if in_transition:
		update_transition(time_diff, next_state)
	elif time_diff > 0 and time_diff < (transition_time * 60):
		in_transition = true
		update_transition(time_diff, next_state) # update transition
	else:
		light_color = color_map[current_state]

func update_transition(time_diff : int, next_state : DayState) -> void:
	var ratio = 1 - (time_diff as float / (transition_time * 60))
	if ratio > 1:
		current_state = next_state
		in_transition = false
	else:
		light_color = color_map[current_state].lerp(color_map[next_state], ratio)
