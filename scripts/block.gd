extends Control

@onready var down := $Down
var falling := false
var held := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	falling = !down.is_colliding()

func _physics_process(delta: float) -> void:
	if falling and not held:
		print('falling')
		position.y += 64
