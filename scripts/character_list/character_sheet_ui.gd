extends CanvasLayer

# ============================================================
# UI Листа персонажа.
# Открывается/закрывается по клавише C.
# Пауза управляется через PauseManager.
# ============================================================

@export_group("Node References")
@export var portrait_texture: TextureRect
@export var title_label: Label
@export var level_label: Label
@export var hp_bar: ProgressBar
@export var mp_bar: ProgressBar
@export var hp_label: Label
@export var mp_label: Label
@export var str_value_label: Label
@export var str_bonus_label: Label
@export var agi_value_label: Label
@export var agi_bonus_label: Label
@export var int_value_label: Label
@export var int_bonus_label: Label

@export var player_stats: PlayerStats

var _is_open: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	
	if player_stats:
		player_stats.health_changed.connect(_on_health_changed)
		player_stats.mana_changed.connect(_on_mana_changed)
		player_stats.stats_changed.connect(_on_stats_changed)
		_refresh_all()
	else:
		push_warning("CharacterSheetUI: player_stats не назначен в инспекторе.")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_character_sheet_toggle"):
		toggle()
		get_viewport().set_input_as_handled()

func toggle() -> void:
	if _is_open: close()
	else: open()

func open() -> void:
	if _is_open: return
	_is_open = true
	visible = true
	
	# Закрываем книгу скиллов, если она открыта
	var book = get_tree().get_first_node_in_group("skill_book_ui")
	if book and book.has_method("close") and book.is_open():
		book.close()
		
	PauseManager.register_open()
	_refresh_all()

func close() -> void:
	if not _is_open: return
	_is_open = false
	visible = false
	PauseManager.register_close()

func is_open() -> bool:
	return _is_open

func _refresh_all() -> void:
	if not player_stats: return
	
	if title_label: title_label.text = player_stats.get_character_name()
	if portrait_texture: portrait_texture.texture = player_stats.get_character_portrait()
	if level_label: level_label.text = "Level " + str(player_stats.get_level())
	
	var hp = player_stats.get_health()
	var mp = player_stats.get_mana()
	_on_health_changed(hp.x, hp.y)
	_on_mana_changed(mp.x, mp.y)
	_on_stats_changed()

func _on_health_changed(current: int, maximum: int) -> void:
	if hp_bar:
		hp_bar.max_value = maximum
		hp_bar.value = current
	if hp_label:
		hp_label.text = "HP: %d / %d" % [current, maximum]

func _on_mana_changed(current: int, maximum: int) -> void:
	if mp_bar:
		mp_bar.max_value = maximum
		mp_bar.value = current
	if mp_label:
		mp_label.text = "MP: %d / %d" % [current, maximum]

func _on_stats_changed() -> void:
	if not player_stats: return
	
	var str_data = player_stats.get_strength()
	if str_value_label: str_value_label.text = str(str_data.x)
	if str_bonus_label: _format_bonus_label(str_bonus_label, str_data.y)
		
	var agi_data = player_stats.get_agility()
	if agi_value_label: agi_value_label.text = str(agi_data.x)
	if agi_bonus_label: _format_bonus_label(agi_bonus_label, agi_data.y)
		
	var int_data = player_stats.get_intelligence()
	if int_value_label: int_value_label.text = str(int_data.x)
	if int_bonus_label: _format_bonus_label(int_bonus_label, int_data.y)

func _format_bonus_label(label: Label, bonus: int) -> void:
	if bonus > 0:
		label.text = "(+" + str(bonus) + ")"
		label.add_theme_color_override("font_color", Color.GREEN)
	elif bonus < 0:
		label.text = "(" + str(bonus) + ")"
		label.add_theme_color_override("font_color", Color.RED)
	else:
		label.text = "(+0)"
		label.add_theme_color_override("font_color", Color.GRAY)
