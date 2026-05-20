extends Camera3D

@export var target: Node3D
@export var follow_speed: float = 3.0       # меньше = больше лага, ленивее камера
@export var tp_offset: Vector3 = Vector3(0, 2.5, 7.0)  # за и выше грузовика
@export var tp_look_height: float = 0.8     # точка куда смотрим (выше центра)
@export var fp_offset: Vector3 = Vector3(0, 1.4, -2.0) # позиция в кабине

var is_first_person: bool = false

func _ready() -> void:
	if not target:
		return
	# Ставим камеру сразу в нужное место без плавности при старте
	var desired = target.global_position + target.global_transform.basis * tp_offset
	global_position = desired
	look_at(target.global_position + Vector3(0, tp_look_height, 0), Vector3.UP)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("camera_toggle"):
		is_first_person = not is_first_person

	if not target:
		return

	if is_first_person:
		# Кабина: жёстко к грузовику, смотрим вперёд
		global_transform = target.global_transform
		global_position = target.global_transform * fp_offset
	else:
		# 3-е лицо: плавно догоняем позицию за грузовиком
		var desired = target.global_position + target.global_transform.basis * tp_offset
		global_position = global_position.lerp(desired, follow_speed * delta)
		look_at(target.global_position + Vector3(0, tp_look_height, 0), Vector3.UP)
