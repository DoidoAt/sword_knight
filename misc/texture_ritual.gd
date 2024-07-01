extends TextureRect

var area: Area2D
var panel: Panel

func _ready() -> void:
	area = %Area2D
	panel = %Panel
	
	panel.visible = false
	
	area.connect("mouse_entered", _on_button_mouse_entered)
	area.connect("mouse_exited", _on_button_mouse_exited)

func _on_button_mouse_entered():
	panel.visible = true

func _on_button_mouse_exited():
	panel.visible = false

