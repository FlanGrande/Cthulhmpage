extends RigidBody2D

signal block_destroyed

export var scale_factor = Vector2(1, 1)
export var hit_points = 100
export var offset_on_punch = false

# If the block is rotated in a direction, this part of the block is facing upwards.
# 0 degrees, upwards side is TOP.
# 90 degrees, upwards side is the LEFT.
# 180 degrees, upwards side is BOTTOM.
# 270 degrees, upwards side is the RIGHT side.
enum UPWARDS_DIRECTION {
	TOP,
	RIGHT,
	BOTTOM,
	LEFT
}

var physics_enabled = false
var falling_apart = false

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	change_animation("idle")
	switch_climbing_borders(false)
	switch_collision_borders(UPWARDS_DIRECTION.TOP)
	
#	print("//////////////////////START")
#
#	print("Sprite position:\t\t", $Sprite.position)
#	print("Sprite scale:\t\t", $Sprite.scale)
#	print("CollisionShape2D Position:\t\t", $CollisionShape2D.position)
#	print("CollisionShape2D scale:\t\t", $CollisionShape2D.scale)
#	print("ClimbingTop Position:\t\t", $ClimbingAreas/Top.position)
#	print("ClimbingTop scale:\t\t", $ClimbingAreas/Top.scale)
#	print("CollTop Position:\t\t", $Colliders/CollTop.position)
#	print("CollTop scale:\t\t", $Colliders/CollTop.scale)
#	print("//////////////////////")
	
	fit_to_scale(scale_factor)
	
#	print("//////////////////////")
#	print("Sprite position:\t\t", $Sprite.position)
#	print("Sprite scale:\t\t", $Sprite.scale)
#	print("CollisionShape2D Position:\t\t", $CollisionShape2D.position)
#	print("CollisionShape2D scale:\t\t", $CollisionShape2D.scale)
#	print("ClimbingTop Position:\t\t", $ClimbingAreas/Top.position)
#	print("ClimbingTop scale:\t\t", $ClimbingAreas/Top.scale)
#	print("CollTop Position:\t\t", $Colliders/CollTop.position)
#	print("CollTop scale:\t\t", $Colliders/CollTop.scale)
#
#	print("//////////////////////END")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# warning-ignore:unused_argument
func _physics_process(delta):
	if(physics_enabled):
		var rot = abs(int(rotation_degrees))
		var sin_x = stepify(sin(rotation), 0.1)
		var cos_x = stepify(cos(rotation), 0.1)
		
		var orientation = Vector2(cos_x, sin_x)
		
		match orientation:
			Vector2(1.0, 0.0):
				switch_climbing_borders(false)
				switch_collision_borders(UPWARDS_DIRECTION.TOP)
			Vector2(0.0, 1.0):
				switch_climbing_borders(true)
				switch_collision_borders(UPWARDS_DIRECTION.LEFT)
			Vector2(-1.0, 0.0):
				switch_climbing_borders(false)
				switch_collision_borders(UPWARDS_DIRECTION.BOTTOM)
			Vector2(0.0, -1.0):
				switch_climbing_borders(true)
				switch_collision_borders(UPWARDS_DIRECTION.RIGHT)
	else:
		check_RayCasts()

func check_RayCasts():
	if(not falling_apart and not $RayCastBottom.is_colliding() and (not $RayCastRight.is_colliding() or not $RayCastLeft.is_colliding())):
		start_falling_apart()

func start_falling_apart():
	change_animation("falling_apart")
	$FallingApartTimer.start()
	falling_apart = true

func enable_physics():
	physics_enabled = true
	mode = RigidBody2D.MODE_RIGID
	apply_impulse(Vector2(), Vector2(0, 0.0001))

func change_animation(new_animation_name):
	if($AnimationPlayer.current_animation != new_animation_name):
		$AnimationPlayer.play(new_animation_name)

