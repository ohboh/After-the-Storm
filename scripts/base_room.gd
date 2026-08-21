extends Control

@export var room_name_display: Label

func _ready() -> void:
	room_name_display.text = get_tree().current_scene.name
