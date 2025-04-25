extends Node3D

@onready var animation: AnimationPlayer = $AnimationPlayer

func _open_gate(body: Node3D):
    if body.is_in_group("Player"):
        animation.play("open")
    
func _close_gate(body: Node3D):
    if body.is_in_group("Player"):
        animation.play("close")
