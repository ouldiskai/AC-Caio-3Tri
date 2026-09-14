extends CharacterBody2D

# Simple player controller: attack, parry, dodge, HP
@export var max_hp: int = 100
@export var attack_damage: int = 20
@export var parry_window_ms: int = 120
@export var dodge_cooldown: float = 0.5

var hp: int
var can_parry: bool = false
var last_attack_time_ms: int = 0
var dodge_timer: float = 0.0

func _ready():
	hp = max_hp

func _process(delta):
	if dodge_timer > 0:
		dodge_timer -= delta

func attack():
	# return damage value and tag as normal attack
	return {"damage": attack_damage, "type": "attack"}

func start_parry():
	can_parry = true
	last_attack_time_ms = OS.get_unix_time_msec()

func check_parry():
	if not can_parry:
		return false
	var elapsed = OS.get_unix_time_msec() - last_attack_time_ms
	if elapsed <= parry_window_ms:
		can_parry = false
		return true
	can_parry = false
	return false

func apply_damage(dmg: int):
	hp -= dmg
	hp = max(hp, 0)

func can_dodge():
	return dodge_timer <= 0

func dodge():
	if can_dodge():
		dodge_timer = dodge_cooldown
		return true
	return false
