extends Node2D

@export var regeneration: int = 10
@export var damage: int = 2
@export var cooldown: float = 0.0
@export var invul: float = 0.5


func _ready():
	$Area2D.body_entered.connect(on_body_entered)


func on_body_entered(body: Node2D) -> void:
	var minsc = 0
	if body.is_in_group("player"):
		var player: Player = body
		if self.is_in_group("heal"):
			player.heal(regeneration)
			minsc = 1
		
		elif self.is_in_group("inc_attack"):
			player.inc_attack(damage)
			minsc = 1
		
		elif self.is_in_group("invulnerability"):
			player.give_armor(invul)
			minsc = 1
		
		elif self.is_in_group("gold"):
			minsc = 0
		
		else:
			player.add_ritual(self.get_groups()[0], damage, cooldown)
			minsc = 1
		
		if minsc:
			player.minsc_collected.emit(1)
		else:
			player.gold_collected.emit(randi_range(15, 25))
		queue_free()
