extends Node2D

# Simple boss controller: attacks periodically, supports sequences
@export var max_hp: int = 250
@export var attack_damage: int = 15
@export var attack_interval: float = 1.2
@export var sequence_length: int = 1 # number of hits in current sequence

var hp: int
var attack_timer: float = 0.0
var current_sequence_count: int = 0

signal attack_started(attack_info)
signal attack_hit(attack_info)

func _ready():
	hp = max_hp
	attack_timer = attack_interval

func _process(delta):
	attack_timer -= delta
	if attack_timer <= 0:
		start_attack()
		attack_timer = attack_interval

func start_attack():
	current_sequence_count = sequence_length
	emit_signal("attack_started", {"damage": attack_damage, "sequence": sequence_length})
	# simulate hitting after short delay per hit
	call_deferred("_do_attack")

func _do_attack():
	for i in range(sequence_length):
		# emit hit signal for each sub-hit
		emit_signal("attack_hit", {"damage": attack_damage, "index": i, "is_last": i == sequence_length - 1})

func apply_damage(dmg: int):
	hp -= dmg
	hp = max(hp, 0)
