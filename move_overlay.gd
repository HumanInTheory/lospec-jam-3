extends MarginContainer

enum MOVE_TYPE {NONE, BLUE, RED}

var state : MOVE_TYPE

func change_state(new_state: MOVE_TYPE):
	state = new_state
	match state:
		MOVE_TYPE.NONE:
			get_child(1).hide()
			get_child(2).hide()
		MOVE_TYPE.RED:
			get_child(1).show()
			get_child(2).hide()
		MOVE_TYPE.BLUE:
			get_child(1).hide()
			get_child(2).show()
