extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_PhysicsBlock_block_destroyed():
	$destructible_object_node.visible = true
	$destructible_object_node.get_node("destructible_object").detonate()
	pass # Replace with function body.
