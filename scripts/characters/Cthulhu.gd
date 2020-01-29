extends KinematicBody2D

enum State {
	STATE_WALK,
	STATE_CLIMB,
	STATE_FALL,
	STATE_JUMP,
	STATE_GLIDE,
	STATE_ATTACK
}

var current_state = State.STATE_WALK


var gravity = 160.0
var speed_factor = 1
var speed = Vector2(0, gravity * speed_factor)
var walk_speed = 80.0
var climb_speed = 120.0
var jump_speed = Vector2(100.0, -120.0)
var glide_speed = Vector2(320.0, 40.0)

# Array containing the nearest buildings, sorted by distance (first item is the closest)
var nearest_buildings_array = []

var current_building_to_climb_anchor_node : Node
var can_climb = false
var falling = false
var attacking = false
var state_after_attack = State.STATE_WALK

# Called when the node enters the scene tree for the first time.
func _ready():
	current_state = State.STATE_FALL
	change_animation("idle")

func _process(delta):
	handle_input()
	update()
	pass

func update():
	#print("CURRENT STATE: " + str(current_state))
	
	if(nearest_buildings_array.size() > 0):
		can_climb = true
	else:
		can_climb = false
	
	if(not $AnimationPlayer.is_playing()):
		current_state = state_after_attack
		attacking = false
		change_animation("idle")
	
	match current_state:
		State.STATE_WALK:
			if(not is_on_floor()):
				current_state = State.STATE_FALL
			else:
				current_state = State.STATE_WALK
		
		State.STATE_CLIMB:
			if(not can_climb and not attacking):
				current_state = State.STATE_FALL
			pass
		
		State.STATE_FALL:
			if(not is_on_floor()):
				current_state = State.STATE_FALL
			else:
				current_state = State.STATE_WALK
		
		State.STATE_JUMP:
			pass
		
		State.STATE_GLIDE:
			pass
		
		State.STATE_ATTACK:
			pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move_and_slide(speed_factor * speed, Vector2(0, -1))

func _input(event):
	if(Input.is_action_pressed("ui_exit")):
		get_tree().quit()

func change_animation(new_animation_name):
	if($AnimationPlayer.current_animation != new_animation_name):
		$AnimationPlayer.play(new_animation_name)

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
			
			if(is_on_floor() and Input.is_action_pressed("jump")):
				speed = Vector2(sign(speed.x) * jump_speed.x, jump_speed.y)
				current_state = State.STATE_JUMP
			
			if(Input.is_action_pressed("attack")):
				attack(State.STATE_WALK)
		
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
			
			if(Input.is_action_pressed("attack")):
				attack(State.STATE_CLIMB)
		
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
			
			if(Input.is_action_just_pressed("jump")):
				current_state = State.STATE_GLIDE
		
		State.STATE_GLIDE:
			speed = Vector2(glide_speed.x * sign(speed.x), glide_speed.y)
			
			if(is_on_floor()):
				current_state = State.STATE_WALK
			
			if(can_climb and Input.is_action_pressed("ui_up")):
				current_state = State.STATE_CLIMB
				hug_wall()
			
			if(not is_on_floor() and Input.is_action_pressed("ui_down")):
				current_state = State.STATE_FALL
		
		State.STATE_ATTACK:
			#speed = Vector2(0, 0)
			current_state = state_after_attack

func hug_wall():
	#if(current_building_to_climb_anchor_node.name == "Left"):
	#	position.x = current_building_to_climb_anchor_node.global_position.x - $Sprite.texture.get_width()/2.0
	
	#if(current_building_to_climb_anchor_node.name == "Right"):
	#	position.x = current_building_to_climb_anchor_node.global_position.x
	pass

func attack(state):
	state_after_attack = state
	current_state = State.STATE_ATTACK
	change_animation("attack")
	attacking = true

#class MyCustomBuildingsByDistanceSorter:
#    static func sort(area_a, area_b):
#		area_a.get_children()[area_shape]
#        if area_a. < area_b[0]:
#            return true
#        return false

func _on_Area2D_area_shape_entered(area_id, area, area_shape, self_shape):
	#TO DO yield an array of close walls and pick the closest one
	#print(area.get_parent().name + " IN")
	if(area.get_parent().is_in_group("buildings")):
		nearest_buildings_array.push_back(area)
		#current_building_to_climb_anchor_node = area.get_children()[area_shape]
		#can_climb = true

func _on_Area2D_area_shape_exited(area_id, area, area_shape, self_shape):
	#print(area.get_parent().name + " OUT")
	if(area.get_parent().is_in_group("buildings")):
		nearest_buildings_array.remove(nearest_buildings_array.find(area))
		#can_climb = false

func _on_Area2D_body_shape_entered(body_id, body, body_shape, area_shape):
	#print(body.get_parent().name + " IN")
	if(body.get_parent().is_in_group("ceilings")):
		#can_climb = false
		position = Vector2(global_position.x, body.global_position.y - $Sprite.texture.get_height()/2 - 16)

func _on_Area2D_body_shape_exited(body_id, body, body_shape, area_shape):
	#print(body.get_parent().name + " OUT")
	if(body.get_parent().is_in_group("ceilings")):
		#can_climb = false
		#speed.y = 0
		pass