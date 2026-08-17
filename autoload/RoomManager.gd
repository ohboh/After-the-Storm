extends Node

signal room_change_started(room_id: String)
signal room_change_completed(room_id: String)

@export_group("Room Registry")
@export var room_registry: Dictionary[String, PackedScene] = {}

var current_room_id: String = ""
var is_transitioning: bool = false

func change_room(target_room_id: String) -> void:
	if is_transitioning:
		return
		
	if not room_registry.has(target_room_id):
		push_error("RoomManager: Room ID '%s' not found in registry." % target_room_id)
		return

	if target_room_id == current_room_id:
		return

	is_transitioning = true
	room_change_started.emit(target_room_id)

	# Optional: Trigger screen fade out or horror transition effect here
	# await TransitionManager.fade_out()

	var target_scene: PackedScene = room_registry[target_room_id]
	get_tree().change_scene_to_packed(target_scene)

	current_room_id = target_room_id
	is_transitioning = false
	
	room_change_completed.emit(target_room_id)
