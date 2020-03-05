extends KinematicBody

class_name TpsController



################
#  Properties  #
################

var movement_direction : Vector3
var velocity : Vector3

# Movement properties
export var movement_speed : float = 400.0
export var airbone_multiplier : float = 0.50
export var jump_height : float = 400.0
export var gravity : float = -20.0
export var slide_value : float = 0.90



#####################
#  Default methods  #
#####################

func _process(delta: float) -> void:
	process_movement_input()


func _physics_process(delta: float) -> void:
	movement_logic()
	debug_fps()
	debug_position(global_transform.origin)



######################
#  Movement methods  #
######################

func movement_logic() -> void: pass


func move() -> void:
	var delta = get_process_delta_time()
	var movement = velocity + movement_direction
	var snapValue = Vector3() if is_jumping() else Vector3(0, -1, 0)
	
	move_and_slide_with_snap(movement * delta, snapValue, Vector3.UP, true)
	debug_movement(movement)


func airborne_move() -> void:
	var delta = get_process_delta_time()
	var movement = velocity + (movement_direction * airbone_multiplier)
	
	move_and_slide(movement * delta, Vector3.UP, true)
	debug_movement(movement)


func jump() -> void:
	velocity = movement_direction
	velocity.y = jump_height


func fall() -> void:
	velocity.y += gravity


func land() -> void:
	velocity.x *= slide_value
	velocity.z *= slide_value
	velocity.y = 0



###################
#  Input methods  #
###################

func process_movement_input() -> void:
	var new_movement_direction = Vector3(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		0,
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
	new_movement_direction = new_movement_direction.normalized()
	
	# Change the transform to local from world
	new_movement_direction = self.transform.basis.xform(new_movement_direction)
	
	new_movement_direction.x *= self.movement_speed
	new_movement_direction.z *= self.movement_speed
	
	self.movement_direction = new_movement_direction


func is_jumping() -> bool:
	return Input.is_action_pressed("ui_select")



###################
#  Debug methods  #
###################
func debug_data(name, value) -> void:
	Signals.emit_signal("debug_data", name, value)

func debug_fps() -> void:
	debug_data("FPS", Engine.get_frames_per_second())

func debug_position(position : Vector3) -> void:
	debug_data("POSITION", position)

func debug_movement(movement : Vector3) -> void:
	debug_data("MOVEMENT", movement)
