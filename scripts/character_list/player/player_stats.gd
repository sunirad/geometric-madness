class_name PlayerStats
extends Node

# ============================================================
# Узел-держатель CharacterStats.
# Проксирует сигналы ресурса наружу и даёт UI удобный доступ
# к данным. Никаких хардкод-путей: ресурс назначается в инспекторе.
# ============================================================

@export var stats: CharacterStats

# Прокси-сигналы (повторяют сигналы CharacterStats)
signal health_changed(current: int, maximum: int)
signal mana_changed(current: int, maximum: int)
signal stats_changed()

func _ready() -> void:
	if stats == null:
		push_warning("PlayerStats: поле 'stats' не назначено в инспекторе.")
		return
	# Подписываемся на сигналы ресурса и пробрасываем наружу
	stats.health_changed.connect(_on_health_changed)
	stats.mana_changed.connect(_on_mana_changed)
	stats.stats_changed.connect(_on_stats_changed)

# --- Проксирование сигналов ---
func _on_health_changed(current: int, maximum: int) -> void:
	health_changed.emit(current, maximum)

func _on_mana_changed(current: int, maximum: int) -> void:
	mana_changed.emit(current, maximum)

func _on_stats_changed() -> void:
	stats_changed.emit()

# --- Удобные методы-обёртки для UI ---
# Возвращают null/значения по умолчанию, если ресурс не назначен,
# чтобы UI не падал при некорректной настройке сцены.

func get_character_name() -> String:
	return stats.character_name if stats else ""

func get_character_portrait() -> Texture2D:
	return stats.character_portrait if stats else null

func get_level() -> int:
	return stats.level if stats else 0

func get_health() -> Vector2i:
	if stats:
		return Vector2i(stats.current_health, stats.max_health)
	return Vector2i.ZERO

func get_mana() -> Vector2i:
	if stats:
		return Vector2i(stats.current_mana, stats.max_mana)
	return Vector2i.ZERO

func get_strength() -> Vector2i:
	# x = итоговое, y = бонус (для отображения "(+N)")
	if stats:
		return Vector2i(stats.get_total_strength(), stats.equip_strength_bonus)
	return Vector2i.ZERO

func get_agility() -> Vector2i:
	if stats:
		return Vector2i(stats.get_total_agility(), stats.equip_agility_bonus)
	return Vector2i.ZERO

func get_intelligence() -> Vector2i:
	if stats:
		return Vector2i(stats.get_total_intelligence(), stats.equip_intelligence_bonus)
	return Vector2i.ZERO
