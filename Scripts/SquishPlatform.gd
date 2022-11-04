extends KinematicBody2D

# Constants
const UP_DIRECTION = Vector2.UP

# Public variables to determine block behavior
export var move_rate = 2
export var move_vertical = true

# Private Variables
var move_velocity = Vector2.ZERO

# Determines block movement
func _physics_process(_delta):
	# warning-ignore:return_value_discarded
	move_and_collide(move_velocity, false)

# When the player hits this, the block moves
func _on_Player_hammer_hit():
	if move_vertical == false:
		move_velocity = Vector2(1 * move_rate, 0)
	else:
		move_velocity = Vector2(0, 1 * move_rate)
	$MoveTime.start()

# Upon a set timer, the block stops moving
func _on_MoveTime_timeout():
	move_velocity = Vector2.ZERO
