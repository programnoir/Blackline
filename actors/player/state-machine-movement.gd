extends StateMachine

#	Velocity max has to be converted to a negative value for falling.
@export var default_velocity_max: Vector3 = Vector3( 5.0, 32.0, 5.0 )
@export var default_acceleration: Vector3 = Vector3( 5.0, 5.0, 5.0 )
@export var default_deceleration: Vector3 = Vector3( 2.0, 0.0, 2.0 )
@export var velocity_y_jump: float = 5.0
@export var default_translation_lerp: float = 15.0

#	Main velocity calculation variable
var total_velocity: Vector3 = Vector3.ZERO
#	We use this if we are lerping translation
var translation_lerp: float = default_translation_lerp

#	Base velocity: The velocity that is specified by the player.
var velocity_max: Vector3 = default_velocity_max
var velocity: Vector3 = Vector3.ZERO
var acceleration: Vector3 = default_acceleration
var deceleration: Vector3 = default_deceleration
var velocity_x_max_sprint: float = 1000.0
var velocity_x_deadzone: float = acceleration.x * 0.05

#	Additional custom velocity to impact the base velocity.
var affect_velocity: Vector3 = Vector3.ZERO


func get_base_velocity_xz( vel: Vector3 = velocity ) -> Vector3:
	return Vector3( vel.x, 0, vel.z )


static func calculate_gravity(
		delta: float,
		velocity_current: float,
		gravity: float,
		minimum: float,
		maximum: float
) -> float:
	var new_vel: float = clamp( velocity_current - ( gravity * delta ),
			minimum, maximum )
	return new_vel


func calculate_velocity(
		delta: float,
		velocity_old_static: Vector3,
		velocity_max_static: Vector3,
		acceleration_input: Vector3,
		_deceleration_input: Vector3,
		_velocity_x_deadzone_input: float,
		velocity_y_jump_max_static: float
) -> Vector3:
	var velocity_new: Vector3 = velocity_old_static
	velocity_new.x = clamp( velocity_new.x, -1 * velocity_max_static.x,
			velocity_max_static.x )
	velocity_new.z = clamp( velocity_new.z, -1 * velocity_max_static.z,
			velocity_max_static.z )
	#	Must invert the sign since it works differently here.
	velocity_new.y = calculate_gravity(
			delta, #delta
			velocity_new.y, #velocity_current
			acceleration_input.y, #gravity
			-1 * velocity_max_static.y, #minimum
			velocity_y_jump_max_static #maximum
	)
	return velocity_new


func physics_process( delta: float ) -> void:
	#	Start with calculating velocity using our properties.
	velocity = calculate_velocity(
			delta,
			velocity,
			velocity_max,
			acceleration,
			deceleration,
			velocity_x_deadzone,
			velocity_y_jump
	)
	#	Now we can add additional velocity factors.
	total_velocity = velocity + Vector3( -1 * affect_velocity.x, affect_velocity.y,
			-1 * affect_velocity.z )
	owner.velocity = total_velocity
	owner.move_and_slide()
	#total_velocity = owner.velocity
	# They set this stuff up in Autoload to keep things focused.
	# Events.emit_signal( "player_moved", owner )


func get_lerp_to_target_velocity(
		target_velocity: Vector3,
		input_translation_lerp: float = translation_lerp
) -> Vector3:
	return lerp( velocity, target_velocity, input_translation_lerp )


func _ready() -> void:
	await owner.ready
	state.enter()
