class_name SkillBarConfig
extends Resource

@export var slots: Dictionary = {}

func get_skill(action_name: String) -> SkillData:
	if slots.has(action_name):
		return slots[action_name]
	return null

func set_skill(action_name: String, skill: SkillData) -> void:
	if skill == null:
		slots.erase(action_name)
	else:
		slots[action_name] = skill

func clear_skill(action_name: String) -> void:
	slots.erase(action_name)
