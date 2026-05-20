extends Camera3D

@export var rotation_speed: float = 2.0   # лаг поворота (меньше = больше лага)
@export var position_speed: float = 6.0   # лаг позиции
@export var tp_offset: Vector3 = Vector3(0, 2.2, 8.0)
@export var tp_look_height: float = 0.9
@export var fp_offset: Vector3 = Vector3(0, 1.4, -2.0)
@export var look_ahead_strength: float = 3.0  # сила бокового смещения при повороте

var target: Node3D
var is_first_person: bool = false
var camera_basis: Basis

func _ready() -> void:
	target = get_parent().get_node_or_null("Truck") as Node3D
	if not target:
		push_error("CameraController: узел Truck не найден!")
		return
	camera_basis = target.global_transform.basis
	global_position = target.global_position + camera_basis * tp_offset
	look_at(target.global_position + Vector3(0, tp_look_height, 0), Vector3.UP)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("camera_toggle"):
		is_first_person = not is_first_person

	if not target:
		return

	if is_first_person:
		global_transform = target.global_transform
		global_position = target.global_transform * fp_offset
	else:
		# Курс камеры плавно следует за грузовиком
		camera_basis = camera_basis.slerp(target.global_transform.basis, rotation_speed * delta)

		# Боковой сдвиг при повороте: виден борт сразу без долгого ожидания
		var truck_body := target as VehicleBody3D
		var steer := truck_body.steering if truck_body else 0.0
		var side_offset := Vector3(steer * look_ahead_strength, 0.0, 0.0)

		var desired = target.global_position + camera_basis * (tp_offset + side_offset)
		global_position = global_position.lerp(desired, position_speed * delta)
		look_at(target.global_position + Vector3(0, tp_look_height, 0), Vector3.UP)
