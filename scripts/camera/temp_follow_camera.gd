extends Camera3D

# Временная камера для Sprint 0 — в Task 3 заменим на полноценную систему
func _process(_delta: float) -> void:
	var truck = get_parent()
	if truck:
		look_at(truck.global_position + Vector3(0, 0.8, 0), Vector3.UP)
