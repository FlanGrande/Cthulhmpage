extends Node2D

var destructible_object_node = preload("res://scenes/explosions/destructible_object_node.tscn")
var explode_object_script = preload("res://scenes/explosions/explode_object.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_PhysicsBlock_block_destroyed():
	var do_node = destructible_object_node.instance()
	do_node.name = "destructible_object_node"
	do_node.get_node("destructible_object").set_script(explode_object_script)
	do_node.position = $PhysicsBlock.position
	do_node.rotation = $PhysicsBlock.rotation
	add_child(do_node)
	
	call_deferred("detonate", true)

func detonate(explode):
	$destructible_object_node.get_node("destructible_object").object.detonate = explode
	$destructible_object_node.get_node("destructible_object").detonate()