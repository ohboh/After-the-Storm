class_name NavButton
extends TextureButton

@export_group("Navigation Targets")
## The room ID matching a room registered in RoomManager
@export var target_room_id: String = ""

@export_group("Audio / Juice")
@export var hover_sfx: AudioStream
@export var click_sfx: AudioStream

func _ready() -> void:
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)

func _on_pressed() -> void:
	if DialogueManager.is_running:
		return
		
	if click_sfx:
		AudioManager.play_sfx(click_sfx)
		
	RoomManager.change_room(target_room_id)

func _on_mouse_entered() -> void:
	if hover_sfx:
		AudioManager.play_sfx(hover_sfx)
		
	# Optional stalker proximity hook
	# if StalkerManager.stalker_room == target_room_id:
	# 	AudioManager.play_sfx(stalker_threat_cue)
