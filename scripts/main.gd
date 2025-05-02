extends Node2D

enum state {WAIT, PLAYING, GAMEOVER}
var current_state : state

@export var tilemap : TileMapLayer
@export var destination_layer : TileMapLayer

@export var passenger : PackedScene
@export var destination : PackedScene

var delivery_count = 0

var passengers : Array

func _ready() -> void:
	pass
	#print(tilemap.get_cell_tile_data(tilemap.local_to_map($Player.global_position)))
	
	#var rand_destination = destination_layer.get_used_cells().pick_random()
	#var dest = destination_layer.map_to_local(rand_destination)
	#var spawn_pos = destination_layer.map_to_local(destination_layer.get_used_cells().pick_random())
	#spawn_passenger(dest, spawn_pos)
	#await get_tree().create_timer(1.0).timeout
	#get_new_destinatio  n() 
	#set_destination(dest)

func _process(delta: float) -> void:
	if current_state == state.PLAYING:
		var tile_map_data = tilemap.get_cell_tile_data(tilemap.local_to_map($Player.global_position))
		#print(tile_map_data)
		var tilemap_id = tilemap.get_cell_source_id(tilemap.local_to_map($Player.global_position))
		if tilemap_id != 0:
			#print("boom")
			current_state = state.GAMEOVER
			$Timer.stop()
			$Player.speed = 0
			$Player.on_crash()
			$CanvasLayer/Restart.show()
			if delivery_count > 1 or delivery_count == 0:
				%LabelDeliveries.text = "You delivered "+str(delivery_count)+" passengers!"
			else:
				%LabelDeliveries.text = "You delivered "+str(delivery_count)+" passenger!"
		#print(tilemap_id)
		#if tile_map_data != null:
		#print(destination_layer.get_used_cells().pick_random())

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		start_game()

func spawn_passenger(destination_vector:Vector2, spawn_position:Vector2):
	var p = passenger.instantiate()
	p.destination = destination_vector
	p.position = spawn_position#Vector2(256+16, 256-32)
	p.picked_up.connect(_on_passenger_collected)
	$Passengers.add_child.call_deferred(p)

var dest_arr : Array

func set_destination(destination_vector:Vector2):
	#var dest = destination_vector
	#if dest_arr.size() < 12:
		#while true:
			#if !dest_arr.has(dest):
				#dest_arr.append(dest)
	var d = destination.instantiate()
	d.position = destination_vector
	$Destinations.add_child.call_deferred(d)
				#break
			#else:
				#print("Retry destination")
				#var rand_destination = destination_layer.get_used_cells().pick_random()
				#dest = destination_layer.map_to_local(rand_destination)


func get_new_destination():
	var rand_destination = destination_layer.get_used_cells().pick_random()
	var dest = destination_layer.map_to_local(rand_destination)
	var spawn_pos = destination_layer.map_to_local(destination_layer.get_used_cells().pick_random())
	if passengers.size() < 12:
		while true:
			if dest != spawn_pos:
				if !passengers.has(spawn_pos):
					passengers.append(spawn_pos)
					spawn_passenger(dest, spawn_pos)
					$PassengerSpawnAudio.play()
					break
				else:
					print("Retry")
					spawn_pos = destination_layer.map_to_local(destination_layer.get_used_cells().pick_random())
			else:
				print("Destination and spawn is the same!")
				return
		#set_destination(dest)

func _on_player_passenger_delivered() -> void:
	pass # Replace with function body.
	$DeliveredAudio.play()
	delivery_count += 1
	if $Player.speed < 100:
		$Player.speed += 1
		print($Player.speed)
	await  get_tree().create_timer(0.5).timeout
	get_new_destination()


func _on_timer_timeout() -> void:
	$Timer.wait_time = randf_range(5.0, 15.0)
	get_new_destination()

func _on_passenger_collected(passenger_destination, pos):
	pass
	for passenger in passengers:
		if passenger == pos:
			print(passenger)
			passengers.remove_at(passengers.find(passenger))
	#print(passenger_destination)
	set_destination(passenger_destination)

func start_game():
	if current_state == state.WAIT:
		current_state = state.PLAYING
		$CanvasLayer/Control.hide()
		$Timer.start()
		$Player.direction = Vector2(0, -1)
		await get_tree().create_timer(1.0).timeout
		get_new_destination()
	if current_state == state.GAMEOVER:
		get_tree().change_scene_to_file("res://scenes/main.tscn")
