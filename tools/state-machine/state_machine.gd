extends RefCounted
class_name StateMachine


var _current_state: State


func _init(default_state: State) -> void:
	_current_state = default_state


func change_state(to: State) -> void:
	if is_instance_valid(_current_state):
		if _current_state.end_func:
			_current_state.end_func.call()
	
	_current_state = to
	
	if _current_state.ready_func:
		_current_state.ready_func.call()


func process(delta: float) -> void:
	_current_state.process_func.call(delta)

func get_state_name() -> String:
	return _current_state.name
