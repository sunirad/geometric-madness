class_name EquipmentUI
extends Control

var equipment: Equipment = null
var inventory_ui: CanvasLayer = null 
var backpack_ui: BackpackUI = null

var _slot_nodes: Dictionary = {}
var _figure_container: Control = null
const CELL_SIZE: float = 32.0 

var _layout_data := {
	SlotType.Type.HELMET:   { "pos": Vector2i(3, 2), "size": Vector2i(2, 2) },
	SlotType.Type.CHEST:    { "pos": Vector2i(3, 4), "size": Vector2i(2, 3) },
	SlotType.Type.AMULET:   { "pos": Vector2i(5, 4), "size": Vector2i(1, 1) },
	SlotType.Type.RING_1:   { "pos": Vector2i(2, 5), "size": Vector2i(1, 1) },
	SlotType.Type.RING_2:   { "pos": Vector2i(5, 5), "size": Vector2i(1, 1) },
	SlotType.Type.WEAPON_1: { "pos": Vector2i(0, 3), "size": Vector2i(2, 4) },
	SlotType.Type.WEAPON_2: { "pos": Vector2i(6, 3), "size": Vector2i(2, 4) },
	SlotType.Type.BELT:     { "pos": Vector2i(3, 7), "size": Vector2i(2, 1) },
	SlotType.Type.GLOVES:   { "pos": Vector2i(0, 7), "size": Vector2i(2, 2) },
	SlotType.Type.BOOTS:    { "pos": Vector2i(6, 7), "size": Vector2i(2, 2) },
}

func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_STOP # Ловим клики
	_build_ui()
	_update_layout.call_deferred()

func set_equipment(p_equipment: Equipment) -> void:
	equipment = p_equipment
	if equipment != null:
		equipment.equipment_changed.connect(_on_equipment_changed)
		_refresh_all()

func _build_ui() -> void:
	_figure_container = Control.new()
	_figure_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_figure_container.clip_contents = false # Отключаем обрезку!
	add_child(_figure_container)
	
	for slot_type in _layout_data.keys():
		var data: Dictionary = _layout_data[slot_type]
		var slot_ui := EquipmentSlotUI.new()
		slot_ui.setup(slot_type, data["size"])
		# ВАЖНО: Слоты ловят клики сами!
		slot_ui.mouse_filter = Control.MOUSE_FILTER_STOP 
		slot_ui.clicked.connect(_on_slot_clicked)
		_figure_container.add_child(slot_ui)
		_slot_nodes[slot_type] = slot_ui

func _update_layout() -> void:
	if _slot_nodes.is_empty(): return
	var max_x: int = 0
	var max_y: int = 0
	for data in _layout_data.values():
		var pos: Vector2i = data["pos"]
		var sz: Vector2i = data["size"]
		max_x = max(max_x, pos.x + sz.x)
		max_y = max(max_y, pos.y + sz.y)
	
	# Задаем размер контейнера, чтобы он не обрезал слоты.
	_figure_container.size = Vector2(max_x * CELL_SIZE, max_y * CELL_SIZE)
	_figure_container.position = Vector2((size.x - _figure_container.size.x) / 2.0, 10.0)
	
	for slot_type in _slot_nodes.keys():
		var slot_ui = _slot_nodes[slot_type]
		var data: Dictionary = _layout_data[slot_type]
		var pos: Vector2i = data["pos"]
		var sz: Vector2i = data["size"]
		slot_ui.position = Vector2(pos.x * CELL_SIZE, pos.y * CELL_SIZE)
		slot_ui.size = Vector2(sz.x * CELL_SIZE, sz.y * CELL_SIZE)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED or what == NOTIFICATION_TRANSFORM_CHANGED:
		_update_layout()

func _on_equipment_changed(slot_type: SlotType.Type, item: EquipItemData) -> void:
	if _slot_nodes.has(slot_type):
		_slot_nodes[slot_type].set_item(item)

func _refresh_all() -> void:
	if equipment == null: return
	for slot_type in _slot_nodes.keys():
		_slot_nodes[slot_type].set_item(equipment.get_item(slot_type))

func _on_slot_clicked(slot_type: SlotType.Type) -> void:
	if inventory_ui == null: return
	var current_item = equipment.get_item(slot_type)
	
	if inventory_ui.dragged_item == null:
		if current_item != null:
			equipment.unequip(current_item)
			inventory_ui.start_drag(current_item)
	else:
		var item_in_hand = inventory_ui.dragged_item
		if item_in_hand.allowed_slots.has(slot_type):
			var displaced = equipment.equip(item_in_hand, slot_type)
			if displaced != null:
				if current_item != null:
					inventory_ui.start_drag(current_item)
				else:
					inventory_ui.stop_drag()
				if displaced.size() > 0:
					for old_item in displaced:
						if old_item != current_item:
							print("Unequipped: ", old_item.display_name)
			else:
				print("ERROR: equip() returned NULL!")
		else:
			print("ERROR: Slot type not allowed!")
