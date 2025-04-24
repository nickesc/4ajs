extends Node3D

@onready var animation: AnimationPlayer = $AnimationPlayer

var regular_animation: String = "attack-kick-left"

func _process(delta: float) -> void:
    if animation.current_animation != regular_animation:
        animation.play(regular_animation, 0.1)
