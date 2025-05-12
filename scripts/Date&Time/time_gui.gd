extends Control

@onready var days_label : Label = $DayControl/Days
@onready var hours_label : Label = $ClockControl/Hours
@onready var minutes_label : Label = $ClockControl/Minutes

func _on_time_system_updated(date_time: DateTime) -> void:
	days_label.text = str(date_time.days)
	if date_time.days < 10:
		days_label.text = '0' + days_label.text
	hours_label.text = str(date_time.hours)
	if date_time.hours < 10:
		hours_label.text = '0' + hours_label.text
	minutes_label.text = str(date_time.minutes)
	if date_time.minutes < 10:
		minutes_label.text = '0' + minutes_label.text
