class_name Interactable
extends TextureButton

@export_group("Dialogue / Action")
@export var timeline_name: String = ""
@export var label_name: String = ""

@export_group("Audio")
#@export var inspect_sfx: AudioStream

func _ready() -> void:
	pressed.connect(_on_pressed)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _on_pressed() -> void:
	if Dialogic.current_timeline != null:
		return

	if not timeline_name.is_empty():
		Dialogic.start(timeline_name, label_name)
