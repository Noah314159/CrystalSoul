extends Node

var playerPos
var crystalPos

onready var max_crystal_energy = 50

onready var crystal_energy = max_crystal_energy setget set_crystal_energy
onready var crystal_alive = true

onready var health = max_health setget set_health
onready var energy = max_energy setget set_energy

onready var max_health = 10
onready var max_energy = 10
onready var speed = 0 #offset from base in player script
onready var power = 0 #extra damage added to attacks
onready var armor = 0 #damage reduced
onready var regenDelay = 0 #reduce time before regen starts (-0.1)
onready var regenRate = 0#reduce timer to make regen faster (-0.05)

onready var healthPoints = 0
onready var energyPoints = 0
onready var speedPoints = 0
onready var powerPoints = 0
onready var armorPoints = 0
onready var regenPoints = 0

onready var unspentPoints = 0

onready var currentLevel = 0
onready var currentXP = 0 setget set_currentXP
onready var xpToNext = 10

#const XP_PER_LEVEL = []

signal no_health
signal no_energy
signal no_crystal_energy

signal health_changed
signal energy_changed
signal crystal_energy_changed
signal energy_restored

signal xp_changed

func set_health(value):
	if value >= max_health:
		health = max_health
	else:
		health = value
		
	if health <= 0:
		emit_signal("no_health")
	
	emit_signal("health_changed")


func set_energy(value):
	if energy <= 0 && value > 0:
		emit_signal("energy_restored")
	
	if value >= max_energy:
		energy = max_energy
	else:
		energy = value
		
	if energy <= 0:
		emit_signal("no_energy")
		energy = 0
		
	
	emit_signal("energy_changed")

func set_crystal_energy(value):
	if value >= max_crystal_energy:
		crystal_energy = value
	else:
		crystal_energy = value
	
	if crystal_energy <= 0:
		emit_signal("no_crystal_energy")
		crystal_alive = false
		crystal_energy = 0
	
	emit_signal("crystal_energy_changed")

func set_currentXP(value):
	if value >= xpToNext:
		currentXP = value - xpToNext
		currentLevel += 1
		xpToNext += 10
		unspentPoints += 2
	else:
		currentXP = value
	emit_signal("xp_changed")


func set_player(player_pos):
	playerPos = player_pos
	playerPos.y += -5
	
func set_crystal_pos(crystal_pos):
	crystalPos = crystal_pos
