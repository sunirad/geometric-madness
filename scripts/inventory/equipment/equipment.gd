class_name Equipment
extends RefCounted

signal equipment_changed(slot: SlotType.Type, item: EquipItemData)

# Физический слот -> надетый предмет (или null).
var _slots: Dictionary = {}

func _init() -> void:
	for slot in SlotType.Type.values():
		_slots[slot] = null

# Возвращает предмет в физическом слоте, либо null.
func get_item(slot: SlotType.Type) -> EquipItemData:
	return _slots.get(slot, null)

# Проверяет, можно ли надеть предмет прямо сейчас (без учёта свапа).
func can_equip(item: EquipItemData) -> bool:
	if item == null:
		return false
	for slot in item.allowed_slots:
		if _slots.get(slot, null) == null:
			return true
	return false

# Надевает предмет. Возвращает массив вытесненных (снятых) предметов.
# Пустой массив — успех без вытеснения.
# null — надеть невозможно.
func equip(item: EquipItemData) -> Variant:
	if item == null:
		return null

	var target_slots: Array = _resolve_slots(item)
	if target_slots.is_empty():
		return null

	# Собираем вытесняемые предметы до перезаписи.
	var displaced: Array = []
	for slot in target_slots:
		var current: EquipItemData = _slots[slot]
		if current != null and current != item:
			displaced.append(current)

	# Снимаем вытесненные предметы (заодно освобождаем второй слот оружия при необходимости).
	for old_item in displaced:
		_unequip_all(old_item)

	# Если надеваем двуручное — освобождаем второй слот оружия.
	if item.two_handed:
		var other_weapon := _other_weapon_slot(target_slots[0])
		var other_item: EquipItemData = _slots[other_weapon]
		if other_item != null:
			_unequip_all(other_item)
			displaced.append(other_item)

	# Кладём предмет во все его целевые слоты.
	for slot in target_slots:
		_slots[slot] = item
		equipment_changed.emit(slot, item)

	return displaced

# Снимает предмет отовсюду, где он надет. Возвращает true, если он был надет.
func unequip(item: EquipItemData) -> bool:
	if item == null:
		return false
	return _unequip_all(item)

# --- Внутренняя логика ---

# Определяет, какие физические слоты займёт предмет.
func _resolve_slots(item: EquipItemData) -> Array:
	var slots: Array = []

	if item.two_handed:
		# Двуручное: занимает оба слота оружия.
		if item.allowed_slots.has(SlotType.Type.WEAPON_1) and item.allowed_slots.has(SlotType.Type.WEAPON_2):
			slots.append(SlotType.Type.WEAPON_1)
			slots.append(SlotType.Type.WEAPON_2)
			return slots
		return []

	if item.allowed_slots.has(SlotType.Type.WEAPON_1) and item.allowed_slots.has(SlotType.Type.WEAPON_2):
		# Одноручное: берём первый свободный слот, иначе WEAPON_1 для свапа.
		if _slots[SlotType.Type.WEAPON_1] == null:
			return [SlotType.Type.WEAPON_1]
		if _slots[SlotType.Type.WEAPON_2] == null:
			return [SlotType.Type.WEAPON_2]
		return [SlotType.Type.WEAPON_1]

	if item.allowed_slots.has(SlotType.Type.RING_1) and item.allowed_slots.has(SlotType.Type.RING_2):
		# Кольцо: первый свободный слот, иначе RING_1 для свапа.
		if _slots[SlotType.Type.RING_1] == null:
			return [SlotType.Type.RING_1]
		if _slots[SlotType.Type.RING_2] == null:
			return [SlotType.Type.RING_2]
		return [SlotType.Type.RING_1]

	# Однослотовый предмет.
	if not item.allowed_slots.is_empty():
		return [item.allowed_slots[0]]

	return []

func _unequip_all(item: EquipItemData) -> bool:
	var was_equipped := false
	for slot in _slots.keys():
		if _slots[slot] == item:
			_slots[slot] = null
			was_equipped = true
			equipment_changed.emit(slot, null)
	return was_equipped

func _other_weapon_slot(slot: SlotType.Type) -> SlotType.Type:
	return SlotType.Type.WEAPON_2 if slot == SlotType.Type.WEAPON_1 else SlotType.Type.WEAPON_1
