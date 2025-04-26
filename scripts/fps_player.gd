extends CharacterBody3D

signal coin_collected
signal killed_by_damage(is_player_2: bool)

@export_subgroup("Properties")
@export var movement_speed = 5
@export var jump_strength = 8
@export var player_2 = false
@export var root_node: Node
@export var rotation_target: Vector3 = Vector3(0,-1,0)
@export_enum("idle", "holding-right", "static") var regular_animation: String = "idle"
@export var spawn_points: Array[Node3D]
@export var unlock_reset = true

@export_subgroup("Weapons")
@export var weapons: Array[Weapon] = []
@export var peaceful: bool = false

var weapon: Weapon
var weapon_index := 0

var mouse_sensitivity = 700
var gamepad_sensitivity := 0.075

var mouse_captured := true

var movement_velocity: Vector3


var input_mouse: Vector2

var health:int = 100
var coins: int = 0
var gravity := 0.0

var score: int = 0

var previously_floored := false

var jump_single := true
var jump_double := true

var container_offset = Vector3(1.2, -1.1, -2.75)

var tween:Tween

signal health_updated

@onready var camera = $Head/Camera
@onready var raycast = $Head/Camera/RayCast
@onready var muzzle = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/Muzzle
@onready var container = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/Container
@onready var sound_footsteps = $SoundFootsteps
@onready var blaster_cooldown = $Cooldown
@onready var model = $AJ
@onready var animation = $AJ/AnimationPlayer
@onready var particles_trail: CPUParticles3D = $ParticlesTrail
@onready var particles_damage: CPUParticles3D = $ParticlesDamage

@export var crosshair:TextureRect

var og_fov
var og_position
var og_rotation

# Functions

func _ready():

    og_fov = camera.fov
    og_position = position
    og_rotation  = rotation

    if player_2:
        add_to_group("P2")
        $AJ.visible = false
        $NE.visible = true
        camera.set_cull_mask_value(3, true)
        camera.set_cull_mask_value(4, false)
        model = $NE
        animation = $NE/AnimationPlayer
        scale = Vector3(1.4, 1.4, 1.4)
    else:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        scale = Vector3(1.3, 1.3, 1.3)

    weapon = weapons[weapon_index] # Weapon must never be nil
    initiate_change_weapon(weapon_index)
    
    if peaceful:
        set_peaceful()

func _physics_process(delta):

    # Handle functions

    handle_controls(delta)
    handle_gravity(delta)

    handle_effects(delta)

    # Movement

    var applied_velocity: Vector3

    movement_velocity = transform.basis * movement_velocity # Move forward

    applied_velocity = velocity.lerp(movement_velocity, delta * 10)
    applied_velocity.y = -gravity

    velocity = applied_velocity
    move_and_slide()

    # Rotation

    camera.rotation.z = lerp_angle(camera.rotation.z, -input_mouse.x * 25 * delta, delta * 5)

    camera.rotation.x = lerp_angle(camera.rotation.x, rotation_target.x, delta * 25)
    rotation.y = lerp_angle(rotation.y, rotation_target.y, delta * 25)

    container.position = lerp(container.position, container_offset - (basis.inverse() * applied_velocity / 30), delta * 10)

    # Movement sound

    if sound_footsteps:
        sound_footsteps.stream_paused = true

        if is_on_floor():
            if abs(velocity.x) > 1 or abs(velocity.z) > 1:
                sound_footsteps.stream_paused = false

    # Animation for scale (jumping and landing)

    model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 10)

    # Landing after jump or falling

    camera.position.y = lerp(camera.position.y, 0.0, delta * 5)

    if is_on_floor() and gravity > 1 and !previously_floored: # Landed
        model.scale = Vector3(1.25, 0.75, 1.25)
        Audio.play("sounds/land.ogg")
        camera.position.y = -0.1

    previously_floored = is_on_floor()

    # Falling/respawning

    if position.y < -10:
        remove_kill()
        kill()

# Mouse movement

