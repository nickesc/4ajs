extends Node3D

signal train_entered

var entereable: bool = false
@onready var particles: CPUParticles3D = $"train-electric-subway-c2/Area3D/CPUParticles3D"
@onready var collider: StaticBody3D = $"train-electric-subway-a/StaticBody3D"

func _physics_process(delta: float) -> void:
    if entereable and (Input.is_action_just_pressed("action_p2") or Input.is_action_just_pressed("action")):
        train_entered.emit()

func _on_area_3d_body_entered(body: Node3D) -> void:
    if body.is_in_group("Player") and not body.is_in_group("P2"):
        entereable = true

func _on_area_3d_body_exited(body: Node3D) -> void:
    if body.is_in_group("Player") and not body.is_in_group("P2"):
        entereable = false

func start_effect():
    particles.emitting = true

func stop_effect():
    particles.emitting = false

func remove_collider():
    collider.queue_free()
