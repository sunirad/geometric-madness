class_name SkillData
extends Resource

# ============================================================
# Данные одного скилла (Ресурс).
# ============================================================

@export var id: String = "basic_attack"
@export var display_name: String = "Basic Attack"
@export var icon: Texture2D
@export var description: String = "A basic sword strike."

# --- Характеристики ---
@export var damage: int = 0 # Урон скилла
@export var support_slots_count: int = 0 # Количество слотов под сапорт-скиллы
