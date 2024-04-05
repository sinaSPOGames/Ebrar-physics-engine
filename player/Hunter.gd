extends KinematicBody

# Allows to pick your animation tree from the inspector
export (NodePath) var PlayerAnimationTree 
export onready var animation_tree = get_node(PlayerAnimationTree)
onready var playback = animation_tree.get("parameters/playback");

# Allows to pick your chracter's mesh from the inspector
export (NodePath) var PlayerCharacterMesh
export (NodePath) var PlayerCharacterMesh2
export (NodePath) var PlayerCharacterMesh3
export onready var player_mesh = get_node(PlayerCharacterMesh)
export onready var player_mesh2 = get_node(PlayerCharacterMesh2)
export onready var player_mesh3 = get_node(PlayerCharacterMesh3)

# Gamplay mechanics and Inspector tweakables
export var gravity = 9.8
export var jump_force = 9
export var walk_speed = 1.3
export var run_speed = 5.5
export var dash_power = 12 # Controls roll and big attack speed boosts

# New system
var is_sprinting = false
var is_still_rotatin_while_idle = false
var is_ragdolling = false
var is_dead = false
var is_parkour = false
var is_idle = false
var frozen = false


# Animation node names
var roll_node_name = "Roll"
var idle_node_name = "Idle"
var walk_node_name = "Walk"
var run_node_name = "Run"
var jump_node_name = "Jump"
var attack1_node_name = "Attack1"
var attack2_node_name = "Attack2"
var bigattack_node_name = "BigAttack"

# Condition States
var is_attacking = bool()
var is_rolling = bool()
var is_walking = bool()
var is_running = bool()

# Physics values
var direction = Vector3()
var horizontal_velocity = Vector3()
export var aim_turn = float()
var movement = Vector3()
var vertical_velocity = Vector3()
var movement_speed = int()
export var angular_acceleration = float()
var acceleration = float()
export var val = 0.0
var on_floor # State control for is jumping/falling/landing



func _ready(): # Camera based Rotation
	direction = Vector3.BACK.rotated(Vector3.UP, $Node/Camroot/h.global_transform.basis.get_euler().y)

func _input(event): # All major mouse and button input events
	if event is InputEventMouseMotion:
		aim_turn = -event.relative.x * 0.015 # animates player with mouse movement while aiming 
	
	if event.is_action_pressed("aim"): # Aim button triggers a strafe walk and camera mechanic
		direction = $Node/Camroot/h.global_transform.basis.z

func roll():
## Dodge button input with dash and interruption to basic actions
	if Input.is_action_just_pressed("roll"):
		if !roll_node_name in playback.get_current_node() and !jump_node_name in playback.get_current_node() and !bigattack_node_name in playback.get_current_node():
			playback.start(roll_node_name) #"start" not "travel" to speedy teleport to the roll!
			horizontal_velocity = direction * dash_power
			
func attack1(): # If not doing other things, start attack1
	if (idle_node_name in playback.get_current_node() or walk_node_name in playback.get_current_node()) and is_on_floor():
		if Input.is_action_just_pressed("attack"):
			if (is_attacking == false):
				playback.travel(attack1_node_name)
				
func attack2(): # If attack1 is animating, combo into attack 2
	if attack1_node_name in playback.get_current_node(): # Big Attack if sprinting, adds a dash
		if Input.is_action_just_pressed("attack"):
			playback.travel(attack2_node_name)
			
func attack3(): # If attack2 is animating, combo into attack 3. This is a template.
	if attack1_node_name in playback.get_current_node(): 
		if Input.is_action_just_pressed("attack"):
			pass #no current animation, but add it's playback here!
	
func rollattack(): # If attack pressed while rolling, do a special attack afterwards.
	if roll_node_name in playback.get_current_node(): 
		if Input.is_action_just_pressed("attack"):
			playback.travel(bigattack_node_name) #change this animation for a different attack
			
