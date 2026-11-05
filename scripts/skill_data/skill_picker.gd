class_name SkillPicker
extends Control # <-- ТЕПЕРЬ ЭТО ПРОСТО CONTROL

signal skill_selected(skill: SkillData)
signal clear_requested()

var _target_slot: SkillSlotUI = null
var _available_skills: Array[SkillData] = []
var _hbox: HBoxContainer

func _ready() -> void:
	visible = false # Скрываем при старте
	size = Vector2i(132, 64)
	
	# Создаем контейнер для иконок
	_hbox = HBoxContainer.new()
	_hbox.add_theme_constant_override("separation", 4)
	add_child(_hbox)
	
	# Загружаем базовую атаку
	var basic_attack = load("res://data/basic_attack.tres")
	if basic_attack:
		_available_skills.append(basic_attack)

func open_for_slot(slot: SkillSlotUI) -> void:
	_target_slot = slot
	_refresh_ui()
	
	# Размер меню
	size = Vector2i(132, 64)
	
	var top_row = get_parent().get_node("VBox/TopRow")
	
	if top_row and top_row.get_child_count() >= 3:
		# Берем MMB (третий слот)
		var right_slot = top_row.get_child(2)
		var right_rect = right_slot.get_global_rect()
		
		# Вычисляем точку: правый край MMB минус ширина меню
		var spawn_x = right_rect.end.x - size.x
		var spawn_y = right_rect.position.y - size.y - 10
		
		# Жестко задаем позицию
		global_position = Vector2(spawn_x, spawn_y)
		
	# Показываем меню
	visible = true

func _refresh_ui() -> void:
	# Очищаем старые кнопки
	for child in _hbox.get_children():
		child.queue_free()
		
	# 1. Добавляем скиллы
	for skill in _available_skills:
		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(64, 64)
		_hbox.add_child(panel)
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.5, 0.5, 0.5)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = Color(0.7, 0.7, 0.7)
		panel.add_theme_stylebox_override("panel", style)
		
		panel.gui_input.connect(_on_skill_panel_input.bind(skill))
		
		var icon = TextureRect.new()
		icon.texture = skill.icon
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon.offset_left = 4
		icon.offset_top = 4
		icon.offset_right = -4
		icon.offset_bottom = -4
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(icon)
		
	# 2. Добавляем крестик
	var clear_panel = Panel.new()
	clear_panel.custom_minimum_size = Vector2(64, 64)
	_hbox.add_child(clear_panel)
	
	var clear_style = StyleBoxFlat.new()
	clear_style.bg_color = Color(0.5, 0.5, 0.5)
	clear_style.border_width_left = 2
	clear_style.border_width_top = 2
	clear_style.border_width_right = 2
	clear_style.border_width_bottom = 2
	clear_style.border_color = Color(0.7, 0.7, 0.7)
	clear_panel.add_theme_stylebox_override("panel", clear_style)
	
	clear_panel.gui_input.connect(_on_clear_input)
	
	var label = Label.new()
	label.text = "X"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clear_panel.add_child(label)

func _on_skill_panel_input(event: InputEvent, skill: SkillData) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		skill_selected.emit(skill)
		visible = false # Вместо hide()

func _on_clear_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clear_requested.emit()
		visible = false # Вместо hide()
