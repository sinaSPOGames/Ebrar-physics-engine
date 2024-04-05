extends RigidBody
#$t#ool
export var enable =false
export (String) var bone_name
var BONE_INDEX : int = -1
var panic = false
export var rot_dis = false
export var left = false
export var right = false
export var head = false
var shake_axis = Vector3(1, 0, 0)
var max_angular_velocity = 10
var val = 0
# Constants
const MAX_TORQUE = 1.0  # Adjust as needed
const ANGLE_THRESHOLD = 0.44  # In radians (approximately 10 degrees)

func _ready() -> void:
	
	
	#connect("body_entered",self,"impact", ["body"])
	disconnect("body_entered",self,"impact")
	
	if not Engine.editor_hint:
		#set_physics_process(false)
	#else:
		assert(get_parent() is Skeleton, "The Ragdoll Bone[%s] is supposed to be a child of a Skeleton" % [self.name])
		assert(bone_name != "", "The Ragdoll Bone[%s] needs to have its bone name defined" % [self.name])
		BONE_INDEX = get_parent().find_bone(bone_name)
		assert(BONE_INDEX >= 0, "The Ragdoll Bone's[%s] bone name[%s] does not match any bone in the skeleton" % [self.name, bone_name])
	if not is_in_group("skeleton_of_player") and not if_con:
		add_to_group("skeleton_of_player")
		if_con = true
		pass
var prev_rotation = rotation
var prev_position = translation
var trigger = false
var myspd = 0.0

export var am_i_locked = false

func _process(delta):
	

	if enable_sync_bones_to_anime:
		var bone_global_rotation : Basis = get_parent().global_transform.basis * get_parent().get_bone_global_pose(BONE_INDEX).basis
		var b2t_rotation : Basis = bone_global_rotation.inverse() * self.transform.basis
		get_parent().set_bone_pose(BONE_INDEX, Transform(get_parent().get_bone_pose(BONE_INDEX).basis * Basis(lerp(b2t_rotation.x,b2t_rotation.x,3.8),lerp(b2t_rotation.y,b2t_rotation.y,0.8),lerp(b2t_rotation.z,b2t_rotation.z,0.8))))

	
	
	#$"CollisionShape".get_shape().margin = 0
	
	
	if !is_in_group("bone"):
		add_to_group("bone")
	# Get the current position and rotation of the Spatial node
	var current_position = translation
	var current_rotation = global_transform.basis.get_euler()
	
	# Calculate the translation velocity
	var translation_velocity = (current_position - prev_position) / delta
	
	# Calculate the rotation velocity
	var rotation_difference = current_rotation - prev_rotation
	var rotation_velocity = rotation_difference / delta
	
	# Store the current position and rotation as the previous values for the next frame
	prev_position = current_position
	prev_rotation = current_rotation
	# Print the rotation and translation velocities to the console
	var yo = true
	
		#pass
	if debug:
		#print("Translation velocity: ", translation_velocity)
		#print("Rotation velocity: ", rotation_velocity)
		pass

func _unused():
	var yo
	if !panic:
			trigger = true
			if trigger and yo:
				linear_velocity# = translation_velocity
				angular_velocity# = rotation_velocity
				trigger = false
				yo = false
			
			var angle = rand_range(-1, 1)
			
			# Create a rotation around the shake axis with the random angle
			var shake_rotation = shake_axis
		#	
		#	# Calculate the resulting angular velocity
			var shake_angular_velocity = shake_rotation.x * max_angular_velocity
		#	
		#	# Apply the angular velocity to the rigid body
			#angular_velocity.x = shake_angular_velocity
		##
	else:
				yo = true
				
"""
APPLY OWN ROTATION TO THE RESPECTIVE BONE IN PARENT SKELETON 
"""

