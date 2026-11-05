class_name EquipItemData
extends ItemData

# Какие слоты принимает предмет. Заполняется в _init() подкласса.
var allowed_slots: Array[SlotType.Type] = []
# Размер в клетках рюкзака. Заполняется в _init() подкласса.
var grid_size: Vector2i = Vector2i.ONE
# Занимает ли предмет оба слота оружия.
var two_handed: bool = false
