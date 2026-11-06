class_name SkillBarUI
extends Control

@onready var top_row: HBoxContainer = $VBox/TopRow
@onready var bottom_row: HBoxContainer = $VBox/BottomRow
@onready var skill_picker: SkillPicker = $SkillPicker

var config: SkillBarConfig
var _slots: Array[SkillSlotUI] = []
var _player_ref: CharacterBody2D = null

var _slot_actions: Array[String] = [
	"MouseLeft", "MouseMiddle", "MouseRight",
	"Key1", "Key2", "Key3", "Key4", "Key5"
]
var _slot_labels: Array[String] = [
	"LMB", "MMB", "RMB",
	"1", "2", "3", "4", "5"
]

func _ready() -> void:
	_player_ref = get_tree().get_first_node_in_group("player")
	
	if not config:
		config = load("res://data/skill_bar_config.tres")
		if not config:
			push_warning("SkillBarUI: Не удалось загрузить skill_bar_config.tres!")
	
	# Загружаем книгу скиллов и передаем её в меню выбора
	var book = load("res://data/skill_book_data.tres")
	if skill_picker and book:
		skill_picker.setup_book(book)
	
	# Ставим базовую атаку на ЛКМ по умолчанию
	if config and config.get_skill("MouseLeft") == null:
		var basic = load("res://data/basic_attack.tres")
		if basic:
			config.set_skill("MouseLeft", basic)
			
	for child in top_row.get_children():
		if child is SkillSlotUI:
			_slots.append(child)
	for child in bottom_row.get_children():
		if child is SkillSlotUI:
			_slots.append(child)
	
	for i in range(_slots.size()):
		if i < _slot_actions.size():
			var slot = _slots[i]
			slot.action_name = _slot_actions[i]
			slot.set_key_text(_slot_labels[i])
			slot.clicked.connect(_on_slot_clicked)
			
	if skill_picker:
		skill_picker.skill_selected.connect(_on_skill_selected)
		skill_picker.clear_requested.connect(_on_clear_requested)
	else:
		push_warning("SkillBarUI: Узел SkillPicker не найден!")
		
	refresh_slots()

func _input(event: InputEvent) -> void:
	if skill_picker and skill_picker.visible:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if not skill_picker.get_global_rect().has_point(event.position):
				skill_picker.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if skill_picker and skill_picker.visible:
		return
		
	var action_name = ""
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			action_name = "MouseLeft"
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			action_name = "MouseRight"
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			action_name = "MouseMiddle"
			
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_1 and event.keycode <= KEY_5:
			action_name = "Key" + str(event.keycode - KEY_0)
			
	if action_name != "" and config:
		var skill = config.get_skill(action_name)
		if skill != null:
			if is_instance_valid(_player_ref):
				if skill.id == "basic_attack":
					_player_ref.attack(skill)
				else:
					_player_ref.cast_skill(skill)

func refresh_slots() -> void:
	if not config: return
	for slot in _slots:
		var skill = config.get_skill(slot.action_name)
		slot.set_skill(skill)

func _on_slot_clicked(slot: SkillSlotUI) -> void:
	if skill_picker:
		skill_picker.open_for_slot(slot)

func _on_skill_selected(skill: SkillData) -> void:
	if not skill_picker or not skill_picker._target_slot: return
	var target_action = skill_picker._target_slot.action_name
	config.set_skill(target_action, skill)
	refresh_slots()
	
func _on_clear_requested() -> void:
	if not skill_picker or not skill_picker._target_slot: return
	var target_action = skill_picker._target_slot.action_name
	config.clear_skill(target_action)
	refresh_slots()

func _process(_delta: float) -> void:
	if skill_picker and skill_picker.visible:
		return

	if not is_instance_valid(_player_ref):
		return

	if get_viewport().gui_get_hovered_control() != null:
		return

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var skill = config.get_skill("MouseLeft") if config else null

		if skill != null and skill.id == "basic_attack":
			if not _player_ref.is_attacking:
				_player_ref.attack(skill)
