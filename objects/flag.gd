extends Node3D

@export var transition_to: PackedScene
@export var player: Node3D

func _on_body_entered(body):
    if (body == player):
        get_tree().change_scene_to_packed(transition_to)
