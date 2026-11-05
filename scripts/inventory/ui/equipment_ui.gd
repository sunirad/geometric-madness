class_name EquipmentUI
extends Control

var equipment: Equipment = null
var inventory_ui: CanvasLayer = null # <--- Объявление переменной
var backpack_ui: BackpackUI = null

var _slot_nodes: Dictionary = {}
var _figure_container: Control = null
var _slot_rects: Dictionary = {}
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
	_build_ui()
	_update_layout.call_deferred()

func set_equipment(p_equipment: Equipment) -> void:
	equipment = p_equipment
	if equipment != null:
		equipment.equipment_changed.connect(_on_equipment_changed)
		_refresh_all()

func _build_ui() -> void:
	_figure_container = Control.new()
	add_child(_figure_container)
	for slot_type in _layout_data.keys():
		var data: Dictionary = _layout_data[slot_type]
		var slot_ui := EquipmentSlotUI.new()
		slot_ui.setup(slot_type, data["size"])
		_figure_container.add_child(slot_ui)
		_slot_nodes[slot_type] = slot_ui

func _update_layout() -> void:
	if _slot_nodes.is_empty(): return
	var max_x: int = 0
	for data in _layout_data.values():
		var pos: Vector2i = data["pos"]
		var sz: Vector2i = data["size"]
		max_x = max(max_x, pos.x + sz.x)
	
	var total_w = max_x * CELL_SIZE
	_figure_container.position = Vector2((size.x - total_w) / 2.0, 10.0)
	
	_slot_rects.clear()
	for slot_type in _slot_nodes.keys():
		var slot_ui = _slot_nodes[slot_type]
		var data: Dictionary = _layout_data[slot_type]
		var pos: Vector2i = data["pos"]
		var sz: Vector2i = data["size"]
		slot_ui.position = Vector2(pos.x * CELL_SIZE, pos.y * CELL_SIZE)
		slot_ui.size = Vector2(sz.x * CELL_SIZE, sz.y * CELL_SIZE)
		
		var global_rect = Rect2(global_position + _figure_container.position + slot_ui.position, slot_ui.size)
		_slot_rects[slot_type] = global_rect

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

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if inventory_ui == null: return
		
		var mouse_pos = get_global_mouse_position()
		
		for slot_type in _slot_rects.keys():
			if _slot_rects[slot_type].has_point(mouse_pos):
				var current_item = equipment.get_item(slot_type)
				
				# 1. Берем предмет из слота.
				if inventory_ui.dragged_item == null:
					if current_item != null:
						equipment.unequip(current_item)
						inventory_ui.start_drag(current_item)
						accept_event()
						return
				
				# 2. Кладем/свапаем.
				else:
					var item_in_hand = inventory_ui.dragged_item
					
					if item_in_hand.allowed_slots.has(slot_type):
						if current_item != null:
							equipment.unequip(current_item)
							
						var displaced = equipment.equip(item_in_hand)
						if displaced != null:
							if current_item != null:
								inventory_ui.start_drag(current_item)
							else:
								inventory_ui.stop_drag()
								if displaced.size() > 0:
									print("Unequipped: ", displaced[0].display_name)
						else:
							if current_item != null:
								equipment.equip(current_item)
							print("ERROR: Cannot equip item here!")
					else:
						print("ERROR: Wrong slot type!")
					accept_event()
					return
