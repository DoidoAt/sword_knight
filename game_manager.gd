extends Node


signal game_over

var player: Player
var player_position: Vector2
var is_game_over: bool = false
var is_game_paused: bool = false

var panel_ritual: PanelRitual

var time_elapsed: float = 0.0
var time_elapsed_string: String
var minsc_collected: int = 0
var kill_collected: int = 0
var gold_collected: int = 0
var lvl: int = 0

var bought: bool = false

func _process(delta):
	# Ignorar Game Over
	if GameManager.is_game_over or GameManager.is_game_paused: return
	
	# Update Timer
	time_elapsed += delta
	var time_sec: int = floori(time_elapsed)
	var seconds: int = time_sec % 60
	var minutes: int = time_sec / 60
	
	time_elapsed_string = "%02d:%02d" % [minutes, seconds]


func end_game():
	if is_game_over: return
	is_game_over = true
	game_over.emit()


func reset():
	player = null
	panel_ritual = null
	player_position = Vector2.ZERO
	is_game_over = false
	is_game_paused = false
	time_elapsed = 0.0
	time_elapsed_string = "00:00"
	minsc_collected = 0
	kill_collected = 0
	gold_collected = 0
	lvl = 0
	bought = false
	for connection in game_over.get_connections():
		game_over.disconnect(connection.callable)
