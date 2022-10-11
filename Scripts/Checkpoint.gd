extends Area2D

signal activated_checkpoint

var is_activated = false

func _on_Checkpoint_body_entered(body):
	if body.is_in_group("Player") and !is_activated:
		is_activated = true
		$AnimatedSprite.animation = "activate"
		
		for curr_node in get_tree().get_nodes_in_group("Checkpoint"):
			if curr_node.name != name:
				curr_node.deactivate_checkpoint()
		
		emit_signal("activated_checkpoint")

func deactivate_checkpoint():
	is_activated = false
	$AnimatedSprite.animation = "deactivate"
