extends Node

@export_group("Audio Files")
## Drag and drop all your audio files here.
@export var audio_files: Array[AudioStream] = []

@export_group("Layer Volumes")
## Master volume sliders (0.0 = Mute, 1.0 = Max)
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

@export_range(0.0, 1.0, 0.05) var player_sfx_volume: float = 1.0
@export_range(0.0, 1.0, 0.05) var ghost_sfx_volume: float = 1.0

@export_group("Pitch Randomization")
## Default pitch variation range for Player SFX (e.g. 0.1 gives 0.9x to 1.1x speed/pitch)
@export_range(0.0, 0.5, 0.01) var player_pitch_randomness: float = 0.08
## Default pitch variation range for Ghost SFX
@export_range(0.0, 0.5, 0.01) var ghost_pitch_randomness: float = 0.15

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

## Player SFX Layer (Footsteps, UI Clicks, Item Pickups, Door UI)
func play_player_sfx(audio: Variant, pitch_variation: float = -1.0) -> void:
	var var_range: float = pitch_variation if pitch_variation >= 0.0 else player_pitch_randomness
	_play_one_shot(audio, player_sfx_volume, var_range)

## Ghost / Stalker SFX Layer (Roars, Screams, Whispers, Scratches)
func play_ghost_sfx(audio: Variant, pitch_variation: float = -1.0) -> void:
	var var_range: float = pitch_variation if pitch_variation >= 0.0 else ghost_pitch_randomness
	_play_one_shot(audio, ghost_sfx_volume, var_range)

# Generic one-shot spawner for overlapping sound effects with pitch modulation
func _play_one_shot(audio: Variant, volume_level: float, pitch_range: float) -> void:
	var stream: AudioStream = _resolve_stream(audio)
	if not stream: return
	
	var temp_player = AudioStreamPlayer.new()
	add_child(temp_player)
	temp_player.stream = stream
	_update_volume(temp_player, volume_level)
	
	if pitch_range > 0.0:
		temp_player.pitch_scale = randf_range(1.0 - pitch_range, 1.0 + pitch_range)
		
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
