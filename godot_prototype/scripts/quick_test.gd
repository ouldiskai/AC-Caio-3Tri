# Simple automated smoke test for controllers (non-visual)
func run_test():
	var p = preload("res://godot_prototype/scripts/player.gd").new()
	var b = preload("res://godot_prototype/scripts/boss.gd").new()
	p._ready()
	b._ready()

	# Parry should not cause damage to the boss.
	var boss_hp_before_parry = b.hp
	p.start_parry()
	var parried = p.check_parry()
	var parry_keeps_boss_hp = not parried or b.hp == boss_hp_before_parry

	# Player should keep ground collisions active while rolling.
	p.dodge()
	var roll_keeps_ground_collision = p.collision_mask == 1 or (p.collision_mask & 1) != 0
	if !roll_keeps_ground_collision:
		push_error("Roll should not disable world collisions.")

	# Player death should be terminal so the controller can return to the menu.
	p.apply_damage(999)
	var death_is_terminal = p.is_dead and p.hp == 0
	if !parry_keeps_boss_hp:
		push_error("Parry should not damage the boss.")
	if !death_is_terminal:
		push_error("Player death should remain terminal until the scene changes.")

	return {
		"parried": parried,
		"player_hp": p.hp,
		"boss_hp": b.hp,
		"parry_keeps_boss_hp": parry_keeps_boss_hp,
		"roll_keeps_ground_collision": roll_keeps_ground_collision,
		"death_is_terminal": death_is_terminal,
	}

func _ready():
	if Engine.is_editor_hint():
		print(run_test())
