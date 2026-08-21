extends Node

signal room_change_started(room_id: String)
signal room_change_completed(room_id: String)

@export_group("Room Setup")
## Base folder path where room scenes are located
@export_dir var room_folder_path: String = "res://scenes/rooms/"

## List of registered room IDs in your project
var room_registry: Array[String] = [
	"living_room",
	"dining_room",
	"kitchen",
	"hallway_1f",
	"stairs_landing",
	"hallway_2f",
	"storage",
	"bathroom",
	"bedroom"
]

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

	# Format path dynamically: e.g., "res://scenes/rooms/dining_room.tscn"
	var scene_path: String = "%s%s.tscn" % [room_folder_path, target_room_id]

	if ResourceLoader.exists(scene_path):
		get_tree().change_scene_to_file(scene_path)
		current_room_id = target_room_id
	else:
		push_error("RoomManager: Scene file missing at path '%s'" % scene_path)

	is_transitioning = false
	room_change_completed.emit(target_room_id)
