extends Node2D

onready var stats = $EnemyStats
onready var dialogZone = $PlayerDetectionArea
onready var dialogBox = $DialogBox
onready var dialogText = $DialogBox/Polygon2D/RichTextLabel
onready var dialogSpeedTimer = $DialogBox/Timer

const DeathEffect = preload("res://Scenes/Effects/FireMageDeathEffect.tscn")


func _ready():
	dialogBox.visible = false
	dialogText.dialog = ["Hello", "Die", "I said die", "once again die"]

func create_death_effect():
	var deathEffect = DeathEffect.instance()
	get_parent().add_child(deathEffect)
	deathEffect.global_position = global_position

func _physics_process(_delta):
	if dialogZone.can_see_and_LOS() && Input.is_action_just_pressed("Interact"):
		dialogBox.visible = true
		dialogSpeedTimer.start(0.1)
		
	if dialogZone.can_see_and_LOS():
		dialogText.within_range = true

		


func _on_HurtBox_area_entered(area):
	stats.health -= area.damage


func _on_EnemyStats_no_health():
	create_death_effect()
	queue_free()


func _on_PlayerDetectionArea_body_exited(body):
	dialogBox.visible = false
	dialogText.set_visible_characters(0)
	dialogText.within_range = false
