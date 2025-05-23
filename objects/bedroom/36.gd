extends Node3D

@export var BedTearaway: Node3D
@export var FamilyTearaway: Node3D
@export var BathroomTearaway: Node3D
@export var HallwayTearaway: Node3D
@export var P2Tearaway: Node3D
@export var ElevatorTearaway: Node3D

@onready var elevator_timer: Timer = $ElevatorTimer

@export_file('*.tscn') var transition_to: String

@export var one_player_mode = false

var p1_elevator = false
var p2_elevator = false

#var transparentStone: StandardMaterial3D = preload("res://materials/stone_transparent.tres")
#var transparentStoneDark: StandardMaterial3D = preload("res://materials/stoneDark_transparent.tres")

signal enter_bed
signal enter_family
signal enter_bathroom
signal enter_hallway
signal enter_p2
signal enter_elevator

signal exit_bed
signal exit_family
signal exit_bathroom
signal exit_hallway
signal exit_p2
signal exit_elevator

signal elevator_ready

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

func turnInvisible(node) -> void:
    #node.visible = false
    for child in node.get_children():
        if ("transparency" in child):
            if (child.name.contains("doorway")):
                child.set_transparency(.7)   
            else:
                child.set_transparency(1)
        
    
func turnOpaque(node) -> void:
    for child in node.get_children():
        if ("transparency" in child):
            child.set_transparency(0)
    
    
func _on_Area3D_body_entered(body, tearawayString):
    if body.is_in_group("Player"):
        match tearawayString:
            "Bed":
                turnInvisible(BedTearaway)
            "Family":
                turnInvisible(FamilyTearaway)
                #turnOpaque(HallwayTearaway)
            "Bathroom":
                turnInvisible(BathroomTearaway)
            "Hallway":
                turnInvisible(HallwayTearaway)
            "P2":
                turnInvisible(P2Tearaway)
                turnInvisible(HallwayTearaway)
            "Elevator":
                turnInvisible(ElevatorTearaway)
                turnInvisible(HallwayTearaway)
                if (body.name == "Player"):
                    p1_elevator = true
                elif (body.name == "P2"):
                    p2_elevator = true
                
                if (p1_elevator and p2_elevator) or (p1_elevator and one_player_mode):
                    emit_signal("elevator_ready")
                
        emit_signal("enter_"+tearawayString.to_lower())
       
        
func _on_Area3D_body_exited(body, tearawayString):
    if body.is_in_group("Player"):
        match tearawayString:
            "Bed":
                turnOpaque(BedTearaway)
            "Family":
                turnOpaque(FamilyTearaway)
                turnOpaque(P2Tearaway)
            "Bathroom":
                turnOpaque(BathroomTearaway)
            "Hallway":
                pass
                #turnOpaque(HallwayTearaway)
            "P2":
                pass
                
            "Elevator":
                left_elevator()
        emit_signal("exit_"+tearawayString.to_lower())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    
var swapping: bool = false
func swap_scenes():
    print("Elevator reached. Transition incoming.")
    swapping = true
    elevator_timer.start(2)

func left_elevator():
    swapping = false

func move_elevator():
    if swapping:
        var next_scene = load(transition_to)
        get_tree().change_scene_to_packed(next_scene)
