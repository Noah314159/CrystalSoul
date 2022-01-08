extends Area2D

export var damage = 0
export var speed = 900
export var knockback_power = 1

var velocity = Vector2.ZERO
var direction = Vector2.ZERO

func _physics_process(delta):
	if direction == Vector2.ZERO:
		direction = (PlayerStats.playerPos - global_position).normalized()
	velocity = velocity.move_toward(direction * speed, 1000 * delta)
	
	position += transform.x * direction.x * speed * delta
	position += transform.y * direction.y * speed * delta

func _on_Projectile_area_entered(_area):
	queue_free()


func _on_Projectile_body_entered(body):
	queue_free()
