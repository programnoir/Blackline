extends Node

func is_switching_to_board() -> bool:
	if( Input.is_action_just_pressed( "board" ) ):
		owner.set_state( "Trick/Move" )
		owner.toggle_board( true )
		return true
	return false
