extends CanvasLayer

var button1: Button
var button2: Button
var button3 : Button

@onready var label_panel: Label = %LabelPanel1
@onready var label_panel_1: Label = %LabelPanel12
@onready var label_panel2: Label = %LabelPanel2
@onready var label_panel2_1: Label = %LabelPanel22
@onready var label_panel3: Label = %LabelPanel3
@onready var label_panel3_1: Label = %LabelPanel32

var lvl_label: Label
var power_ups: Array[String] = ["Light Beacon", "Chain Lightning",  "Heal", "Flash Step", "Attack UP", "Invulnerability Up"]
var damage: Array[int] = [3, 6, 5, 2]
var cooldown: Array[float] = [45.5, 60.5, 30.5, 60]
var inc_damage: int = 2
var inc_invul: float = 0.5
var choiches: Array[int] = [0,0,0]

func _ready():
	button1 = %Button1
	button2 = %Button2
	button3 = %Button3

	button1.pressed.connect(button_pressed)
	button2.pressed.connect(button_pressed2)
	button3.pressed.connect(button_pressed3)
	
	get_random_ups()


func update(value: int) -> void:
	lvl_label = %LvlLabel
	lvl_label.text = str(value-1) + "LVL -> " + str(value) + "LVL"

func get_random_ups():
	choiches[0] = randi_range(0, power_ups.size()-1)
	var message: String
	var maxed: bool = false
	if choiches[0] < 4:
		if GameManager.player.ritual_lvl[choiches[0]] < GameManager.player.ritual_max_lvl[choiches[0]]:
			message = "Gain/Increase the ability: "
		else:
			message = "Ability maxed out!"
			maxed = true
	else:
		if choiches[0] == 4:
			if GameManager.player.sword_damage < GameManager.player.max_sword_damage:
				message = "Increase: "
			else:
				message = "Attack maxed out!"
				maxed = true
		else:
			if GameManager.player.hitbox_cooldown < GameManager.player.max_hitbox_cooldown:
				message = "Increase: "
			else:
				message = "Hitbox maxed out!"
				maxed = true
	
	var first
	
	if power_ups[choiches[0]] != "":
		first = power_ups[choiches[0]].rsplit(" ")
	else:
		first = ["Ø", ""]
	
	if first.size() > 1:
		label_panel.text = first[0] + "\n" + first[1]
	else:
		label_panel.text = first[0]
	
	if maxed:
		label_panel_1.text = message
	else:
		label_panel_1.text = message + "\n" + power_ups[choiches[0]]
	
	#-------------------------------------
	maxed = false
	choiches[1] =  randi_range(0, power_ups.size()-1)
	if choiches[1] < 4:
		if GameManager.player.ritual_lvl[choiches[1]] < GameManager.player.ritual_max_lvl[choiches[1]]:
			message = "Gain/Increase the ability: "
		else:
			message = "Ability maxed out!"
			maxed = true
	else:
		if choiches[1] == 4:
			if GameManager.player.sword_damage < GameManager.player.max_sword_damage:
				message = "Increase: "
			else:
				message = "Attack maxed out!"
				maxed = true
		else:
			if GameManager.player.hitbox_cooldown < GameManager.player.max_hitbox_cooldown:
				message = "Increase: "
			else:
				message = "Hitbox maxed out!"
				maxed = true

	if power_ups[choiches[1]] != "":
		first = power_ups[choiches[1]].rsplit(" ")
	else:
		first = ["Ø", ""]
	
	
	if first.size() > 1:
		label_panel2.text = first[0] + "\n" + first[1]
	else:
		label_panel2.text = first[0]
	
	if maxed:
		label_panel2_1.text = message
	else:
		label_panel2_1.text = message + "\n" + power_ups[choiches[1]]
	
	#--------------------------------------------
	maxed = false
	choiches[2] = randi_range(0, power_ups.size()-1)
	if choiches[2] < 4:
		if GameManager.player.ritual_lvl[choiches[2]] < GameManager.player.ritual_max_lvl[choiches[2]]:
			message = "Gain/Increase the ability: "
		else:
			message = "Ability maxed out!"
			maxed = true
	else:
		if choiches[2] == 4:
			if GameManager.player.sword_damage < GameManager.player.max_sword_damage:
				message = "Increase: "
			else:
				message = "Attack maxed out!"
				maxed = true
		else:
			if GameManager.player.hitbox_cooldown < GameManager.player.max_hitbox_cooldown:
				message = "Increase: "
			else:
				message = "Hitbox maxed out!"
				maxed = true
	
	if power_ups[choiches[2]] != "":
		first = power_ups[choiches[2]].rsplit(" ")
	else:
		first = ["Ø", ""]
	
	if first.size() > 1:
		label_panel3.text = first[0] + "\n" + first[1]
	else:
		label_panel3.text = first[0]
	
	if maxed:
		label_panel3_1.text = message
	else:
		label_panel3_1.text = message + "\n" + power_ups[choiches[2]]


func button_pressed():
	var op = choiches[0]
	if op < 4:
		add_ritual(op)
	else:
		add_upgrade(op)
	end()

func button_pressed2():
	var op = choiches[1]
	if op < 4:
		add_ritual(op)
	else:
		add_upgrade(op)
	end()

func button_pressed3():
	var op = choiches[2]
	if op < 4:
		add_ritual(op)
	else:
		add_upgrade(op)
	end()

func add_ritual(id: int):
	var ritual = catch_ritual(id)
	if ritual != "":
		GameManager.player.add_ritual(ritual, damage[id], cooldown[id])

func add_upgrade(id: int):
	if id == 4:
		GameManager.player.inc_attack(inc_damage)
	else:
		GameManager.player.give_armor(inc_invul)

func catch_ritual(value: int):
	if value == 0:
		return "ritual_0"
	elif value == 1:
		return "ritual_1"
	elif value == 2:
		return "ritual_2"
	else:
		return "ritual_3"

func end():
	GameManager.is_game_paused = false
	queue_free()
