extends CanvasLayer

signal qte_challenge_completed(success: bool)

enum Difficulty { EASY, MEDIUM, PANIC }

@export var circle_scene: PackedScene
@export var spawn_margin: float = 100.0

@export_group("Difficulty Settings")
@export var targets_to_win: int = 5
@export var max_misses: int = 2
@export var spawn_interval: float = 1.5
@export var target_lifespan: float = 2.0

@onready var spawn_timer: Timer = $SpawnTimer
@onready var container: Control = $Control
@onready var ghost_sprite: TextureRect = $Ghost
@onready var background_dim: ColorRect = $BackgroundDim

var targets_spawned_count: int = 0
var hits_count: int = 0
var misses_count: int = 0
var is_active: bool = false
var screen_size: Vector2
var ghost_tween: Tween

var ghost_base_position: Vector2 = Vector2.ZERO

const PRESETS = {
	Difficulty.EASY: {
		"targets_to_win": 3,
		"max_misses": 3,
		"spawn_interval": 1.5,
		"target_lifespan": 3.0
	},
	Difficulty.MEDIUM: {
		"targets_to_win": 5,
		"max_misses": 2,
		"spawn_interval": 1.5,
		"target_lifespan": 2.0
	},
	Difficulty.PANIC: {
		"targets_to_win": 10,
		"max_misses": 1,
		"spawn_interval": 0.8,
		"target_lifespan": 1.2
	}
}

func _ready() -> void:
	hide()
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	screen_size = get_viewport().get_visible_rect().size

func _process(_delta: float) -> void:
	if not is_active:
		return

	var scale_progress: float = clamp((ghost_sprite.scale.x - 1.0) / 0.5, 0.0, 1.0)
	var shake_strength: float = lerp(2.0, 15.0, scale_progress)

	var shake_offset = Vector2(
		randf_range(-shake_strength, shake_strength),
		randf_range(-shake_strength, shake_strength)
	)
	ghost_sprite.position = ghost_base_position + shake_offset

## Call with string ("easy", "medium", "panic") OR Enum (Difficulty.PANIC)
func start_challenge(difficulty = Difficulty.MEDIUM) -> void:
	if is_active: return
	
	var selected_preset: Dictionary = {}

	# Handle string inputs like "easy", "medium", "panic"
	if difficulty is String:
		match difficulty.to_lower():
			"easy": selected_preset = PRESETS[Difficulty.EASY]
			"medium": selected_preset = PRESETS[Difficulty.MEDIUM]
			"panic": selected_preset = PRESETS[Difficulty.PANIC]
			_: selected_preset = PRESETS[Difficulty.MEDIUM]
	elif difficulty in PRESETS:
		selected_preset = PRESETS[difficulty]
	else:
		selected_preset = PRESETS[Difficulty.MEDIUM]

	# Apply preset values
	targets_to_win = selected_preset["targets_to_win"]
	max_misses = selected_preset["max_misses"]
	spawn_interval = selected_preset["spawn_interval"]
	target_lifespan = selected_preset["target_lifespan"]

	is_active = true
	hits_count = 0
	misses_count = 0
	targets_spawned_count = 0
	
	for child in container.get_children():
		child.queue_free()
		
	show()
	_start_ghost_creep()

	spawn_timer.wait_time = spawn_interval
	spawn_timer.start()
	_on_spawn_timer_timeout()

func _start_ghost_creep() -> void:
	if ghost_tween: 
		ghost_tween.kill()
	
	ghost_sprite.scale = Vector2(1, 1)
	ghost_sprite.pivot_offset = ghost_sprite.size / 2.0
	ghost_base_position = (screen_size / 2.0) - (ghost_sprite.size / 2.0)
	ghost_sprite.position = ghost_base_position
	
	ghost_sprite.modulate.a = 0.25
	background_dim.color.a = 0.5

	var total_duration: float = (targets_to_win * spawn_interval) + target_lifespan
	
	ghost_tween = create_tween().set_parallel(true)
	
	ghost_tween.tween_property(ghost_sprite, "scale", Vector2(1.5, 1.5), total_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		
	ghost_tween.tween_property(ghost_sprite, "modulate:a", 0.95, total_duration * 0.85)
	
	ghost_tween.tween_property(background_dim, "color:a", 1.5, total_duration)

func _on_spawn_timer_timeout() -> void:
	if not is_active:
		return

	if targets_spawned_count >= targets_to_win + max_misses:
		spawn_timer.stop()
		return
		
	var margin: float = spawn_margin
	var random_pos = Vector2(
		randf_range(margin, screen_size.x - margin),
		randf_range(margin, screen_size.y - margin)
	)

	var new_circle: QTECircle = circle_scene.instantiate()
	container.add_child(new_circle)
	
	new_circle.position = random_pos
	new_circle.target_clicked.connect(_on_target_hit)
	new_circle.target_timed_out.connect(_on_target_missed)
	new_circle.activate(target_lifespan)
	
	targets_spawned_count += 1

func _on_target_hit(_node: QTECircle) -> void:
	if not is_active: return
	hits_count += 1
	print("QTE Hit: %d/%d" % [hits_count, targets_to_win])
	_check_game_state()

func _on_target_missed(_node: QTECircle) -> void:
	if not is_active: return
	misses_count += 1
	print("QTE Miss: %d/%d" % [misses_count, max_misses])
	_check_game_state()

func _check_game_state() -> void:
	if misses_count > max_misses:
		_end_challenge(false)
		return
		
	if hits_count >= targets_to_win:
		_end_challenge(true)

func _end_challenge(success: bool) -> void:
	is_active = false
	spawn_timer.stop()
	
	if ghost_tween: 
		ghost_tween.kill()

	for child in container.get_children():
		child.queue_free()

	if success:
		print("QTE CHALLENGE WON!")
		ghost_sprite.position = ghost_base_position
		var exit_tween = create_tween()
		exit_tween.tween_property(ghost_sprite, "modulate:a", 0.0, 0.2)
		await exit_tween.finished
	else:
		print("QTE CHALLENGE FAILED!")
		ghost_sprite.position = ghost_base_position
		ghost_sprite.scale = Vector2(2.2, 2.2)
		ghost_sprite.modulate.a = 1.0
		background_dim.color = Color(0.8, 0.0, 0.0, 0.8)
		await get_tree().create_timer(0.4).timeout

	hide()
	qte_challenge_completed.emit(success)
