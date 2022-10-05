# This allows for movement by force
extends KinematicBody2D

# What direction is the player going UP
const UP_DIRECTION = Vector2.UP

# Variables that are exposed to the inspector
export var move_speed = 2000.0
export var jump_strength = 2000.0
export var gravity_scale = 4500.0

# Private variables
var move_velocity = Vector2.ZERO

var is_falling = false	# check if we are grounded
var is_jumping = false # check if we are jumping
var is_jump_canceled = false # check if we cancelled the jump so we can have more control

# This is equivalent to FixedUpdate
func _physics_process(delta):
	
	# Get player inputs
	get_input()
	
	## Gravity
	move_velocity.y += gravity_scale * delta
	
	## Checks for specific flags
	is_falling = move_velocity.y >= 0.0 and not is_on_floor()
	
	## Jumping
	if is_jumping:
		move_velocity.y = -jump_strength
	elif is_jump_canceled:
		move_velocity.y = 0.0
	
	move_velocity = move_and_slide(move_velocity, UP_DIRECTION)

# Take player input and modify the move_velocity accordingly
func get_input():
	is_jumping = Input.is_action_just_pressed("Jump") and is_on_floor()
	is_jump_canceled = Input.is_action_just_released("Jump") and move_velocity.y < 0.0
	
	var horizontal_direction = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	move_velocity.x = horizontal_direction * move_speed
