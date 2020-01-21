extends KinematicBody2D

enum State {
	STATE_WALK,
	STATE_CLIMB,
	STATE_FALL,
	STATE_JUMP,
	STATE_GLIDE
}

var current_state = State.STATE_WALK


var gravity = 160.0
var speed_factor = 1
var speed = Vector2(0, gravity * speed_factor)
var walk_speed = 80.0
var climb_speed = 120.0
var jump_speed = Vector2(100.0, -120.0)
var glide_speed = Vector2(320.0, 40.0)

var current_building_to_climb_anchor_node : Node
var can_climb = false
var falling = false

# Called when the node enters the scene tree for the first time.
func _ready():
	current_state = State.STATE_FALL

func _process(delta):
	handle_input()
	update()
	pass

func update():
	print("STATE: " + str(current_state))
	
	if(current_state != State.STATE_CLIMB and current_state != State.STATE_JUMP and current_state != State.STATE_GLIDE):
		if(not is_on_floor()):
			current_state = State.STATE_FALL
		else:
			current_state = State.STATE_WALK
	
	if(current_state == State.STATE_CLIMB and not can_climb):
		current_state = State.STATE_FALL

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move_and_slide(speed_factor * speed, Vector2(0, -1))

func _input(event):
	if(Input.is_action_pressed("ui_exit")):
		get_tree().quit()

func handle_input():
	#print(str(current_state))
	
	match current_state:
		State.STATE_WALK:
			if(Input.is_action_pressed("ui_left")):
				speed.x = -walk_speed
			elif(Input.is_action_pressed("ui_right")):
				speed.x = walk_speed
			else:
				speed.x = 0
				
			if(can_climb and (Input.is_action_pressed("ui_up"))):
				current_state = State.STATE_CLIMB
				hug_wall()
			
			if(not can_climb and is_on_floor() and Input.is_action_pressed("ui_up")):
				speed = Vector2(sign(speed.x) * jump_speed.x, jump_speed.y)
				current_state = State.STATE_JUMP
		
		State.STATE_CLIMB:
			speed.x = 0
			
			if(Input.is_action_pressed("ui_up")):
				speed.y = -climb_speed
			elif(Input.is_action_pressed("ui_down")):
				speed.y = climb_speed
				
				if(is_on_floor()):
					current_state = State.STATE_WALK
			else:
				speed.y = 0
		
		State.STATE_FALL:
			speed = Vector2(0, gravity * speed_factor)
			#if floor -> WALK (or fall damage)
		
		State.STATE_JUMP:
			speed += Vector2(0, 4.0)
			
			if(is_on_floor()):
				current_state = State.STATE_WALK
			
			if(Input.is_action_just_pressed("ui_up")):
				if(can_climb):
					current_state = State.STATE_CLIMB
					hug_wall()
				else:
					current_state = State.STATE_GLIDE
		
		State.STATE_GLIDE:
			speed = Vector2(glide_speed.x * sign(speed.x), glide_speed.y)
			
			if(is_on_floor()):
				current_state = State.STATE_WALK
			
			if(can_climb and Input.is_action_pressed("ui_up")):
				current_state = State.STATE_CLIMB
				hug_wall()

func hug_wall():
	if(current_building_to_climb_anchor_node.name == "Left"):
		position.x = current_building_to_climb_anchor_node.global_position.x - $Sprite.texture.get_width()/2.0
	
	if(current_building_to_climb_anchor_node.name == "Right"):
		position.x = current_building_to_climb_anchor_node.global_position.x

func _on_Area2D_area_shape_entered(area_id, area, area_shape, self_shape):
	#TO DO yield an array of close walls and pick the closest one
	print(area.get_parent().name + " IN")
	if(area.get_parent().is_in_group("buildings")):
		current_building_to_climb_anchor_node = area.get_children()[area_shape]
		can_climb = true

func _on_Area2D_area_shape_exited(area_id, area, area_shape, self_shape):
	print(area.get_parent().name + " OUT")
	if(area.get_parent().is_in_group("buildings")):
		can_climb = false

func _on_Area2D_body_shape_entered(body_id, body, body_shape, area_shape):
	print(body.get_parent().name + " IN")
	if(body.get_parent().is_in_group("ceilings")):
		#can_climb = false
		position = Vector2(position.x, body.global_position.y - $Sprite.texture.get_height()/2 - 16)

func _on_Area2D_body_shape_exited(body_id, body, body_shape, area_shape):
	print(body.get_parent().name + " OUT")
	if(body.get_parent().is_in_group("ceilings")):
		#can_climb = false
		#speed.y = 0
		pass