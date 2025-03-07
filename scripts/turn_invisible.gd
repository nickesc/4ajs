extends Node3D

@export var visibilityTarget: Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

func onEnter(body):
    turnInvisible()

func turnInvisible() -> void:
    visibilityTarget.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
