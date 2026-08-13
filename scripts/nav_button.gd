extends Node2D

@export var next_scene: PackedScene

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		get_tree().change_scene_to_packed(next_scene)
