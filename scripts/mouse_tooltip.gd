extends CanvasLayer

@onready var label: Label = $Label

func _ready() -> void:
	hide()
	# Ignore mouse input on the label so it doesn't block clicks on hotspots!
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(_delta: float) -> void:
	if visible:
		# Keep the label floating slightly offset from the mouse cursor
		var mouse_pos = get_viewport().get_mouse_position()
		label.global_position = mouse_pos + Vector2(15, 15)

## Show the room target text near the cursor
func show_tooltip(text_content: String) -> void:
	label.text = text_content
	show()

## Hide the label when not hovering a door
func hide_tooltip() -> void:
	hide()
