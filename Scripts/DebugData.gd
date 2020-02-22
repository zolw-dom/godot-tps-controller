extends VBoxContainer



var labels = {}
var background : ColorRect



func _ready() -> void:
	background = get_node("../DebugBackground")
	var label_names = ["FPS", "POSITION", "MOVEMENT", "CAMERA_ZOOM"]
	generate_debug_labels(label_names)
	
	Signals.connect("debug_data", self, "update_debug_data")
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Debug Window"):
		toggle_visibility()


func toggle_visibility() -> void:
	visible = not visible
	background.visible = not background.visible


func generate_debug_labels(label_names) -> void:
	for name in label_names:
		var label = Label.new()
		add_child(label)
		labels[name] = label


func update_debug_data(name, value) -> void:
	if name in labels:
		labels[name].text = "%s: %s" % [name, format_value(value)]
	background.rect_size = rect_size


func format_value(value) -> String:
	if typeof(value) == TYPE_VECTOR3:
		return "(X: %.2f,  Y: %.2f,  Z: %.2f)" % [value.x, value.y, value.z]
	elif typeof(value) == TYPE_REAL:
		return "%.2f" % value
	else:
		return str(value)
