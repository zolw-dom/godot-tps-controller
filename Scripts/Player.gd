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
	move()

	if is_on_floor():
		land()
		if is_jumping():
			jump()
	else:
		fall()
