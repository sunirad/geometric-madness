class_name SkillBookUI
extends CanvasLayer

# ============================================================
# Окно скиллов (Книга Скиллов).
# Открывается по J, НЕ ставит игру на паузу.
# ============================================================

@onready var skills_list: VBoxContainer = $Root/LeftPanel/Margin/VBox/ScrollContainer/SkillsList
@onready var title_label: Label = $Root/LeftPanel/Margin/VBox/TitleLabel
@onready var root_control: Control = $Root

@export var skill_book_data: SkillBookData
@export var skill_card_scene: PackedScene

var _is_open: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	root_control.visible = false
	_is_open = false
	
	if title_label:
		title_label.text = "SKILLS"
	
	if not skill_book_data:
		skill_book_data = load("res://data/skill_book_data.tres")
		
	if not skill_card_scene:
		skill_card_scene = load("res://scenes/ui/skill_card_ui.tscn")
		
	_populate_skills()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("skill_book"):
		toggle()
		get_viewport().set_input_as_handled()

func toggle() -> void:
	if _is_open: close()
	else: open()

func open() -> void:
	if _is_open: return
	_is_open = true
	root_control.visible = true
	
	# Закрываем лист персонажа, если он открыт
	var sheet = get_tree().get_first_node_in_group("character_sheet_ui")
	if sheet and sheet.has_method("close") and sheet.is_open():
		sheet.close()
		
	# Снимаем игру с паузы (если инвентарь не открыт)
	if not _is_any_other_ui_open():
		get_tree().paused = false
		
	_populate_skills()

func close() -> void:
	if not _is_open: return
	_is_open = false
	root_control.visible = false

func is_open() -> bool:
	return _is_open

# Вспомогательный метод для проверки открытых окон
func _is_any_other_ui_open() -> bool:
	for node in get_tree().get_nodes_in_group("closable_ui"):
		if node != self and node.has_method("is_open") and node.is_open():
			return true
	return false

func _populate_skills() -> void:
	if not skills_list: return
	
	for child in skills_list.get_children():
		child.queue_free()
		
	if not skill_book_data or not skill_card_scene:
		return
		
	for skill in skill_book_data.skills:
		var card = skill_card_scene.instantiate()
		skills_list.add_child(card)
		
		if card.has_method("setup"):
			card.setup(skill)
			
		card.mouse_entered.connect(_on_card_mouse_entered.bind(skill))
		card.mouse_exited.connect(_on_card_mouse_exited)

func _on_card_mouse_entered(skill: SkillData) -> void:
	print("Наведение на скилл: ", skill.display_name, " | Описание: ", skill.description)

func _on_card_mouse_exited() -> void:
	print("Мышь ушла со скилла")
