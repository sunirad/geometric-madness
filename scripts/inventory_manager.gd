extends Node

var held_item: ItemData = null 
var drag_icon: TextureRect = null
var clicked_slot: Panel = null 
var is_dragging: bool = false  

func setup_ui(icon: TextureRect) -> void:
	if icon != null:
		drag_icon = icon

func start_action(slot: Panel) -> void:
	clicked_slot = slot
	if held_item == null and slot.current_item != null:
		held_item = slot.current_item
		slot.set_item(null)
		show_icon(held_item)
		is_dragging = true 
	elif held_item != null:
		try_put_in_slot(slot)

func end_action() -> void:
	if is_dragging and held_item != null:
		var hovered_slot = get_slot_under_mouse()
		if hovered_slot:
			try_put_in_slot(hovered_slot)
	is_dragging = false

func try_put_in_slot(slot: Panel) -> void:
	var item_before = slot.current_item
	slot.set_item(held_item)
	
	if slot.current_item == held_item:
		if item_before != null:
			held_item = item_before
			show_icon(held_item)
			is_dragging = true
		else:
			held_item = null
			hide_icon()
			is_dragging = false
	else:
		show_icon(held_item)

func show_icon(item: ItemData) -> void:
	if drag_icon and item and item.icon:
		drag_icon.texture = item.icon
		drag_icon.visible = true
		drag_icon.size = Vector2(48, 48)

func hide_icon() -> void:
	if drag_icon:
		drag_icon.visible = false
		drag_icon.texture = null

func get_slot_under_mouse() -> Panel:
	var mouse_pos = get_viewport().get_mouse_position()
	var root = get_tree().root
	for slot in root.find_children("*", "Panel", true, false):
		if slot.has_method("set_item") and slot.is_visible_in_tree():
			if slot.get_global_rect().has_point(mouse_pos):
				return slot
	return null

func _process(_delta: float) -> void:
	if held_item and drag_icon and drag_icon.visible:
		# Берем позицию мыши прямо из Viewport (глобальные координаты экрана)
		var mouse_pos = drag_icon.get_viewport().get_mouse_position()
		
		# Ставим картинку. Так как она лежит в CanvasLayer, её координаты = координаты экрана.
		drag_icon.global_position = mouse_pos - (drag_icon.size / 2)
