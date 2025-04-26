extends Node3D

@onready var train: Node3D = $train

var cleared_train: bool = true

func _ready() -> void:
    train.remove_collider()

func _physics_process(delta: float) -> void:
    train.position.z+=.1
    
    if train.position.z > 50 and not cleared_train:
        train.queue_free()