var been_down_for = 0
var time_to_get_up = 50
var health = 100
#this line very needed otherwise the bones will start bitching
export var enable_sync_bones_to_anime = true
export var legsaa = false
export var test = false
export var debug = false
var if_con = false
var balance = 0.0
var head_node = self
var foot_l = self
var foot_r = self
func _physics_process(_delta: float) -> void: #remember 200 physics frames
	if im_correcting_foot:
		#if name == "pelvis":
		balance = abs(get_parent().get_node("pelvis").rotation.x) + abs(get_parent().get_node("pelvis").rotation.z) /2
	if panic:
		if name == "head":
			head_node = get_parent().get_node("head")
			foot_l = get_parent().get_node("foot_l")
			foot_r = get_parent().get_node("foot_r")
		if im_correcting_foot:
				var foot_x = foot_l.translation.x
				var head_x = head_node.translation.x
				var fake_origin = get_parent().get_node("pelvis").global_transform
				var foot_realitive_to_fake_origin = fake_origin.affine_inverse().xform(foot_l.global_translation)
				var head_realitive_to_fake_origin = fake_origin.affine_inverse().xform(head_node.global_translation)
				var foot_distance_x = foot_realitive_to_fake_origin.x - head_realitive_to_fake_origin.x /2
				var foot_distance_z = foot_realitive_to_fake_origin.z - head_realitive_to_fake_origin.z /2
#				print(foot_distance_x , "  ",foot_distance_z)
				#print(balance)
				#print(head_node.translation.distance_squared_to(get_parent().get_node("foot_l").translation))
			#	print(foot_x," ", foot_z)
				#print(get_parent().get_node("foot_l").translation.x + head_node.translation.x/2)
				#print(Vector3(.global_translation.x,get_parent().get_node("foot_l").global_translation.x,get_parent().get_node("foot_l").global_translation.x).distance_to(Vector3(head_node.global_translation.x,head_node.global_translation.x,head_node.global_translation.x)))
				var prim_rot_y = get_parent().get_node("pelvis").global_rotation.y
			#print(prim_rot_y)
				
				if prim_rot_y >= -3.14 and prim_rot_y < -1.57: # -180 to -90 degrees
					#print("west")
					if balance < 0.4:
						get_parent().get_node("foot_l").add_central_force(Vector3(-foot_distance_z * 370, 9.1,-foot_distance_x * 3700))
						get_parent().get_node("foot_r").add_central_force(Vector3(foot_distance_z * 370,  4.1,foot_distance_x * 3700))

				elif prim_rot_y >= -1.57 and prim_rot_y < 0: # -90 to 0 degrees
					#print("south")
					if balance < 0.4:
						get_parent().get_node("foot_l").add_central_force(Vector3(foot_distance_z * 370,  4.1,-foot_distance_x * 3700))
						get_parent().get_node("foot_r").add_central_force(Vector3(foot_distance_z * 370,  9.1,-foot_distance_x * 3700))

				elif prim_rot_y >= 0 and prim_rot_y < 1.57: # 0 to 90 degrees
					#print("north")
					if balance < 0.4:
						get_parent().get_node("foot_l").add_central_force(Vector3(-foot_distance_z * 370,  4.1,foot_distance_x * 3700))
						get_parent().get_node("foot_r").add_central_force(Vector3(-foot_distance_z * 370,  4.1,foot_distance_x * 3700))

				elif prim_rot_y >= 1.57 and prim_rot_y <= 3.14: # 90 to 180 degrees
					#print("east")
					if balance < 0.4:
						get_parent().get_node("foot_l").add_central_force(Vector3(-foot_distance_z * 370,  4.1,-foot_distance_x * 3700))
						get_parent().get_node("foot_r").add_central_force(Vector3(-foot_distance_z * 370,  9.1,-foot_distance_x * 3700))



func _integrate_forces(state):
	pass

func impact(body):

	pass
func get_up():
	for my_joints in get_tree().get_nodes_in_group("skeleton_of_player"):
		#if "JOINT" in my_joints:
		#	print(my_joints)
			my_joints.set("get_up",true)
			my_joints.set("enable_sync_bones_to_anim",true)
	linear_velocity = Vector3.ZERO

func got_up():
	panic = false
var forward_direction = Vector3()

export var im_correcting_foot = false

