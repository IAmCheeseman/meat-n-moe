extends RefCounted
class_name State


var name: String
var process_func: Callable
var ready_func: Callable
var end_func: Callable


func _init(n: String, pf: Callable, rf=null, ef=null) -> void:
	name = n
	process_func = pf
	ready_func = rf
	end_func = ef
