class_name NavButton
extends TextureButton

@export_group("Navigation Targets")
@export_enum(
	"living_room",
	"dining_room",
	"kitchen",
	"hallway_1f",
	"stairs_landing",
	"hallway_2f",
	"storage",
	"bathroom",
	"bedroom"
	)
var target_room: String = ""
@onready var label: Label = $Label

@export_group("Audio / Juice")
@export var hover_sfx: AudioStream
@export var click_sfx: AudioStream

func _ready() -> void:
	if target_room.is_empty():
		queue_free()
		
	label.text = "Going to:\n" + target_room
	pressed.connect(_on_pressed)
	#mouse_entered.connect(_on_mouse_entered)

func _on_pressed() -> void:
	#if DialogueManager:
	#	return
		
	#if click_sfx:
	#	AudioManager.play_sfx(click_sfx)
		
	RoomManager.change_room(target_room)

#func _on_mouse_entered() -> void:
	#if hover_sfx:
	#	AudioManager.play_sfx(hover_sfx)
		
	# Optional stalker proximity hook
	# if StalkerManager.stalker_room == target_room_id:
	# 	AudioManager.play_sfx(stalker_threat_cue)
