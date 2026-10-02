extends Control

@onready var play_button: Button = $Panel/VBoxContainer/PlayButton
@onready var upgrades_button: Button = $Panel/VBoxContainer/UpgradesButton
@onready var settings_button: Button = $Panel/VBoxContainer/SettingsButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	upgrades_button.pressed.connect(_on_upgrades_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://arena.tscn")

func _on_upgrades_pressed() -> void:
	print("Tela de Upgrades em desenvolvimento.")

func _on_settings_pressed() -> void:
	print("Tela de Configurações em desenvolvimento.")

func _on_quit_pressed() -> void:
	get_tree().quit()
