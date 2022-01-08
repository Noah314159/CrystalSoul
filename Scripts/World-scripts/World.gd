extends Node2D

const MAX_POINTS = 20

onready var stats = PlayerStats
onready var timer = $WorldTimer
onready var wSpawn = $WorldSpawn
onready var crystal = $YSort/RespawnCrystal
onready var player = $YSort/Player
onready var Ysort = $YSort
onready var escMenu = $PauseMenu
onready var DeadCrystal = preload("res://Scenes/Player/DeadCrystal.tscn")

var menu_open = false


func _ready():
	crystal.connect("crystal_dead", self, "_on_no_crystal_energy")
	stats.connect("xp_changed", self, "_on_xp_changed")

	escMenu.visible = false
	escMenu.connect("resume_pressed", self, "destroy_pause_menu")
	escMenu.connect ("quit_pressed", self, "quit")
	
	update_stats()
	_on_xp_changed()

func _physics_process(_delta):
	if Input.is_action_just_pressed("EscMenu") && !menu_open:
		create_pause_menu()
		
	elif Input.is_action_just_pressed("EscMenu") && menu_open:
		destroy_pause_menu()
	
	if Input.is_action_just_pressed("devButton"): #all test code for spawning training dummies
		spawn_at_mouse("res://Scenes/Enemies/circleAttack.tscn")
	elif Input.is_action_just_pressed("devButton2"):
		print ("health: " + str(PlayerStats.health))
		print ("energy: " + str(PlayerStats.energy))
		print ("crystal energy: " + str(PlayerStats.crystal_energy))
		
		
	if Input.is_action_just_pressed("EscMenu"):
		pass
		
func respawn():
	timer.start(5)
	
	

func _on_no_crystal_energy():
	print("1")
	var deadCrystal = DeadCrystal.instance()
	Ysort.add_child(deadCrystal)
	deadCrystal.global_position = stats.crystalPos
	stats.crystal_alive = false


func _on_WorldTimer_timeout():
	var playerObject = load("res://Scenes/Player/Player.tscn")

	var respawnPos = stats.crystalPos
	respawnPos.x += 10
	
	stats.energy = stats.max_energy
	stats.health = stats.max_health
	
	player = playerObject.instance()
	
	
	Ysort.add_child(player)
	if stats.crystal_alive:
		player.global_position = respawnPos
	else:
		player.global_position = wSpawn.global_position
		
	
	stats.crystal_energy -= stats.max_health * 1.5
	if stats.crystal_energy <= 0:
		stats.health = stats.max_health/2
		


func _on_CrystalRespawnArea_crystal_respawned():
	var Crystal = load ("res://Scenes/Player/RespawnCrystal.tscn")
	var crystal = Crystal.instance()
	Ysort.add_child(crystal)
	var crystalPos = stats.playerPos
	stats.crystal_energy = stats.max_crystal_energy
	crystalPos.x += 5
	crystal.global_position = crystalPos
	stats.crystal_alive = true
	crystal.connect("crystal_dead", self, "_on_no_crystal_energy")


func create_pause_menu():
	var pos = stats.playerPos
	pos.x -= 90
	pos.y -= 140
	escMenu.set_global_position(pos)
	escMenu.visible = true
	menu_open = true
	get_tree().paused = true
	
func destroy_pause_menu():
	escMenu.visible = false
	menu_open = false
	get_tree().paused = false
	
	
func spawn_at_mouse(path):
	var obj = load(path)
	var instance = obj.instance()
	Ysort.add_child(instance)
	instance.global_position = get_global_mouse_position()

func spawn_at_player(path, xOffest, yOffset):
	var obj = load(path)
	var instance = obj.instance()
	Ysort.add_child(instance)
	var pos = stats.playerPos
	pos.x += xOffest
	pos.y += yOffset
	instance.global_position = pos
	
func quit():
	get_tree().quit()


func _on_plusHealth_pressed():
	if stats.unspentPoints > 0:
		stats.healthPoints += 1
		stats.unspentPoints -= 1
		update_stats()
	


func _on_minusHealth_pressed():
	if stats.healthPoints > 0:
		stats.healthPoints -= 1
		stats.unspentPoints += 1
		update_stats()
	

