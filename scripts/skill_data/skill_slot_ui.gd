class_name SkillSlotUI
extends Control

@onready var background: ColorRect = $Background
@onready var icon: TextureRect = $Icon
@onready var key_label: Label = $KeyLabel

var action_name: String = ""
var skill: SkillData = null

signal clicked(slot: SkillSlotUI)

func _ready() -> void:
	custom_minimum_size = Vector2(64, 64)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

func set_key_text(text: String) -> void:
	key_label.text = text

func set_skill(new_skill: SkillData) -> void:
	skill = new_skill
	if skill != null:
		icon.texture = skill.icon
		icon.visible = true
	else:
		icon.texture = null
		icon.visible = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var global_rect = get_global_rect()
		if global_rect.has_point(event.position):
			clicked.emit(self)
			get_viewport().set_input_as_handled()
