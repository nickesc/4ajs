extends Node3D

@export_file('*.tscn') var transition_to: String
@export var player: Node3D

func _on_body_entered(body):
    if (body == player):
        print("Flag reached. Scene transition incoming.")
        var next_scene = load(transition_to)
        get_tree().change_scene_to_packed(next_scene)
