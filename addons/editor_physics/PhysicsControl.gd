tool
extends Control

func _ready() -> void:
	pass

func _on_CheckButton_toggled(button_pressed: bool) -> void:
	PhysicsServer.set_active(button_pressed)

func set_icon(new_icon):
	$ToolButton.icon = new_icon
