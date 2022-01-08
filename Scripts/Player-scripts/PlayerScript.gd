extends KinematicBody2D



export var FRICTION = 1000 #(1000 default)how quickly the player comes to a stop after releasing movement keys


export var DODGE_SPEED = 500 #(500 default) the speed the player moves during a dodge

const BASE_SPEED = 65
const BASE_REGEN_DELAY = 3
const BASE_REGEN_RATE = 0.5

export var I_FRAME_TIME = 0.5 #the amount of time the player is invincible after taking a hit

export var attack_energy_cost = -1 #how much energy each attack costs
export var dodge_energy_cost = -2 #how much energy each attack costs

var attackDelay = 0.3
var energy_regen_amount = 1
var energy_regen_rate = BASE_REGEN_RATE
var energy_regen_delay = BASE_REGEN_DELAY

var dodgeDelay = 0.4

enum {MOVE, DODGE, ATTACK, NO_ENERGY}

var state = MOVE

var ACCELERATION = 0 #how quickly the player will reach their max speed

var topSpeed = 0 #this determines the max speed that the player can acheive
var velocity = Vector2.ZERO #initializes the players velocity to 0
var dodge_velocity = Vector2.ZERO #speed and direction of the dodge
var dodge_vel_inverse = Vector2.ZERO
var input_vector = Vector2.ZERO
var knockback = Vector2.ZERO
var can_dodge = true
var can_attack = true


var stats = PlayerStats #autoload singleton that handles player stats

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var basicAttackHitBox = $AttackHitBoxPivot/BasicAttackHitBox
onready var hurtbox = $HurtBox
onready var healthBar = $HealthUI/statBar
onready var healthLabel = $HealthUI/statLabel
onready var energyBar = $EnergyUI/statBar
onready var energyLabel = $EnergyUI/statLabel
onready var stamRegenTimer = $staminaRegen
onready var stamRegenDelayTimer = $staminaRegenDelay
onready var dodgeTimer = $dodgeDelay
onready var attackTimer = $attackDelay
onready var camera = $Camera2D
onready var animationState = animationTree.get("parameters/playback")

func _ready():
	stats.connect("no_health", self, "respawn")
	stats.connect("no_energy", self, "_on_no_energy")
	stats.connect("health_changed", self, "update_healthBar")
	stats.connect("energy_changed", self, "update_energyBar")
	stats.connect("energy_restored", self, "_on_energy_restored")
	
	camera.make_current()
	
	update_energyBar()
	update_healthBar()
	
	animationTree.active = true
	get_node("AttackHitBoxPivot/BasicAttackHitBox/CollisionShape2D").disabled = true
	basicAttackHitBox.knockback_vector = input_vector
	

	


func _physics_process(delta):
	energy_regen_rate = BASE_REGEN_RATE + stats.regenRate
	energy_regen_delay = BASE_REGEN_DELAY + stats.regenDelay
	
	topSpeed = BASE_SPEED + stats.speed
	ACCELERATION = 1000
	
	if knockback != Vector2.ZERO:
		knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
		knockback = move_and_slide(knockback)
	
	stats.set_player(global_position)
	
	input_vector = Vector2.ZERO #this block gets the input vector from the movement keys every frame
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	
	if Input.is_action_just_pressed("Dodge") && state != NO_ENERGY && can_dodge: #placed here so dodge can be used at any time
		animationTree.set("parameters/Dodge/blend_position", input_vector) #sets dodge direction here so it can change mid attack
		state = DODGE
		dodgeTimer.start(dodgeDelay)
	
	
	match state: #match, similar to switch statements, selects the state based off enum
		MOVE:
			move_state(delta)
		DODGE:
			dodge_state(delta)
		ATTACK:
			attack_state(delta)
		NO_ENERGY:
			get_node("AttackHitBoxPivot/BasicAttackHitBox/CollisionShape2D").disabled = true
			if input_vector != Vector2.ZERO:
				animationTree.set("parameters/Walk/blend_position", input_vector)
				animationTree.set("parameters/Idle/blend_position", input_vector)
				animationState.travel("Walk")
				velocity = velocity.move_toward(input_vector * 40, 350 * delta)
			else:
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			
			move()
		

