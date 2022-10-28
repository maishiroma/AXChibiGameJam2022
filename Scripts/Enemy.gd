extends KinematicBody2D

signal damage_player

const UP_DIRECTION = Vector2.UP

export var move_speed = 2000.0
export var gravity_scale = 4500.0
export var is_horizontal = true
export var patrol_time = 2

var move_direction = 0
var move_velocity = Vector2.ZERO
var is_hit = false

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
	
	$PatrolTime.wait_time = patrol_time
	$PatrolTime.start()
	
	# Cool trick to auto connect nodes together dynamically
	# Since some of these can be spawned dynamically
	if get_tree().get_nodes_in_group("Player").size() == 1:
		var playerNode = get_tree().get_nodes_in_group("Player")[0]
		self.connect("damage_player", playerNode, "_on_Enemy_damage_player")
		playerNode.connect("hit_enemy", self, "_on_Player_hit_enemy")

func animation_set():
	$AnimatedSprite.flip_h = sign(move_direction)
	if move_velocity.normalized() != Vector2.ZERO:
		if is_on_floor():
			if is_hit:
				$AnimatedSprite.animation = "ground_hit"
			else:
				$AnimatedSprite.animation = "ground_moving"
		else:
			if is_hit:
				$AnimatedSprite.animation = "air_hit"
			else:
				$AnimatedSprite.animation = "air_moving"
	$AnimatedSprite.play()

func _process(_delta):
	animation_set()

func _physics_process(delta):
	# Standard Movement
	if is_horizontal:
		move_velocity.x = move_direction * move_speed
		# Gravity
		move_velocity.y += gravity_scale * delta
	else:
		move_velocity.y = move_direction * move_speed

	# Translate object
	move_velocity = move_and_slide(move_velocity, UP_DIRECTION)

# When the time is up, the enemy changes direction
func _on_PatrolTime_timeout():
	move_direction *= -1

func _on_DamageHitBox_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("damage_player")

func _on_HitTimer_timeout():
	is_hit = false

func _on_Player_hit_enemy(collider_name):
	if name == collider_name:
		is_hit = true
		$HitTimer.start()
