extends StaticBody2D

# Public variables
export var respawn_time = 5
export var bounce_strength = 100.0

# Sets up the timer
func _ready():
	$Timer.wait_time = respawn_time
	$AnimatedSprite.animation = "idle"

# When the player hits this, the block dissapears
func _on_Player_hammer_hit(collider_name):
	if name == collider_name:
		$CollisionShape2D.set_deferred("disabled", true)
		# If this block has a positive spawn time, this will respawn
		# if not, the block never respawns
		if respawn_time > 0:
			$Timer.start()
			$AnimatedSprite.animation = "break"
			$AnimatedSprite.speed_scale = 2
			$AnimatedSprite.play()

# After the timer goes off, the block can be interacted again
func _on_Timer_timeout():
	$AnimatedSprite.animation = "revert"
	$AnimatedSprite.play()

# Once the specific animation plays once, we stop it
func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.get_animation() == "break":
		$AnimatedSprite.animation = "empty"
	elif $AnimatedSprite.get_animation() == "revert":
		$AnimatedSprite.animation = "idle"
		$CollisionShape2D.set_deferred("disabled", false)
	$AnimatedSprite.stop()
	$AnimatedSprite.speed_scale = 1

