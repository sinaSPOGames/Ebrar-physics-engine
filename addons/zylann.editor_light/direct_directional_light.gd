tool

var _instance_rid = null
var _light_rid = null


func _init():
	_instance_rid = VisualServer.instance_create()
	_light_rid = VisualServer.directional_light_create()
	VisualServer.instance_set_base(_instance_rid, _light_rid)


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		
		if _instance_rid != null:
			VisualServer.free_rid(_instance_rid)
			_instance_rid = null
			
		if _light_rid != null:
			VisualServer.free_rid(_light_rid)
			_light_rid = null


func set_world(world):
	VisualServer.instance_set_scenario(_instance_rid, world.scenario if world != null else RID())


func set_transform(trans):
	VisualServer.instance_set_transform(_instance_rid, trans)

