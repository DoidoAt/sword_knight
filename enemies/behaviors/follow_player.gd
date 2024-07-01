extends Node


@export var speed: float = 1
@export var type: int = 0
@export var running_cooldown: float = 0.0


var enemy : Enemy
var animated_enemy: AnimationPlayer
var sprite
var input_vector: Vector2 = Vector2(0, 0)
var is_running: bool = true
var animation: int = 1
var is_exploding: bool = false

func _ready():
	enemy = get_parent()
	sprite = enemy.get_node("AnimatedSprite2D")
	if type != 0:
		animated_enemy = enemy.get_node("AnimationPlayer")

func _process(delta: float) -> void:
	# Ignorar Game Over
	if GameManager.is_game_over or GameManager.is_game_paused: return
	
	# Calcular direção
	read_location_player(delta)
	
	# Rotacionar personagem
	rotate_sprite()


func _physics_process(delta: float) -> void:
	# Ignorar Game Over
	if GameManager.is_game_over or GameManager.is_game_paused: return
	
	# Andar
	enemy.velocity = input_vector * speed * 100.0
	enemy.move_and_slide()


func read_location_player(delta) -> void:
	var player_position = GameManager.player_position
	
	input_vector = player_position - enemy.position
	input_vector = input_vector.normalized()
	var dist = enemy.position.distance_to(player_position)
	if type == 1:
		if dist > 300 and dist < 500:
			input_vector = Vector2(0, 0)
			is_running = false
		elif dist < 300:
			is_running = true
			input_vector *= -1
		else:
			is_running = true
			
		if is_running:
			animated_enemy.play("running")
		else:
			animated_enemy.play("throwing")
	elif type == 2:
		running_cooldown -= delta
		if is_exploding:
			input_vector = Vector2(0, 0)
			return
		if dist < 70:
			input_vector = Vector2(0, 0)
			is_exploding = true
			animated_enemy.play("explosion")
			return
		
		if running_cooldown > 3:
			input_vector = Vector2(0, 0)
			animated_enemy.play("idle")
			return
		elif  running_cooldown <= 0:
			running_cooldown = 4.5
			return
			
		if dist > 200:
			animation = 1
		else:
			animation = 2
		
		animated_enemy.play("running_" + str(animation))

func rotate_sprite() -> void:
	# Girar Sprite
	if input_vector.x > 0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true
