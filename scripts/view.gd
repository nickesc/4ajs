extends Node3D

@export_group("Components")
@export var camera: Camera3D

@export_group("Properties")
@export var target: Node
@export var player_2: bool = false

@export_group("Zoom")
@export var zoom_minimum = 16
@export var zoom_maximum = 4
@export var zoom_speed = 10

@export_group("Rotation")
@export var rotation_speed = 120

var camera_rotation:Vector3
var zoom = 10



func _ready():
    
    camera_rotation = rotation_degrees # Initial rotation
    
    pass

func _physics_process(delta):
    
    # Set position and rotation to targets
    
    if (target):
        self.position = self.position.lerp(target.position, delta * 4)
    
    rotation_degrees = rotation_degrees.lerp(camera_rotation, delta * 6)
    
    if (camera):
        camera.position = camera.position.lerp(Vector3(0, 1, zoom), 8 * delta)
    
    handle_input(delta)

# Handle input

func handle_input(delta):
    
    # Rotation and Zooming
    
    var input := Vector3.ZERO
    
    if player_2:
        input.y = Input.get_axis("camera_right_p2", "camera_left_p2")
        input.x = Input.get_axis("camera_down_p2", "camera_up_p2")
        zoom += Input.get_axis("zoom_in_p2", "zoom_out_p2") * zoom_speed * delta
    else:
        input.y = Input.get_axis("camera_right", "camera_left")
        input.x = Input.get_axis("camera_down", "camera_up")
        zoom += Input.get_axis("zoom_in", "zoom_out") * zoom_speed * delta    
    
    camera_rotation += input.limit_length(1.0) * rotation_speed * delta
    camera_rotation.x = clamp(camera_rotation.x, -80, -10)
    zoom = clamp(zoom, zoom_maximum, zoom_minimum)
    
    
