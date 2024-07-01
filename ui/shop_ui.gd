extends CanvasLayer

@onready var button_buy: TextureButton = %ButtonBuy
@onready var button_exit: TextureButton = %ButtonExit
@onready var button: Button = %Button1
@onready var label_money: Label = %LabelMoney

var selected: bool = false

func _ready():
	label_money.visible = false
	button_buy.pressed.connect(buy)
	button_exit.pressed.connect(exit)
	button.pressed.connect(choose)


func choose():
	selected = !selected

func buy():
	if GameManager.gold_collected >= 2000:
		GameManager.player.max_sword_damage = 999
		var max: int = GameManager.player.ritual_max_lvl.size()
		for i in range(max):
			GameManager.player.ritual_max_lvl[i] = 999
		
		max = GameManager.player.ritual_max_damage.size()
		for i in range(max):
			GameManager.player.ritual_max_damage[i] = 999
		GameManager.player.max_health = 200
		GameManager.bought = true
		exit()
	else:
		label_money.visible = true

func exit():
	GameManager.is_game_paused = false
	queue_free()