var left_timer = 0.0
var right_timer = 0.0
func _on_Refresher_test_timeout():
	
	


	if panic:
		for me in get_tree().get_nodes_in_group("self_balance"):
			
			if name == "pelvis":
				var my_left = get_parent().get_node("thigh_l")
				var my_right = get_parent().get_node("thigh_r")
				var my_step_left = get_parent().get_node("foot_l")
				var my_step_right = get_parent().get_node("foot_r")
				#print("ahoy")  # Adjust the name as needed
				# Calculate the pelvis's rotation in local space
				var pelvis_rotation = global_transform.basis
				var pelvis_x_angle = rotation.x
				var pelvis_z_angle = rotation.z

				# Check if the absolute angles exceed the threshold
				if not abs(rotation.x + rotation.y /2) > ANGLE_THRESHOLD:
					# Get the pelvis's linear velocity (ignoring Y component)
					#print("IM DOWN   ",abs(rotation.x + rotation.y /2))
					var pelvis_velocity = linear_velocity
					pelvis_velocity.y = 0.0

					# Determine the direction of pelvis movement
					forward_direction = pelvis_velocity.normalized()

						# Calculate torque based on the direction
					var torque = Vector3.ZERO
					if forward_direction.x > 0.13:
						#print("A")
						torque.x = -MAX_TORQUE
					elif forward_direction.x < 0.13:
						#print("B")
						torque.x = MAX_TORQUE
					if forward_direction.z > 0.13:
					#	print("C")
						torque.x = -MAX_TORQUE
					elif forward_direction.z < 0.13:
					#	print("D")
						torque.x = MAX_TORQUE
					# Apply torque to the leg rigid body


					if left_timer > 0.0:
						# Use the right foot to step
						my_right.apply_torque_impulse(Vector3(MAX_TORQUE, 0.0, 0.0))
						my_left.apply_torque_impulse(-torque)
						#print("Aa")
						left_timer -= 0.01
					elif right_timer > 0.0:
						# Use the left foot to step
						my_left.apply_torque_impulse(Vector3(MAX_TORQUE, 0.0, 0.0))
						right_timer -= 0.01
						#print("A")
						my_right.apply_torque_impulse(-torque)


	
	val = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get("val")
	#print(val)



	if am_i_locked:
		linear_velocity = Vector3.ZERO
	


	if panic:

			if rot_dis:
				set_angular_velocity(Vector3(0,0,0))
			if left:
				add_torque(Vector3(val ,0,-val ))
				#set_angular_velocity(Vector3(angular_velocity.x,angular_velocity.y,val))
			if right:
				add_torque(Vector3(val ,0,-val ))
				
				#set_angular_velocity(Vector3(angular_velocity.x,angular_velocity.y,-val))
			if head:
				#set_angular_velocity(Vector3(angular_velocity.x,val,angular_velocity.z))
				add_torque(Vector3(0 ,val,0))
			
			
			if name == "pelvis":
				#print(get_parent().get_node("head"))
				var head =get_parent().get_node("head")
				var balance = abs(rotation.x) + abs(rotation.z) /2
				if balance < 0.8 and linear_velocity.length() < 3:
					head.gravity_scale = -470
				#	print("I GOT CONTROL")
					#if self.get("im_correcting_foot"):
					#	self.rotation.x = 0
					#	self.rotation.z = 0
						#print(rotation)
				else:
					head.gravity_scale = 1
			#		print("i am down")
				
				#var my_kinematic = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
				#print(my_kinematic)
				#my_kinematic.translation.x = self.global_transform.basis.x.x
				#my_kinematic.rotation = Vector3.ZERO
				if linear_velocity.length() < 1:
					#print("finally im stopped")
					been_down_for += 0.01
					
					if been_down_for > time_to_get_up:
						pass
						#print("wugh gotta get up")
						#get_up()
				
				
			if name == "pelvis":
				#print("A")
				#print(get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_node("ragdoll panic tree")["parameters/Blend2/blend_amount"])
				myspd = linear_velocity.length()*0.04
				
				myspd = clamp(myspd,0.1,1.0)
				#print(get_physics_material_override().friction)
				get_physics_material_override().friction = myspd * 4
				get_physics_material_override().bounce = 1
				get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_node("ragdoll panic tree")["parameters/Blend2/blend_amount"] = myspd
	else:
		for my_joints in get_tree().get_nodes_in_group("skeleton_of_player"):
			#if "JOINT" in my_joints:
		#	print(my_joints)
			my_joints.set("get_up",false)
	
	
	
	
	if enable:
		#self.translation = get_parent().get_bone_global_pose(BONE_INDEX).origin

		

		
		
		
		
		
		if debug:
			#print("b2t_rotation:", b2t_rotation)
			#print("bone_global_rotation:", bone_global_rotation)
			#print("final transformation:", get_parent().get_bone_pose(BONE_INDEX))
			pass










func testing():
	pass

func __process(delta: float) -> void:
	# Check if this node represents the pelvis
	pass





func _on_foot_l_body_entered(body):
	left_timer = 31


func _on_foot_r_body_entered(body):
	right_timer = 31
