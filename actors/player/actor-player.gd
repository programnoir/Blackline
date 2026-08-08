extends CharacterBody3D
#	https://www.youtube.com/watch?v=EP5AYllgHy8 Player Movement
#	actual slop code lol

@onready var nVisuals: Node3D = $Visuals
@onready var nAnimationPlayer: AnimationPlayer = nVisuals.get_node(
		"mixamo_base/AnimationPlayer" )
@onready var nCamMount: Node3D = $cam_mount

const JOYSTICK_DEADZONE: float = 0.3

@export var look_sensitivity: Vector2 = Vector2( -0.2, -0.2 )
@export var default_turn_lerp: float = 15

#	Blocks on player input.
var is_input_locked: bool = false
var is_animation_locked: bool = false

#	Input: Moving stick
var in_move_digital: Vector2 = Vector2.ZERO
var in_move_analog: Vector2 = Vector2.ZERO
var in_move: Vector2 = Vector2.ZERO
#	Input: Camera stick
var camera_movement: Vector2 = Vector2.ZERO

#	Common variables for player movement.
var in_move_rotated: Vector3 = Vector3.ZERO:
	get: return transform.basis * Vector3( in_move.x, 0, in_move.y )


func _input( event: InputEvent ) -> void:
	if( event is InputEventMouseMotion ):
		var rotation_y: float = event.relative.x * look_sensitivity.x
		rotate_y( deg_to_rad( rotation_y ) )
		nVisuals.rotate_y( deg_to_rad( -1 * rotation_y ) )
		nCamMount.rotate_x(
				deg_to_rad( event.relative.y * look_sensitivity.y ) )


func update_animation(
		new_animation: StringName,
		force_lock: bool = false
) -> void:
	if( force_lock and is_animation_locked ):
		return
	#	End defensive return
	if( nAnimationPlayer.current_animation != new_animation ):
			nAnimationPlayer.play( new_animation )


func toggle_board( new_value: bool ) -> void:
	var save_blend_time: float = nAnimationPlayer.playback_default_blend_time
	nAnimationPlayer.playback_default_blend_time = 0.0
	if( new_value ):
		nAnimationPlayer.play( &"on_board" )
	else:
		nAnimationPlayer.play( &"off_board" )
	nVisuals.get_node( "CSGBox3D" ).visible = new_value
	nAnimationPlayer.playback_default_blend_time = save_blend_time


func limit_camera() -> void:
	nCamMount.rotation.x = clamp( nCamMount.rotation.x,
				deg_to_rad(-60), deg_to_rad(60) )


func update_input() -> void:
	in_move_digital = Input.get_vector( &"ui_left", &"ui_right",
			&"ui_up", &"ui_down" ).normalized()
	in_move_analog = Input.get_vector( &"in_joystick_left", &"in_joystick_right",
			&"in_joystick_up", &"in_joystick_down", JOYSTICK_DEADZONE )
	in_move = ( in_move_digital + in_move_analog ).limit_length()
	camera_movement = Input.get_vector( &"in_joystick_left_2",
			&"in_joystick_right_2", &"in_joystick_up_2", &"in_joystick_down_2",
			JOYSTICK_DEADZONE )


func set_state( new_state: String, info: Dictionary = {} ) -> void:
	%StateMachine.transition_to( new_state, info )


func _physics_process( delta: float ) -> void:
	update_input()
	limit_camera()
	#if( not nAnimationPlayer.is_playing() ):
	#	is_locked = false
	#if( Input.is_action_just_pressed( "kick" ) ):
	#	update_animation( &"kick" )
	#	is_locked = true
	

func turn_visuals_yaw(
		turn_vector: Vector3,
		delta: float,
		turn_lerp: float = default_turn_lerp
) -> void:
	if( is_animation_locked ):
		return
	#	End defensive return: Animation is locked. Input locks should be blocked
	#	 before making turn_visuals calls.
	var global_target_angle = atan2( turn_vector.x, turn_vector.z )
	var local_target_angle = global_target_angle - rotation.y + PI
	nVisuals.rotation.y = lerp_angle(
			nVisuals.rotation.y, local_target_angle, turn_lerp * delta )


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	process_mode = Node.PROCESS_MODE_INHERIT
	%StateMachine.process_mode = Node.PROCESS_MODE_INHERIT
