class_name Equipment
extends RefCounted

signal equipment_changed(slot: SlotType.Type, item: EquipItemData)

var _slots: Dictionary = {}

func _init() -> void:
	for slot in SlotType.Type.values():
		_slots[slot] = null

func get_item(slot: SlotType.Type) -> EquipItemData:
	return _slots.get(slot, null)

func equip(item: EquipItemData, preferred_slot: SlotType.Type = SlotType.Type.WEAPON_1) -> Variant:
	if item == null: return null

	if item.two_handed:
		if preferred_slot == SlotType.Type.WEAPON_2:
			return null # Ошибка: двуручное в правый слот нельзя
		
		var displaced_two_hand: Array = []
		for slot in [SlotType.Type.WEAPON_1, SlotType.Type.WEAPON_2]:
			var current: EquipItemData = _slots[slot]
			if current != null and current != item:
				displaced_two_hand.append(current)
				_unequip_all(current)
		
		_slots[SlotType.Type.WEAPON_1] = item
		_slots[SlotType.Type.WEAPON_2] = item
		equipment_changed.emit(SlotType.Type.WEAPON_1, item)
		equipment_changed.emit(SlotType.Type.WEAPON_2, item)
		return displaced_two_hand

	if preferred_slot == SlotType.Type.WEAPON_2 and item.allowed_slots.has(SlotType.Type.WEAPON_2):
		var left_item = _slots[SlotType.Type.WEAPON_1]
		if left_item == null or left_item.two_handed:
			return null # Ошибка: в правый слот без левого одноручного нельзя
		
		var displaced_right: Array = []
		var current_right = _slots[SlotType.Type.WEAPON_2]
		if current_right != null and current_right != item:
			displaced_right.append(current_right)
			_unequip_all(current_right)
			
		_slots[SlotType.Type.WEAPON_2] = item
		equipment_changed.emit(SlotType.Type.WEAPON_2, item)
		return displaced_right

	var target_slots: Array = _resolve_slots(item, preferred_slot)
	if target_slots.is_empty(): return null

	var displaced_std: Array = []
	for slot in target_slots:
		var current: EquipItemData = _slots[slot]
		if current != null and current != item:
			displaced_std.append(current)

	for old_item in displaced_std:
		_unequip_all(old_item)

	for slot in target_slots:
		_slots[slot] = item
		equipment_changed.emit(slot, item)

	return displaced_std

func unequip(item: EquipItemData) -> bool:
	if item == null: return false
	return _unequip_all(item)

func _resolve_slots(item: EquipItemData, preferred_slot: SlotType.Type) -> Array:
	if item.allowed_slots.has(SlotType.Type.RING_1) and item.allowed_slots.has(SlotType.Type.RING_2):
		if preferred_slot == SlotType.Type.RING_1 or preferred_slot == SlotType.Type.RING_2:
			return [preferred_slot]
		if _slots[SlotType.Type.RING_1] == null: return [SlotType.Type.RING_1]
		if _slots[SlotType.Type.RING_2] == null: return [SlotType.Type.RING_2]
		return [SlotType.Type.RING_1]

	if item.allowed_slots.has(SlotType.Type.WEAPON_1) and not item.two_handed:
		if preferred_slot == SlotType.Type.WEAPON_1:
			return [SlotType.Type.WEAPON_1]
		if _slots[SlotType.Type.WEAPON_1] == null: return [SlotType.Type.WEAPON_1]
		if _slots[SlotType.Type.WEAPON_2] == null: return [SlotType.Type.WEAPON_2]
		return [SlotType.Type.WEAPON_1]

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
