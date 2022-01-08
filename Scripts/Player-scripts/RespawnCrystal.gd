extends KinematicBody2D

export var Speed = 80
export var Acceleration = 500

onready var direction = Vector2.ZERO
onready var playerDetection = $PlayerDetectionArea
onready var rechargeRange = $RechargeRange
onready var animation = $AnimationPlayer
onready var shadow = $Shadow
onready var camera = $Camera2D
onready var energyBar = $TinyHealthBar/TextureProgress
onready var playerStats = PlayerStats

enum {FOLLOW, WAIT, IDLE}

var state = FOLLOW
var velocity = Vector2.ZERO
var wait = false
var flag = false

signal crystal_dead

func _ready():
	animation.play("idle")
	playerStats.connect("no_crystal_energy", self, "_on_no_energy")
	playerStats.connect("no_health", self, "make_crystalCam_current")
	playerStats.connect("crystal_energy_changed", self, "update_energyBar")
	energyBar.max_value = playerStats.max_crystal_energy
	energyBar.value = playerStats.max_crystal_energy

func _physics_process(delta):
	playerStats.set_crystal_pos(global_position)
	direction = global_position
	direction = direction.direction_to(PlayerStats.playerPos)
	velocity = velocity.move_toward(direction * Speed, Acceleration * delta)
	
	if Input.is_action_just_pressed("Wait"):
		wait = !wait
	
	if rechargeRange.can_see_player() && Input.is_action_just_pressed("Interact"):
		recharge_player()
	
	if flag:
		state = IDLE
	elif wait:
		state = WAIT
	elif playerDetection.can_see_player():
		state = IDLE
	else:
		state = FOLLOW
	
	match state:
		FOLLOW:
			velocity = move_and_slide(velocity)
		WAIT:
			pass
		IDLE:
			pass
		


func recharge_player():
	var rechargeAmount = playerStats.max_health - playerStats.health
	if rechargeAmount > playerStats.crystal_energy:
		rechargeAmount = playerStats.crystal_energy
	
	playerStats.crystal_energy -= rechargeAmount
	playerStats.health += rechargeAmount
	

func update_energyBar():
	energyBar.value = playerStats.crystal_energy

func make_crystalCam_current():
	camera.make_current()

func _on_no_energy():
	flag = true
	stop_moving()
	animation.play("death")
	shadow.visible = false
	

func stop_moving():
	velocity.move_toward(Vector2.ZERO, 1000)
	velocity = move_and_slide(velocity) 

func _on_death_animation_done():
	emit_signal("crystal_dead")
	queue_free()
	
	

