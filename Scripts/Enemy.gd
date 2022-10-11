extends KinematicBody2D

signal damage_player

const UP_DIRECTION = Vector2.UP

export var move_speed = 2000.0
export var gravity_scale = 4500.0
export var is_horizontal = true

var move_direction = 0
var move_velocity = Vector2.ZERO

# Randomly selects the move_direction of the enemy
func _ready():
	if randi() % 10 + 1 < 5:
		if is_horizontal:
			move_direction = 1
		else:
			move_direction = -1
	else:
		if is_horizontal:
			move_direction = 1
		else:
			move_direction = -1
	
	$PatrolTime.start()

func _physics_process(delta):
	# Standard Movement
	if is_horizontal:
		move_velocity.x = move_direction * move_speed
	else:
		move_velocity.y = move_direction * move_speed
	# Gravity
	move_velocity.y += gravity_scale * delta

	# Translate object
	move_velocity = move_and_slide(move_velocity, UP_DIRECTION)

# When the time is up, the enemy changes direction
func _on_PatrolTime_timeout():
	move_direction *= -1

func _on_DamageHitBox_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("damage_player")
