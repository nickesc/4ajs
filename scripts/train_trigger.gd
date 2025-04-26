extends Area3D

@export var player: Node3D
@export var player_2: Node3D
@export var train: Node3D
@export var train_time: int = 10
@export var train_pos: float = .586
@export var train_end: float = 21.661

@export_file('*.tscn') var transition_to: String

@onready var train_timer: Timer = $Timer
var timer_done: bool = false

var entered: bool = false
var emitting: bool = false

func _process(delta: float) -> void:
    if train.position.x < train_pos and timer_done:
        train.position.x+=.05
    if train.position.x >= train_pos and not emitting:
        train.start_effect()
        emitting = true
    if train.position.x >= train_pos and entered:
        train.position.x+=.05
    if train.position.x >= train_end and entered:
        var next_scene = load(transition_to)
        get_tree().change_scene_to_packed(next_scene)

func _on_body_entered(body: Node3D) -> void:
    if body.is_in_group("Player") and not body.is_in_group("P2"):
        train_timer.start(train_time)


func _on_timer_timeout() -> void:
    timer_done = true
    print("timer")
    
func _on_train_train_entered() -> void:
    print("entered")
    train.stop_effect()
    player.visible = false
    player_2.visible = false
    entered = true
