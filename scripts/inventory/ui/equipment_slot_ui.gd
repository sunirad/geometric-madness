class_name EquipmentSlotUI
extends Control

signal clicked(slot_type: SlotType.Type)

var slot_type: SlotType.Type
var item: EquipItemData = null
var grid_size: Vector2i = Vector2i.ONE

var _bg_color: Color = Color(0.15, 0.15, 0.15, 0.8)
var _border_color: Color = Color(0.3, 0.3, 0.3)
var _item_bg_color: Color = Color(0.25, 0.25, 0.3, 0.9)

const PADDING: float = 2.0

func setup(p_slot_type: SlotType.Type, p_grid_size: Vector2i) -> void:
	slot_type = p_slot_type
	grid_size = p_grid_size
	# Слот перехватывает клики.
	mouse_filter = Control.MOUSE_FILTER_STOP

func set_item(p_item: EquipItemData) -> void:
	item = p_item
	queue_redraw()

func _draw() -> void:
	var inner_rect := Rect2(Vector2(PADDING, PADDING), size - Vector2(PADDING * 2, PADDING * 2))
	if item != null:
		draw_rect(inner_rect, _item_bg_color)
		draw_rect(inner_rect, _border_color, false, 2.0)
		if item.icon != null:
			draw_texture_rect(item.icon, inner_rect.grow(-4.0), false)
	else:
		draw_rect(inner_rect, _bg_color)
		draw_rect(inner_rect, _border_color, false, 2.0)
		if grid_size.x > 1 or grid_size.y > 1:
			var cell_w = inner_rect.size.x / grid_size.x
			var cell_h = inner_rect.size.y / grid_size.y
			for x in range(1, grid_size.x):
				draw_line(Vector2(inner_rect.position.x + x * cell_w, inner_rect.position.y), 
						  Vector2(inner_rect.position.x + x * cell_w, inner_rect.end.y), 
						  _border_color, 1.0)
			for y in range(1, grid_size.y):
				draw_line(Vector2(inner_rect.position.x, inner_rect.position.y + y * cell_h), 
						  Vector2(inner_rect.end.x, inner_rect.position.y + y * cell_h), 
						  _border_color, 1.0)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("CLICK ON SLOT: ", slot_type) # Отладка!
		clicked.emit(slot_type)
		accept_event()
