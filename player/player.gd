class_name Player
extends CharacterBody2D

@export_category("Movement")
@export var speed: float = 3

@export_category("Damage")
@export var sword_damage: int = 3
@export var max_sword_damage: int = 15

@export_category("Ritual")
var ritual_names: Array[String] = ["Light Beacon", "Chain Lightning", "Heal", "Flash Step"]
var ritual_item_location: Array[String] = ["res://addons/Particles/PNG (Transparent)/magic_02.png", "res://addons/Particles/PNG (Transparent)/magic_01.png", "res://addons/Particles/PNG (Transparent)/star_09.png", "res://addons/Particles/PNG (Transparent)/twirl_01.png"]
@export var ritual_lvl: Array[int] = [0, 0, 0, 0]
@export var ritual_damage: Array[int] = [0, 0, 0, 0]
@export var ritual_interval: Array[float] = [0, 0, 0, 0]
var ritual_max_lvl: Array[int] = [3, 3, 3, 3]
var ritual_max_damage: Array[int] = [15, 15, 15, 15]
var ritual_inc_damage: Array[int] = [5, 5, 5, 1]
var ritual_max_interval: Array[float] = [30, 30, 30, 30]
var ritual_compare_max: float = 30.0
@export var ritual_scene: Array[PackedScene] =[null, null, null, null]

@export_category("Health")
@export var max_health: int = 100
@export var health: int = 100

@export_category("Death")
@export var death_prefab: PackedScene

@export_category("HitBox")
@export var hitbox_cooldown: float = 0.0
@export var max_hitbox_cooldown: float = 1.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitBoxArea
@onready var health_progress_bar: ProgressBar = $HealthProgressBar

var kill: int = 0
var input_vector: Vector2 = Vector2(0, 0)
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var attack_direction: int
var animation: int

signal minsc_collected(value: int)
signal gold_collected(value: int)
signal kill_collected(value: int)

func _ready():
	GameManager.player = self
	minsc_collected.connect(func (value: int): GameManager.minsc_collected += value)
	gold_collected.connect(func (value: int): GameManager.gold_collected += value)


func _process(delta: float) -> void:
	if GameManager.is_game_paused: return
	
	GameManager.player_position = position
	
	# Ler input
	read_input()
	read_input_ritual(delta)
	
	# Processar ataque
	update_attack_cooldown(delta)
	if Input.is_action_just_pressed("attack"):
		attack()
	
	# Processar animação e rotação de sprite
	play_run_idle()
	if not is_attacking:
		rotate_sprite()
	
	
	# Processar Dano
	update_hitbox_detection(delta)
	
	# Processar Ritual
	#update_ritual(delta)
	
	# Atualizar Health Bar
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if GameManager.is_game_paused: return
	# Modificar a Velocidade
	var target_velocity = input_vector * speed * 100.0
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity, target_velocity, 0.05)
	move_and_slide()



func read_input() -> void:
	# Obter o Input Vector
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
		# Apagar deadzone do input vector
	var deadzone = 0.15
	if abs(input_vector.x) < deadzone:
		input_vector.x = 0
		
	if abs(input_vector.y) < deadzone:
		input_vector.y = 0
		
	# Atualizar o is_running
	was_running = is_running
	is_running = not input_vector.is_zero_approx()

func update_attack_cooldown(delta: float) -> void:
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")

func add_ritual(nome: String, damag: int, coold: float) -> void:
	
	var index: int = nome.split("_")[1].to_int()
	ritual_lvl[index] = mini(ritual_lvl[index] + 1, ritual_max_lvl[index])
	
	if ritual_scene[index] == null:
		ritual_scene[index] = load("res://magic/ritual_" + str(index) + ".tscn")
		ritual_damage[index] = damag
		ritual_max_interval[index] = coold
		ritual_interval[index] = 0
		
	
		var location = ritual_item_location[index]
		GameManager.panel_ritual.initiate(location, coold, index)
		
	else:
		ritual_damage[index] = mini(ritual_damage[index] + ritual_inc_damage[index], ritual_max_damage[index])
		ritual_max_interval[index] = maxf(ritual_max_interval[index] - 5, ritual_compare_max)
		GameManager.panel_ritual.update(index, ritual_max_interval[index])


