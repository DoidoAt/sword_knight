class_name MobSpawner
extends Node2D

@export var creatures: Array[PackedScene]
@export var chance_creatures: Array[float]
var mobs_per_minute: float = 60

@onready var path_follow: PathFollow2D = $Path2D/PathFollow2D


var cooldown: float = 0.0

func _process(delta: float) -> void:
	# Ignorar Game Over
	if GameManager.is_game_over or GameManager.is_game_paused: return
	
	# Temporizador (cooldown)
	cooldown -= delta
	if cooldown > 0:
		return
	
	# Frequência
	var interval = 60.0 / mobs_per_minute
	cooldown = interval
	
	# Checar se o ponto é válido
	var point = get_point()
	
	var world_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = point
	var result = world_state.intersect_point(parameters, 1)
	
	if not result.is_empty(): return
	
	# Instanciar uma criatura aleatória
	spawn(point)

func spawn(point: Vector2) -> void:
	var creature = get_random_spawn().instantiate()
	creature.global_position = point
	creature.health += creature.health * (GameManager.lvl / 2)
	get_parent().add_child(creature)

func get_random_spawn() -> PackedScene:
	if creatures.size() == 1:
		return creatures[0]
	
	var max_chance: float = 0.0
	for chance in chance_creatures:
		max_chance += chance
	
	var random_value = randf() * max_chance
	
	var needle: float = 0.0
	
	var qtd = creatures.size()
	
	for i in qtd:
		var drop = creatures[i]
		var chance = chance_creatures[i] if i < chance_creatures.size() else 1
		if random_value <= chance + needle:
			return drop
		needle += chance
	
	return creatures[0]

func get_point() -> Vector2:
	path_follow.progress_ratio = randf() # Random Float
	return path_follow.global_position
