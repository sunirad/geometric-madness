class_name RingData
extends EquipItemData

func _init() -> void:
	allowed_slots = [SlotType.Type.RING_1, SlotType.Type.RING_2]
	grid_size = Vector2i(1, 1)
