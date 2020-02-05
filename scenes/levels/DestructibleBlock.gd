extends Node2D

var destruction_particles_node = preload("res://scenes/explosions/destructible_object_node.tscn")
var explode_object_script = preload("res://scenes/explosions/explode_object.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_PhysicsBlock_block_destroyed():
	var dp_node = destruction_particles_node.instance()
	dp_node.name = "destructible_object_node"
	dp_node.get_node("destructible_object").set_script(explode_object_script)
	add_child(dp_node)
	
	call_deferred("detonate")

func detonate():
	$destructible_object_node.get_node("destructible_object").object.detonate = true
	$destructible_object_node.get_node("destructible_object").detonate()