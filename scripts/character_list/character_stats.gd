class_name CharacterStats
extends Resource

# ============================================================
# ДАННЫЕ ПЕРСОНАЖА (источник правды)
# Все числовые значения хранятся здесь. UI только читает их
# и подписывается на сигналы. Бонусы от экипировки складываются
# с базовыми значениями через методы get_total_*().
# ============================================================

# --- Идентификация ---
@export var character_name: String = "Hero"
@export var character_portrait: Texture2D

# --- Уровень ---
@export var level: int = 1

# --- Здоровье ---
@export var max_health: int = 100:
	set(value):
		max_health = max(value, 0)
		current_health = clampi(current_health, 0, max_health)
		health_changed.emit(current_health, max_health)

@export var current_health: int = 100:
	set(value):
		current_health = clampi(value, 0, max_health)
		health_changed.emit(current_health, max_health)

# --- Мана ---
@export var max_mana: int = 50:
	set(value):
		max_mana = max(value, 0)
		current_mana = clampi(current_mana, 0, max_mana)
		mana_changed.emit(current_mana, max_mana)

@export var current_mana: int = 50:
	set(value):
		current_mana = clampi(value, 0, max_mana)
		mana_changed.emit(current_mana, max_mana)

# --- Базовые характеристики ---
@export var base_strength: int = 10:
	set(value):
		base_strength = value
		stats_changed.emit()

@export var base_agility: int = 10:
	set(value):
		base_agility = value
		stats_changed.emit()

@export var base_intelligence: int = 10:
	set(value):
		base_intelligence = value
		max_mana = get_total_max_mana()
		stats_changed.emit()

# --- Бонусы от экипировки (заполняются извне, пока 0) ---
@export var equip_strength_bonus: int = 0:
	set(value):
		equip_strength_bonus = value
		stats_changed.emit()

@export var equip_agility_bonus: int = 0:
	set(value):
		equip_agility_bonus = value
		stats_changed.emit()

@export var equip_intelligence_bonus: int = 0:
	set(value):
		equip_intelligence_bonus = value
		max_mana = get_total_max_mana()
		stats_changed.emit()

# --- Сигналы ---
signal health_changed(current: int, maximum: int)
signal mana_changed(current: int, maximum: int)
signal stats_changed()

# --- Итоговые значения (база + экипировка) ---
func get_total_strength() -> int:
	return base_strength + equip_strength_bonus

func get_total_agility() -> int:
	return base_agility + equip_agility_bonus

func get_total_intelligence() -> int:
	return base_intelligence + equip_intelligence_bonus

func get_bonus_max_mana() -> int:
	return max(0, get_total_intelligence() - 10) * 5

func get_total_max_mana() -> int:
	return 50 + get_bonus_max_mana()