func _input(event):

    if not player_2:
        if event is InputEventMouseMotion and mouse_captured:

            input_mouse = event.relative / mouse_sensitivity

            rotation_target.y -= event.relative.x / mouse_sensitivity
            rotation_target.x -= event.relative.y / mouse_sensitivity
            #print(rotation_target)

func handle_controls(_delta):

    # Mouse capture

    if not player_2:
        if Input.is_action_just_pressed("mouse_capture"):
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
            mouse_captured = true

        if Input.is_action_just_pressed("mouse_capture_exit"):
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
            mouse_captured = false

            input_mouse = Vector2.ZERO

    # Movement

    var input: Vector2

    if not player_2:
        input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    else:
        input = Input.get_vector("move_left_p2", "move_right_p2", "move_forward_p2", "move_back_p2")

    movement_velocity = Vector3(input.x, 0, input.y).normalized() * movement_speed

    # Rotation

    var rotation_input: Vector2

    if not player_2:
        rotation_input = Input.get_vector("camera_right", "camera_left", "camera_down", "camera_up")
    else:
        rotation_input = Input.get_vector("camera_right_p2", "camera_left_p2", "camera_down_p2", "camera_up_p2")

    rotation_target -= Vector3(-rotation_input.y, -rotation_input.x, 0).limit_length(1.0) * gamepad_sensitivity
    rotation_target.x = clamp(rotation_target.x, deg_to_rad(-90), deg_to_rad(90))

    # Shooting

    action_zoom()
    action_unzoom()
    if not peaceful:
        action_shoot()

    # Jumping

    var jumped

    if not player_2:
        jumped = Input.is_action_just_pressed("jump")
    else:
        jumped = Input.is_action_just_pressed("jump_p2")

    if jumped:

        if jump_single or jump_double:
            Audio.play("sounds/jump.ogg")

        if jump_double:

            gravity = -jump_strength
            jump_double = false

        if(jump_single): action_jump()

    # Weapon switching

    if not peaceful:
        action_weapon_toggle()
    
    if (unlock_reset):
        if Input.is_action_just_pressed("reset") and not player_2:
            reset_scene()
        elif Input.is_action_just_pressed("reset_p2") and player_2:
            respawn()

# Handle gravity

func handle_gravity(delta):

    gravity += 20 * delta

    if gravity > 0 and is_on_floor():

        jump_single = true
        gravity = 0

# Animation

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
                #sound_footsteps.pitch_scale = speed_factor

            if speed_factor > 0.75:
                particles_trail.emitting = true

        elif animation.current_animation != regular_animation:
            animation.play(regular_animation, 0.1)
    elif animation.current_animation != "jump":
        animation.play("jump", 0.1)

# Jumping

func action_jump():

    gravity = -jump_strength

    jump_single = false;
    jump_double = true;

# Shooting

func action_zoom():
    var zoomed

    if not player_2:
        zoomed = Input.is_action_pressed("zoom")
    else:
        zoomed = Input.is_action_pressed("zoom_p2")

    if zoomed:
        camera.fov = og_fov / 2
    else:
        camera.fov = og_fov

func action_unzoom():
    var unzoomed

    if not player_2:
        unzoomed = Input.is_action_pressed("zoom")
    else:
        unzoomed = Input.is_action_pressed("zoom_p2")

    if unzoomed:
        pass

