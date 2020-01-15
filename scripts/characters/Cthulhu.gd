extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed = Vector2(0, 0)
var speed_factor = 1
var walk_speed = 80.0
var climb_speed = 120.0
var gravity = 50.0

var can_climb = false
var climbing = false
var current_building_to_climb_anchor

# Called when the node enters the scene tree for the first time.
func _ready():
	speed = Vector2(0, gravity)
	can_climb = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move_and_slide(speed_factor * speed, Vector2(0, -1))
	
	if(climbing and is_on_floor()):
		climbing = false

func _input(event):
	if(can_climb and not climbing and Input.is_action_pressed("ui_up")):
		climbing = true
		hug_wall()
	
	if(climbing):
		if(Input.is_action_pressed("ui_up")):
			speed.y = -climb_speed
		elif(Input.is_action_pressed("ui_down")):
			speed.y = climb_speed
		else:
			speed.y = 0
	else:
		speed.y = gravity
	
	if(not climbing):
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
	if(current_building_to_climb_anchor.name == "Left"):
		position.x = current_building_to_climb_anchor.global_position.x - $Sprite.texture.get_width()/2
		
	if(current_building_to_climb_anchor.name == "Right"):
		position.x = current_building_to_climb_anchor.global_position.x

func _on_Area2D_area_shape_entered(area_id, area, area_shape, self_shape):
	if(area.get_parent().is_in_group("buildings")):
		current_building_to_climb_anchor = area.get_children()[area_shape]
		print(current_building_to_climb_anchor)
		can_climb = true

func _on_Area2D_area_shape_exited(area_id, area, area_shape, self_shape):
	if(area.get_parent().is_in_group("buildings")):
		can_climb = false
