extends Node

@export var success_timeline: String = ""
@export var fail_timeline: String = ""

func _ready() -> void:
	if QteManager:
		QteManager.qte_challenge_completed.connect(_on_qte_completed)

func _on_qte_completed(success: bool) -> void:
	if success:
		if success_timeline != "":
			Dialogic.start(success_timeline)
	else:
		if fail_timeline != "":
			Dialogic.start(fail_timeline)
