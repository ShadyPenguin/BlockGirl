extends Node2D
const Player := preload("res://scripts/player.gd")

func _on_area_2d_body_entered(body: Node2D) -> void:
	print('entered ', body)
