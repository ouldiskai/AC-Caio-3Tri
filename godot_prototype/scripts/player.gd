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

var hp: int
var can_parry: bool = false
var parry_start_time_ms: int = 0
var dodge_timer: float = 0.0
var facing: Vector2 = Vector2.RIGHT
var is_rolling: bool = false
var roll_timer: float = 0.0
var roll_cooldown_timer: float = 0.0
var health_bar: ProgressBar
var parry_effect: ColorRect

func _ready():
	hp = max_hp
	_create_health_bar()
	_create_parry_effect()
	_update_health_bar()
	if animated_sprite != null:
		animated_sprite.play("idle")

func _physics_process(delta):
	if dodge_timer > 0:
		dodge_timer -= delta

	if roll_cooldown_timer > 0.0:
		roll_cooldown_timer -= delta
	if is_rolling:
		roll_timer -= delta
		if roll_timer <= 0.0:
			is_rolling = false
			roll_timer = 0.0

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0.0

	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_rolling:
		velocity.y = jump_force

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
		if not is_rolling:
			velocity.x = direction.x * move_speed
			if animated_sprite != null:
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
		if animated_sprite != null and not is_rolling:
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
		animated_sprite.play("idle")
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
		show_parry_effect()
	return success

func show_parry_effect() -> void:
	if parry_effect == null:
		_create_parry_effect()
	parry_effect.visible = true
	parry_effect.modulate = Color(1.0, 1.0, 0.4, 1.0)
	var tween = get_tree().create_tween()
	tween.tween_property(parry_effect, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func():
		parry_effect.visible = false
	)

func _create_parry_effect() -> void:
	if parry_effect != null:
		return
	parry_effect = ColorRect.new()
	parry_effect.size = Vector2(120, 120)
	parry_effect.position = Vector2(-60, -60)
	parry_effect.color = Color(1.0, 0.9, 0.4, 1.0)
	parry_effect.modulate = Color(1.0, 1.0, 0.4, 0.0)
	parry_effect.visible = false
	add_child(parry_effect)

func apply_damage(dmg: int):
	hp -= dmg
	hp = max(hp, 0)
	_update_health_bar()

func can_dodge():
	return dodge_timer <= 0 and roll_cooldown_timer <= 0.0

func dodge():
	if can_dodge():
		dodge_timer = dodge_cooldown
		roll_cooldown_timer = dodge_cooldown
		is_rolling = true
		roll_timer = roll_duration
		if facing.x == 0.0:
			facing.x = 1.0 if animated_sprite != null and not animated_sprite.flip_h else -1.0
		velocity.x = facing.x * roll_speed
		collision_mask = 0
		var _ignore = get_tree().create_tween()
		_ignore.tween_interval(roll_duration)
		_ignore.tween_callback(func():
			collision_mask = 1
			is_rolling = false
		)
		return true
	return false
