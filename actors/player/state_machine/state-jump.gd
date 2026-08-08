extends State
#	Jump Parkour State

@export var jump_lerp: float = 0.2
@export var jump_translation_lerp: float = 0.02

""" When we enter the state """
func enter( _machine_info: Dictionary = {} ) -> void:
	%StateMachine.velocity.y = %StateMachine.velocity_y_jump
	
	#owner.update_animation( &"jump", true )


""" The state's step event. """
func physics_process( delta: float ) -> void:
	#if( owner.is_on_floor() and %StateMachine.velocity.y == 0.0 ):
	#	if( %StateMachine.get_base_velocity_xz().length() > 0.0 ):
	#		owner.set_state( "Parkour/Idle" )
	#		return
		#	End defensive return: Idle
	#	owner.set_state( "Parkour/Run" )
	#	return
	if( %StateMachine.get_node( "Parkour" ).is_switching_to_board() ):
		return
	#	End defensive return: Switching to board!
	if( %StateMachine.velocity.y < 0 ):
		owner.set_state( "Parkour/Fall" )
		return
	#	End defensive return: Running.
	var local_motion_direction: Vector3 = owner.in_move_rotated
	if( local_motion_direction ):
		var target_velocity: Vector3 = %StateMachine.velocity
		target_velocity.x = local_motion_direction.x * \
				 %StateMachine.velocity_max.x
		target_velocity.z = local_motion_direction.z * \
				%StateMachine.velocity_max.z
		%StateMachine.velocity = %StateMachine.get_lerp_to_target_velocity( 
				target_velocity, jump_translation_lerp )
		owner.turn_visuals_yaw( local_motion_direction, delta, jump_lerp )
	else:
		var target_velocity: Vector3 = %StateMachine.velocity
		target_velocity.x = move_toward( %StateMachine.velocity.x, 0,
				%StateMachine.velocity_max.x )
		target_velocity.z = move_toward( %StateMachine.velocity.z, 0,
				%StateMachine.velocity_max.z )
		%StateMachine.velocity = %StateMachine.get_lerp_to_target_velocity( 
				target_velocity, jump_translation_lerp )
	%StateMachine.physics_process( delta )


""" When we're done with the state """
func exit() -> void:
	return