func bigattack(): # If attack pressed while springing, do a special attack
	if run_node_name in playback.get_current_node(): # Big Attack if sprinting, adds a dash
		if Input.is_action_just_pressed("attack"):
			horizontal_velocity = direction * dash_power
			playback.travel(bigattack_node_name) #Add and Change this animation node for a different attack
	



onready var last_pos2 = Vector3(player_mesh.translation.x,player_mesh.translation.y,player_mesh.translation.z)

onready var last_pos = Vector3(player_mesh.rotation.y,player_mesh.rotation.y,player_mesh.rotation.y)
var current_speed_y = 0.0
var current_speed = Vector3()

func get_speed_kph():
	return current_speed_y * 3600.0 / 1000.0


var angel = 1


var ragdolling = false
var tic = 0

func _physics_process(delta):
	if tic > 0:
		rollattack()
		bigattack()
		attack1()
		attack2()
		roll()
		
		
		
		#print(vertical_velocity.y)
		if vertical_velocity.y < -6 or vertical_velocity.y > 1:
			on_floor = false
		else:
			on_floor = true
		
		for bones in get_tree().get_nodes_in_group("skeleton_of_player"):
			#PlayerCharacterMesh2 = bones
			if not $Height_base/height.is_colliding():
				is_ragdolling = true
				$Height_base/height.enabled = false
				bones.set("enable_sync_bones_to_anim",false)
				if bones is RigidBody:
					#print("hey")
					$col.disabled = true
					gravity = 0
					#bones.add_torque(Vector3(0,2,5))
					
				bones.set("enable_sync_bones_to_anim",false)
			else:
				is_ragdolling = false
				if bones is RigidBody:
					
					bones.linear_velocity = Vector3(0,0,0)
					bones.angular_velocity = Vector3(0,0,0)
				bones.set("enable_sync_bones_to_anim",true)
				$col.disabled = false
				gravity = 9.8
		
		
		#$Node/Camroot/h.translation = player_mesh.global_transform.origin
		
		if Input.is_key_pressed(KEY_R):
			$Height_base/height.enabled = true
			global_transform.origin = Vector3(0,1,0)
			for me in get_tree().get_nodes_in_group("skeleton_of_player"):
				me.set("get_up",false)
		if Input.is_key_pressed(KEY_T):
			$Height_base/height.enabled = false
		if Input.is_key_pressed(KEY_Y):
			$Height_base/height.enabled = true
			#translation = Vector3(0,0.1,0)
		
		if last_pos > Vector3(player_mesh.rotation.y,player_mesh.rotation.y,player_mesh.rotation.y):
			#print("A")
			angel =  1
		else:
			angel =  -1
			#print("B")
		var y_rot = player_mesh.rotation.y
		var pos = player_mesh.translation
		#print(last_pos)
		current_speed_y = (Vector3(player_mesh.rotation.y,player_mesh.rotation.y,player_mesh.rotation.y) - last_pos).length() #/ delta
		current_speed = (Vector3(player_mesh.translation.x,player_mesh.translation.y,player_mesh.translation.z) - last_pos2) #/ delta
		var h_rot = $Node/Camroot/h.global_transform.basis.get_euler().y
		#print(current_speed)
		
		for me in get_tree().get_nodes_in_group("bone"):
			me.set("val",val)
		if is_ragdolling and not ragdolling:
			
			for me in get_tree().get_nodes_in_group("bone"):
				
				me.linear_velocity.x = current_speed.x * 200
				me.linear_velocity.y = current_speed.y * 200
				me.linear_velocity.z = current_speed.z * 200
				
		
		
		
			#print(player_mesh2.get_node("EXAMPLE_MODEL/root/Skeleton/pelvis").linear_velocity)
			ragdolling = true
		elif !is_ragdolling:
			#print("reset")
			ragdolling = false
		movement_speed = 0
		last_pos = Vector3(y_rot,y_rot,y_rot)
		last_pos2 = pos#Vector3(y_rot,y_rot,y_rot)
		
		if is_sprinting:
			angular_acceleration = 3
		elif is_idle:
			angular_acceleration = 4
		elif !is_sprinting:
			angular_acceleration = 2
		acceleration = 15

		# Gravity mechanics and prevent slope-sliding
		if !frozen:
			#print(direction)
			if not is_on_floor(): 
				vertical_velocity += Vector3.DOWN * gravity * 2 * delta
			else: 
				vertical_velocity = -get_floor_normal() * gravity / 3
			
			# Defining attack state: Add more attacks animations here as you add more!
			if (attack1_node_name in playback.get_current_node()) or (attack2_node_name in playback.get_current_node()) or (bigattack_node_name in playback.get_current_node()): 
				is_attacking = true
			else: 
				is_attacking = false

		# Giving BigAttack some Slide
			if bigattack_node_name in playback.get_current_node(): 
				acceleration = 3

			# Defining Roll state and limiting movment during rolls
			if roll_node_name in playback.get_current_node(): 
				is_rolling = true
				acceleration = 2
				angular_acceleration = 2
			else: 
				is_rolling = false
			
		#	Jump input and Mechanics
			if Input.is_action_just_pressed("jump") and ((is_attacking != true) and (is_rolling != true)) and is_on_floor():
				vertical_velocity = Vector3.UP * jump_force
				
			# Movement input, state and mechanics. *Note: movement stops if attacking
			if (Input.is_action_pressed("forward") ||  Input.is_action_pressed("backward") ||  Input.is_action_pressed("left") ||  Input.is_action_pressed("right")):
				direction = Vector3(Input.get_action_strength("left") - Input.get_action_strength("right"),
							0,
							Input.get_action_strength("forward") - Input.get_action_strength("backward"))
				direction = direction.rotated(Vector3.UP, h_rot).normalized()
				is_walking = true
			
				

			# Sprint input, state and speed
				if (Input.is_action_pressed("sprint")) and (is_walking == true): 
					movement_speed = run_speed
					is_running = true
					is_sprinting = true
				else: # Walk State and speed
					movement_speed = walk_speed
					is_running = false
					is_sprinting = false
					
			else: 
				is_walking = false
				is_running = false
			if not is_ragdolling:
				player_mesh.translation = self.translation
				player_mesh2.translation = self.global_transform.origin
			#	player_mesh3.translation = self.translation
				player_mesh3.global_transform.origin.x = player_mesh2.get_node("EXAMPLE_MODEL/root/Skeleton/pelvis").global_transform.origin.x 
				player_mesh3.global_transform.origin.y = player_mesh2.get_node("EXAMPLE_MODEL/root/Skeleton/pelvis").global_transform.origin.y - 0.82
				player_mesh3.global_transform.origin.z = player_mesh2.get_node("EXAMPLE_MODEL/root/Skeleton/pelvis").global_transform.origin.z -0.25
			
			
			
			
			
			
			
			
			
			
			
			
			
				if Input.is_action_pressed("aim"):  # Aim/Strafe input and  mechanics
					$Height_base.rotation.y = player_mesh.rotation.y
					player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, $Node/Camroot/h.rotation.y, (delta) +0.1)
					player_mesh2.rotation.y = lerp_angle(player_mesh2.rotation.y, $Node/Camroot/h.rotation.y,(delta) + 0.1)
					player_mesh3.rotation.y = lerp_angle(player_mesh3.rotation.y, $Node/Camroot/h.rotation.y, (delta) +0.1)

				else: # Normal turn movement mechanics
					$Height_base.rotation.y = player_mesh.rotation.y
					
					player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(direction.x, direction.z) - rotation.y, (delta) /0.1)
					player_mesh2.rotation.y = lerp_angle(player_mesh2.rotation.y, atan2(direction.x, direction.z) - rotation.y,(delta) / 0.1)
					player_mesh3.rotation.y = lerp_angle(player_mesh3.rotation.y, atan2(direction.x, direction.z) - rotation.y,(delta) / 0.1)
				
				#if is_sprinting:
					#$"Hunter/reference/AnimationPlayer".set_speed_scale(5)
					#print("A")
				#else:
					#print("B")
					#$"Hunter/reference/AnimationPlayer".set_speed_scale(1)

				if is_walking:
						player_mesh.rotation.z = lerp(player_mesh.rotation.z,current_speed_y * (angel * 2),0.2)
						player_mesh2.rotation.z = lerp(player_mesh.rotation.z,current_speed_y * (angel * 2),0.2)
						player_mesh3.rotation.z = lerp(player_mesh.rotation.z,current_speed_y * (angel * 2),0.2)
				else:
						player_mesh.rotation.z = lerp(player_mesh.rotation.z,0.0,0.1)
						player_mesh2.rotation.z = lerp(player_mesh.rotation.z,0.0,0.1)
						player_mesh3.rotation.z = lerp(player_mesh.rotation.z,0.0,0.1)
						
			else:
				#print("AAA")
				for my_bones in get_tree().get_nodes_in_group("bone"):
					my_bones.set("panic",true)
				#player_mesh3.translation = player_mesh2.get_node("EXAMPLE_MODEL/root/Skeleton/pelvis").translation
				player_mesh3.translation.x = player_mesh2.get_node("EXAMPLE_MODEL/root/Skeleton/pelvis").translation.x 
				player_mesh3.translation.y = player_mesh2.get_node("EXAMPLE_MODEL/root/Skeleton/pelvis").translation.y - 0.82
				player_mesh3.translation.z = player_mesh2.get_node("EXAMPLE_MODEL/root/Skeleton/pelvis").translation.z -0.25
			# Movment mechanics with limitations during rolls/attacks
			if ((is_attacking == true) or (is_rolling == true)): 
				horizontal_velocity = horizontal_velocity.linear_interpolate(direction.normalized() * .01 , acceleration * delta)
			else: # Movement mechanics without limitations 
				horizontal_velocity = horizontal_velocity.linear_interpolate(direction.normalized() * movement_speed, acceleration * delta)
			
			# The Physics Sauce. Movement, gravity and velocity in a perfect dance.
			movement.z = horizontal_velocity.z + vertical_velocity.z
			movement.x = horizontal_velocity.x + vertical_velocity.x
			movement.y = vertical_velocity.y
			move_and_slide(movement, Vector3.UP)

			# ========= State machine controls =========
			# The booleans of the on_floor, is_walking etc, trigger the 
			# advanced conditions of the AnimationTree, controlling animation paths
			
			# on_floor manages jumps and falls
			animation_tree["parameters/conditions/IsOnFloor"] = on_floor
			animation_tree["parameters/conditions/IsInAir"] = !on_floor
			# Moving and running respectively
			animation_tree["parameters/conditions/IsWalking"] = is_walking
			animation_tree["parameters/conditions/IsNotWalking"] = !is_walking
			animation_tree["parameters/conditions/IsRunning"] = is_running
			animation_tree["parameters/conditions/IsNotRunning"] = !is_running
			# Attacks and roll don't use these boolean conditions, instead
			# they use "travel" or "start" to one-shot their animations.
			
		#else:
			
			#animation_tree["parameters/conditions/IsOnFloor"] = false
			#animation_tree["parameters/conditions/IsInAir"] = false
			# Moving and running respectively
			#animation_tree["parameters/conditions/IsWalking"] = true
			#animation_tree["parameters/conditions/IsNotWalking"] = false
			#animation_tree["parameters/conditions/IsRunning"] = true
			#animation_tree["parameters/conditions/IsNotRunning"] = true
		tic = 0


func _on_Refresher_test_timeout():
	tic = 1
