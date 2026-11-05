class_name EquipmentSlotUI
extends Control

var slot_type: SlotType.Type
var item: EquipItemData = null
var grid_size: Vector2i = Vector2i.ONE

var _bg_color: Color = Color(0.15, 0.15, 0.15, 0.8)
var _border_color: Color = Color(0.3, 0.3, 0.3)

const PADDING: float = 2.0 # Отступ внутри слота

# Убрали p_label, оставили только тип слота и размер сетки.
func setup(p_slot_type: SlotType.Type, p_grid_size: Vector2i) -> void:
	slot_type = p_slot_type
	grid_size = p_grid_size

func set_item(p_item: EquipItemData) -> void:
	item = p_item
	queue_redraw()

func _draw() -> void:
	# Внутренний прямоугольник с учетом отступа.
	var inner_rect := Rect2(Vector2(PADDING, PADDING), size - Vector2(PADDING * 2, PADDING * 2))
	
	# Фон и рамка.
	draw_rect(inner_rect, _bg_color)
	draw_rect(inner_rect, _border_color, false, 2.0)
	
	# Внутренняя сетка (клетки).
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
			
	# Иконка предмета.
	if item != null and item.icon != null:
		var icon_rect := Rect2(inner_rect.position + Vector2(4, 4), inner_rect.size - Vector2(8, 8))
		draw_texture_rect(item.icon, icon_rect, false)
