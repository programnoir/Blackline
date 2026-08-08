extends State
#	Idle Parkour State


""" When we enter the state """
func enter( _machine_info: Dictionary = {} ) -> void:
	%StateMachine.velocity.y = 0
	%StateMachine.acceleration.y = 0
	owner.update_animation( &"idle", true )


""" The state's step event. """
func physics_process( delta: float ) -> void:
	if( not owner.is_on_floor() ):
		owner.set_state( "Parkour/Fall" )
		return
	#	End defensive return: I'm Falling!
	if( %StateMachine.get_node( "Parkour" ).is_switching_to_board() ):
		return
	#	End defensive return: Switching to board!
	if( Input.is_action_just_pressed( "jump" ) ):
		owner.set_state( "Parkour/Jump" )
		return
	#	End defensive return: Jumping
	var local_motion_direction: Vector3 = owner.in_move_rotated
	if( local_motion_direction ):
		owner.set_state( "Parkour/Run" )
		return
	#owner.velocity.x = move_toward( owner.velocity.x, 0, active_speed )
	#owner.velocity.z = move_toward( owner.velocity.z, 0, active_speed )
	%StateMachine.physics_process( delta )


""" When we're done with the state """
func exit() -> void:
	%StateMachine.acceleration = %StateMachine.default_acceleration
