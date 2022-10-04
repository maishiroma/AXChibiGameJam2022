# This allows for movement by force
extends KinematicBody2D

export var move_speed = 10
export var jump_speed = 10

var move_velocity = Vector2.ZERO

# This is equivalent to FixedUpdate
func _physics_process(delta):
	get_input()
	
	# Allows us to use a built in method to control movement speed
	var motion = move_velocity * delta
	move_and_collide(motion)

func get_input():
	if Input.is_action_pressed("move_left"):
		move_velocity.x += -1
	elif Input.is_action_pressed("move_right"):
		move_velocity.x += 1
	else:
		move_velocity.x = 0
