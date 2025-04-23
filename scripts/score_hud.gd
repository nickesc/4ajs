extends CanvasLayer

@export var player: Node3D
@export var player_2: Node3D

@onready var game_timer: Timer = $ScoreContainer/GameTimerLabel/GameTimer
@onready var game_timer_label: Label = $ScoreContainer/GameTimerLabel

@onready var player_score_label: Label = $ScoreContainer/PlayerScore
@onready var player_2_score_label: Label = $ScoreContainer/Player2Score

func _process(delta: float) -> void:
    game_timer_label.text = "%02d:%2d" % [(game_timer.time_left/60), (int(game_timer.time_left) % 60)]
    player_score_label.text = "%02d" % player.score
    player_2_score_label.text = "%02d" % player_2.score

func _on_killed_by_damage(is_player_2: bool) -> void:
    if is_player_2:
        player.add_kill()
    else:
        player_2.add_kill()
