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
	_build_controls_hud()
	print("Prototype started: boss 1v1")

func _build_controls_hud() -> void:
	var controls_canvas = CanvasLayer.new()
	controls_canvas.name = "ControlsHUD"
	add_child(controls_canvas)

	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.position = Vector2(18, 18)
	panel.custom_minimum_size = Vector2(280, 140)
	controls_canvas.add_child(panel)

	var label = Label.new()
	label.text = "Controles\nA/D: mover\nEspaço: pular\nEnter: atacar\nJ: parry\nK: rolar\n"
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 16)
	panel.add_child(label)

	var viewport_size = get_viewport_rect().size
	player.health_bar = ProgressBar.new()
	player.health_bar.min_value = 0
	player.health_bar.max_value = player.max_hp
	player.health_bar.value = player.hp
	player.health_bar.show_percentage = true
	player.health_bar.custom_minimum_size = Vector2(420, 22)
	player.health_bar.position = Vector2(viewport_size.x - 450, viewport_size.y - 52)
	player.health_bar.modulate = Color(0.8, 0.3, 0.3, 1.0)
	controls_canvas.add_child(player.health_bar)

	boss.health_bar = ProgressBar.new()
	boss.health_bar.min_value = 0
	boss.health_bar.max_value = boss.max_hp
	boss.health_bar.value = boss.hp
	boss.health_bar.show_percentage = true
	boss.health_bar.custom_minimum_size = Vector2(560, 24)
	boss.health_bar.position = Vector2((viewport_size.x - boss.health_bar.custom_minimum_size.x) * 0.5, 20)
	boss.health_bar.modulate = Color(0.35, 0.8, 0.35, 1.0)
	controls_canvas.add_child(boss.health_bar)
	player.health_bar.visible = true
	boss.health_bar.visible = true

	player._update_health_bar()
	boss._update_health_bar()

func _on_boss_attack_started(attack_info):
	player.start_parry()
	print("Boss started attack: %s" % attack_info.get("type", "unknown"))

func _on_boss_attack_hit(attack_info):
	var dmg = attack_info.get("damage", 0)
	if player.check_parry():
		player.show_parry_effect()
		boss.stun_for(1.0)
		print("Parry success: boss stunned for 1.0s")
		return
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
