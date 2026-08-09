extends State
#	Fall Parkour State

@export var fall_lerp: float = 2.0
@export var fall_translation_lerp: float = 0.02

""" When we enter the state """
func enter( _machine_info: Dictionary = {} ) -> void:
	print( "Entering Falling" )
	pass
	#%StateMachine.velocity = 0
	#owner.update_animation( &"jump", true )


""" The state's step event. """
func physics_process( delta: float ) -> void:
	if( %StateMachine.get_node( "Parkour" ).is_switching_to_board() ):
		return
	#	End defensive return: Switching to board!
	if( owner.is_on_floor() ):
		if( %StateMachine.get_base_velocity_xz().length() > 0.0 ):
			owner.set_state( "Parkour/Idle" )
			return
		#	End defensive return: Idle
		owner.set_state( "Parkour/Run" )
		return
	#	End defensive return: Running.
	var local_motion_direction: Vector3 = owner.in_move_rotated
	if( local_motion_direction ):
		var target_velocity: Vector3 = %StateMachine.velocity
		target_velocity.x = local_motion_direction.x * \
				 %StateMachine.velocity_max.x
		target_velocity.z = local_motion_direction.z * \
				%StateMachine.velocity_max.z
		#	I think this turning lerp works for hoverboarding and sliding.
		#	For *parkour* I think we should be doing something closer to
		#	Classic platforming instead.
		%StateMachine.velocity = %StateMachine.get_lerp_to_target_velocity( 
				target_velocity, fall_translation_lerp )
		owner.turn_visuals_yaw( local_motion_direction, delta, fall_lerp )
	else:
		var target_velocity: Vector3 = %StateMachine.velocity
		target_velocity.x = move_toward( %StateMachine.velocity.x, 0,
				%StateMachine.velocity_max.x )
		target_velocity.z = move_toward( %StateMachine.velocity.z, 0,
				%StateMachine.velocity_max.z )
		%StateMachine.velocity = %StateMachine.get_lerp_to_target_velocity( 
				target_velocity, fall_translation_lerp )
	%StateMachine.physics_process( delta )


""" When we're done with the state """
func exit() -> void:
	return