func update_stats():
	var unspentNum = $PauseMenu/TabContainer/Stats/Unspent/numUnspent
	var healthNum = $PauseMenu/TabContainer/Stats/Health/numHealth
	var energyNum = $PauseMenu/TabContainer/Stats/Energy/numEnergy
	var speedNum = $PauseMenu/TabContainer/Stats/Speed/number
	var armorNum = $PauseMenu/TabContainer/Stats/Armor/number
	var regenNum = $PauseMenu/TabContainer/Stats/Recovery/number
	var powerNum = $PauseMenu/TabContainer/Stats/Power/number
	
	
	if stats.healthPoints >= MAX_POINTS:
		stats.healthPoints = MAX_POINTS
	if stats.energyPoints >= MAX_POINTS:
		stats.energyPoints = MAX_POINTS
	if stats.speedPoints >= MAX_POINTS:
		stats.speedPoints = MAX_POINTS
	if stats.armorPoints >= MAX_POINTS:
		stats.armorPoints = MAX_POINTS
	if stats.regenPoints >= MAX_POINTS:
		stats.regenPoints = MAX_POINTS
	if stats.powerPoints >= MAX_POINTS:
		stats.powerPoints = MAX_POINTS
	
	
	unspentNum.text = str(stats.unspentPoints)
	if stats.healthPoints < 10:
		healthNum.text = "0" + str(stats.healthPoints)
	else:
		healthNum.text = str(stats.healthPoints)
	if stats.energyPoints < 10:
		energyNum.text = "0" + str(stats.energyPoints)
	else:
		energyNum.text = str(stats.energyPoints)
	if stats.speedPoints < 10:
		speedNum.text = "0" + str(stats.speedPoints)
	else:
		speedNum.text = str(stats.speedPoints)
	if stats.armorPoints < 10:
		armorNum.text = "0" + str(stats.armorPoints)
	else:
		armorNum.text = str(stats.armorPoints)
	if stats.regenPoints < 10:
		regenNum.text = "0" + str(stats.regenPoints)
	else:
		regenNum.text = str(stats.regenPoints)
	if stats.powerPoints < 10:
		powerNum.text = "0" + str(stats.powerPoints)
	else:
		powerNum.text = str(stats.powerPoints)
	
	
	
	stats.max_health = (stats.healthPoints * 2) + 10
	stats.max_energy = (stats.energyPoints * 2) + 10
	stats.speed = (stats.speedPoints * 5)
	stats.power = stats.powerPoints
	if stats.armorPoints % 2 == 0:
		stats.armor = stats.armorPoints / 2
	else:
		stats.armor = (stats.armorPoints - 1) / 2
	stats.regenDelay = stats.regenPoints * -0.1
	stats.regenRate = stats.regenPoints * -0.02
	
	if stats.health > stats.max_health:
		stats.health = stats.max_health
	if stats.energy > stats.max_energy:
		stats.energy = stats.max_energy
	
	
	player.update_energyBar()
	player.update_healthBar()
	
	


func _on_minusEnergy_pressed():
	if stats.energyPoints > 0:
		stats.energyPoints -= 1
		stats.unspentPoints += 1
		update_stats()


func _on_plusEnergy_pressed():
	if stats.unspentPoints > 0:
		stats.energyPoints += 1
		stats.unspentPoints -= 1
		update_stats()


func _on_minusSpeed_pressed():
	if stats.speedPoints > 0:
		stats.speedPoints -= 1
		stats.unspentPoints += 1
		update_stats()


func _on_plusSpeed_pressed():
	if stats.unspentPoints > 0:
		stats.unspentPointsPoints -= 1
		stats.speedPoints += 1
		update_stats()


func _on_minusPower_pressed():
	if stats.powerPoints > 0:
		stats.powerPoints -= 1
		stats.unspentPoints += 1
		update_stats()


func _on_plusPower_pressed():
	if stats.unspentPoints > 0:
		stats.powerPoints += 1
		stats.unspentPoints -= 1
		update_stats()


func _on_minusArmor_pressed():
	if stats.armorPoints > 0:
		stats.armorPoints -= 1
		stats.unspentPoints += 1
		update_stats()


func _on_plusArmor_pressed():
	if stats.unspentPoints > 0:
		stats.armorPoints += 1
		stats.unspentPoints -= 1
		update_stats()


func _on_minusRegen_pressed():
	if stats.regenPoints > 0:
		stats.regenPoints -= 1
		stats.unspentPoints += 1
		update_stats()


func _on_plusRegen_pressed():
	if stats.unspentPoints > 0:
		stats.regenPoints += 1
		stats.unspentPoints -= 1
		update_stats()


func _on_xp_changed():
	var currentXP = $PauseMenu/TabContainer/Stats/xp/currentXP
	var xpToNext = $PauseMenu/TabContainer/Stats/xp/nextLevelXP
	var levelNum = $PauseMenu/TabContainer/Stats/Level/numLevel
	
	currentXP.text = str(stats.currentXP)
	xpToNext.text = str(stats.xpToNext)
	levelNum.text = str(stats.currentLevel)
	
	update_stats()
