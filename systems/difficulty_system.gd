extends Node


@export var mob_spawner: MobSpawner
@export var spawn_rate_per_minute: float = 30.0
@export var initial_spawn_rate: float = 60.0
@export var wave_duration: float = 30.0
@export var break_intensity: float = 0.5

var time: float = 0.0
var chance_rate_per_minute: float = 0.001
var chance_creatures: Array[float]

func _ready() -> void:
	chance_creatures = mob_spawner.chance_creatures.duplicate()

func _process(delta: float) -> void:
	# Ignorar Game Over
	if GameManager.is_game_over: return
	
	# Aplicar apenas para mobs
	if mob_spawner.is_in_group("mobs"):
		time += delta
		
		# Dificuldade Linear : Linha Verde
		var spawn_rate = initial_spawn_rate + spawn_rate_per_minute * (time / 60)
		
		# Sistema de ondas: Linha Rosa
		var sin_wave = sin((time * TAU) / wave_duration)
		var wave_factor = remap(sin_wave, -1, 1, break_intensity, 1)
		spawn_rate *= wave_factor
		
		# Aplica a Dificuldade
		mob_spawner.mobs_per_minute = spawn_rate
		
		for i in range(3, 6):
			var chance = chance_creatures[i] * chance_rate_per_minute * (time / 60) * 100
			mob_spawner.chance_creatures[i] = minf(chance, chance_creatures[i])
