extends Node
#const player = preload("res://scenes/player.tscn")
@onready var player: Player = $"../Player"
	
func load_level(level: int):
	player.position = Vector2i(32, 32)
	# disable previous level
	if level > 0:
		get_child(level - 1).enabled = false
			
	var level_scene = get_child(level) as TileMapLayer
	player.reparent(level_scene)
	level_scene.visible = true
	return level_scene
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
