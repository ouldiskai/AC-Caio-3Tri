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

	return {
		"parried": parried,
		"player_hp": p.hp,
		"boss_hp": b.hp,
	}

func _ready():
	if Engine.is_editor_hint():
		print(run_test())
