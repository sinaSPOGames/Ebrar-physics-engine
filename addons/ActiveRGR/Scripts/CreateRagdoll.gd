tool
extends Skeleton

const RAGDOLL_BONE = preload("RagdollBone.gd")
const ACTIVE_RAGDOLL_JOINT = preload("ActiveRagdollJoint.gd")

export (bool) var create_ragdoll = false setget _set_create_ragdoll
export (bool) var create_joints = false setget _set_create_joints
export (bool) var have_debug_meshes = false setget _set_have_debug_meshes
export (String) var bone_whitelist = ""

var _whitelist := PoolIntArray([])

signal trace_animation_skeleton(value)




"""
CREATION OF ALL THE BONES/RIGID BODIES FOR THE RAGDOLL
"""
func _set_create_ragdoll(value):
	if value:
		if bone_whitelist:
			_whitelist.resize(0)  ## Clear list
			if _interpret_whitelist():
				for bone_id in _whitelist:
					_add_ragdoll_bone(bone_id)
		else:
			for bone_id in range(self.get_bone_count()):
				_add_ragdoll_bone(bone_id)

func _add_ragdoll_bone( bone_id : int ):
	var BONE = RAGDOLL_BONE.new()
	BONE.bone_name = self.get_bone_name(bone_id)
	BONE.name = get_clean_bone_name(bone_id)
	BONE.transform = self.get_bone_global_pose(bone_id)
	
	var collision := CollisionShape.new()
	collision.shape = CapsuleShape.new()
	collision.shape.radius = .1
	collision.shape.height = .1
	collision.rotate_x(PI/2)
	BONE.add_child(collision)
	
	self.add_child(BONE)
	BONE.set_owner(owner) 
	collision.set_owner(owner)


"""
CREATION OF ALL THE JOINTS INBETWEEN THE BONES
"""
func _set_create_joints(value):
	if value:
		if bone_whitelist:
			_whitelist.resize(0)   ## Clear list
			if _interpret_whitelist():
				if _whitelist.size() > 1:
					for bone_id in _whitelist:
						_add_joint_for(bone_id)
				else:
					push_error("Too few bones whitelisted. Need at least two.")
		else:
			for bone_id in range(1, self.get_bone_count()):
				_add_joint_for(bone_id)

func _add_joint_for( bone_id : int ):
	### CHECK THAT THIS BONE ISN'T A ROOT BONE
	if self.get_bone_parent(bone_id) >= 0:
		### CHECK THAT BOTH BONES EXIST
		var node_a : RAGDOLL_BONE = self.get_node_or_null(get_clean_bone_name(self.get_bone_parent(bone_id)))
		var node_b : RAGDOLL_BONE = self.get_node_or_null(get_clean_bone_name(bone_id))
		if node_a and node_b:
			var JOINT := ACTIVE_RAGDOLL_JOINT.new()
			JOINT.transform = self.get_bone_global_pose(bone_id)
			JOINT.name = "JOINT_" + node_a.name + "_" + node_b.name
			JOINT.BONE_A_INDEX = self.find_bone(node_a.bone_name)
			JOINT.BONE_B_INDEX = self.find_bone(node_b.bone_name)
			
			self.add_child(JOINT)
			JOINT.set_owner(owner)
			
			JOINT.set("nodes/node_a", JOINT.get_path_to(node_a) )
			JOINT.set("nodes/node_b", JOINT.get_path_to(node_b) )
			
			## For enabling and disabling animation tracing
			self.connect("trace_animation_skeleton", JOINT, "trace_skeleton")

"""
CREATION OF MESHES THAT ARE THE VISUAL REPRESENTATION OF BONES FOR DEBUG
"""
func _set_have_debug_meshes( value ):
	have_debug_meshes = value
	if have_debug_meshes:
		for bone_id in range(self.get_bone_count()):
			var ragdoll_bone = get_node_or_null(get_clean_bone_name(bone_id))
			if ragdoll_bone: ## DOES BONE EXIST
				var collision = ragdoll_bone.get_node("CollisionShape")
				if collision: ## DOES IT HAVE A COLLISION
					if not collision.has_node("DEBUG_MESH"):
						## FIGURE OUT WHICH MESH SHOULD MASK THE COLLISION SHAPE
						if collision.shape is BoxShape: 
							var box = MeshInstance.new()
							box.name = "DEBUG_MESH"   ## THIS NAME IS IMPORTANT IDENTIFIER FOR LATER DELETION
							box.mesh = CubeMesh.new()
							box.mesh.size.x = collision.shape.extents.x * 2
							box.mesh.size.y = collision.shape.extents.y * 2
							box.mesh.size.z = collision.shape.extents.z * 2 
							collision.add_child(box)
							box.set_owner(owner)
						elif collision.shape is CapsuleShape:
							var capsule := MeshInstance.new()
							capsule.name = "DEBUG_MESH"  ## THIS NAME IS IMPORTANT IDENTIFIER FOR LATER DELETION
							capsule.mesh = CapsuleMesh.new()
							capsule.mesh.radius = collision.shape.radius
							capsule.mesh.mid_height = collision.shape.height
							collision.add_child(capsule)
							capsule.set_owner(owner)
	else:
		for bone_id in range(self.get_bone_count()):
			var ragdoll_bone = get_node_or_null(get_clean_bone_name(bone_id))
			if ragdoll_bone:  ## DOES BONE EXIST
				var collision = ragdoll_bone.get_node("CollisionShape")
				if collision:   ## DOES COLLISON EXIST
					if collision.has_node("DEBUG_MESH"):
						collision.get_node("DEBUG_MESH").queue_free()


"""
PARSE THE BONE LIST(turns the string ranges into numbers and appends them to _whitelist)
"""
func _interpret_whitelist() -> bool:
	var l = bone_whitelist.split(",")
	for _range in l:
		var num = _range.split("-")
		if num.size() == 1:
			_whitelist.push_back(int(num[0]))
		elif num.size() == 2:
			for i in range(int(num[0]), int(num[1]) + 1):
				_whitelist.push_back(i)
		elif num.size() > 2:
			push_error("Incorrect entry in blacklist")
			return false
	return true


"""
NAME THE RIGID BODIES APPROPRIATELY
"""
func get_clean_bone_name( bone_id : int ) -> String:
	return self.get_bone_name(bone_id).replace(".", "_")



"""
DISABLE JOINT CONSTRANTS, AND APPLY FORCES TO MATCH THE TARGET ROTATION
"""
func start_tracing():
	call_deferred("emit_signal", "trace_animation_skeleton", true)

"""
GO LIMP, AND APPLY ALL JOINT CONSTRAINTS
"""
func stop_tracing():
	call_deferred("emit_signal", "trace_animation_skeleton", false)
