extends CanvasLayer

signal qte_challenge_completed(success: bool)

@export var circle_scene: PackedScene
@export var spawn_margin: float = 100.0

@export_group("Difficulty Settings")
@export var targets_to_win: int = 5
@export var max_misses: int = 2
@export var spawn_interval: float = 1.5
@export var target_lifespan: float = 2.0

@onready var spawn_timer: Timer = $SpawnTimer
@onready var container: Control = $Control

var targets_spawned_count: int = 0
var hits_count: int = 0
var misses_count: int = 0
var is_active: bool = false
var screen_size: Vector2

const DIFFICULTY_EASY = {
	"targets_to_win": 3,
	"max_misses": 3,
	"spawn_interval": 2.0,
	"target_lifespan": 3.0
}

const DIFFICULTY_PANIC = {
	"targets_to_win": 10,
	"max_misses": 1,
	"spawn_interval": 0.8,
	"target_lifespan": 1.2
}

func _ready() -> void:
	hide() 
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	screen_size = get_viewport().get_visible_rect().size

## initiate a QTE
func start_challenge(difficulty_preset: Dictionary = {}) -> void:
	if is_active: return
	
	# Optional: Apply difficulty overrides from the call
	if difficulty_preset.has("targets_to_win"): targets_to_win = difficulty_preset["targets_to_win"]
	if difficulty_preset.has("target_lifespan"): target_lifespan = difficulty_preset["target_lifespan"]
	# ... (apply other overrides)

	is_active = true
	hits_count = 0
	misses_count = 0
	targets_spawned_count = 0
	
	# Remove any leftover circles
	for child in container.get_children():
		child.queue_free()
		
	show()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.start()
	_on_spawn_timer_timeout()

func _on_spawn_timer_timeout() -> void:
	if not is_active:
		return
		
	var margin: float = 200
	var random_pos = Vector2(
		randf_range(margin, screen_size.x - margin),
		randf_range(margin, screen_size.y - margin)
	)

	var new_circle: QTECircle = circle_scene.instantiate()
	container.add_child(new_circle)
	
	new_circle.position = random_pos
	
	new_circle.target_clicked.connect(_on_target_hit)
	new_circle.target_timed_out.connect(_on_target_missed)
	new_circle.activate(targets_spawned_count, target_lifespan)
	
	targets_spawned_count += 1

func _on_target_hit(node: QTECircle) -> void:
	hits_count += 1
	print("QTE Hit: %d/%d" % [hits_count, targets_to_win])
	_check_game_state()

func _on_target_missed(node: QTECircle) -> void:
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
	
	if success:
		print("QTE CHALLENGE WON!")
	else:
		print("QTE CHALLENGE FAILED!")
		
	await get_tree().create_timer(0.5).timeout
	hide()
	qte_challenge_completed.emit(success)
