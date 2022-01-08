extends KinematicBody2D


const KNOCKBACK_FRICTION = 1000 #friction for the enemy after being knocked back

onready var stats = $EnemyStats #gets a stats objet for the enemy
onready var playerDetectionArea = $PlayerDetectionArea
onready var hurtbox = $HurtBox
onready var softCollision = $SoftCollision
onready var timer = $Timer
onready var attackRange = $AttackRange
onready var fleeRange = $FleeRange
onready var healthBar = $TinyHealthBar/TextureProgress
onready var sprite = $AnimatedSprite
onready var playerStats = PlayerStats

var canAttack = true
var velocity = Vector2.ZERO
var knockback = Vector2.ZERO #direction and speed of the knockback against the enemy
var state = IDLE #current state

export var attackSpeed = 2
export var ACCELERATION = 700
export var FRICTION = 1000
export var TOP_SPEED = 50
export var XP_REWARD = 20

enum {IDLE, WANDER, CHASE, ATTACK} #states for AI

func _ready():
	healthBar.value = stats.max_health
	healthBar.max_value = stats.max_health

func _physics_process(delta):
	
	
	knockback = knockback.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			sprite.stop()
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
		WANDER:
			pass
		CHASE:
			sprite.play("default")
			var player = playerDetectionArea.player
			if player != null && playerDetectionArea.has_lineOfSight():
				var direction = (player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * TOP_SPEED, ACCELERATION * delta)
				seek_player()
				if direction.x <= 0:
					sprite.flip_h = true
				else:
					sprite.flip_h = false
			else:
				state = IDLE
			
		ATTACK:
			sprite.stop()
			var world = get_tree().current_scene
			world.spawn_at_player("res://Scenes/Enemies/circleAttack.tscn", 0, -23)
			state = IDLE
			timer.start(attackSpeed)
			canAttack = false
		
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 500
	velocity = move_and_slide(velocity)
			
			

func seek_player():
	if fleeRange.can_see_player() && playerDetectionArea.has_lineOfSight():
		state = CHASE
	elif attackRange.can_see_player() && canAttack && playerDetectionArea.has_lineOfSight():
		state = ATTACK
	elif attackRange.can_see_player() && !canAttack:
		state = IDLE
	elif playerDetectionArea.can_see_player() && playerDetectionArea.has_lineOfSight():
		state = CHASE

func _on_HurtBox_area_entered(area):
	stats.health -= area.damage + playerStats.power #gets the damage from the hitbox attacking it
	healthBar.value = stats.health
	knockback = (global_position - playerStats.playerPos).normalized() * area.knockback_power
	hurtbox.create_hit_effect()

func _on_EnemyStats_no_health():
	playerStats.currentXP += XP_REWARD
	queue_free()


func _on_Timer_timeout():
	canAttack = true

