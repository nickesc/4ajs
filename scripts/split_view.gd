extends Node3D

@export_group("Components")
@export var camera: Camera3D

@export_group("Properties")
@export var target: Node3D

func _ready() -> void:
    self.position = target.position
    self.rotation = target.rotation

func _physics_process(delta: float) -> void:
    self.position = target.position
    self.rotation = target.rotation
