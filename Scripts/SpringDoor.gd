extends StaticBody2D

# Allows us to specify a scene file to load
export var scene_to_load = "TestLevel"

var current_scene = null
var has_activated = false

# Sets the variables up
func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

func _process(delta):
	if !has_activated:
		$AnimatedSprite.animation = "inactive"
	$AnimatedSprite.play()

func _deferred_goto_scene(path):
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)

# When the player activates the spring, the scene changes
func _on_Player_spring_door_activate():
	if !has_activated:
		has_activated = true
		$AnimatedSprite.animation = "activate"
		$AnimatedSprite.speed_scale = 2
		$ActivationTimer.start()

func _on_ActivationTimer_timeout():
	return get_tree().change_scene("res://Levels/" + scene_to_load + ".tscn")

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.get_animation() == "activate":
		$AnimatedSprite.animation = "idle"
		$AnimatedSprite.speed_scale = 1
