extends StaticBody2D

# Allows us to specify a scene file to load
export var scene_to_load = "TestLevel"

var current_scene = null

# Sets the variables up
func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)


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
	get_tree().change_scene("res://Levels/" + scene_to_load + ".tscn")