extends State
#	Run Parkour State


""" When we enter the state """
func enter( _machine_info: Dictionary = {} ) -> void:
	%StateMachine.acceleration.y = 0
	#%StateMachine.velocity = 0
	#owner.update_animation( &"jump", true )


func update_run_animations() -> void:
	if( %StateMachine.velocity.length() >
			( %StateMachine.velocity_max.length() / 2.0 )
	):
		owner.update_animation( &"running", true )
	else:
		owner.update_animation( &"walking", true )


""" The state's step event. """
func physics_process( delta: float ) -> void:
	if( not owner.is_on_floor() ):
		owner.set_state( "Parkour/Fall" )
		return
	if( %StateMachine.get_node( "Parkour" ).is_switching_to_board() ):
		return
	#	End defensive return: Switching to board!
	if( Input.is_action_just_pressed( "jump" ) ):
		owner.set_state( "Parkour/Jump" )
		return
	%StateMachine.velocity.y = 0
	#	End defensive return: Falling
	var local_motion_direction: Vector3 = owner.in_move_rotated
	if( local_motion_direction ):
		%StateMachine.velocity.x = local_motion_direction.x * \
				 %StateMachine.velocity_max.x
		%StateMachine.velocity.z = local_motion_direction.z * \
				%StateMachine.velocity_max.z
		owner.turn_visuals_yaw( local_motion_direction, delta )
		update_run_animations()
	else:
		%StateMachine.velocity.x = move_toward( %StateMachine.velocity.x, 0,
				%StateMachine.velocity_max.x )
		%StateMachine.velocity.z = move_toward( %StateMachine.velocity.z, 0,
				%StateMachine.velocity_max.z )
		if( %StateMachine.get_base_velocity_xz().length() < 
				%StateMachine.velocity_x_deadzone
		):
			%StateMachine.velocity = Vector3.ZERO
			owner.set_state( "Parkour/Idle" )
			return
	%StateMachine.physics_process( delta )


""" When we're done with the state """
func exit() -> void:
	%StateMachine.acceleration = %StateMachine.default_acceleration
