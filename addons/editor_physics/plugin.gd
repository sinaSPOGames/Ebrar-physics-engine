tool
extends EditorPlugin

var node

func _enter_tree():
	node = preload("res://addons/editor_physics/PhysicsControl.tscn").instance()
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, node)
	var gui = get_editor_interface().get_base_control()
	var load_icon = gui.get_icon("RigidBody", "EditorIcons")
	node.set_icon(load_icon)

func _exit_tree():
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, node)
	node.queue_free()
