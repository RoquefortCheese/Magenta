extends Node

func _input(event: InputEvent):
	if event.is_action("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
