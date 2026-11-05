class_name SkillCardUI
extends PanelContainer

# ============================================================
# Карточка одного скилла для окна скиллов.
# Отображает иконку, название, урон и слоты под сапорт.
# ============================================================

@onready var icon_texture: TextureRect = $Margin/HBox/IconFrame/Icon
@onready var name_label: Label = $Margin/HBox/VBox/NameLabel
@onready var damage_label: Label = $Margin/HBox/VBox/DamageLabel
@onready var support_slots_container: HBoxContainer = $Margin/HBox/VBox/SupportSlots

var skill_data: SkillData = null

# Инициализация карточки данными скилла
func setup(skill: SkillData) -> void:
	skill_data = skill
	if skill == null:
		return
		
	# Заполняем данные
	if icon_texture:
		icon_texture.texture = skill.icon
	if name_label:
		name_label.text = skill.display_name
	if damage_label:
		damage_label.text = "Damage: " + str(skill.damage)
		
	# Создаем слоты под сапорт-скиллы
	_create_support_slots(skill.support_slots_count)

# Создает пустые квадратики под сапорт-скиллы
func _create_support_slots(count: int) -> void:
	if not support_slots_container:
		return
		
	# Очищаем старые слоты (если есть)
	for child in support_slots_container.get_children():
		child.queue_free()
		
	# Создаем новые
	for i in range(count):
		var slot = Panel.new()
		slot.custom_minimum_size = Vector2(32, 32)
		
		# Красивый фон слота (темный с рамкой)
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.1, 0.1, 0.8)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = Color(0.5, 0.5, 0.5)
		slot.add_theme_stylebox_override("panel", style)
		
		support_slots_container.add_child(slot)
