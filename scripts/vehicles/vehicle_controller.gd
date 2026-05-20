extends VehicleBody3D

@export var engine_force_value: float = 300.0
@export var brake_force_value: float = 60.0
@export var max_steer_angle: float = 0.4  # радианы (~23°)

var speed_kmh: float = 0.0

func _physics_process(delta: float) -> void:
	speed_kmh = linear_velocity.length() * 3.6

	# Руль — при высокой скорости угол уменьшается
	var speed_t = clampf(speed_kmh / 100.0, 0.0, 1.0)
	var current_max_steer = lerp(max_steer_angle, max_steer_angle * 0.3, speed_t)
	var steer_input = Input.get_axis("ui_left", "ui_right")
	steering = move_toward(steering, steer_input * current_max_steer, delta * 3.0)

	# Газ и тормоз
	var throttle = Input.get_axis("ui_down", "ui_up")
	var forward_speed = -linear_velocity.dot(global_transform.basis.z)

	if throttle > 0:
		engine_force = engine_force_value * throttle
		brake = 0.0
	elif throttle < 0:
		if forward_speed > 0.5:
			# Едем вперёд — тормозим
			brake = brake_force_value
			engine_force = 0.0
		else:
			# Стоим или уже едем назад — даём задний ход
			engine_force = engine_force_value * throttle * 0.4
			brake = 0.0
	else:
		engine_force = 0.0
		brake = 8.0  # лёгкое торможение двигателем
