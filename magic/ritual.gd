extends Node2D

@export var damage: int = 1

@onready var area2d: Area2D = $Area2D

func deal_damage():
	var bodies = area2d.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies") or body.is_in_group("enemy"):
			var enemy: Enemy = body
			enemy.damage(damage)

func heal():
	GameManager.player.heal(damage)

func speed_up():
	GameManager.player.speed *= damage

func speed_down():
	GameManager.player.speed /= damage
