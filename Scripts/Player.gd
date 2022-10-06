# This allows for movement by force
extends KinematicBody2D

# What direction is the player going UP
const UP_DIRECTION = Vector2.UP

# Variables that are exposed to the inspector
export var move_speed = 2000.0
export var jump_strength = 2000.0
export var gravity_scale = 4500.0
export var high_jump_strength = 2500.0

# Private variables
var move_velocity = Vector2.ZERO

var is_falling = false	# check if we are grounded
var is_jumping = false # check if we are jumping
var is_jump_canceled = false # check if we cancelled the jump so we can have more control
var is_high_jump = false
var is_idle = false
var is_running = false
var is_deploying_hammer = false

func _process(delta):
	animate_player()
	
	# Activates/deactivates the hitbox
	$HammerHitBox/CollisionShape2D.disabled = !is_deploying_hammer

# This is equivalent to FixedUpdate
func _physics_process(delta):
	
	# Get player inputs
	get_input()
	
	## Gravity
	move_velocity.y += gravity_scale * delta
	
	## Checks for specific flags
	is_falling = move_velocity.y >= 0.0 and not is_on_floor()
	is_idle = is_on_floor() and is_zero_approx(move_velocity.x)
	is_running = is_on_floor() and not is_zero_approx(move_velocity.x)
	
	## Jumping
	if is_jumping:
		move_velocity.y = -jump_strength
	elif is_high_jump:
		move_velocity.y = -high_jump_strength
	elif is_jump_canceled:
		move_velocity.y = 0.0
	
	move_velocity = move_and_slide(move_velocity, UP_DIRECTION)

# Take player input and modify the move_velocity accordingly
func get_input():
	is_jumping = Input.is_action_just_pressed("Jump") and is_on_floor()
	is_jump_canceled = Input.is_action_just_released("Jump") and move_velocity.y < 0.0
	is_deploying_hammer = Input.is_action_pressed("deploy_hammer") and is_falling
	
	var horizontal_direction = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	move_velocity.x = horizontal_direction * move_speed

func animate_player():
	if is_on_floor():
		if is_running:
			$PlayerSprite.animation = "move"
		elif is_idle:
			$PlayerSprite.animation = "idle"
	else:
		if is_jumping:
			$PlayerSprite.animation = "jump"
		elif is_deploying_hammer:
			$PlayerSprite.animation = "deploy_hammer"
		elif is_high_jump:
			$PlayerSprite.animation = "jump_hammer"
		elif is_falling:
			# Replace with Falling Animation
			$PlayerSprite.animation = "idle"

# If we hit a platform while the hammer is out, we perform a high jump
func _on_HammerHitBox_body_entered(body):
	if body.get_owner().name == "Platform":
		is_high_jump = true
		$HammerHitBox/HammerJumpCooldown.start()


# When tthe timer ends, we stop the higher jump
func _on_HammerJumpCooldown_timeout():
	is_high_jump = false
