extends Area3D

@onready var hearts: CPUParticles3D = $HeartCollider/Hearts

func _on_body_entered(body: Node3D) -> void:
    if body.is_in_group("Player"):
        hearts.emitting = true


func _on_body_exited(body: Node3D) -> void:
    if body.is_in_group("Player"):
        hearts.emitting = true
