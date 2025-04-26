extends Node3D

@export_range(.1, 1) var rotation_speed: float = 1
@export var on: bool = true

@onready var title: MeshInstance3D = $Title

func _process(delta):
    if on:
        rotate_y(rad_to_deg(rotation_speed) * delta/10)
        title.rotate_y(rad_to_deg(-rotation_speed) * delta/10)
