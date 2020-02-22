extends KinematicBody

class_name TpsController



################
#  Properties  #
################

var movement_direction : Vector3
var velocity : Vector3

# Camera nodes
var camera_pivot : Spatial
var camera_rod : Spatial
var camera_raycast : RayCast

# Movement properties
export var movement_speed : float = 400.0
export var airbone_multiplier : float = 0.50
export var jump_height : float = 400.0
export var gravity : float = -20.0
export var slide_value : float = 0.90

# Camera properties
	# Camera movement
export var mouse_sensitivity : float = 0.15
export var camera_min_vertical_rotation : float = -45.0
export var camera_max_vertical_rotation : float = 45.0
	# Camera zooming
export var camera_zoom : float = 3.0 setget set_camera_zoom
func set_camera_zoom(value): camera_zoom = clamp(value, camera_min_zoom_distance, camera_max_zoom_distance)
export var camera_min_zoom_distance : float = 3.0
export var camera_max_zoom_distance : float = 15.0
export var camera_zoom_step : float = 0.5

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
	camera_raycast = camera_pivot.get_node("CameraRayCast")
	
	self.camera_zoom = self.camera_zoom
	
	self.is_cursor_visible = false


func _process(delta: float) -> void:
	process_basic_input()
	process_movement_input()


func _physics_process(delta: float) -> void:
	movement_logic()
	camera_movement()
	
	debug_fps()
	debug_position(global_transform.origin)
	debug_camera_zoom(camera_rod.transform.origin.z)


func _unhandled_input(event: InputEvent) -> void:
	process_mouse_input(event)



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



####################
#  Camera methods  #
####################

func camera_movement():
	camera_raycast.cast_to = camera_pivot.transform.origin
	camera_raycast.cast_to.z = self.camera_zoom
	
	if camera_raycast.is_colliding():
		camera_rod.transform.origin.z = camera_pivot.global_transform.origin.distance_to(camera_raycast.get_collision_point())
	else:
		camera_rod.transform.origin.z += (self.camera_zoom - camera_rod.transform.origin.z) * 0.50


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
				self.camera_zoom -= camera_zoom_step
			if event.button_index == BUTTON_WHEEL_DOWN:
				self.camera_zoom += camera_zoom_step


func process_movement_input() -> void:
	var new_movement_direction = Vector3(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		0,
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
	new_movement_direction = new_movement_direction.normalized()
	
	# Change the transform to local from world
	new_movement_direction = self.transform.basis.xform(new_movement_direction)
	
	new_movement_direction.x *= movement_speed
	new_movement_direction.z *= movement_speed
	
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

func debug_camera_zoom(zoom_value : float) -> void:
	debug_data("CAMERA_ZOOM", zoom_value)
