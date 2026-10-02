# Simple automated smoke test for controllers (non-visual)
func run_test():
	var p = preload("res://godot_prototype/scripts/player.gd").new()
	var b = preload("res://godot_prototype/scripts/boss.gd").new()
	p._ready()
	b._ready()

	# Simulates a successful parry and immediate counter-attack.
	p.start_parry()
	var parried = p.check_parry()
	if parried:
		var counter = p.attack()
		b.apply_damage(counter.get("damage", 0))

	# Player should keep ground collisions active while rolling.
	p.dodge()
	var roll_keeps_ground_collision = p.collision_mask == 1 or (p.collision_mask & 1) != 0
	if !roll_keeps_ground_collision:
		push_error("Roll should not disable world collisions.")

	# Player should respawn after dying.
	p.apply_damage(999)
	var respawned = p.hp == p.max_hp and p.global_position == p.spawn_position
	if !respawned:
		push_error("Player did not respawn after death.")

	return {
		"parried": parried,
		"player_hp": p.hp,
		"boss_hp": b.hp,
		"roll_keeps_ground_collision": roll_keeps_ground_collision,
		"respawned": respawned,
	}

func _ready():
	if Engine.is_editor_hint():
		print(run_test())
