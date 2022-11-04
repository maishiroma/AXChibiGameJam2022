extends StaticBody2D

# Public variables
export var respawn_time = 5

# Sets up the timer
func _ready():
	$Timer.wait_time = respawn_time

# When the player hits this, the block dissapears
func _on_Player_hammer_hit():
	$CollisionShape2D.set_deferred("disabled", true)
	# If this block has a positive spawn time, this will respawn
	# if not, the block never respawns
	if respawn_time > 0:
		$Timer.start()

# After the timer goes off, the block can be interacted again
func _on_Timer_timeout():
	$CollisionShape2D.set_deferred("disabled", false)
