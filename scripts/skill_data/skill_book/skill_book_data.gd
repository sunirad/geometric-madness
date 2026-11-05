class_name SkillBookData
extends Resource

# ============================================================
# Данные книги скиллов (Ресурс).
# Хранит список всех скиллов, доступных игроку.
# ============================================================

@export var skills: Array[SkillData] = []

# Проверяет, есть ли скилл в книге (по id)
func has_skill(skill_id: String) -> bool:
	for skill in skills:
		if skill.id == skill_id:
			return true
	return false

# Возвращает скилл по id (или null)
func get_skill_by_id(skill_id: String) -> SkillData:
	for skill in skills:
		if skill.id == skill_id:
			return skill
	return null
