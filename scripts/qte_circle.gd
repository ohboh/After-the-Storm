class_name QTECircle
extends Control

signal target_clicked(node: QTECircle)
signal target_timed_out(node: QTECircle)

@export_group("Visual Style")
@export var base_radius: float = 60.0
@export var circle_color: Color = Color.RED
@export var fill_color: Color = Color(1.0, 0.0, 0.0, 0.3)
@export var line_width: float = 4.0

var lifespan: float = 2.0
var time_left: float = 2.0
var is_active: bool = false
var current_radius: float = 60.0

func _ready() -> void:
	# Ignore standard control mouse filtering
	mouse_filter = MOUSE_FILTER_IGNORE

func activate(duration: float) -> void:
	lifespan = duration
	time_left = duration
	current_radius = base_radius
	is_active = true
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	if not is_active:
		return

	time_left -= delta
	var progress: float = clamp(time_left / lifespan, 0.0, 1.0)
	current_radius = base_radius * progress

	if time_left <= 0.0:
		is_active = false
		target_timed_out.emit(self)
		queue_free()
		return

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_pos = get_global_mouse_position()
		var click_distance = mouse_pos.distance_to(global_position)

		if click_distance <= current_radius:
			is_active = false
			target_clicked.emit(self)
			queue_free()
			return

	queue_redraw()

func _draw() -> void:
	if current_radius > 0.0:
		draw_arc(Vector2.ZERO, current_radius, 0.0, TAU, 32, circle_color, line_width, true)
		draw_circle(Vector2.ZERO, current_radius, fill_color)
