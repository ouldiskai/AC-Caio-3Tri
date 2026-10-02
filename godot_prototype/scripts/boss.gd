extends CharacterBody2D

const GRAVITY: float = 1200.0

# Boss controller for the 1v1 prototype
@export var max_hp: int = 220
@export var attack_damage: int = 15
@export var attack_interval: float = 2.4
@export var attack_sequence: Array[String] = ["attack1", "attack2", "fireball"]
@export var move_speed: float = 110.0
@export var dash_speed: float = 260.0
@export var melee_reach: float = 120.0
@export var dash_reach: float = 240.0
@export var fireball_reach: float = 420.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var hp: int
var attack_timer: float = 1.0
var pattern_index: int = 0
var attack_active: bool = false
var player: CharacterBody2D
var health_bar: ProgressBar
var stun_timer: float = 0.0
var is_dashing: bool = false
var dash_direction: float = 1.0
var dash_timer: float = 0.0
var weapon_sprite: Sprite2D

signal attack_started(attack_info)
signal attack_hit(attack_info)

func _ready():
	collision_layer = 8
	collision_mask = 1
	hp = max_hp
	attack_timer = 1.2
	_create_weapon_sprite()
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

	if is_dashing:
		dash_timer -= delta
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		else:
			velocity.y = 0.0
		velocity.x = dash_direction * dash_speed
		_update_boss_facing()
		move_and_slide()
		if dash_timer <= 0.0:
			is_dashing = false
			velocity.x = move_toward(velocity.x, 0.0, dash_speed)
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0.0

	if player != null:
		var direction = player.global_position - global_position
		var distance = direction.length()
		_update_boss_facing()
		if distance > 0.1:
			direction = direction.normalized()
			if not is_attack_pattern_active():
				var desired_distance := 210.0
				var steering := 0.0
				if distance > desired_distance + 45.0:
					steering = 1.0
				elif distance < desired_distance - 45.0:
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

func _create_weapon_sprite() -> void:
	if weapon_sprite != null:
		return
	var texture = load("res://godot_prototype/sprites/armas/devilsclub.png")
	if texture == null:
		return
	weapon_sprite = Sprite2D.new()
	weapon_sprite.name = "DevilsClub"
	weapon_sprite.texture = texture
	weapon_sprite.visible = false
	weapon_sprite.scale = Vector2(2.2, 2.2)
	weapon_sprite.modulate = Color(1, 1, 1, 0.0)
	weapon_sprite.position = Vector2(100.0, 12.0)
	add_child(weapon_sprite)

func _update_boss_facing() -> void:
	if animated_sprite == null or player == null:
		return
	var facing_direction = player.global_position.x - global_position.x
	var should_face_right = facing_direction >= 0.0
	var base_scale_x = abs(animated_sprite.scale.x)
	animated_sprite.scale.x = base_scale_x if should_face_right else -base_scale_x
	if weapon_sprite != null:
		weapon_sprite.scale = Vector2(2.2, 2.2)
		weapon_sprite.position = Vector2(100.0 if should_face_right else -100.0, 12.0)
		weapon_sprite.visible = false
		weapon_sprite.modulate = Color(1, 1, 1, 0.0)
		weapon_sprite.scale.x = abs(weapon_sprite.scale.x) if should_face_right else -abs(weapon_sprite.scale.x)

func _resolve_attack_reach(attack_name: String) -> float:
	match attack_name:
		"attack1":
			return melee_reach
		"attack2":
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

func _decide_attack_name(distance_to_player: float) -> String:
	if distance_to_player <= melee_reach + 35.0:
		return "attack1"
	if distance_to_player <= dash_reach + 80.0:
		return "attack2"
	return "fireball"

func _resolve_attack_hit_delay(attack_name: String) -> float:
	match attack_name:
		"attack1":
			return 0.18
		"attack2":
			return 0.22
		"fireball":
			return 0.40
		_:
			return 0.18

func trigger_attack():
	if attack_active or player == null:
		return
	var distance_to_player = global_position.distance_to(player.global_position)
	var attack_name = _decide_attack_name(distance_to_player)
	var attack_reach = _resolve_attack_reach(attack_name)
	var hit_delay = _resolve_attack_hit_delay(attack_name)
	var attack_info = {
		"type": attack_name,
		"damage": attack_damage,
		"is_last": true,
		"pattern_index": pattern_index,
		"range": attack_reach,
		"knockback": 1.0,
		"hit_delay": hit_delay
	}
	pattern_index += 1
	attack_active = true
	match attack_name:
		"attack1":
			_play_animation("attack1")
		"attack2":
			_play_animation("attack2")
			is_dashing = true
			dash_direction = 1.0 if player.global_position.x >= global_position.x else -1.0
			dash_timer = 0.45
		"fireball":
			_play_animation("attack2")
		_:
			_play_animation("attack1")
	_spawn_attack_hitbox(attack_info)
	emit_signal("attack_started", attack_info)
	await get_tree().create_timer(hit_delay).timeout
	emit_signal("attack_hit", attack_info)
	attack_active = false
	attack_timer = attack_interval
	_play_animation("idle")

