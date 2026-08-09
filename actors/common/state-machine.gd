extends Node
class_name StateMachine

""" Filepath res://s/common/state_machine.gd
Description:
	Generic State Machine; inits states, delegates all engine callbacks (such
	  as _physics_process, _unhandled_input, etc) to the active state.
Properties:
	(State) initial_state: The first state the machine loads into.
	(State) state: The active State being used.
	(String) _state_name: The name of said state.
"""
#	Makes a field in the inspector where you can
#	 assign a state node to be the first state.
@export var initial_state: NodePath = NodePath()

@onready var state: State = get_node( initial_state ): set = set_state
@onready var state_name: String = state.name


func _unhandled_input( event: InputEvent ) -> void:
	state.unhandled_input( event )


func set_state( value: State ) -> void:
	state = value
	state_name = state.name


"""
Awaits the parentmost node of the scene to be ready, first. This is because the
 state vars need to be initialized.
"""
func _ready() -> void:
	await owner.ready
	state.enter()


""" This is considered to be this engine's step event. """
func _physics_process( delta: float ) -> void:	state.physics_process( delta )


""" transition_to( String, Dictionary )
Description:
	States call this function to switch which state will run.
	 This involves calling the state's exit() function,
	 then calling the next state's enter() function before
	 finally running the next state's code.
Parameters:
	path_target_state: Local NodePath to the next state.
	machine_info: Info passed between states.
"""
func transition_to(
		path_target_state: String,
		machine_info: Dictionary = {}
) -> void:
	if( has_node( path_target_state ) == false ):
		return
	#	End defensive return
	var target_state: = get_node( path_target_state )
	state.exit()
	state = target_state
	state.enter( machine_info )
