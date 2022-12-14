# This allows for movement by force
extends KinematicBody2D

signal spring_door_activate(collider_name)
signal hit_enemy(collider_name)
signal hammer_interact(collider_name)

# What direction is the player going UP
const UP_DIRECTION = Vector2.UP

# Variables that are exposed to the inspector
export var move_speed = 2000.0
export var jump_strength = 2000.0
export var gravity_scale = 4500.0
export var high_jump_mod = 0.5
export var max_high_jumps = 3
export var ground_bounce = 4000.0
export var weak_ground_bounce = 400.0
export var acceleration_speed = 0.05
export var deacceleration_speed = 0.1

# Private variables
var move_velocity = Vector2.ZERO
var numb_high_jumps = 0
var curr_high_jump_strength = 0.0

var saved_checkpoint = Vector2.ZERO

var can_input = true
var is_falling = false	# check if we are grounded
var is_jumping = false # check if we are jumping
var is_jump_canceled = false # check if we cancelled the jump so we can have more control
var is_high_jump = false # check if we are in a high jump
var is_idle = false	# are we standing still
var is_running = false # are we moving?
var is_deploying_hammer = false # are we deploying the hammer?

var MainCameraNode

# Saves the player's initial position as the initial checkpoint
func _ready():
	_on_Checkpoint_activated_checkpoint()
	
	# Cool trick to auto connect nodes together dynamically
	# Since some of these can be spawned dynamically
	if get_tree().get_nodes_in_group("MainCamera").size() == 1:
		MainCameraNode = get_tree().get_nodes_in_group("MainCamera")[0]
	if get_tree().get_nodes_in_group("SpringDoor").size() > 0:
		for currOne in get_tree().get_nodes_in_group("SpringDoor"):
			# warning-ignore:return_value_discarded
			self.connect("spring_door_activate", currOne, "_on_Player_spring_door_activate")
	if get_tree().get_nodes_in_group("HammerInteract").size() > 0:
		for currOne in get_tree().get_nodes_in_group("HammerInteract"):
			# warning-ignore:return_value_discarded
			self.connect("hammer_interact", currOne, "_on_Player_hammer_hit")	

func _process(_delta):
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
	if can_input:
		if Input.is_action_just_pressed("Jump") and is_on_floor():
			is_jumping = true
			$PlayerSprite.animation = "jump"
			$PlayerSounds/Jump.play()
		else:
			is_jumping = false
		is_jump_canceled = Input.is_action_just_released("Jump") and move_velocity.y < 0.0
		
		if Input.is_action_just_pressed("deploy_hammer") and is_falling:
			is_deploying_hammer = true
			$PlayerSprite.animation = "deploy_hammer_start"
			$PlayerSprite.speed_scale = 3
			$HammerHitBox/HammerInput.start()

		var horizontal_direction = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
		if horizontal_direction != 0:
			$PlayerSprite.flip_h = horizontal_direction < 0
			move_velocity.x = lerp(move_velocity.x, horizontal_direction * move_speed, acceleration_speed)
		else:
			move_velocity.x = lerp(move_velocity.x, horizontal_direction * move_speed, deacceleration_speed)
			if(abs(move_velocity.x) < 10.0):
				move_velocity.x = 0

# Animtes the player with sprites
func animate_player():
	if is_on_floor():
		if is_running:
			$PlayerSprite.animation = "move"
		elif is_idle:
			$PlayerSprite.animation = "idle"
	else:
		if is_high_jump:
			$PlayerSprite.animation = "jump_hammer"
		elif is_falling and !is_deploying_hammer:
			$PlayerSprite.animation = "falling"
	$PlayerSprite.play()

# Saves the current position of the player and camera
func save_spawn():
	saved_checkpoint = position

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
	move_velocity = Vector2.ZERO
	
	position = saved_checkpoint

func get_bounce_height(node_name, group_name):
	for curr_node in get_tree().get_nodes_in_group(group_name):
		if curr_node.name == node_name:
			return curr_node.bounce_strength
	return ground_bounce

# If we hit a platform while the hammer is out, we perform a high jump
func _on_HammerHitBox_body_entered(body):
	if body.is_in_group("HammerInteract"):
		is_deploying_hammer = false
		is_high_jump = true
		curr_high_jump_strength = lerp(curr_high_jump_strength, get_bounce_height(body.name, "HammerInteract"), high_jump_mod)
		emit_signal("hammer_interact", body.name)
		$PlayerSounds/HammerHit.play()
		$HammerHitBox/HammerJumpCooldown.start()
	elif body.is_in_group("Ground"):
		is_deploying_hammer = false
		is_high_jump = true
		if numb_high_jumps < max_high_jumps:
			numb_high_jumps += 1
			curr_high_jump_strength = lerp(curr_high_jump_strength, ground_bounce, high_jump_mod)
			$HammerHitBox/HammerJumpCooldown.start()
		else:
			curr_high_jump_strength = lerp(curr_high_jump_strength, weak_ground_bounce, high_jump_mod)
			$HammerHitBox/HammerJumpCooldown.start()
		$PlayerSounds/HammerHit.play()
	elif body.is_in_group("Enemy"):
		is_deploying_hammer = false
		is_high_jump = true
		curr_high_jump_strength = lerp(curr_high_jump_strength, get_bounce_height(body.name, "Enemy"), high_jump_mod)
		# We pass an extra argument to the signal
		emit_signal("hit_enemy", body.name)
		$HammerHitBox/HammerJumpCooldown.start()
		$PlayerSounds/EnemyBounce.play()
	elif body.is_in_group("SpringDoor"):
		is_high_jump = true
		is_deploying_hammer = false
		can_input = false
		move_velocity.x = 0.0
		curr_high_jump_strength = lerp(curr_high_jump_strength, get_bounce_height(body.name, "SpringDoor"), high_jump_mod)
		MainCameraNode.smoothing_speed = 0.1
		emit_signal("spring_door_activate", body.name)
		$PlayerSounds/HammerHit.play()

# When the timer ends, we stop the higher jump
func _on_HammerJumpCooldown_timeout():
	is_high_jump = false

# Upon activation, we save the player's position as well as the camera
func _on_Checkpoint_activated_checkpoint():
	save_spawn()

# On touching a Death Plane, we move back to the last checkpoint we touched
func _on_DeathPlane_body_entered(body):
	if body.is_in_group("Player"):
		$PlayerSounds/Die.play()
		MainCameraNode.smoothing_speed = 10;
		respawn()

# After a set time, we disenage the hammer
func _on_HammerInput_timeout():
	is_deploying_hammer = false;
	$PlayerSprite.speed_scale = 1

# When the player touches an enemy, they are sent back to the last spawn
func _on_Enemy_damage_player():
	$PlayerSounds/Die.play()
	MainCameraNode.smoothing_speed = 10;
	respawn()

# When this animation finishes playing, we go to the deploy_hammer_animation
func _on_PlayerSprite_animation_finished():
	if $PlayerSprite.get_animation() == "deploy_hammer_start":
		$PlayerSprite.animation = "deploy_hammer_stay"

# When the player is dying, what happens once it finishes
func _on_Die_finished():
	MainCameraNode.smoothing_speed = 1;
