extends Timer

@export var Bed_PCam: PhantomCamera3D
@export var Bathroom_PCam: PhantomCamera3D
@export var Family_PCam: PhantomCamera3D
@export var Hallway_PCam: PhantomCamera3D
@export var P2_PCam: PhantomCamera3D

@export var Player: CharacterBody3D
@export var P2: CharacterBody3D

@onready var currCam: PhantomCamera3D = Bed_PCam

func _ready() -> void:
    set_hallway_cam_targets()

func set_hallway_cam_targets():
    Hallway_PCam.set_look_at_targets([Player, P2])

func _on_enter_room(roomString):
    match roomString:
            "Bed":
                setPCamPriority(Bed_PCam)
            "Family":
                setPCamPriority(Family_PCam)
            "Bathroom":
                setPCamPriority(Bathroom_PCam)
            "Hallway":
                setPCamPriority(Hallway_PCam)
            "P2":
                setPCamPriority(Hallway_PCam)
    print("moved rooms")

func setPCamPriority(pcam: PhantomCamera3D):
    currCam.set_priority(0)
    pcam.set_priority(10)
    currCam = pcam
    start(1)
    

func _set_view():
    Player.set_view(currCam)
    P2.set_view(currCam)
