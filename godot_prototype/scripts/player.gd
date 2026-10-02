extends CharacterBody2D

const GRAVITY: float = 1200.0

# Player controller for the 1v1 boss prototype
@export var max_hp: int = 90
@export var attack_damage: int = 20
@export var parry_window_ms: int = 100
@export var move_speed: float = 220.0
@export var dodge_cooldown: float = 0.5
@export var jump_force: float = -420.0
@export var roll_speed: float = 420.0
@export var roll_duration: float = 0.35

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapon_sprite: Sprite2D = $Sprite2D
@onready var weapon_slash: AnimatedSprite2D = $Sprite2D/AnimatedSprite2D
@onready var weapon_parry: AnimatedSprite2D = $AnimatedSprite2D2

var hp: int
var can_parry: bool = false
var parry_start_time_ms: int = 0
var dodge_timer: float = 0.0
var facing: Vector2 = Vector2.RIGHT
var is_rolling: bool = false
var roll_timer: float = 0.0
var roll_cooldown_timer: float = 0.0
var spawn_position: Vector2 = Vector2.ZERO
var invulnerability_timer: float = 0.0
var health_bar: ProgressBar

func _ready():
	spawn_position = global_position
	collision_layer = 4
	collision_mask = 1
	hp = max_hp
	_reset_weapon_effects()
	_update_weapon_orientation()
	_create_health_bar()
	_update_health_bar()
	if animated_sprite != null:
		animated_sprite.play("idle")

func _reset_weapon_effects() -> void:
	if weapon_slash != null:
		weapon_slash.visible = false
		weapon_slash.stop()
	if weapon_parry != null:
		weapon_parry.visible = false
		weapon_parry.stop()

func _update_weapon_orientation() -> void:
	if weapon_sprite == null:
		return
	var facing_right := facing.x >= 0.0
	weapon_sprite.visible = not is_rolling
	weapon_sprite.position = Vector2(17.0 if facing_right else -17.0, 16.0)
	weapon_sprite.rotation = 0.76096356 if facing_right else -0.76096356
	weapon_sprite.flip_h = not facing_right
	if weapon_slash != null:
		weapon_slash.position = Vector2(3.57 if facing_right else -3.57, -7.27)
		weapon_slash.rotation = -0.5235988 if facing_right else 0.5235988
		weapon_slash.flip_h = not facing_right
		weapon_slash.visible = weapon_slash.visible and not is_rolling
	if weapon_parry != null:
		weapon_parry.position = Vector2(34.0 if facing_right else -34.0, -2.0)
		weapon_parry.scale = Vector2(3.0, 3.0)
		weapon_parry.flip_h = not facing_right
		weapon_parry.visible = weapon_parry.visible and not is_rolling

func _play_weapon_slash() -> void:
	if weapon_slash == null or is_rolling:
		return
	weapon_slash.visible = true
	weapon_slash.flip_h = facing.x < 0.0
	weapon_slash.play("slash")
	var tween = get_tree().create_tween()
	tween.tween_interval(0.18)
	tween.tween_callback(func():
		if weapon_slash != null:
			weapon_slash.visible = false
			weapon_slash.stop()
	)

func _play_weapon_parry() -> void:
	if weapon_parry == null or is_rolling:
		return
	weapon_parry.visible = true
	weapon_parry.flip_h = facing.x < 0.0
	weapon_parry.play("parry")
	var tween = get_tree().create_tween()
	tween.tween_interval(0.18)
	tween.tween_callback(func():
		if weapon_parry != null:
			weapon_parry.visible = false
			weapon_parry.stop()
	)

func _physics_process(delta):
	if invulnerability_timer > 0.0:
		invulnerability_timer -= delta

	if dodge_timer > 0:
		dodge_timer -= delta

	if roll_cooldown_timer > 0.0:
		roll_cooldown_timer -= delta
	if is_rolling:
		roll_timer -= delta
		if roll_timer <= 0.0:
			is_rolling = false
			roll_timer = 0.0
			collision_mask = 1

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0.0

	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_rolling:
		velocity.y = jump_force
		if animated_sprite != null:
			animated_sprite.play("jump")

	if Input.is_action_just_pressed("roll"):
		dodge()

	if Input.is_action_just_pressed("parry"):
		start_parry()

	var direction := Vector2.ZERO
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	if direction.length() > 1.0:
		direction = direction.normalized()

	if direction != Vector2.ZERO:
		facing = direction.normalized()
		facing.x = clampf(facing.x, -1.0, 1.0)
		_update_weapon_orientation()
		if not is_rolling:
			velocity.x = direction.x * move_speed
			if animated_sprite != null and animated_sprite.animation not in ["attack", "parry", "dash"]:
				if direction.x < 0:
					animated_sprite.flip_h = true
					animated_sprite.play("ui_left")
				elif direction.x > 0:
					animated_sprite.flip_h = false
					animated_sprite.play("ui_right")
		else:
			velocity.x = facing.x * roll_speed
	else:
		if not is_rolling:
			velocity.x = move_toward(velocity.x, 0.0, move_speed)
		if animated_sprite != null and not is_rolling and animated_sprite.animation not in ["attack", "parry", "dash"]:
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")
	move_and_slide()

	if Input.is_action_just_pressed("ui_accept"):
		attack()

