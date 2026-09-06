class_name NavButton
extends TextureButton

@export var target_room: String = ""
@onready var label: Label = $Label

@export_group("Condition Settings")
## If enabled, requires a specific Dialogic variable to be true to navigate.
@export var is_conditional: bool = false
## The name of the Dialogic variable that must be true (e.g., "front_door_unlocked")
@export var required_variable_name: String = ""
## Optional timeline to play when the door is locked/blocked
@export var locked_timeline: String = ""

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
	if Dialogic.current_timeline != null:
		return

	# Check variable condition if enabled
	if is_conditional and not _check_condition():
		if not locked_timeline.is_empty():
			MouseTooltip.hide_tooltip()
			Dialogic.start(locked_timeline)
		else:
			AudioManager.play_player_sfx("door_locked")
		return

	MouseTooltip.hide_tooltip()
	AudioManager.play_player_sfx("door_open")
	RoomManager.change_room(target_room)

func _on_mouse_entered() -> void:
	MouseTooltip.show_tooltip("Go to " + target_room.capitalize())

func _on_mouse_exited() -> void:
	MouseTooltip.hide_tooltip()

## Evaluates whether the required Dialogic variable is set to true
func _check_condition() -> bool:
	if required_variable_name.is_empty():
		return true
		
	if not Dialogic.has_subsystem("VAR"):
		return true

	var var_value: Variant = Dialogic.VAR.get_variable(required_variable_name)
	
	if var_value is bool:
		return var_value
	elif var_value is String:
		return var_value.to_lower() == "true" or var_value == "1"
	elif var_value is float or var_value is int:
		return var_value > 0
		
	return false
