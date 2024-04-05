extends Skeleton

export var is_lose = false

#onready var camera_origin_pos = Vector3()



#func _ready():
	#camera_origin_pos =get_parent().get_node("Camroot").translation

func _process(delta):


	for my_bones in get_tree().get_nodes_in_group("ragdoll member"):
		if is_lose:
			my_bones.disabled = false
			print("vv")
		else:
			my_bones.disabled = true
		
	for me in get_tree().get_nodes_in_group("player"):
		if is_lose:
			me.set("frozen", true)
			#print("ragdoll")
		else:
			me.set("frozen", false)



	for my_broken_bones in get_tree().get_nodes_in_group("bone"):
		pass
		my_broken_bones.apply_central_impulse(Vector3(0.0,0,0.3))
		#my_broken_bones.set_friction(3.0)
	get_parent().get_parent().get_parent().get_parent().get_node("Node/Camroot").translation = $"camera".global_transform.origin
	#print($"BoneAttachment".translation)

	if Input.is_key_pressed(KEY_R):
		is_lose = false
		get_parent().get_parent().get_parent().get_parent().translation = Vector3(0,0,0)

	if Input.is_key_pressed(KEY_T):
		is_lose = true

		

	if is_lose:
		physical_bones_start_simulation()
		
		#######get_parent().get_parent().get_parent().get_parent().translation.x = get_parent().get_parent().get_parent().get_parent().get_node("Camroot").translation.x
		##get_parent().get_parent().get_parent().get_parent().translation.z = get_parent().get_parent().get_parent().get_parent().get_node("Camroot").translation.z
		
	else:
		physical_bones_stop_simulation()
		pass
