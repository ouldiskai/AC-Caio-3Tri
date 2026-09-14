extends Node

# Orchestrates interactions between player and boss, parry logic and victory/defeat

@onready var player = $Arena/Player
@onready var boss = $Arena/Boss

signal combat_ended(result)

func _ready():
    boss.connect("attack_hit", Callable(self, "_on_boss_attack_hit"))
    boss.connect("attack_started", Callable(self, "_on_boss_attack_started"))

func _on_boss_attack_started(attack_info):
    # when boss starts an attack sequence, allow player to parry
    player.start_parry()

func _on_boss_attack_hit(attack_info):
    var is_last = attack_info.get("is_last", true)
    var dmg = attack_info.get("damage", 0)
    # check parry
    if player.check_parry():
        # if parry and last in sequence -> trigger counterattack
        if is_last:
            var atk = player.attack()
            boss.apply_damage(atk.damage)
    else:
        # player takes damage and punishment (brief control reduction simulated via HP loss)
        player.apply_damage(dmg)
    _check_end_conditions()

func _check_end_conditions():
    if boss.hp <= 0:
        emit_signal("combat_ended", "victory")
    elif player.hp <= 0:
        emit_signal("combat_ended", "defeat")
