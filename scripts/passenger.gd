extends Area2D

var destination : Vector2

signal picked_up(d:Vector2, pos: Vector2)

func _on_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
	#print("hello?")
	if area.is_in_group("Bus"):
		#$AnimationPlayer.stop()
		$AnimationPlayer.play("spin")
		$AudioStreamPlayer.play()
		picked_up.emit(destination, global_position)
		#queue_free()

func _remove():
	queue_free()
