extends Camera2D

export var camera_scroll_amount = 10
var saved_camera_position = Vector2.ZERO

func _on_LeftArea_body_entered(body):
	if body.is_in_group("Player"):
		translate(Vector2(-camera_scroll_amount, 0))


func _on_RightArea_body_entered(body):
	if body.is_in_group("Player"):
		translate(Vector2(camera_scroll_amount, 0))
