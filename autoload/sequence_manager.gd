extends Node

func start_intro() -> void:
	Dialogic.start("intro")

func start_gameplay() -> void:
	RoomManager.change_room("entrance_hallway")