func _create_health_bar() -> void:
	if health_bar != null:
		return
	health_bar = ProgressBar.new()
	health_bar.min_value = 0
	health_bar.max_value = max_hp
	health_bar.value = hp
	health_bar.show_percentage = true
	health_bar.custom_minimum_size = Vector2(100, 12)
	health_bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	health_bar.position = Vector2(-50, -80)
	health_bar.modulate = Color(0.8, 0.3, 0.3, 1.0)
	health_bar.visible = false
	add_child(health_bar)

func _update_health_bar() -> void:
	if health_bar == null:
		return
	health_bar.max_value = max_hp
	health_bar.value = hp
	if hp <= 0:
		health_bar.modulate = Color(0.2, 0.2, 0.2, 1.0)

func attack():
	if animated_sprite != null:
		animated_sprite.play("attack")
		_play_weapon_slash()
		var tween = get_tree().create_tween()
		tween.tween_interval(0.18)
		tween.tween_callback(func():
			if animated_sprite != null and animated_sprite.animation == "attack":
				if is_rolling:
					animated_sprite.play("dash")
				else:
					animated_sprite.play("idle")
		)
	return {"damage": attack_damage, "type": "attack"}

func start_parry():
	can_parry = true
	parry_start_time_ms = Time.get_ticks_msec()

func check_parry():
	if not can_parry:
		return false
	var elapsed = Time.get_ticks_msec() - parry_start_time_ms
	var success = elapsed <= parry_window_ms
	can_parry = false
	if success:
		if animated_sprite != null:
			animated_sprite.play("parry")
			_play_weapon_parry()
			var tween = get_tree().create_tween()
			tween.tween_interval(0.15)
			tween.tween_callback(func():
				if animated_sprite != null and animated_sprite.animation == "parry":
					if is_rolling:
						animated_sprite.play("dash")
					else:
						animated_sprite.play("idle")
			)
	return success

func apply_damage(dmg: int):
	if invulnerability_timer > 0.0:
		return
	hp -= dmg
	hp = max(hp, 0)
	_update_health_bar()
	if hp <= 0:
		respawn()

func take_hit_from(source_position: Vector2, dmg: int, knockback_scale: float = 1.0):
	if invulnerability_timer > 0.0:
		return
	apply_damage(dmg)
	var push_direction: float = 1.0
	if source_position != Vector2.ZERO:
		push_direction = -1.0 if global_position.x <= source_position.x else 1.0
	velocity.x = push_direction * 180.0 * knockback_scale
	if animated_sprite != null:
		animated_sprite.play("jump")

func respawn() -> void:
	hp = max_hp
	velocity = Vector2.ZERO
	global_position = spawn_position
	invulnerability_timer = 1.0
	collision_mask = 1
	is_rolling = false
	roll_timer = 0.0
	roll_cooldown_timer = 0.0
	_update_health_bar()
	if animated_sprite != null:
		animated_sprite.play("idle")

func can_dodge():
	return dodge_timer <= 0 and roll_cooldown_timer <= 0.0

func dodge():
	if can_dodge():
		dodge_timer = dodge_cooldown
		roll_cooldown_timer = dodge_cooldown
		is_rolling = true
		roll_timer = roll_duration
		invulnerability_timer = max(invulnerability_timer, roll_duration + 0.1)
		if animated_sprite != null:
			animated_sprite.play("dash")
		if facing.x == 0.0:
			facing.x = 1.0 if animated_sprite != null and not animated_sprite.flip_h else -1.0
		velocity.x = facing.x * roll_speed
		collision_mask = 1
		var _ignore = get_tree().create_tween()
		_ignore.tween_interval(roll_duration)
		_ignore.tween_callback(func():
			collision_mask = 1
			is_rolling = false
			if animated_sprite != null and animated_sprite.animation == "dash":
				animated_sprite.play("idle")
		)
		return true
	return false
