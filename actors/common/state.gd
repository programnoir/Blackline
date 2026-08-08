@icon( "res://assets/images/editor/state.svg" )
extends Node
class_name State

"""
Description:
	States are intended to be child nodes of the StateMachine node.
	Each state represents an independent script for the associated
	 actions. This interface provides a means of detailing the
	 state behavior, the information it handles, and when the tasks
	 are to be handled by a parent state.
	The state machine uses built-in functions for execution, while
	 the states have similar but non-matching function names that
	 are to be called in the body of the state machine's execution.
	 This ensures that the only running state is the active one.
Properties:
Notes:
Debug Info:
"""

#	Reference to the state machine it belongs to.
@onready var state_machine: Node = find_state_machine( self )


func get_state_machine() -> Node:
	return state_machine


"""
Locate the state machine node up the parents. The parent will eventually be
 null or we will find our state machine.
"""
func find_state_machine( node: Node ) -> Node:
	if( node != null and ( node is StateMachine ) == false ):
		#	Result has yet to be found; search the parent.
		return find_state_machine( node.get_parent() )
	return node


""" Unexpected input that is handled. """
func unhandled_input( _event: InputEvent ) -> void:
	return


""" When we enter the state """
func enter( _machine_info: Dictionary = {} ) -> void:
	return


""" The state's step event. """
func physics_process( _delta: float ) -> void:
	return


""" When we're done with the state """
func exit() -> void:
	return
