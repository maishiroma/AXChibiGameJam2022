extends KinematicBody2D

export var move_rate = 2
export var move_vertical = true

const UP_DIRECTION = Vector2.UP

var move_velocity = Vector2.ZERO

func _physics_process(_delta):
	# warning-ignore:return_value_discarded
	move_and_collide(move_velocity, false)

func _on_Player_hammer_hit():
	if move_vertical == false:
		move_velocity = Vector2(1 * move_rate, 0)
	else:
		move_velocity = Vector2(0, 1 * move_rate)
	$MoveTime.start()

func _on_MoveTime_timeout():
	move_velocity = Vector2.ZERO
