extends Camera3D

@export var follow_speed: float = 3.0
@export var tp_offset: Vector3 = Vector3(0, 2.5, 7.0)
@export var tp_look_height: float = 0.8
@export var fp_offset: Vector3 = Vector3(0, 1.4, -2.0)

var target: Node3D
var is_first_person: bool = false

func _ready() -> void:
	# Ищем грузовик в родительской сцене по имени
	target = get_parent().get_node_or_null("Truck") as Node3D
	if not target:
		push_error("CameraController: узел Truck не найден!")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("camera_toggle"):
		is_first_person = not is_first_person

	if not target:
		return

	if is_first_person:
		global_transform = target.global_transform
		global_position = target.global_transform * fp_offset
	else:
		var desired = target.global_position + target.global_transform.basis * tp_offset
		global_position = global_position.lerp(desired, follow_speed * delta)
		look_at(target.global_position + Vector3(0, tp_look_height, 0), Vector3.UP)