func read_input_ritual(delta: float) -> void:
	for i in range(ritual_interval.size()):
		ritual_interval[i] = maxf(ritual_interval[i] - delta, 0.0)
		if ritual_scene[i]:
			GameManager.panel_ritual.update_timer(i, ritual_interval[i])
	
	if Input.is_action_just_pressed("ritual_1"):
		if ritual_scene[0]:
			if ritual_interval[0] <= 0:
				ritual_interval[0] = ritual_max_interval[0]
				var ritual = ritual_scene[0].instantiate()
				ritual.damage = ritual_damage[0]
				add_child(ritual)
				
				GameManager.panel_ritual.reset(0)
				
	if Input.is_action_just_pressed("ritual_2"):
		if ritual_scene[1]:
			if ritual_interval[1] <= 0:
				ritual_interval[1] = ritual_max_interval[1]
				var ritual = ritual_scene[1].instantiate()
				ritual.damage = ritual_damage[1]
				add_child(ritual)
				
				GameManager.panel_ritual.reset(1)
				
	if Input.is_action_just_pressed("ritual_3"):
		if ritual_scene[2]:
			if ritual_interval[2] <= 0:
				ritual_interval[2] = ritual_max_interval[2]
				var ritual = ritual_scene[2].instantiate()
				ritual.damage = ritual_damage[2]
				add_child(ritual)
				
				GameManager.panel_ritual.reset(2)
				
	if Input.is_action_just_pressed("ritual_4"):
		if ritual_scene[3]:
			if ritual_interval[3] <= 0:
				ritual_interval[3] = ritual_max_interval[3]
				var ritual = ritual_scene[3].instantiate()
				ritual.damage = ritual_damage[3]
				add_child(ritual)
				
				GameManager.panel_ritual.reset(3)

func play_run_idle() -> void:
		# Tocar Animação
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")

func rotate_sprite() -> void:
	# Girar Sprite
	if input_vector.x > 0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true

func attack() -> void:
	if is_attacking:
		return
		
	# Escolher Animação
	animation = randi_range(1, 2)
		
	# Tocar Animação
	if input_vector.x or input_vector.x == input_vector.y:
		animation_player.play("attack_side_" + str(animation))
		attack_direction = 0
	elif input_vector.y > 0:
		animation_player.play("attack_down_" + str(animation))
		attack_direction = 1
	elif input_vector.y < 0:
		animation_player.play("attack_up_" + str(animation))
		attack_direction = 2
	
	# Configurar Temporizador
	attack_cooldown = 0.6
	
	# Marcar Ataque
	is_attacking = true

func inc_attack(amount: int) -> void:
	if sword_damage == max_sword_damage:
		return
	
	sword_damage += amount
	sword_damage = mini(max_sword_damage, sword_damage)
	
	# Piscar node
	modulate = Color.GREEN
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	pass

func deal_damage_to_enemies() -> void:
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies") or body.is_in_group("enemy"):
			var enemy: Enemy = body
			
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction_vector: Vector2
			var attack_direction_vector2: Vector2
			var dot_product2: float = 0.0
			if attack_direction == 0:
				if sprite.flip_h:
					attack_direction_vector = Vector2.LEFT
				else:
					attack_direction_vector = Vector2.RIGHT
					
				if animation == 2:
					attack_direction_vector2 = Vector2.DOWN
					dot_product2 = direction_to_enemy.dot(attack_direction_vector2)
				else:
					dot_product2 = direction_to_enemy.dot(attack_direction_vector)
			elif attack_direction == 1:
				attack_direction_vector = Vector2.DOWN
			else:
				attack_direction_vector = Vector2.UP
				
			var dot_product = direction_to_enemy.dot(attack_direction_vector)
			
			if dot_product > 0.5 or dot_product2 > 0:
				enemy.damage(sword_damage)

func update_hitbox_detection(delta: float) -> void:
	# Temporizador
	hitbox_cooldown -= delta
	hitbox_cooldown = maxf(hitbox_cooldown, 0.0)
	if hitbox_cooldown > 0.0:
		return
	
	# Frequência
	var took_damage = 0
	
	# Detectar inimigos
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = enemy.damage_points
			damage(damage_amount)
			took_damage = 1
	
	# Frequência
	if took_damage == 1:
		hitbox_cooldown = max_hitbox_cooldown

func damage(amount: int) -> void:
	if health <= 0 or hitbox_cooldown > 0.0:
		return
	
	health -= amount
	
	# Piscar node
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	
	# Processar Morte
	if health <= 0:
		die()

func give_armor(amount: float) -> void:
	if max_hitbox_cooldown >= 10.0:
		return
	
	max_hitbox_cooldown += amount
	
	# Piscar node
	modulate = Color.GREEN
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	pass

func heal(amount: int) -> void:
	if health == max_health:
		return
	
	health += amount
	health = mini(max_health, health)
	
	# Piscar node
	modulate = Color.GREEN
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)

func die() -> void:
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	
	GameManager.end_game()
	queue_free()
