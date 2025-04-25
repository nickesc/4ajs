extends Node3D

signal end_entered(player_2: bool)
signal end_exited(player_2: bool)

var player_end: bool = false
var player_2_end: bool = false
var transitioning: bool = false

@export var action_delay: float = 1
@export_file('*.tscn') var transition_to: String

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Area3D2/Timer

func _open_gate(body: Node3D):
    if body.is_in_group("Player"):
        animation.play("open")
        if body.is_in_group("P2") and not player_2_end:
                player_2_end = true
                end_entered.emit(true)
        elif not player_end:
                player_end = true
                end_entered.emit(false)
    
func _close_gate(body: Node3D):
    if body.is_in_group("Player"):
        animation.play("close")

func _on_subway_entered(body: Node3D) -> void:
    if not body.is_in_group("P2") and body.is_in_group("Player"):
        transitioning = true
        timer.start(action_delay)


func _on_subway_timeout() -> void:    
    var next_scene = load(transition_to)
    get_tree().change_scene_to_packed(next_scene)
