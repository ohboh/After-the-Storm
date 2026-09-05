class_name NavButton
extends TextureButton

@export var target_room: String = ""
@onready var label: Label = $Label

@export_group("Audio / Juice")
@export var hover_sfx: AudioStream
@export var click_sfx: AudioStream

func _ready() -> void:
	if target_room.is_empty():
		queue_free()
		return
		
	# Formatting the button's internal label text
	label.text = "Going to:\n" + target_room.capitalize()
	
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_pressed() -> void:
	MouseTooltip.hide_tooltip()
	
	if click_sfx and AudioManager:
		AudioManager.play_sfx(click_sfx)
		
	RoomManager.change_room(target_room)

func _on_mouse_entered() -> void:
	if hover_sfx and AudioManager:
		AudioManager.play_sfx(hover_sfx)
		
	# Display cursor tooltip using target_room
	MouseTooltip.show_tooltip("Go to " + target_room.capitalize())

func _on_mouse_exited() -> void:
	MouseTooltip.hide_tooltip()