func switch_climbing_borders(invert):
	var climbing_areas = $ClimbingAreas.get_children()
	
	climbing_areas[0].disabled = not invert #Top
	climbing_areas[1].disabled = invert #Right
	climbing_areas[2].disabled = not invert #Bottom
	climbing_areas[3].disabled = invert #Left

func switch_collision_borders(upwards_side):
	var colliders = $Colliders.get_children()
	
	match upwards_side:
		UPWARDS_DIRECTION.TOP:
			colliders[0].get_node("CollisionShape2D").disabled = false #Top
			colliders[1].get_node("CollisionShape2D").disabled = true #Right
			colliders[2].get_node("CollisionShape2D").disabled = true #Bottom
			colliders[3].get_node("CollisionShape2D").disabled = true #Left
		UPWARDS_DIRECTION.RIGHT:
			colliders[0].get_node("CollisionShape2D").disabled = true #Top
			colliders[1].get_node("CollisionShape2D").disabled = false #Right
			colliders[2].get_node("CollisionShape2D").disabled = true #Bottom
			colliders[3].get_node("CollisionShape2D").disabled = true #Left
		UPWARDS_DIRECTION.BOTTOM:
			colliders[0].get_node("CollisionShape2D").disabled = true #Top
			colliders[1].get_node("CollisionShape2D").disabled = true #Right
			colliders[2].get_node("CollisionShape2D").disabled = false #Bottom
			colliders[3].get_node("CollisionShape2D").disabled = true #Left
		UPWARDS_DIRECTION.LEFT:
			colliders[0].get_node("CollisionShape2D").disabled = true #Top
			colliders[1].get_node("CollisionShape2D").disabled = true #Right
			colliders[2].get_node("CollisionShape2D").disabled = true #Bottom
			colliders[3].get_node("CollisionShape2D").disabled = false #Left

func fit_to_scale(factor):
	# Sprite
	$Sprite.scale *= factor
	
	# Collision Shape
	$CollisionShape2D.scale *= factor
	
	# Climbing Areas
	$ClimbingAreas/Top.position *= factor
	$ClimbingAreas/Top.scale *= factor
	$ClimbingAreas/Right.position *= factor
	$ClimbingAreas/Right.scale *= factor
	$ClimbingAreas/Bottom.position *= factor
	$ClimbingAreas/Bottom.scale *= factor
	$ClimbingAreas/Left.position *= factor
	$ClimbingAreas/Left.scale *= factor
	
	# Colliders
	$Colliders/CollTop.position *= factor
	$Colliders/CollTop.scale *= factor
	$Colliders/CollRight.position *= factor
	$Colliders/CollRight.scale *= Vector2(factor.y, factor.x) # This collider is rotated 90 degrees
	$Colliders/CollBottom.position *= factor
	$Colliders/CollBottom.scale *= factor
	$Colliders/CollLeft.position *= factor
	$Colliders/CollLeft.scale *= Vector2(factor.y, factor.x) # This collider is rotated 90 degrees

func _on_ClimbingAreas_body_entered(body):
	if(body.is_in_group("punch")):
		if(offset_on_punch):
			position.x = floor(rand_range(0, 6) - 3)
			position.y = floor(rand_range(0, 6) - 3)
		
		call_deferred("hit_received", 35)
	
	if(body.is_in_group("block") and body.mode == RigidBody2D.MODE_RIGID):
		call_deferred("hit_received", 1)
	
	if(body.is_in_group("floor") and body.mode == RigidBody2D.MODE_RIGID):
		call_deferred("hit_received", 200)

func hit_received(damage_amount):
	if(not $AnimationPlayer.is_playing()):
		change_animation("hit_received")
	
	hit_points -= damage_amount
	
	if(hit_points <= 0):
		enable_physics()
	
	if(hit_points <= -100):
		destroy()

func destroy():
	emit_signal("block_destroyed")
	queue_free()

func _on_FallingApartTimer_timeout():
	falling_apart = false
	change_animation("idle")
	enable_physics()
