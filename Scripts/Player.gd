# This allows for movement by force
extends KinematicBody2D

signal spring_door_activate

# What direction is the player going UP
const UP_DIRECTION = Vector2.UP

# Variables that are exposed to the inspector
export var move_speed = 2000.0
export var jump_strength = 2000.0
export var gravity_scale = 4500.0
export var high_jump_mod = 0.5
export var max_high_jumps = 3

# Private variables
var move_velocity = Vector2.ZERO
var numb_high_jumps = 0
var curr_high_jump_strength = 0.0

var saved_checkpoint = Vector2.ZERO

var is_falling = false	# check if we are grounded
var is_jumping = false # check if we are jumping
var is_jump_canceled = false # check if we cancelled the jump so we can have more control
var is_high_jump = false # check if we are in a high jump
var is_idle = false	# are we standing still
var is_running = false # are we moving?
var is_deploying_hammer = false # are we deploying the hammer?

# Saves the player's initial position as the initial checkpoint
func _ready():
	_on_Checkpoint_activated_checkpoint()

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
		move_velocity.y = -curr_high_jump_strength
	elif is_jump_canceled:
		move_velocity.y = 0.0
		
	if is_on_floor() and numb_high_jumps > 0:
		numb_high_jumps = 0
		curr_high_jump_strength = 0.0
	
	move_velocity = move_and_slide(move_velocity, UP_DIRECTION)

# Take player input and modify the move_velocity accordingly
func get_input():
	is_jumping = Input.is_action_just_pressed("Jump") and is_on_floor()
	is_jump_canceled = Input.is_action_just_released("Jump") and move_velocity.y < 0.0
	
	if Input.is_action_just_pressed("deploy_hammer") and is_falling and numb_high_jumps < max_high_jumps:
		is_deploying_hammer = true
		$HammerHitBox/HammerInput.start()

	var horizontal_direction = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	move_velocity.x = horizontal_direction * move_speed

# Animtes the player with sprites
func animate_player():
	if is_on_floor():
		if is_running:
			$PlayerSprite.animation = "move"
		elif is_idle:
			$PlayerSprite.animation = "idle"
	else:
		if is_jumping:
			$PlayerSprite.animation = "jump"
		elif is_high_jump:
			$PlayerSprite.animation = "jump_hammer"
		elif is_deploying_hammer:
			$PlayerSprite.animation = "deploy_hammer"
		elif is_falling:
			# Replace with Falling Animation
			$PlayerSprite.animation = "idle"

# Saves the current position of the player and camera
func save_spawn():
	saved_checkpoint = position
	for curr_node in get_tree().get_nodes_in_group("MainCamera"):
		curr_node.saved_camera_position = curr_node.position

# Respawns the player back to the last saved location
func respawn():
	is_falling = false
	is_jumping = false
	is_jump_canceled = false
	is_high_jump = false
	is_idle = false
	is_running = false
	is_deploying_hammer = false
	curr_high_jump_strength = 0.0
	numb_high_jumps = 0
	
	position = saved_checkpoint
	for curr_node in get_tree().get_nodes_in_group("MainCamera"):
		curr_node.position = curr_node.saved_camera_position

# If we hit a platform while the hammer is out, we perform a high jump
func _on_HammerHitBox_body_entered(body):
	if body.is_in_group("Ground"):
		is_deploying_hammer = false
		is_high_jump = true
		if numb_high_jumps < max_high_jumps:
			numb_high_jumps += 1
			curr_high_jump_strength = lerp(curr_high_jump_strength, jump_strength * 2, high_jump_mod)
			$HammerHitBox/HammerJumpCooldown.start()
		else:
			is_high_jump = false
	elif body.is_in_group("Enemy"):
		numb_high_jumps = 1
		is_deploying_hammer = false
		is_high_jump = true
		curr_high_jump_strength = lerp(curr_high_jump_strength, jump_strength * 1.1, high_jump_mod)
		$HammerHitBox/HammerJumpCooldown.start()
	elif body.is_in_group("SpringDoor"):
		emit_signal("spring_door_activate")


# When the timer ends, we stop the higher jump
func _on_HammerJumpCooldown_timeout():
	is_high_jump = false

# Upon activation, we save the player's position as well as the camera
func _on_Checkpoint_activated_checkpoint():
	save_spawn()

# On touching a Death Plane, we move back to the last checkpoint we touched
func _on_DeathPlane_body_entered(body):
	respawn()

# After a set time, we disenage the hammer
func _on_HammerInput_timeout():
	is_deploying_hammer = false;

# When the player touches an enemy, they are sent back to the last spawn
func _on_Enemy_damage_player():
	respawn()
