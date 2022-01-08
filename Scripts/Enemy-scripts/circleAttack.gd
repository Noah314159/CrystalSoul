extends Area2D
	
onready var damage = 5
onready var knockback_power = 0
	
func _ready():
	$AnimationPlayer.play("default")

func _on_animation_done():
	queue_free()