func move_state(delta):
	get_node("AttackHitBoxPivot/BasicAttackHitBox/CollisionShape2D").disabled = true #ensure that hitbox cannot be active while outside attack state
	
	var mouseVector = Vector2.ZERO #this block gets mouse vector to aim attacks
	mouseVector = get_local_mouse_position()
	mouseVector.normalized()
	
	animationTree.set("parameters/Attack/blend_position", mouseVector) #sets attack animation blendspace towards mouse
	
	if input_vector != Vector2.ZERO:
		dodge_vel_inverse = -dodge_velocity #inverse for idle dodgeing
		basicAttackHitBox.knockback_vector = input_vector #sets the knockback direction to be the direction you are moving
		dodge_velocity = input_vector
		animationTree.set("parameters/Walk/blend_position", input_vector)
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationState.travel("Walk")
		velocity = velocity.move_toward(input_vector * topSpeed, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()
	
	if Input.is_action_just_pressed("Attack") && can_attack:
		state = ATTACK
	
	
func attack_state(delta):
	stamRegenTimer.stop()
	
	animationState.travel("Attack")
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * topSpeed, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	move()


func dodge_state(_delta):
	stamRegenTimer.stop()
	get_node("AttackHitBoxPivot/BasicAttackHitBox/CollisionShape2D").disabled = true #ensure that hitbox cannot be active while outside attack state
	
	if input_vector != Vector2.ZERO && can_dodge: #if theres input, dodge in that direction
		dodge_velocity = input_vector
	elif can_dodge: #else dodge opposite the idle direction
		dodge_velocity = dodge_vel_inverse

	velocity = dodge_velocity * (DODGE_SPEED + (2 * stats.speed))
	

	animationState.travel("Dodge")
	
	can_dodge = false
	move()


func dodge_animation_done():
	start_energy_regen_delay(energy_regen_delay)
	velocity = Vector2.ZERO
	if stats.energy <= 0:
		state = NO_ENERGY
	else:
		state = MOVE


func attack_animation_done():
	attackTimer.start(attackDelay)
	can_attack = false
	animationState.travel("Idle")
	start_energy_regen_delay(energy_regen_delay)
	if stats.energy <= 0:
		state = NO_ENERGY
	else:
		state = MOVE
	
func move():
	velocity = move_and_slide(velocity)
	
func start_energy_regen_delay(value):
	stamRegenDelayTimer.start(value)

func _on_no_energy():
	stamRegenTimer.stop()
	start_energy_regen_delay(energy_regen_delay * 2)
	state = NO_ENERGY
	velocity = Vector2.ZERO

func _on_energy_restored():
	state = MOVE

func attack_energy_update():
	update_energy(attack_energy_cost)

func dodge_energy_update():
	update_energy(dodge_energy_cost)

func update_energy(value):
	stats.energy += value
	energyBar.value = stats.energy
	energyLabel.set_text(str(stats.energy))
	
func update_energyBar():
	energyBar.value = stats.energy
	energyBar.set_max(stats.max_energy)
	energyLabel.set_text(str(stats.energy))

func update_healthBar():
	healthBar.value = stats.health
	healthBar.set_max(stats.max_health)
	healthLabel.set_text(str(stats.health))

func respawn():
	queue_free()
	get_tree().current_scene.respawn()
	

func _on_HurtBox_area_entered(area):
	if (hurtbox.invincible == false):
		if area.damage - stats.armor <= 0:
			stats.health -= 1
		else:
			stats.health -= (area.damage - stats.armor)
			
		update_healthBar()
		hurtbox.start_invincibility(I_FRAME_TIME)
		hurtbox.create_hit_effect()
		knockback = (global_position - area.global_position).normalized() * area.knockback_power


func _on_staminaRegen_timeout():
	stats.energy += energy_regen_amount


func _on_staminaRegenDelay_timeout():
	stamRegenTimer.start(energy_regen_rate)


func _on_dodgeDelay_timeout():
	can_dodge = true



func _on_attackDelay_timeout():
	print(str(can_attack))
	can_attack = true
	print(str(can_attack))
