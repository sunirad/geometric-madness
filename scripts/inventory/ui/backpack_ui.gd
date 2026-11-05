class_name BackpackUI
extends Control

const COLUMNS: int = 15
const ROWS: int = 5
const CELL_SIZE: float = 32.0 

var backpack: BackpackGrid = null
var inventory_ui: CanvasLayer = null 
var _items_positions: Dictionary = {}

var _bg_color: Color = Color(0.15, 0.15, 0.15, 0.8)
var _border_color: Color = Color(0.3, 0.3, 0.3)
var _item_bg_color: Color = Color(0.25, 0.25, 0.3, 0.9)
const PADDING: float = 2.0 

func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	# Разрешаем кликам проходить сквозь пустые места
	mouse_filter = Control.MOUSE_FILTER_PASS 
	_update_layout.call_deferred()

func set_backpack(p_backpack: BackpackGrid) -> void:
	backpack = p_backpack
	if backpack != null:
		backpack.item_placed.connect(_on_item_placed)
		backpack.item_removed.connect(_on_item_removed)
		_update_from_model()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_layout()

func _update_layout() -> void:
	queue_redraw()

func _update_from_model() -> void:
	_items_positions.clear()
	if backpack == null: return
	for item in backpack.get_all_items():
		_items_positions[item] = backpack.get_origin(item)
	queue_redraw()

func _on_item_placed(item: EquipItemData, origin: Vector2i) -> void:
	_items_positions[item] = origin
	queue_redraw()

func _on_item_removed(item: EquipItemData) -> void:
	_items_positions.erase(item)
	queue_redraw()

func _draw() -> void:
	var grid_width = COLUMNS * CELL_SIZE
	var grid_height = ROWS * CELL_SIZE
	var start_x = (size.x - grid_width) / 2.0
	var start_y = (size.y - grid_height) / 2.0
	
	for x in COLUMNS:
		for y in ROWS:
			var cell_rect = Rect2(start_x + x * CELL_SIZE, start_y + y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
			var inner_rect = Rect2(cell_rect.position + Vector2(PADDING, PADDING), cell_rect.size - Vector2(PADDING * 2, PADDING * 2))
			draw_rect(inner_rect, _bg_color)
			draw_rect(inner_rect, _border_color, false, 2.0)
			
	for item in _items_positions.keys():
		var origin: Vector2i = _items_positions[item]
		var item_rect = Rect2(
			start_x + origin.x * CELL_SIZE + PADDING,
			start_y + origin.y * CELL_SIZE + PADDING,
			item.grid_size.x * CELL_SIZE - PADDING * 2,
			item.grid_size.y * CELL_SIZE - PADDING * 2
		)
		draw_rect(item_rect, _item_bg_color)
		draw_rect(item_rect, _border_color, false, 2.0)
		if item.icon != null:
			draw_texture_rect(item.icon, item_rect.grow(-4.0), false)

func _get_grid_pos(mouse_pos: Vector2) -> Vector2i:
	var grid_width = COLUMNS * CELL_SIZE
	var grid_height = ROWS * CELL_SIZE
	var start_x = (size.x - grid_width) / 2.0
	var start_y = (size.y - grid_height) / 2.0
	return Vector2i(floor((mouse_pos.x - start_x) / CELL_SIZE), floor((mouse_pos.y - start_y) / CELL_SIZE))

func _get_item_top_left(item: EquipItemData) -> Vector2i:
	if backpack != null:
		return backpack.get_origin(item)
	return Vector2i(-1, -1)

func _get_overlapping_items(origin: Vector2i, item_size: Vector2i) -> Array:
	var overlaps = []
	if backpack == null: return overlaps
	
	var rect_a = Rect2(origin, item_size)
	
	for item in _items_positions.keys():
		var item_origin = _get_item_top_left(item)
		var rect_b = Rect2(item_origin, item.grid_size)
		
		if rect_a.intersects(rect_b):
			overlaps.append(item)
			
	return overlaps

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if inventory_ui == null: return
		
		var mouse_pos = get_local_mouse_position()
		
		# Проверяем, попали ли мы в сетку рюкзака.
		var grid_width = COLUMNS * CELL_SIZE
		var grid_height = ROWS * CELL_SIZE
		var start_x = (size.x - grid_width) / 2.0
		var start_y = (size.y - grid_height) / 2.0
		var grid_rect = Rect2(start_x, start_y, grid_width, grid_height)
		
		if not grid_rect.has_point(mouse_pos):
			return # Клик не в сетке рюкзака, пропускаем (пусть ловит экипировка).
		
		var grid_pos = _get_grid_pos(mouse_pos)
		
		if backpack != null:
			var clicked_item = backpack.get_item_at(grid_pos)
			
			# 1. Берем предмет.
			if inventory_ui.dragged_item == null:
				if clicked_item != null:
					backpack.remove(clicked_item)
					inventory_ui.start_drag(clicked_item)
					accept_event()
			
			# 2. Кладем или свапаем.
			else:
				var item_in_hand = inventory_ui.dragged_item
				var target_origin = grid_pos
				
				var overlapping_items = _get_overlapping_items(target_origin, item_in_hand.grid_size)
				
				if overlapping_items.size() > 0:
					var swap_item = overlapping_items[0]
					var swap_origin = _get_item_top_left(swap_item)
					
					backpack.remove(swap_item)
					
					if backpack.can_place(item_in_hand, target_origin):
						backpack.place(item_in_hand, target_origin)
						inventory_ui.start_drag(swap_item)
					else:
						backpack.place(swap_item, swap_origin)
						print("ERROR: Cannot swap items - not enough space!")
				else:
					if backpack.can_place(item_in_hand, target_origin):
						backpack.place(item_in_hand, target_origin)
						inventory_ui.stop_drag()
					else:
						print("ERROR: Cannot place item here!")
				accept_event()
