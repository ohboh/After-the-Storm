class_name Interactable
extends TextureButton

@export_group("Dialogue / Action")
@export var timeline_name: String = ""
@export var label_name: String = ""

@export_group("Interaction Settings")
## If enabled, disables this button after the primary interaction succeeds.
@export var disable_on_press: bool = true
## If enabled, automatically triggers this dialogue upon entering the scene.
@export var trigger_on_entry: bool = false

@export_group("Condition Settings")
## If enabled, requires a specific Dialogic variable to be true before running the primary timeline.
@export var is_conditional: bool = false
## The name of the Dialogic variable that must be true (e.g., "has_crowbar" or "found_key")
@export var required_variable_name: String = ""
## Optional label inside 'timeline_name' to jump to if condition fails (e.g., "locked_label")
@export var fallback_label_name: String = ""

@export_group("Audio")
#@export var inspect_sfx: AudioStream

func _ready() -> void:
	pressed.connect(_on_pressed)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	if trigger_on_entry:
		call_deferred("_on_pressed")

func _on_pressed() -> void:
	if Dialogic.current_timeline != null:
		return

	# Check variable condition if enabled
	if is_conditional and not _check_condition():
		# Jump to fallback label inside the same timeline if condition fails
		if not timeline_name.is_empty() and not fallback_label_name.is_empty():
			Dialogic.start(timeline_name, fallback_label_name)
		return

	if not timeline_name.is_empty():
		Dialogic.start(timeline_name, label_name)
		Dialogic.VAR.interactables_clicked += 1
		
	# Only disable if the condition passed and the primary timeline was started
	if disable_on_press:
		disabled = true
		mouse_default_cursor_shape = Control.CURSOR_ARROW

## Evaluates whether the required Dialogic variable is set to true
func _check_condition() -> bool:
	if required_variable_name.is_empty():
		return true
		
	if not Dialogic.has_subsystem("VAR"):
		return true

	# Fetch the variable value directly from Dialogic's variable subsystem
	var var_value: Variant = Dialogic.VAR.get_variable(required_variable_name)
	
	# Evaluate truthiness (handles boolean true or truthy values)
	if var_value is bool:
		return var_value
	elif var_value is String:
		return var_value.to_lower() == "true" or var_value == "1"
	elif var_value is float or var_value is int:
		return var_value > 0
		
	return false
