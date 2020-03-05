extends Spatial

class_name TpsCamera



################
#  Properties  #
################

onready var player : KinematicBody = get_parent()

# Nodes
onready var camera_pivot : Spatial = self
onready var camera_rod : Spatial = get_node("CameraRod")
onready var camera_raycast : RayCast = get_node("CameraRayCast")

# Movement
export var mouse_sensitivity : float = 0.15
export var camera_min_vertical_rotation : float = -45.0
export var camera_max_vertical_rotation : float = 45.0

# zooming
export var camera_zoom : float = 3.0 setget set_camera_zoom
func set_camera_zoom(value): camera_zoom = clamp(value, camera_min_zoom_distance, camera_max_zoom_distance)
export var camera_min_zoom_distance : float = 3.0
export var camera_max_zoom_distance : float = 15.0
export var camera_zoom_step : float = 0.5

# Cursor
onready var is_cursor_visible setget set_is_cursor_visible, get_is_cursor_visible
func set_is_cursor_visible(value): Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if value else Input.MOUSE_MODE_CAPTURED)
func get_is_cursor_visible(): return Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE



#####################
#  Default methods  #
#####################

func _ready() -> void:
	self.is_cursor_visible = false


func _process(delta: float) -> void:
	camera_movement()
	process_basic_input()


func _unhandled_input(event: InputEvent) -> void:
	process_mouse_input(event)



####################
#  Camera methods  #
####################

func camera_movement():
	camera_raycast.cast_to = camera_pivot.transform.origin
	camera_raycast.cast_to.z = camera_zoom
	
	if camera_raycast.is_colliding():
		camera_rod.transform.origin.z = camera_pivot.global_transform.origin.distance_to(camera_raycast.get_collision_point())
	else:
		camera_rod.transform.origin.z += (camera_zoom - camera_rod.transform.origin.z) * 0.50


func rotate_camera(camera_direction : Vector2) -> void:
	# Vertical rotation
	camera_pivot.rotate_x(-camera_direction.y)
	
	# Limit vertical rotation
	camera_pivot.rotation_degrees.x = clamp(
		camera_pivot.rotation_degrees.x,
		camera_min_vertical_rotation, camera_max_vertical_rotation
	)
	
	# Horizontal rotation
	player.rotate_y(-camera_direction.x)


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
		if event.is_pressed() and not self.is_cursor_visible:
			if event.button_index == BUTTON_WHEEL_UP:
				self.camera_zoom -= camera_zoom_step
			if event.button_index == BUTTON_WHEEL_DOWN:
				self.camera_zoom += camera_zoom_step
