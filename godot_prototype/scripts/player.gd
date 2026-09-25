extends CharacterBody2D

# Player controller for the 1v1 boss prototype
@export var max_hp: int = 90
@export var attack_damage: int = 20
@export var parry_window_ms: int = 100
@export var move_speed: float = 220.0
@export var dodge_cooldown: float = 0.5

var hp: int
var can_parry: bool = false
var parry_start_time_ms: int = 0
var dodge_timer: float = 0.0
var facing: Vector2 = Vector2.RIGHT

func _ready():
	hp = max_hp

func _physics_process(delta):
	if dodge_timer > 0:
		dodge_timer -= delta

	var direction := Vector2.ZERO
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	if direction.length() > 1.0:
		direction = direction.normalized()

	if direction != Vector2.ZERO:
		facing = direction.normalized()
		velocity = direction * move_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()

	if Input.is_action_just_pressed("ui_accept"):
		attack()
	if Input.is_action_just_pressed("ui_select"):
		start_parry()
	if Input.is_action_just_pressed("ui_cancel"):
		dodge()

func attack():
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
	return success

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
