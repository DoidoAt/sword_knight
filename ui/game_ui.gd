extends CanvasLayer


@onready var timer_label: Label = %TimerLabel
@onready var gold_label: Label = %GoldLabel
@onready var minsc_label: Label = %MinscLabel
@onready var kill_label: Label = %KillLabel
@onready var level_bar: ProgressBar = %LevelBar
@onready var level_label: Label = %LevelLabel
@onready var shop_button: TextureButton = %ShopButton

@export var lvl_ui: PackedScene
@export var shop_ui: PackedScene

var xp: float = 0
var next_lvl: float = 10

func _ready() -> void:
	GameManager.player.kill_collected.connect(func (value: int): xp += value)
	shop_button.pressed.connect(open_shop)

func _process(delta: float):
	# Ignorar Game Over
	if GameManager.is_game_over or GameManager.is_game_paused: return

	timer_label.text = GameManager.time_elapsed_string
	
	minsc_label.text = str(GameManager.minsc_collected)
	gold_label.text = str(GameManager.gold_collected)
	kill_label.text = str(GameManager.kill_collected)
	
	level_bar.max_value = next_lvl
	level_bar.value = xp
	level_label.text = "Level: " + str(GameManager.lvl)
	update_lvl()
	
	if GameManager.bought:
		shop_button.disabled = true


func update_lvl() -> void:
	if xp < next_lvl: return
	
	var rest = xp - next_lvl
	next_lvl += 100 * GameManager.lvl
	GameManager.lvl += 1
	xp = rest
	if lvl_ui and not GameManager.is_game_paused:
		GameManager.is_game_paused = true
		var lvl_panel = lvl_ui.instantiate()
		lvl_panel.update(GameManager.lvl)
		get_parent().add_child(lvl_panel)

func open_shop():
	if shop_ui and not GameManager.is_game_paused and not GameManager.bought:
		GameManager.is_game_paused = true
		var shop_panel = shop_ui.instantiate()
		get_parent().add_child(shop_panel)
