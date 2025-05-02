extends Area2D

var grid_size = 8
var direction : Vector2
var timer = 0
var speed = 15
var lerp_pos : Vector2
var rotation_value = 0

var passengers : Array

signal passenger_collected
signal passenger_delivered

func _ready() -> void:
	lerp_pos = Vector2(256+16, 256)

func _process(delta: float) -> void:
	if get_parent().current_state == get_parent().state.PLAYING:
		if Input.is_action_just_pressed("ui_up"):
			if direction.y != 1:
				direction = Vector2(0, -1)
				#rotation_degrees = 0
				rotation_value = 0
				modulate_sfx(0.75)
		elif Input.is_action_just_pressed("ui_down"):
			if direction.y != -1:
				direction = Vector2(0, 1)
				#rotation_degrees = 180
				rotation_value = 180
				modulate_sfx(0.6)
		elif Input.is_action_just_pressed("ui_left"):
			if direction.x != 1:
				direction = Vector2(-1, 0)
				#rotation_degrees = 90
				rotation_value = -90
				modulate_sfx(0.8)
		elif Input.is_action_just_pressed("ui_right"):
			if direction.x != -1:
				direction = Vector2(1, 0)
				#rotation_degrees = 90
				rotation_value = 90
				modulate_sfx(0.9)
		
		if timer < 1:
			timer += speed * delta
		else:
			lerp_pos += direction * grid_size
			timer = 0
		position = position.lerp(lerp_pos, 0.1)
		rotation = lerp_angle(rotation, deg_to_rad(rotation_value), 0.2)
	
	#if Input.is_action_just_pressed("ui_accept"):
		#lerp_pos = Vector2(256+16, 256)
		#timer = 0
		#speed = 15
		#$AudioStreamPlayer2D.volume_db = 0.0
		#$AudioStreamPlayer2D.pitch_scale = 1.0

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		honk()
	
func _on_timer_timeout() -> void:
	position += direction * grid_size


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Destination"):
		check_passenger_info(area)
	if area.is_in_group("Passenger"):
		print("Picked up passenger")
		passenger_collected.emit(area.destination)
		passengers.append(area.destination)

func check_passenger_info(area):
	for passenger in passengers:
		if passenger == area.position:
			passenger_delivered.emit()
			passengers.remove_at(passengers.find(passenger))
			print("arrived to destination")
			await get_tree().create_timer(0.2).timeout
			area.queue_free()

func modulate_sfx(value:float):
	var tween = get_tree().create_tween()
	tween.tween_property($AudioStreamPlayer2D,"pitch_scale", value - randf_range(0.1, 0.2), 0.2)
	tween.tween_property($AudioStreamPlayer2D,"pitch_scale", 1.0 - randf_range(0.0, 0.2), 0.2)
	tween.tween_callback(tween.kill)

func on_crash():
	var tween = get_tree().create_tween()
	tween.tween_property($AudioStreamPlayer2D,"pitch_scale", 0.1, 0.3)
	tween.tween_property($AudioStreamPlayer2D,"volume_db", -80, 1)
	$Explosion.play()
	$Bus/ExplosionParticles.emitting = true
	$Bus/ExplosionParticles2.emitting = true

func honk():
	$Honk.play()
	
