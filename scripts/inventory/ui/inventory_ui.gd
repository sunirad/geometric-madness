extends CanvasLayer

@onready var root: Control = $Root
@onready var eq_ui = $Root/RightPanel/VBox/EquipmentArea
@onready var bp_ui = $Root/RightPanel/VBox/BackpackArea

var _is_open: bool = false
var dragged_item: EquipItemData = null
var _drag_canvas: Control = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	root.visible = false
	_is_open = false
	
	_drag_canvas = Control.new()
	_drag_canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_drag_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_drag_canvas.draw.connect(_draw_dragged_item)
	add_child(_drag_canvas)
	
	set_process(true)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle()
		get_viewport().set_input_as_handled()

func toggle() -> void:
	if _is_open: close()
	else: open()

func open() -> void:
	if _is_open: return
	_is_open = true
	root.visible = true
	get_tree().paused = true

func close() -> void:
	if not _is_open: return
	_is_open = false
	root.visible = false
	get_tree().paused = false
	if dragged_item != null:
		stop_drag()

func setup_inventory(p_equipment: Equipment, p_backpack: BackpackGrid) -> void:
	if eq_ui:
		eq_ui.set_equipment(p_equipment)
		eq_ui.inventory_ui = self
	if bp_ui:
		bp_ui.set_backpack(p_backpack)
		bp_ui.inventory_ui = self

# Убрали offset, просто передаем предмет.
func start_drag(item: EquipItemData) -> void:
	dragged_item = item
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func stop_drag() -> void:
	dragged_item = null
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_drag_canvas.queue_redraw()

func _process(_delta: float) -> void:
	if dragged_item != null:
		_drag_canvas.queue_redraw()

func _draw_dragged_item() -> void:
	if dragged_item == null: return
	
	var mouse_pos = get_viewport().get_mouse_position()
	var item_size = dragged_item.grid_size * 32.0
	
	# Рисуем так, чтобы ЛЕВЫЙ ВЕРХНИЙ УГОЛ был ровно под мышкой.
	var draw_rect = Rect2(mouse_pos, item_size)
	
	_drag_canvas.draw_rect(draw_rect, Color(0.25, 0.25, 0.3, 0.8))
	_drag_canvas.draw_rect(draw_rect, Color(0.3, 0.3, 0.3), false, 2.0)
	
	if dragged_item.icon != null:
		_drag_canvas.draw_texture_rect(dragged_item.icon, draw_rect.grow(-4.0), false)
