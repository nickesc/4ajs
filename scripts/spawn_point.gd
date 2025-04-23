extends Area3D

@export var player_allowed: bool = true
@export var player_2_allowed: bool = true

var player_inside: bool = false
var player_2_inside: bool = false

func is_available(player_2: bool) -> bool:
    if not player_inside and not player_2_inside:
        if player_allowed and not player_2:
            return true
        elif player_2_allowed and player_2:
            return true
        else:
            return false
    else:
        return false

func _on_body_entered(body: Node3D) -> void:
    if body.is_in_group("P2"):
        player_2_inside = true
    elif body.is_in_group("Player"):
        player_inside = true


func _on_body_exited(body: Node3D) -> void:
    if body.is_in_group("P2"):
        player_2_inside = false
    elif body.is_in_group("Player"):
        player_inside = false
