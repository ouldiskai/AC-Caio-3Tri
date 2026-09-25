extends CharacterBody2D

# Boss controller for the 1v1 prototype
@export var max_hp: int = 220
@export var attack_damage: int = 15
@export var attack_interval: float = 2.0
@export var attack_sequence: Array[String] = ["club_slam", "dash", "fireball"]
@export var move_speed: float = 240.0

var hp: int
var attack_timer: float = 1.0
var pattern_index: int = 0
var attack_active: bool = false
var player: CharacterBody2D

signal attack_started(attack_info)
signal attack_hit(attack_info)

func _ready():
	hp = max_hp
	attack_timer = 1.2

func _physics_process(delta):
	if not attack_active and player != null:
		var direction = player.global_position - global_position
		if direction.length() > 0.1:
			direction = direction.normalized()
			if not is_attack_pattern_active():
				global_position += direction * 15.0 * delta
		attack_timer -= delta
		if attack_timer <= 0:
			trigger_attack()

func is_attack_pattern_active() -> bool:
	return attack_active

func trigger_attack():
	if attack_active:
		return
	var attack_name = attack_sequence[pattern_index % attack_sequence.size()]
	pattern_index += 1
	var attack_info = {
		"type": attack_name,
		"damage": attack_damage,
		"is_last": true,
		"pattern_index": pattern_index
	}
	attack_active = true
	emit_signal("attack_started", attack_info)
	await get_tree().create_timer(0.45).timeout
	emit_signal("attack_hit", attack_info)
	attack_active = false
	attack_timer = attack_interval

func apply_damage(dmg: int):
	hp -= dmg
	hp = max(hp, 0)
