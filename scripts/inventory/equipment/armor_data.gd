class_name ArmorData
extends EquipItemData

func _init() -> void:
	allowed_slots = [SlotType.Type.CHEST]
	grid_size = Vector2i(2, 3)
