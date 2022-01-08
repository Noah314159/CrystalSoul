extends Area2D

onready var ray = $RayCast2D

var player = null
var sightLine = false


func can_see_and_LOS():
	if player != null && has_lineOfSight():
		return true
	else:
		return false

func can_see_player():
	return player != null

func has_lineOfSight():
	ray.enabled = true
	ray.set_cast_to(PlayerStats.playerPos - global_position)
	
	return !ray.is_colliding()

func _on_PlayerDetectionArea_body_entered(body):
	player = body


func _on_PlayerDetectionArea_body_exited(_body):
	player = null
	ray.enabled = false
