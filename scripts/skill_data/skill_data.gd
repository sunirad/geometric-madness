class_name SkillData
extends Resource

enum DamageType {
	PHYSICAL,
	MAGICAL
}

@export var id: String = "basic_attack"
@export var display_name: String = "Basic Attack"
@export var icon: Texture2D
@export_multiline var description: String = "A basic sword strike."
@export var skill_scene: PackedScene
@export_group("Combat")
@export var damage: int = 0
@export var damage_type: DamageType = DamageType.PHYSICAL
@export var mana_cost: int = 0
@export var can_crit: bool = true

@export_group("Support")
@export var support_slots_count: int = 0
