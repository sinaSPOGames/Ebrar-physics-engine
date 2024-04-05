tool
extends EditorPlugin

const DirectDirectionalLight = preload("res://addons/zylann.editor_light/direct_directional_light.gd")

var _light = null


func _enter_tree():
	print("EditorLight plugin enter tree")
	connect("scene_changed", self, "_on_scene_changed")


func _exit_tree():
	print("EditorLight plugin exit tree")
	disconnect("scene_changed", self, "_on_scene_changed")
	destroy_light()


func handles(object):
	if object is DirectionalLight:
		destroy_light()


func _on_scene_changed(scene_root):
	#print("Switched to scene ", scene_root)
	if scene_root != null:
		var res = find_node_by_type(scene_root, DirectionalLight)
		if res == null:
			create_light()
	else:
		destroy_light()


func create_light():
	if _light == null:
		_light = DirectDirectionalLight.new()
		_light.set_world(get_viewport().world)
		var rot = Quat()
		rot.set_euler(Vector3(-PI/3.0, PI/6.0, 0))
		var trans = Transform(Basis(rot), Vector3())
		_light.set_transform(trans)


func destroy_light():
	_light = null


static func find_node_by_type(root, klass):
	for i in root.get_child_count():
		var child = root.get_child(i)
		if child is klass:
			return child
		else:
			var res = find_node_by_type(child, klass)
			if res != null:
				return res
	return null

