extends CanvasLayer

# ============================================================
# HUD (Heads-Up Display).
# Следит за PlayerStats и обновляет шары HP и MP, а также текст.
# ============================================================

@export var player_stats: PlayerStats
@export var hp_orb: Control
@export var mp_orb: Control
@export var hp_text_label: Label   # <-- Новое поле
@export var mp_text_label: Label   # <-- Новое поле

func _ready() -> void:
	await get_tree().process_frame
	
	if player_stats:
		player_stats.health_changed.connect(_on_health_changed)
		player_stats.mana_changed.connect(_on_mana_changed)
		
		var hp = player_stats.get_health()
		var mp = player_stats.get_mana()
		_on_health_changed(hp.x, hp.y)
		_on_mana_changed(mp.x, mp.y)
	else:
		push_warning("HUD: player_stats не назначен!")

func _on_health_changed(current: int, maximum: int) -> void:
	if hp_orb:
		hp_orb.update_value(current, maximum)
	if hp_text_label:
		hp_text_label.text = "%d / %d" % [current, maximum]

func _on_mana_changed(current: int, maximum: int) -> void:
	if mp_orb:
		mp_orb.update_value(current, maximum)
	if mp_text_label:
		mp_text_label.text = "%d / %d" % [current, maximum]
