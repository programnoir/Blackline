extends State
#	Trick move State

@export var move_lerp: float = 2.0
@export var move_translation_lerp: float = 0.02

@export var max_thrust: Vector3 = Vector3( 0.0, 0.0, 12.0 )
var thrust: Vector3 = Vector3.ZERO
@export var thrust_deccel: float = 0.1
@export var thrust_lerp: float = 7.0
var stored_thrust: float = 0.0
@export var brake: float = 0.1

""" When we enter the state """
func enter( _machine_info: Dictionary = {} ) -> void:
	owner.update_animation( &"on_board" )
	pass
	#%StateMachine.velocity = 0
	#owner.update_animation( &"jump", true )


func check_thrust() -> Vector3:
	if( Input.is_action_just_pressed( "brake" ) ):
		stored_thrust = thrust.z * 0.85
	#	End defensive return: Brake just applies.
	#	Apply full brake calculation
	var total_brake: float = 1.0
	if( not Input.is_action_pressed( "boost" ) ):
		total_brake -= thrust_deccel
	if( Input.is_action_pressed( "brake" ) ):
		total_brake -= brake
		owner.nVisuals.rotation.x = deg_to_rad( 6.0 )
	else:
		owner.nVisuals.rotation.x = 0.0
	#	End brake calculations
	if( Input.is_action_just_released( "brake" ) ):
		thrust.z = stored_thrust
	if( Input.is_action_pressed( "boost" ) ):
		thrust = clamp( lerp( thrust, max_thrust, thrust_lerp ), thrust, max_thrust )
	thrust.z *= total_brake
	return thrust


func is_switching_to_parkour() -> bool:
	if( Input.is_action_just_pressed( "board" ) ):
		owner.set_state( "Parkour/Idle" )
		owner.toggle_board( false )
		return true
	return false


""" The state's step event. """
func physics_process( delta: float ) -> void:
	if( is_switching_to_parkour() ):
		return
	#	End defensive return: Back to parkour!
	if( owner.is_on_floor() ):
		%StateMachine.velocity.y = 0.0
	var thrust_vector: Vector3 = check_thrust().rotated( Vector3.UP, 
			owner.nVisuals.rotation.y ).rotated( Vector3.UP, owner.rotation.y )
	%StateMachine.affect_velocity = thrust_vector
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
				target_velocity, move_translation_lerp )
		owner.turn_visuals_yaw( local_motion_direction, delta, move_lerp )
	else:
		var target_velocity: Vector3 = %StateMachine.velocity
		target_velocity.x = move_toward( %StateMachine.velocity.x, 0,
				%StateMachine.velocity_max.x )
		target_velocity.z = move_toward( %StateMachine.velocity.z, 0,
				%StateMachine.velocity_max.z )
		%StateMachine.velocity = %StateMachine.get_lerp_to_target_velocity( 
				target_velocity, move_translation_lerp )
	%StateMachine.physics_process( delta )


""" When we're done with the state """
func exit() -> void:
	%StateMachine.affect_velocity = Vector3.ZERO
	return