func action_shoot():

    # Shooting

    var shot

    if not player_2:
        shot = Input.is_action_pressed("shoot")
    else:
        shot = Input.is_action_pressed("shoot_p2")

    if shot:

        if !blaster_cooldown.is_stopped(): return # Cooldown for shooting

        Audio.play(weapon.sound_shoot)

        container.position.z += 0.25 # Knockback of weapon visual
        camera.rotation.x += 0.025 # Knockback of camera
        movement_velocity += Vector3(0, 0, weapon.knockback) # Knockback

        # Set muzzle flash position, play animation

        muzzle.play("default")

        muzzle.rotation_degrees.z = randf_range(-45, 45)
        muzzle.scale = Vector3.ONE * randf_range(0.40, 0.75)
        muzzle.position = container.position - weapon.muzzle_position

        blaster_cooldown.start(weapon.cooldown)

        # Shoot the weapon, amount based on shot count

        for n in weapon.shot_count:

            raycast.target_position.x = randf_range(-weapon.spread, weapon.spread)
            raycast.target_position.y = randf_range(-weapon.spread, weapon.spread)

            raycast.force_raycast_update()

            if !raycast.is_colliding(): continue # Don't create impact when raycast didn't hit

            var collider = raycast.get_collider()

            # Hitting an enemy

            if collider.has_method("damage"):
                collider.damage(weapon.damage)

            # Creating an impact animation

            var impact = preload("res://objects/impact.tscn")
            var impact_instance = impact.instantiate()

            impact_instance.play("shot")

            root_node.add_child(impact_instance)

            impact_instance.position = raycast.get_collision_point() + (raycast.get_collision_normal() / 10)
            impact_instance.look_at(camera.global_transform.origin, Vector3.UP, true)

# Toggle between available weapons (listed in 'weapons')

func action_weapon_toggle():

    var toggled

    if not player_2:
        toggled = Input.is_action_just_pressed("weapon_toggle")
    else:
        toggled = Input.is_action_just_pressed("weapon_toggle_p2")

    if toggled:

        weapon_index = wrap(weapon_index + 1, 0, weapons.size())
        initiate_change_weapon(weapon_index)

        Audio.play("sounds/weapon_change.ogg")

# Initiates the weapon changing animation (tween)

func initiate_change_weapon(index):

    weapon_index = index

    tween = self.create_tween()
    tween.set_ease(Tween.EASE_OUT_IN)
    tween.tween_property(container, "position", container_offset - Vector3(0, 1, 0), 0.1)
    tween.tween_callback(change_weapon) # Changes the model

# Switches the weapon model (off-screen)

func change_weapon():

    weapon = weapons[weapon_index]

    # Step 1. Remove previous weapon model(s) from container

    for n in container.get_children():
        container.remove_child(n)

    # Step 2. Place new weapon model in container

    var weapon_model = weapon.model.instantiate()
    container.add_child(weapon_model)

    weapon_model.position = weapon.position
    weapon_model.rotation_degrees = weapon.rotation

    # Step 3. Set model to only render on layer 2 (the weapon camera)

    for child in weapon_model.find_children("*", "MeshInstance3D"):
        child.layers = 2

    # Set weapon data

    raycast.target_position = Vector3(0, 0, -1) * weapon.max_distance
    if crosshair:
        crosshair.texture = weapon.crosshair

func damage(amount):

    health -= amount
    health_updated.emit(health) # Update health on HUD
    
    particles_damage.emitting = true
    #particles_damage.mesh.text = "%d" % amount

    if health <= 0:
        killed_by_damage.emit(player_2)
        kill() # Reset when out of health

func get_avaialable_spawn_point() -> Node3D:
    var respawn_point = spawn_points.pick_random()
    
    if not respawn_point.is_available(player_2):
        respawn_point = get_avaialable_spawn_point()
    
    return respawn_point

func respawn():
    var respawn_position: Vector3 = og_position
    var respawn_rotation: Vector3 = og_rotation
    
    if spawn_points:
        var spawn_point = get_avaialable_spawn_point()
        
        respawn_position = spawn_point.get_global_position()
        respawn_rotation = spawn_point.get_global_rotation()
    
    reset_pos(respawn_position, respawn_rotation)
    
    health = 100
    health_updated.emit(health)

func reset_pos(pos: Vector3, rot: Vector3):
    position = pos
    rotation = rot

func kill():
    respawn()

func add_kill():
    score += 1

func remove_kill():
    score -= 1

func collect_coin():

    coins += 1

    coin_collected.emit(coins)

func reset_scene():
    get_tree().reload_current_scene()

func set_peaceful():
    peaceful = true
    muzzle.visible = false
    container.visible = false
    crosshair.visible = false
