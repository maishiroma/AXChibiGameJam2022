extends KinematicBody2D

# Constants
const UP_DIRECTION = Vector2.UP

# Public variables to determine block behavior
export var move_rate = 2
export var move_vertical = true
export var reset_position = false
export var bounce_strength = 100.0

var original_location = Vector2.ZERO

# Private Variables
var move_velocity = Vector2.ZERO

func _ready():
	$AnimatedSprite.animation = "idle"
	original_location = position

# Determines block movement
func _physics_process(_delta):
	if reset_position:
		print("IsMoving")
	else:
		# warning-ignore:return_value_discarded
		move_and_collide(move_velocity, false)

# When the player hits this, the block moves
func _on_Player_hammer_hit(collider_name):
	if name == collider_name:
		if move_vertical == false:
			move_velocity = Vector2(1 * move_rate, 0)
		else:
			move_velocity = Vector2(0, 1 * move_rate)
		$AnimatedSprite.animation = "move"
		$AnimatedSprite.speed_scale = 5
		$AnimatedSprite.play()
		$MoveTime.start()

# Upon a set timer, the block stops moving
func _on_MoveTime_timeout():
	move_velocity = Vector2.ZERO
	$AnimatedSprite.animation = "idle"
	$AnimatedSprite.stop()
	$ResetTime.start()


# This tells the platform to move back
func _on_ResetTime_timeout():
	print("Time Reset")
	pass
