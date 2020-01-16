extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var gravity = 180.0
var speed_factor = 1
var speed = Vector2(0, gravity * speed_factor)
var walk_speed = 80.0
var climb_speed = 120.0

var current_building_to_climb_anchor_node : Node
var can_climb = false
var climbing = false
var falling = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if(not climbing and not is_on_floor()):
		falling = true
		print("HOLA")
		speed = Vector2(0, gravity * speed_factor)
	
	move_and_slide(speed_factor * speed, Vector2(0, -1))
	
	if(climbing and is_on_floor()):
		climbing = false
	
	#print("CLIMBING: " + str(climbing))
	#print("CAN CLIMB: " + str(can_climb))
	
	if(is_on_floor()):
		falling = false

func _input(event):
	if(Input.is_action_pressed("ui_up")):
		set_collision_mask_bit(1, 1)
	
	if(Input.is_action_pressed("ui_down") and not climbing):
		set_collision_mask_bit(1, 0)
	
	if(can_climb and not climbing and (Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"))):
		climbing = true
		hug_wall()
	
	if(can_climb and climbing):
		if(Input.is_action_pressed("ui_up")):
			speed.y = -climb_speed
		elif(Input.is_action_pressed("ui_down")):
			speed.y = climb_speed
		else:
			speed.y = 0
	else:
		speed.y = gravity
	
	if(not climbing and not falling):
		if(Input.is_action_pressed("ui_left")):
			speed.x = -walk_speed
		elif(Input.is_action_pressed("ui_right")):
			speed.x = walk_speed
		else:
			speed.x = 0
	else:
		speed.x = 0
	
	if(Input.is_action_pressed("ui_exit")):
		get_tree().quit()

func hug_wall():
	if(current_building_to_climb_anchor_node.name == "Left"):
		position.x = current_building_to_climb_anchor_node.global_position.x - $Sprite.texture.get_width()/2.0
	
	if(current_building_to_climb_anchor_node.name == "Right"):
		position.x = current_building_to_climb_anchor_node.global_position.x

func _on_Area2D_area_shape_entered(area_id, area, area_shape, self_shape):
	print(area.get_parent().name + " IN")
	if(area.get_parent().is_in_group("buildings")):
		current_building_to_climb_anchor_node = area.get_children()[area_shape]
		can_climb = true

func _on_Area2D_area_shape_exited(area_id, area, area_shape, self_shape):
	print(area.get_parent().name + " OUT")
	if(area.get_parent().is_in_group("buildings")):
		can_climb = false
		climbing = false
		speed.y = 0

func _on_Area2D_body_shape_entered(body_id, body, body_shape, area_shape):
	print(body.get_parent().name + " IN")
	#if(body.get_parent().is_in_group("ceilings")):
	#	can_climb = false

func _on_Area2D_body_shape_exited(body_id, body, body_shape, area_shape):
	print(body.get_parent().name + " OUT")
	if(body.get_parent().is_in_group("ceilings")):
		can_climb = false
		climbing = false
		speed.y = 0