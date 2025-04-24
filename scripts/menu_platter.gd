extends Node3D

@export_range(.1, 1) var rotation_speed: float = 1

func _process(delta):
    rotate_y(rad_to_deg(rotation_speed) * delta/10)
