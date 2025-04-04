extends Area3D

@export var ring: AudioStreamPlayer3D

var allowRing = false



func _process(delta):
    if Input.is_action_just_pressed("action_p2") and allowRing:
        if !ring.is_playing():
            ring.play()


func _on_body_entered(body: Node3D) -> void:
    if body.is_in_group("P2"):
        allowRing = true


func _on_body_exited(body: Node3D) -> void:
    if body.is_in_group("P2"):
        allowRing = false
