extends TpsController

class_name Player



#####################
#  Default methods  #
#####################

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass



######################
#  Movement methods  #
######################

func movement_logic() -> void:
	if is_on_floor():
		move()
		land()
		if is_jumping():
			jump()
	else:
		airborne_move()
		fall()
