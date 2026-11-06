extends CanvasLayer

# ============================================================
# UI Инвентаря.
# Открывается/закрывается по клавише инвентаря.
# Пауза управляется через PauseManager.
# ============================================================

@onready var root: Control = $Root
@onready var eq_ui = $Root/RightPanel/VBox/EquipmentArea
@onready var bp_ui = $Root/RightPanel/VBox/BackpackArea

var _is_open: bool = false
var dragged_item: EquipItemData = null
var _backpack: BackpackGrid = null
var _drag_canvas: Control = null

@export var world_item_scene: PackedScene

func _ready() -> void:
	# Всегда обрабатываем ввод, даже на паузе
	process_mode = Node.PROCESS_MODE_ALWAYS
	root.visible = false
	_is_open = false
	
	# Создаем полноэкранный слой для отрисовки перетаскиваемого предмета
	_drag_canvas = Control.new()
	_drag_canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_drag_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_drag_canvas.draw.connect(_draw_dragged_item)
	add_child(_drag_canvas)
	
	set_process(true)

func _unhandled_input(event: InputEvent) -> void:
	# Обрабатываем только клавишу открытия/закрытия инвентаря.
	# Esc обрабатывается глобально в PauseManager.
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
	PauseManager.register_open()

func close() -> void:
	if not _is_open: return
	_is_open = false
	root.visible = false
	PauseManager.register_close()
	if dragged_item != null:
		stop_drag()

func is_open() -> bool:
	return _is_open

func setup_inventory(p_equipment: Equipment, p_backpack: BackpackGrid) -> void:
	_backpack = p_backpack

	if eq_ui:
		eq_ui.set_equipment(p_equipment)
		eq_ui.inventory_ui = self
		eq_ui.backpack_ui = bp_ui

	if bp_ui:
		bp_ui.set_backpack(p_backpack)
		bp_ui.inventory_ui = self

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

		if Input.is_action_just_pressed("drop_item"):
			drop_dragged_item()

func _draw_dragged_item() -> void:
	if dragged_item == null: return
	var mouse_pos = get_viewport().get_mouse_position()
	var item_size = dragged_item.grid_size * 32.0
	var draw_rect = Rect2(mouse_pos, item_size)
	
	_drag_canvas.draw_rect(draw_rect, Color(0.25, 0.25, 0.3, 0.8))
	_drag_canvas.draw_rect(draw_rect, Color(0.3, 0.3, 0.3), false, 2.0)
	if dragged_item.icon != null:
		_drag_canvas.draw_texture_rect(dragged_item.icon, draw_rect.grow(-4.0), false)


func try_add_item(item: EquipItemData) -> bool:
	if _backpack == null:
		return false
	var inventory_item := item.duplicate(true) as EquipItemData
	if inventory_item == null:
		return false
	var result = _backpack.try_add_item(inventory_item)
	return result


func drop_dragged_item() -> void:
	if dragged_item == null:
		return

	if world_item_scene == null:
		push_warning("WorldItem scene не назначена!")
		return

	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		push_warning("Игрок не найден!")
		return

	var dropped_item = world_item_scene.instantiate()

	if not dropped_item is Area2D:
		push_warning("WorldItem должен иметь корень Area2D!")
		dropped_item.free()
		return

	dropped_item.item_data = dragged_item.duplicate(true)

	get_tree().current_scene.add_child(dropped_item)

	dropped_item.global_position = player.global_position + Vector2(40, 0)

	print("Выброшен предмет: ", dragged_item.display_name)

	stop_drag()
