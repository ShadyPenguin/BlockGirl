extends Node2D
class_name Player

@onready var above_right := $AboveRight
@onready var above := $Above
@onready var above_above_right := $AboveAboveRight
@onready var above_left := $AboveLeft
@onready var above_above_left := $AboveAboveLeft
@onready var down := $Down
@onready var right := $Right
@onready var left := $Left
@onready var texture_rect: TextureRect = $TextureRect
@onready var below_left := $BelowLeft
@onready var below_right := $BelowRight

var direction = -1
var holding_block = false
var falling := false
var level
var level_index: int = 0
@onready var side_collision = {-1: left.is_colliding, 1: right.is_colliding}
@onready var above_side_collision = {-1: above_left.is_colliding, 1: above_right.is_colliding}
@onready var above_above_side_collision = {-1: above_above_left.is_colliding, 1: above_above_right.is_colliding}
@onready var below_side_collision = {-1: below_left.is_colliding, 1: below_right.is_colliding}

func _ready() -> void:
	level = get_parent()
	
func next_level():
	level_index += 1
	level = level.get_parent().load_level(level_index)
	reparent(level)
	position = Vector2i(32, 32)
	
var step_global_coordinate: Vector2:
	get: return Vector2i(self.position.x + (direction * 64), self.position.y)
	
var step_local_coordinate: Vector2i:
	get: return level.local_to_map(step_global_coordinate)

var climb_coordinate: Vector2i:
	get: return level.local_to_map(Vector2i(self.position.x + (direction * 64), self.position.y - 64))

var coords_in_front: Vector2:
	get: return level.local_to_map(Vector2i(self.position.x + (direction * 64), self.position.y))

func select_block():
	for block in level.get_children():
		if level.local_to_map(block.position) == step_local_coordinate:
			return block

func select_block_above():
	for block in level.get_children():
		if level.local_to_map(block.position) == climb_coordinate:
			return block

func walk():
	self.position.x = self.position.x + (direction * 64)

func climb():
	var y = round(self.position.y - 64)
	var x = round(self.position.x + (direction * 64))
	self.position = Vector2i(x, y)
		
func pick_up_block():
	var block = select_block()
	if not block:
		return
	
	# if blocks are stacked
	if select_block_above():
		return
	
	# tile above self
	if above.is_colliding():
		return
		
	#if level.get_cell_tile_data(climb_coordinate):
	holding_block = block
	level.remove_child(block)
	texture_rect.visible = true
		

func place_down_block():
	var offset = 0
	# if nothing there, put it down
	if side_collision[direction].call():
		if above_side_collision[direction].call():
			return
		offset = -1
		
	if not below_side_collision[direction].call():
		return
			
	holding_block.position.x = step_global_coordinate.x
	holding_block.position.y = step_global_coordinate.y + (offset * 64)
	level.add_child(holding_block)
	holding_block = null
	texture_rect.visible = false
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		get_parent().get_parent().load_level(level_index)
		position = Vector2i(32, 32)
		return
		
	if Input.is_action_just_pressed("Action"):
		if holding_block:
			place_down_block()
		else:
			pick_up_block()
	
	if Input.is_action_just_pressed("Left"):
		direction = -1
		if left.is_colliding():
			return
			
		if holding_block and above_left.is_colliding():
			return
			
		walk()
	
	if Input.is_action_just_pressed("Right"):
		direction = 1
		if right.is_colliding():
			return
		
		if holding_block and above_right.is_colliding():
			return
			
		walk()
			
	if Input.is_action_just_pressed("Up"):
		# can only climb on a tile
		if not side_collision[direction].call():
			return
		
		if above.is_colliding():
			return
			
		# square above climbable tile is not empty
		if above_side_collision[direction].call():
			return
		
		# square above the tile above climbable tile is not empty
		if holding_block and above_above_side_collision[direction].call():
			return
			
		climb()

func _process(delta: float) -> void:
	falling = !down.is_colliding()
	if level:
		var tile = level.get_cell_tile_data(level.local_to_map(position))
		if tile:
			if tile.get_custom_data('exit'):
				next_level()
	
func _physics_process(delta: float) -> void:
	if falling:
		self.position.y += 64
