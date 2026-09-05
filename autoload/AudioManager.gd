extends Node

@export_group("Audio Files")
## Drag and drop all your audio files here.
@export var audio_files: Array[AudioStream] = []

@export_group("Layer Volumes")
## Master volume slider (0.0 = Mute, 1.0 = Max)
@export_range(0.0, 1.0, 0.05) var bgm_volume: float = 0.8:
	set(value):
		bgm_volume = value
		_update_volume(bgm_player, bgm_volume)

@export_range(0.0, 1.0, 0.05) var ambient_volume: float = 0.8:
	set(value):
		ambient_volume = value
		_update_volume(ambient_player, ambient_volume)

@export_range(0.0, 1.0, 0.05) var cue_volume: float = 1.0:
	set(value):
		cue_volume = value
		_update_volume(cue_player, cue_volume)

@export_range(0.0, 1.0, 0.05) var sfx_volume: float = 1.0

# Automated lookup map built from file names
var library: Dictionary = {}

@onready var bgm_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var ambient_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var cue_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	add_child(bgm_player)
	add_child(ambient_player)
	add_child(cue_player)
	
	_build_library()
	_apply_initial_volumes()

## Build lookup map using filename without extensions
func _build_library() -> void:
	for stream in audio_files:
		if stream and stream.resource_path != "":
			var file_name: String = stream.resource_path.get_file().get_basename()
			library[file_name] = stream

func _apply_initial_volumes() -> void:
	_update_volume(bgm_player, bgm_volume)
	_update_volume(ambient_player, ambient_volume)
	_update_volume(cue_player, cue_volume)

## Converts 0.0 - 1.0 slider value to Decibels
func _update_volume(player: AudioStreamPlayer, linear_val: float) -> void:
	if is_instance_valid(player):
		player.volume_db = linear_to_db(linear_val)

# ==============================================================================
# AUDIO LAYERS
# ==============================================================================

## BGM Layer
func play_bgm(audio: Variant) -> void:
	var stream: AudioStream = _resolve_stream(audio)
	if not stream or (bgm_player.playing and bgm_player.stream == stream): return
	bgm_player.stream = stream
	_update_volume(bgm_player, bgm_volume)
	bgm_player.play()

func stop_bgm() -> void:
	bgm_player.stop()

## Ambient Layer (Rain, Wind, House Creaks)
func play_ambient(audio: Variant) -> void:
	var stream: AudioStream = _resolve_stream(audio)
	if not stream: return
	ambient_player.stream = stream
	_update_volume(ambient_player, ambient_volume)
	ambient_player.play()

func stop_ambient() -> void:
	ambient_player.stop()

## Audio Cues (Stalker threats, Jumpscares)
func play_cue(audio: Variant) -> void:
	var stream: AudioStream = _resolve_stream(audio)
	if not stream: return
	cue_player.stream = stream
	_update_volume(cue_player, cue_volume)
	cue_player.play()

func stop_cue() -> void:
	cue_player.stop()

## SFX Layer (Overlapping one-shots)
func play_sfx(audio: Variant) -> void:
	var stream: AudioStream = _resolve_stream(audio)
	if not stream: return
	
	var temp_player = AudioStreamPlayer.new()
	add_child(temp_player)
	temp_player.stream = stream
	_update_volume(temp_player, sfx_volume)
	temp_player.play()
	temp_player.finished.connect(temp_player.queue_free)

# ==============================================================================
# HELPER: Resolves AudioStream or String key
# ==============================================================================
func _resolve_stream(audio: Variant) -> AudioStream:
	if audio is AudioStream:
		return audio
	elif audio is String:
		if library.has(audio):
			return library[audio]
		elif ResourceLoader.exists(audio):
			return load(audio)
		else:
			push_warning("AudioManager: Sound key or path not found: " + audio)
	return null
