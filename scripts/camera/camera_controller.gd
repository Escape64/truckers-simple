extends Camera3D

@export var rotation_speed: float = 1.8   # как быстро камера разворачивается вслед за машиной
@export var position_speed: float = 6.0   # как быстро камера догоняет позицию
@export var tp_offset: Vector3 = Vector3(0, 2.2, 8.0)
@export var tp_look_height: float = 0.9
@export var fp_offset: Vector3 = Vector3(0, 1.4, -2.0)

var target: Node3D
var is_first_person: bool = false
var camera_basis: Basis  # запаздывающий курс камеры

func _ready() -> void:
	target = get_parent().get_node_or_null("Truck") as Node3D
	if not target:
		push_error("CameraController: узел Truck не найден!")
		return
	# Стартуем с правильным курсом — без рывка в начале
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
		# Курс камеры медленно поворачивается вслед за грузовиком
		# При повороте грузовика камера отстаёт — виден борт и колёса
		camera_basis = camera_basis.slerp(target.global_transform.basis, rotation_speed * delta)

		# Позиция считается на основе запаздывающего курса
		var desired = target.global_position + camera_basis * tp_offset
		global_position = global_position.lerp(desired, position_speed * delta)

		look_at(target.global_position + Vector3(0, tp_look_height, 0), Vector3.UP)
