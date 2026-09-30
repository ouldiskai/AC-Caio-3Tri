extends CharacterBody2D

const GRAVITY: float = 1200.0

# Boss controller for the 1v1 prototype
@export var max_hp: int = 220
@export var attack_damage: int = 15
@export var attack_interval: float = 2.0
@export var attack_sequence: Array[String] = ["club_slam", "dash", "fireball"]
@export var move_speed: float = 240.0
@export var melee_reach: float = 150.0
@export var dash_reach: float = 200.0
@export var fireball_reach: float = 360.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var hp: int
var attack_timer: float = 1.0
var pattern_index: int = 0
var attack_active: bool = false
var player: CharacterBody2D
var health_bar: ProgressBar
var stun_timer: float = 0.0

signal attack_started(attack_info)
signal attack_hit(attack_info)

func _ready():
	hp = max_hp
	attack_timer = 1.2
	_create_health_bar()
	_update_health_bar()
	if animated_sprite != null:
		animated_sprite.play("idle")

func _physics_process(delta):
	if stun_timer > 0.0:
		stun_timer -= delta
		velocity.x = move_toward(velocity.x, 0.0, move_speed * 2.0)
		move_and_slide()
		if animated_sprite != null:
			_play_animation("idle")
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0.0

	if player != null:
		var direction = player.global_position - global_position
		var distance = direction.length()
		if distance > 0.1:
			direction = direction.normalized()
			if not is_attack_pattern_active():
				var desired_distance := 170.0
				var steering := 0.0
				if distance > desired_distance + 30.0:
					steering = 1.0
				elif distance < desired_distance - 30.0:
					steering = -1.0
				else:
					steering = 0.0

				if player.is_rolling and distance < 90.0:
					steering = 0.0
					velocity.x = move_toward(velocity.x, 0.0, move_speed)
				else:
					velocity.x = direction.x * move_speed * steering
					if abs(velocity.x) > 0.1:
						_play_animation("walk")
						if animated_sprite != null:
							animated_sprite.flip_h = velocity.x < 0.0
					else:
						_play_animation("idle")
			else:
				velocity.x = move_toward(velocity.x, 0.0, move_speed)
		else:
			velocity.x = move_toward(velocity.x, 0.0, move_speed)

		if not attack_active:
			attack_timer -= delta
			if attack_timer <= 0:
				trigger_attack()

	move_and_slide()

func _create_health_bar() -> void:
	if health_bar != null:
		return
	health_bar = ProgressBar.new()
	health_bar.min_value = 0
	health_bar.max_value = max_hp
	health_bar.value = hp
	health_bar.show_percentage = true
	health_bar.custom_minimum_size = Vector2(110, 12)
	health_bar.position = Vector2(-55, -90)
	health_bar.modulate = Color(0.35, 0.8, 0.35, 1.0)
	health_bar.visible = false
	add_child(health_bar)

func _update_health_bar() -> void:
	if health_bar == null:
		return
	health_bar.max_value = max_hp
	health_bar.value = hp

func _resolve_attack_reach(attack_name: String) -> float:
	match attack_name:
		"club_slam":
			return melee_reach
		"dash":
			return dash_reach
		"fireball":
			return fireball_reach
		_:
			return melee_reach

func _play_animation(animation_name: String):
	if animated_sprite != null and animated_sprite.animation != animation_name:
		animated_sprite.play(animation_name)

func is_attack_pattern_active() -> bool:
	return attack_active

func trigger_attack():
	if attack_active:
		return
	var attack_name = attack_sequence[pattern_index % attack_sequence.size()]
	pattern_index += 1
	var attack_reach = _resolve_attack_reach(attack_name)
	var attack_info = {
		"type": attack_name,
		"damage": attack_damage,
		"is_last": true,
		"pattern_index": pattern_index,
		"range": attack_reach
	}
	attack_active = true
	match attack_name:
		"club_slam":
			_play_animation("attack1")
		"dash":
			_play_animation("walk")
		"fireball":
			_play_animation("fireball_preparation")
		_:
			_play_animation("attack1")
	_spawn_attack_hitbox(attack_info)
	emit_signal("attack_started", attack_info)
	await get_tree().create_timer(0.45).timeout
	emit_signal("attack_hit", attack_info)
	attack_active = false
	attack_timer = attack_interval
	_play_animation("idle")

func _spawn_attack_hitbox(attack_info: Dictionary) -> void:
	if player == null:
		return
	var hitbox = Area2D.new()
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	var attack_range = float(attack_info.get("range", melee_reach))
	rect.size = Vector2(min(attack_range, 160.0), 90)
	shape.shape = rect
	hitbox.position = Vector2(0, 0)
	hitbox.monitoring = true
	hitbox.monitorable = true
	hitbox.collision_layer = 0
	hitbox.collision_mask = 1
	hitbox.add_child(shape)
	var direction = 1 if player.global_position.x >= global_position.x else -1
	hitbox.position = Vector2(direction * (attack_range * 0.5), 0)
	hitbox.body_entered.connect(_on_attack_hitbox_body_entered.bind(attack_info))
	add_child(hitbox)
	await get_tree().create_timer(0.18).timeout
	if is_instance_valid(hitbox):
		hitbox.queue_free()

func _on_attack_hitbox_body_entered(body: Node2D, attack_info: Dictionary) -> void:
	if body != player:
		return
	var attack_range = float(attack_info.get("range", melee_reach))
	if player.global_position.distance_to(global_position) > attack_range:
		return
	if player.has_method("apply_damage"):
		player.apply_damage(int(attack_info.get("damage", 0)))
	print("Boss attack hit the player for %s" % attack_info.get("damage", 0))

func stun_for(seconds: float) -> void:
	stun_timer = max(stun_timer, seconds)
	velocity.x = 0.0
	attack_active = false
	attack_timer = max(attack_timer, 0.6)
	_play_animation("idle")

func apply_damage(dmg: int):
	hp -= dmg
	hp = max(hp, 0)
	_update_health_bar()
