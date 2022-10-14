extends Node2D

# Allows us to specify a scene file to load
export var scene_to_load = "TestLevel"

var current_scene = null

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

func _on_RetryButton_pressed():
	return get_tree().change_scene("res://Levels/" + scene_to_load + ".tscn")

func _on_QuitButton_pressed():
	return get_tree().quit()
