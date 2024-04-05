#tool
extends HingeJoint

export var enable_sync_bones_to_anim = false
export (NodePath) var animation_skeleton
var TARGET_SKELETON : Skeleton
export (int) var BONE_A_INDEX : int = -1
export (int) var BONE_B_INDEX : int = -1
export(float) var matching_velocity_multiplier = 1  ## HOW FAST, AND WITH WHICH FORCE THE JOINT MOTOR TRIES TO SNAP INTO POSITION



# temp test
export var joint_follow = false


func _ready() -> void:
	
	if not is_in_group("skeleton_of_player"):
		add_to_group("skeleton_of_player")
	if enable_sync_bones_to_anim:
		if not Engine.editor_hint:
			### BLINDLY FOLLOWING THE THE CODE FOR THIS EXTENSION
			## https://gist.github.com/mstevenson/7b85893e8caf5ca034e6 ...AT LINE 66
			## COULD BE SPARADIC MOVEMENT IN RAGDOLL  
			#self.set_param_x(Generic6DOFJoint.PARAM_ANGULAR_FORCE_LIMIT, 9999999)
			#self.set_param_y(Generic6DOFJoint.PARAM_ANGULAR_FORCE_LIMIT, 9999999)
			#self.set_param_z(Generic6DOFJoint.PARAM_ANGULAR_FORCE_LIMIT, 9999999)
			
			#self.set_param_x(Generic6DOFJoint.PARAM_ANGULAR_MOTOR_FORCE_LIMIT, 9999999)
			#self.set_param_y(Generic6DOFJoint.PARAM_ANGULAR_MOTOR_FORCE_LIMIT, 9999999)
			#self.set_param_z(Generic6DOFJoint.PARAM_ANGULAR_MOTOR_FORCE_LIMIT, 9999999)
			assert(self.get_parent() is Skeleton, "The Ragdoll Bone[%s] is supposed to be a child of a Skeleton" % [self.name])
			
			
			TARGET_SKELETON = self.get_node_or_null(animation_skeleton)
			if TARGET_SKELETON:  ### IF ANIMATED SKELETON EXISTS
				trace_skeleton(true)
			else:
				trace_skeleton(false)
			
			if BONE_A_INDEX < 0:
				assert(self.get_node(self.get("nodes/node_a")) is self.get_parent().RAGDOLL_BONE, "A RAGDOLL JOINT should have RAGDOLL BONE as node_a")
				BONE_A_INDEX = self.get_node(self.get("nodes/node_a")).BONE_INDEX
			
			if BONE_B_INDEX < 0:
				assert(self.get_node(self.get("nodes/node_b")) is self.get_parent().RAGDOLL_BONE, "A RAGDOLL JOINT should have RAGDOLL BONE as node_a")
				BONE_B_INDEX = self.get_node(self.get("nodes/node_b")).BONE_INDEX


"""
enable_sync_bones_to_anim/DISABLE ANIMATED SKELETON TRACING
"""
func trace_skeleton( value : bool ) -> void:
	if enable_sync_bones_to_anim:
		#self.set_physics_process(value)
		#_declare_flag_for_all_axis( Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, not value )
		#_declare_flag_for_all_axis( Generic6DOFJoint.FLAG_ENABLE_MOTOR, value )
		pass

"""
APPLY FORCES TO THE JOINTS TO MAKE THEM MATCH THE ANIMATED SKELETON
"""
var target_rotation : Basis
onready var nodea = self.get_node(self.get("nodes/node_a"))
onready var nodeb = self.get_node(self.get("nodes/node_b"))
func _physics_process(delta):
	a()
var vell = 0.0
func _process(delta: float) -> void:
	vell = lerp(vell,rand_range(40,-40),0.1)

######################################
func _declare_flag_for_all_axis( param : int, value : bool ) -> void:
	pass



var get_up = false

func a():
	target_rotation = TARGET_SKELETON.get_bone_global_pose(BONE_B_INDEX).basis.inverse() * self.get_parent().get_bone_global_pose(BONE_B_INDEX).basis
	if enable_sync_bones_to_anim:
		
		
		
		#	var max_fps = 0.2
			#var fps = 0.0
		
			#fps += delta * 30
			#if# fps > 0.05:
			#	fps = 0.0
				#print("A")
		#if not Engine.editor_hint:
			#Engine.set_time_scale(1.0)
			if not get_up:
				nodea.transform.basis = TARGET_SKELETON.get_bone_global_pose(BONE_A_INDEX).basis
				nodeb.transform.basis = TARGET_SKELETON.get_bone_global_pose(BONE_B_INDEX).basis
				nodea.transform.origin = TARGET_SKELETON.get_bone_global_pose(BONE_A_INDEX).origin
				nodeb.transform.origin = TARGET_SKELETON.get_bone_global_pose(BONE_B_INDEX).origin
			else:
				#print("resync")

				nodea.transform.basis.x = lerp(TARGET_SKELETON.get_bone_global_pose(BONE_A_INDEX).basis.x,TARGET_SKELETON.get_bone_global_pose(BONE_A_INDEX).basis.x,0.01)
				nodea.transform.basis.y = lerp(TARGET_SKELETON.get_bone_global_pose(BONE_A_INDEX).basis.y,TARGET_SKELETON.get_bone_global_pose(BONE_A_INDEX).basis.y,0.01)
				nodea.transform.basis.z = lerp(TARGET_SKELETON.get_bone_global_pose(BONE_A_INDEX).basis.z,TARGET_SKELETON.get_bone_global_pose(BONE_A_INDEX).basis.z,0.01)
				nodea.transform.origin = lerp(TARGET_SKELETON.get_bone_global_pose(BONE_A_INDEX).origin,TARGET_SKELETON.get_bone_global_pose(BONE_A_INDEX).origin,0.01)
				nodeb.transform.basis.x = lerp(TARGET_SKELETON.get_bone_global_pose(BONE_B_INDEX).basis.x,TARGET_SKELETON.get_bone_global_pose(BONE_B_INDEX).basis.x,0.01)
				nodeb.transform.basis.y = lerp(TARGET_SKELETON.get_bone_global_pose(BONE_B_INDEX).basis.y,TARGET_SKELETON.get_bone_global_pose(BONE_B_INDEX).basis.y,0.01)
				nodeb.transform.basis.z = lerp(TARGET_SKELETON.get_bone_global_pose(BONE_B_INDEX).basis.z,TARGET_SKELETON.get_bone_global_pose(BONE_B_INDEX).basis.z,0.01)
				nodeb.transform.origin = lerp(TARGET_SKELETON.get_bone_global_pose(BONE_B_INDEX).origin,TARGET_SKELETON.get_bone_global_pose(BONE_B_INDEX).origin,0.01)
				#nodea.transform.basis.y += TARGET_SKELETON.get_bone_global_pose(BONE_A_INDEX).basis.y
				#nodea.transform.basis.z += TARGET_SKELETON.get_bone_global_pose(BONE_A_INDEX).basis.z
