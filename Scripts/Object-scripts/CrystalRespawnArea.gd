extends Node2D


onready var zone = $PlayerDetectionArea
onready var crystal = preload("res://Scenes/Player/RespawnCrystal.tscn")
onready var stats = PlayerStats

signal crystal_respawned



func _on_PlayerDetectionArea_body_entered(body):
	if !stats.crystal_alive:
		emit_signal("crystal_respawned")
	else:
		stats.crystal_energy = stats.max_crystal_energy
