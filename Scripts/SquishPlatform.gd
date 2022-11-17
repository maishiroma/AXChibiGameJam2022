extends KinematicBody2D

# Constants
const UP_DIRECTION = Vector2.UP

# Public variables to determine block behavior
export var move_rate = 2
export var move_vertical = true
export var reset_position = false
export var time_to_reset = 0.5
export var bounce_strength = 100.0

# Private Variables
var move_velocity = Vector2.ZERO
var original_location = Vector2.ZERO
var is_returning = false

func _ready():
	$AnimatedSprite.animation = "idle"
	original_location = position

# Determines block movement
func _physics_process(_delta):
	if reset_position and is_returning:
		# If we are resetting the block's position we do it gradually
		var result = position - original_location
		if int(result.length_squared()) != 0:
			determine_movement(move_rate * -1)
			position += move_velocity
		else:
			position = original_location
			move_velocity = Vector2.ZERO
			is_returning = false
	else:
		# warning-ignore:return_value_discarded
		move_and_collide(move_velocity, false)


func determine_movement(speed):
	if move_vertical == false:
		move_velocity = Vector2(1 * speed, 0)
	else:
		move_velocity = Vector2(0, 1 * speed)

# When the player hits this, the block moves
func _on_Player_hammer_hit(collider_name):
	if name == collider_name:
		determine_movement(move_rate)
		$AnimatedSprite.animation = "move"
		$AnimatedSprite.speed_scale = 5
		$AnimatedSprite.play()
		if $ResetTime.time_left > 0:
			is_returning = false
			$ResetTime.stop()
		$MoveTime.start()

# Upon a set timer, the block stops moving
func _on_MoveTime_timeout():
	move_velocity = Vector2.ZERO
	$AnimatedSprite.animation = "idle"
	$AnimatedSprite.stop()
	$ResetTime.start(time_to_reset)

# This tells the platform to move back
func _on_ResetTime_timeout():
	is_returning = true
