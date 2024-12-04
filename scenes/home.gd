extends Node2D

signal start_level(level: int)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is Button:
			child.connect('pressed', _on_button_pressed.bind(child))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed(button: Button) -> void:
	start_level.emit(button.text)
	
