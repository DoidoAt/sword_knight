extends CharacterBody2D

@export var speed: float = 3
@export var kaboom_prefab: PackedScene
@export var damage: int = 30

@onready var hitbox_area: Area2D = $HitBoxArea
@onready var player: Sprite2D

var player_position
var input_vector: Vector2 = Vector2(0, 0)

var countdown: float = 1.5
var is_moving: bool = true
var hit: int = 0

func _ready() -> void:
	player_position = GameManager.player_position
	if self.is_in_group("arrow"):
		player = $Arrow

func _process(delta: float) -> void:
	# Ignorar Game Over
	if GameManager.is_game_over or GameManager.is_game_paused: return
	
	countdown -= delta
	if countdown <= 0:
		if self.is_in_group("tnt"):
			kaboom()
	if hit == 0:
		if self.is_in_group("arrow"):
			fall()
	
	read_location()


func _physics_process(delta: float) -> void:
	if GameManager.is_game_over or GameManager.is_game_paused: return
	var target_velocity = input_vector * speed * 100
	velocity = target_velocity
	if self.is_in_group("arrow"):
		if velocity.x < 0:
			player.flip_h = true
		else:
			player.flip_h = false
	move_and_slide()

func read_location() -> void:
	if hit:
		input_vector = Vector2(0, 0)
		return
	input_vector = player_position - position
	input_vector = input_vector.normalized()
	if position.distance_to(player_position) < 20:
		input_vector = Vector2(0, 0)
		is_moving = false


func kaboom() -> void:
	# Causa dano nos corpos próximos a explosão
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body != self and !body.is_in_group("static") and !body.is_in_group("tile_map"):
			var enemy = body
			enemy.damage(damage)
	
	if kaboom_prefab:
		var kaboom_object = kaboom_prefab.instantiate()
		kaboom_object.position = position
		get_parent().add_child(kaboom_object)
		
	queue_free()

func fall() -> void:
	if hitbox_area.monitoring:
		var bodies = hitbox_area.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("player"):
				var enemy = body
				enemy.damage(5)
				hit = 1
		if hit == 1 or is_moving == false:
			%AnimationPlayer.play("fall")
