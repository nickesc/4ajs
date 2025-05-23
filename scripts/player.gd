extends CharacterBody3D

signal coin_collected

@export_subgroup("Components")
@export var view: Node3D

@export_subgroup("Properties")
@export var movement_speed = 250
@export var jump_strength = 7
@export var unlock_x = true
@export var unlock_z = true
@export var unlock_jump = true
@export var unlock_double_jump = true
@export var unlock_reset = true
@export var player_2 = false
@export_enum("idle", "sit", "attack-kick-left") var regular_animation: String = "idle"

var movement_velocity: Vector3
var rotation_direction: float
var gravity = 0

var previously_floored = false

var jump_single = true
var jump_double = true

var coins = 0
var initial_position: Vector3

var testing_emit_hearts: bool = false

@onready var particles_trail = $ParticlesTrail
@onready var particles_hearts: CPUParticles3D = $ParticlesHearts
@onready var sound_footsteps = $SoundFootsteps
@onready var model = $AJ
@onready var animation = $AJ/AnimationPlayer

# Functions

func _ready() -> void:
    initial_position = self.get_position()
    if player_2:
        add_to_group("P2")
        $AJ.visible = false
        $NE.visible = true
        model = $NE
        animation = $NE/AnimationPlayer
        scale = Vector3(1.4, 1.4, 1.4)
    else:
        scale = Vector3(1.3, 1.3, 1.3)

func _physics_process(delta):

    # Handle functions

    handle_controls(delta)
    handle_gravity(delta)

    handle_effects(delta)

    # Movement

    var applied_velocity: Vector3

    applied_velocity = velocity.lerp(movement_velocity, delta * 10)
    applied_velocity.y = -gravity

    velocity = applied_velocity
    move_and_slide()

    # Rotation

    if Vector2(velocity.z, velocity.x).length() > 0:
        rotation_direction = Vector2(velocity.z, velocity.x).angle()

    rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 10)

    # Falling/respawning

    if position.y < -10:
        if not player_2:
            get_tree().reload_current_scene()
        else:
            position = initial_position

    # Animation for scale (jumping and landing)

    model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 10)

    # Animation when landing

    if is_on_floor() and gravity > 2 and !previously_floored:
        model.scale = Vector3(1.25, 0.75, 1.25)
        Audio.play("res://sounds/land.ogg")

    previously_floored = is_on_floor()

# Handle animation(s)

func handle_effects(delta):

    particles_trail.emitting = false
    sound_footsteps.stream_paused = true

    if is_on_floor():
        var horizontal_velocity = Vector2(velocity.x, velocity.z)
        var speed_factor = horizontal_velocity.length() / movement_speed / delta
        if speed_factor > 0.05:
            if animation.current_animation != "walk":
                animation.play("walk", 0.1)

            if speed_factor > 0.3:
                sound_footsteps.stream_paused = false
                sound_footsteps.pitch_scale = speed_factor

            if speed_factor > 0.75:
                particles_trail.emitting = true

        elif animation.current_animation != regular_animation:
            animation.play(regular_animation, 0.1)
    elif animation.current_animation != "jump":
        animation.play("jump", 0.1)

# Handle movement input

func handle_controls(delta):

    # Movement

    var input := Vector3.ZERO

    if (unlock_x):
        if not player_2:
            input.x = Input.get_axis("move_left", "move_right")
        else:
            input.x = Input.get_axis("move_left_p2", "move_right_p2")
    if (unlock_z):
        if not player_2:
            input.z = Input.get_axis("move_forward", "move_back")
        else:
            input.z = Input.get_axis("move_forward_p2", "move_back_p2")

    if (view):
        input = input.rotated(Vector3.UP, view.rotation.y)

    if input.length() > 1:
        input = input.normalized()

    movement_velocity = input * movement_speed * delta

    # Jumping
    
    if (unlock_jump):
        var jumped
        
        if not player_2:
            jumped = Input.is_action_just_pressed("jump")
        else:
            jumped = Input.is_action_just_pressed("jump_p2")
            
        if jumped:
            if jump_single or (jump_double and unlock_double_jump):
                jump()
                
    if (unlock_reset):
        if Input.is_action_just_pressed("reset"):
            reset_scene()
        if Input.is_action_just_pressed("reset_p2"):
            position = initial_position
        

# Handle gravity

func handle_gravity(delta):

    gravity += 25 * delta

    if gravity > 0 and is_on_floor():

        jump_single = true
        gravity = 0

# Jumping

func jump():

    Audio.play("res://sounds/jump.ogg")

    gravity = -jump_strength

    model.scale = Vector3(0.5, 1.5, 0.5)

    if jump_single:
        jump_single = false;
        jump_double = true;
    else:
        jump_double = false;

# Collecting coins

func collect_coin():

    coins += 1

    coin_collected.emit(coins)

func set_view(newView: Node3D):
    view = newView



func start_emitting_hearts():
    particles_hearts.emitting = true
    
func stop_emitting_hearts():
    particles_hearts.emitting = false


func _on_hearts_entered(area: Node3D) -> void:
    if area.is_in_group("kissable") and not player_2:
        testing_emit_hearts = true
        $ParticlesHearts/HeartsTimer.start(1)
        


func _on_hearts_exited(area: Node3D) -> void:
    if area.is_in_group("kissable") and not player_2:
        testing_emit_hearts = false
        stop_emitting_hearts()


func _on_heart_timer_timeout() -> void:
    if testing_emit_hearts:
        start_emitting_hearts()
        
        
func reset_scene():
    get_tree().reload_current_scene()