func _spawn_attack_hitbox(attack_info: Dictionary) -> void:
	if player == null:
		return
	if attack_info.get("type") == "fireball":
		_spawn_fireball_projectile(attack_info)
		return
	var hitbox = Area2D.new()
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	var attack_range = float(attack_info.get("range", melee_reach))
	rect.size = Vector2(min(attack_range, 220.0), 120)
	shape.shape = rect
	hitbox.position = Vector2(0, 0)
	hitbox.monitoring = true
	hitbox.monitorable = true
	hitbox.collision_layer = 0
	hitbox.collision_mask = 1 | 4
	hitbox.add_child(shape)
	var direction = 1 if player.global_position.x >= global_position.x else -1
	if weapon_sprite != null:
		weapon_sprite.visible = true
		weapon_sprite.position = Vector2(direction * 85.0, 10.0)
		weapon_sprite.flip_h = direction < 0.0
	hitbox.position = Vector2(direction * (attack_range * 0.5), 0)
	hitbox.body_entered.connect(_on_attack_hitbox_body_entered.bind(attack_info))
	add_child(hitbox)
	await get_tree().create_timer(max(0.12, float(attack_info.get("hit_delay", 0.18)))).timeout
	if is_instance_valid(hitbox):
		hitbox.queue_free()
	if weapon_sprite != null:
		weapon_sprite.visible = false

func _spawn_fireball_projectile(attack_info: Dictionary) -> void:
	if player == null:
		return
	var projectile = Area2D.new()
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	var fireball_sprite = Sprite2D.new()
	var fireball_texture = load("res://godot_prototype/sprites/animacoesboss1/FireBallProjectil.png")
	circle.radius = 24.0
	shape.shape = circle
	projectile.add_child(shape)
	projectile.monitoring = true
	projectile.monitorable = true
	projectile.collision_layer = 0
	projectile.collision_mask = 1 | 4
	if fireball_texture != null:
		fireball_sprite.texture = fireball_texture
		fireball_sprite.scale = Vector2(1.5, 1.5)
		projectile.add_child(fireball_sprite)
	else:
		fireball_sprite.modulate = Color(1.0, 0.5, 0.1, 1.0)
		fireball_sprite.scale = Vector2(1.0, 1.0)
		projectile.add_child(fireball_sprite)
	var direction = Vector2.RIGHT if player.global_position.x >= global_position.x else Vector2.LEFT
	projectile.global_position = global_position + Vector2(direction.x * 70.0, -12.0)
	projectile.body_entered.connect(_on_attack_hitbox_body_entered.bind(attack_info))
	add_child(projectile)
	var travel = float(attack_info.get("range", fireball_reach))
	var tween = get_tree().create_tween()
	tween.tween_property(projectile, "global_position", projectile.global_position + direction * travel, 1.1)
	tween.tween_callback(func():
		if is_instance_valid(projectile):
			if player != null and projectile.global_position.distance_to(player.global_position) <= 40.0:
				if player.has_method("take_hit_from"):
					player.take_hit_from(global_position, int(attack_info.get("damage", 0)), float(attack_info.get("knockback", 1.0)))
				elif player.has_method("apply_damage"):
					player.apply_damage(int(attack_info.get("damage", 0)))
			projectile.queue_free()
	)

func _on_attack_hitbox_body_entered(body: Node2D, attack_info: Dictionary) -> void:
	if body != player:
		return
	var attack_range = float(attack_info.get("range", melee_reach))
	var hit_position = global_position if attack_info.get("type") == "fireball" else global_position
	if player.global_position.distance_to(hit_position) > attack_range and attack_info.get("type") != "fireball":
		return
	if player.has_method("take_hit_from"):
		player.take_hit_from(hit_position, int(attack_info.get("damage", 0)), float(attack_info.get("knockback", 1.0)))
	else:
		if player.has_method("apply_damage"):
			player.apply_damage(int(attack_info.get("damage", 0)))
	if is_instance_valid(body):
		body.set_meta("last_hit_by_fireball", true)
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
