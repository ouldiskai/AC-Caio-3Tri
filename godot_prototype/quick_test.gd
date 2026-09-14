# Simple automated smoke test for controllers (non-visual)
func run_test():
	var p = preload("res://player.gd").new()
	var b = preload("res://boss.gd").new()
	p._ready()
	b._ready()
	# simulate boss starting sequence of 1 hit
	b.sequence_length = 1
	b.start_attack()
	# player starts parry and immediately succeeds
	p.start_parry()
	var parried = p.check_parry()
	return {"parried": parried, "player_hp": p.hp, "boss_hp": b.hp}

if Engine.is_editor_hint():
	print(run_test())
