class_name Enemy
extends Node2D


@export var health: int = 10
@export var damage_points: int = 1
@export var death_prefab: PackedScene
@export var tnt_prefab: PackedScene
@export var kaboom_prefab: PackedScene
@export var arrow_prefab: PackedScene
@export var gold: int = 1
@export var exp: float = 3.0

@onready var damage_digit_marker = $DamageDigitMarker

@export_category("Drops")
@export var drop_itens: Array[PackedScene]
@export var drop_chances: Array[float]
@export var drop_chance: float = 0.1

var hitbox_area: Area2D
var damage_digit_prefeb: PackedScene

func _ready():
	damage_digit_prefeb = preload("res://misc/damage_digit.tscn")


func _process(delta):
	if GameManager.is_game_over or GameManager.is_game_paused: return
	

func damage(amount: int) -> void:
	health -= amount
	
	# Piscar node
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	
	# Criar Damage Digit
	var damage_digit = damage_digit_prefeb.instantiate()
	damage_digit.value = amount
	if damage_digit_marker:
		damage_digit.global_position = damage_digit_marker.global_position
	else:
		damage_digit.global_position = global_position
	
	get_parent().add_child(damage_digit)
	
	# Processar Morte
	if health <= 0:
		die()
		

func die() -> void:
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)

	GameManager.kill_collected += 1
	GameManager.player.kill_collected.emit(exp + exp * (GameManager.lvl / 2))
	GameManager.player.gold_collected.emit(gold)
	
	# Drop
	if randf() <= drop_chance:
		drop_item()
	
	# Deletar Node
	queue_free()

func drop_item() -> void:
	var drop = get_random_drop_item().instantiate()
	drop.position = position
	get_parent().add_child(drop)

func get_random_drop_item() -> PackedScene:
	
	if drop_itens.size() == 1:
		return drop_itens[0]
	
	var max_chance: float = 0.0
	for chance in drop_chances:
		max_chance += chance
	
	var random_value = randf() * max_chance
	
	var needle: float = 0.0
	
	var qtd = drop_itens.size()
	
	for i in qtd:
		var drop = drop_itens[i]
		var chance = drop_chances[i] if i < drop_chances.size() else 1
		if random_value <= chance + needle:
			return drop
		needle += chance
		
	return drop_itens[0]


func tnt() -> void:
	# Taca a TNT
	if tnt_prefab:
		var tnt_object = tnt_prefab.instantiate()
		tnt_object.position = position
		get_parent().add_child(tnt_object)

func arrow() -> void:
	# Atira a flecha
	if arrow_prefab:
		var arrow_object = arrow_prefab.instantiate()
		arrow_object.position = position
		get_parent().add_child(arrow_object)

func kaboom() -> void:
	# Se explode
	hitbox_area = $HitBoxArea
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body != self and !body.is_in_group("static") and !body.is_in_group("tile_map"):
			var enemy = body
			enemy.damage(damage_points)
			
	# Explode o barril
	if kaboom_prefab:
		var kaboom_object = kaboom_prefab.instantiate()
		kaboom_object.position = position
		get_parent().add_child(kaboom_object)
	
	GameManager.kill_collected += 1
	GameManager.player.kill_collected.emit(exp + exp * (GameManager.lvl / 2))
	GameManager.player.gold_collected.emit(0)
	queue_free()
