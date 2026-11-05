class_name OneHandData
extends EquipItemData

enum Size {
	NARROW_WIDE,  # 2x3
	LONG_THIN,    # 1x4
}

@export var size_variant: Size = Size.NARROW_WIDE:
	set(value):
		size_variant = value
		grid_size = Vector2i(2, 3) if value == Size.NARROW_WIDE else Vector2i(1, 4)

func _init() -> void:
	allowed_slots = [SlotType.Type.WEAPON_1, SlotType.Type.WEAPON_2]
	grid_size = Vector2i(2, 3)
