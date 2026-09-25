extends Node2D

# Orchestrates the 1v1 prototype between the player and the boss
@onready var player: CharacterBody2D = $Player
@onready var boss: CharacterBody2D = $Boss2

signal combat_ended(result)

func _ready():
	if player == null or boss == null:
		return
	boss.player = player
	boss.connect("attack_started", Callable(self, "_on_boss_attack_started"))
	boss.connect("attack_hit", Callable(self, "_on_boss_attack_hit"))
	print("Prototype started: boss 1v1")

func _on_boss_attack_started(attack_info):
	player.start_parry()
	print("Boss started attack: %s" % attack_info.get("type", "unknown"))

func _on_boss_attack_hit(attack_info):
	var dmg = attack_info.get("damage", 0)
	if player.check_parry():
		var counter = player.attack()
		boss.apply_damage(counter.get("damage", 0))
		print("Parry success: boss took %s damage" % counter.get("damage", 0))
	else:
		player.apply_damage(dmg)
		print("Parry failed: player took %s damage" % dmg)
	_check_end_conditions()

func _check_end_conditions():
	if boss.hp <= 0:
		emit_signal("combat_ended", "victory")
		print("Victory")
	elif player.hp <= 0:
		emit_signal("combat_ended", "defeat")
		print("Defeat")
