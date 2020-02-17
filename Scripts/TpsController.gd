extends KinematicBody

class_name TpsController



################
#  Properties  #
################

var movement_direction : Vector3

# Camera nodes
var camera_pivot : Spatial
var camera_rod : Spatial

# Movement properties
export var movement_speed : float = 400.0
export var jump_height : float = 400.0
export var gravity : float = -20.0

# Camera properties
	# Camera movement
export var mouse_sensitivity : float = 0.15
export var camera_min_vertical_rotation : float = -45.0
export var camera_max_vertical_rotation : float = 45.0
	# Camera zooming
export var camera_min_zoom_distance : float = 0.0
export var camera_max_zoom_distance : float = 10.0

# Cursor
var is_cursor_visible setget set_is_cursor_visible, get_is_cursor_visible
func set_is_cursor_visible(value): Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if value else Input.MOUSE_MODE_CAPTURED)
func get_is_cursor_visible(): return Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE



#####################
#  Default methods  #
#####################

func _ready() -> void:
	camera_pivot = get_node("CameraPivot")
	camera_rod = camera_pivot.get_node("CameraRod")
	
	self.is_cursor_visible = false


# warning-ignore:unused_argument
func _process(delta: float) -> void:
	process_basic_input()
	process_movement_input()


func _physics_process(delta: float) -> void:
	movement_logic()


func _input(event : InputEvent):
	process_mouse_input(event)



######################
#  Movement methods  #
######################

func movement_logic() -> void: pass


func move() -> void:
	var delta = get_physics_process_delta_time()
	
	var snapValue = Vector3() if is_jumping() else Vector3(0, -1, 0)
	
	move_and_slide_with_snap(movement_direction * delta, snapValue, Vector3.UP, true)


func jump() -> void:
	movement_direction.y = jump_height


func fall() -> void:
	movement_direction.y += gravity


func land() -> void:
	movement_direction.y = 0



####################
#  Camera methods  #
####################

func camera_zoom(zoom_value : float):
	var current_zoom = camera_rod.transform.origin.z
	camera_rod.transform.origin.z = clamp(
		current_zoom + zoom_value,
		camera_min_zoom_distance, camera_max_zoom_distance
	)


func rotate_camera(camera_direction : Vector2) -> void:
	# Vertical rotation
	self.camera_pivot.rotate_x(-camera_direction.y)
	
	# Limit vertical rotation
	self.camera_pivot.rotation_degrees.x = clamp(
		self.camera_pivot.rotation_degrees.x,
		camera_min_vertical_rotation, camera_max_vertical_rotation
	)
	
	# Horizontal rotation
	self.rotate_y(-camera_direction.x)


func toggle_cursor_visibility() -> void:
	self.is_cursor_visible = !self.is_cursor_visible



###################
#  Input methods  #
###################

func process_basic_input():
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_cursor_visibility()


func process_mouse_input(event : InputEvent) -> void:
	# Cursor movement
	if event is InputEventMouseMotion:
		var camera_direction = Vector2(
			deg2rad(event.relative.x * mouse_sensitivity),
			deg2rad(event.relative.y * mouse_sensitivity)
		)
		if !self.is_cursor_visible:
			rotate_camera(camera_direction)
	
	# Scrolling
	elif event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				camera_zoom(-1)
			if event.button_index == BUTTON_WHEEL_DOWN:
				camera_zoom(1)


func process_movement_input() -> void:
	var oldGravity = movement_direction.y
	
	var new_movement_direction = Vector3()
	
	# Get movement direction from input
	new_movement_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	new_movement_direction.z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	movement_direction.x *= movement_speed
	movement_direction.z *= movement_speed
	
	new_movement_direction = new_movement_direction.normalized()
	
	# Change the transform to local from world
	new_movement_direction = self.transform.basis.xform(new_movement_direction)
	
	new_movement_direction.y = oldGravity;
	
	self.movement_direction = new_movement_direction


func is_jumping() -> bool:
	return Input.is_action_pressed("ui_select")
