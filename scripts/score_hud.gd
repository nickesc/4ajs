extends CanvasLayer

@export var player: Node3D
@export var player_2: Node3D
@export var game_time: int = 180

@onready var game_timer: Timer = $ScoreContainer/GameTimerLabel/GameTimer
@onready var game_timer_label: Label = $ScoreContainer/GameTimerLabel

@onready var player_score_label: Label = $ScoreContainer/PlayerScore
@onready var player_2_score_label: Label = $ScoreContainer/Player2Score

var playing: bool = true
var unset_weapons: bool = false

func _ready() -> void:
    game_timer.start(game_time)

func _process(delta: float) -> void:
    if playing:
        game_timer_label.text = "%02d:%02d" % [(game_timer.time_left/60), (int(game_timer.time_left) % 60)]
        player_score_label.text = "%02d" % player.score
        player_2_score_label.text = "%02d" % player_2.score
    else:
        if not unset_weapons:
            unset_weapons = true

func _on_killed_by_damage(is_player_2: bool) -> void:
    if playing:
        if is_player_2:
            player.add_kill()
        else:
            player_2.add_kill()


func _on_game_timer_timeout() -> void:
    playing = false
    player.set_peaceful()
    player_2.set_peaceful()
    if player_2.score > player.score:
        game_timer_label.text = "P2 Wins!"
    elif player.score == player_2.score:
        game_timer_label.text = "Tie!"
    else:
        game_timer_label.text = "P1 Wins!"
