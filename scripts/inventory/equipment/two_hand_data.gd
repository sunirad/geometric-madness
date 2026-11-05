class_name TwoHandData
extends EquipItemData

func _init() -> void:
	allowed_slots = [SlotType.Type.WEAPON_1, SlotType.Type.WEAPON_2]
	grid_size = Vector2i(2, 4)
	two_handed = true
