extends Node2D


onready var dialogZone = $PlayerDetectionArea
onready var dialogBox = $DialogBox
onready var dialogText = $DialogBox/Polygon2D/RichTextLabel
onready var dialogSpeedTimer = $DialogBox/Timer


func _ready():
	dialogBox.visible = false
	dialogText.dialog = ["Hello.", "I am a signpost.", "u like reading huh?", "fair enough."]

func _physics_process(_delta):
	if dialogZone.can_see_and_LOS() && Input.is_action_just_pressed("Interact"):
		dialogBox.visible = true
		dialogSpeedTimer.start(0.1)
		
	if dialogZone.can_see_and_LOS():
		dialogText.within_range = true


func _on_PlayerDetectionArea_body_exited(body):
	dialogBox.visible = false
	dialogText.set_visible_characters(0)
	dialogText.within_range = false
