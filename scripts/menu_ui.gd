extends VBoxContainer

@export var action_delay: float = 1
#@export_file('*.tscn') var transition_to: String

var next_scene: PackedScene = preload("res://scenes/bedroom.tscn")

@onready var start: Button = $Start
@onready var quit: Button = $Quit
@onready var start_delay: Timer = $StartDelay

var focus_grabbed: bool = false
var starting: bool = false
var quitting: bool = false

func _process(delta):
    if not focus_grabbed:
        if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
            start.grab_focus()
            focus_grabbed = true

func _on_quit_pressed() -> void:
    get_tree().quit()


func _on_start_pressed() -> void:
    starting = true
    start_delay.start(action_delay)


func _on_start_delay_timeout() -> void:
    get_tree().change_scene_to_packed(next_scene)
