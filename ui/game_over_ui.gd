class_name GameOverUi
extends CanvasLayer

@onready var time_label: Label = %TimeLabel
@onready var monster_label: Label = %MonstersLabel
@onready var itens_label: Label = %ItensLabel
@onready var gold_label: Label = %GoldLabel
@onready var score_label: Label = %ScoreLabel
@onready var lvl_label: Label = %LvlLabel
@onready var restart_button: TextureButton = %RestartButton

var score_total: int

func _ready():
	restart_button.pressed.connect(restart_game)
	
	time_label.text = GameManager.time_elapsed_string
	monster_label.text = str(GameManager.kill_collected)
	itens_label.text = str(GameManager.minsc_collected)
	gold_label.text = str(GameManager.gold_collected)
	lvl_label.text = str(GameManager.lvl)
	
	
	score_total = GameManager.kill_collected + GameManager.minsc_collected + GameManager.gold_collected
	score_total += GameManager.time_elapsed
	score_total *= GameManager.lvl
	
	if GameManager.bought:
		score_total *= 5
	
	if score_total == 0:
		score_total = GameManager.time_elapsed / 5
	score_label.text = str(score_total)

func restart_game():
	GameManager.reset()
	get_tree().reload_current_scene()
