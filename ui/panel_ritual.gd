class_name PanelRitual
extends Panel


func _ready():
	GameManager.panel_ritual = self
	


func initiate(local: String, maximo: float, index: int) -> void:
	var children = self.get_children()[0].get_children()[index]
	children.texture = load(local)
	children.modulate = Color(0,1,0)
	var progress = children.get_children()[0]
	progress.max_value = maximo
	progress.value = 0
	children.visible = true
	
	var panel = children.get_children()[2]
	panel = panel.get_children()[0]
	panel.text = "Button: " + str(index+1) + "\n" + GameManager.player.ritual_names[index] + "\nLVL: " + str(GameManager.player.ritual_lvl[index]) + "\nPOWER: " + str(GameManager.player.ritual_damage[index]) + "\n CD: " + str(GameManager.player.ritual_max_interval[index])

func update(index: int, maximo: float) -> void:
	var children = self.get_children()[0].get_children()[index]
	var progress = children.get_children()[0]
	progress.max_value = maximo
	
	var panel = children.get_children()[2]
	panel = panel.get_children()[0]
	panel.text = "Button: " + str(index+1) + "\n" + GameManager.player.ritual_names[index] + "\nLVL: " + str(GameManager.player.ritual_lvl[index]) + "\nPOWER: " + str(GameManager.player.ritual_damage[index]) + "\n CD: " + str(GameManager.player.ritual_max_interval[index])

func update_timer(index: int, time: float) -> void:
	var children = self.get_children()[0].get_children()[index]
	var progress = children.get_children()[0]
	if time == 0:
		children.modulate = Color(0,1,0)
	progress.value = time

func reset(index: int) -> void:
	var children = self.get_children()[0].get_children()[index]
	children.modulate = Color(1,0,0)
	var progress = children.get_children()[0]
	progress.value = progress.max_value
