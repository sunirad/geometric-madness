
extends Area2D

@export var item_data: EquipItemData

@onready var sprite: Sprite2D = $Sprite2D
@onready var name_button: Button = $NameButton

var player_in_range: bool = false
var inventory_ui: Node = null
var can_pick_up: bool = true


func _ready() -> void:
	add_to_group("world_item")

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	name_button.pressed.connect(_on_name_button_pressed)

	name_button.flat = true
	name_button.focus_mode = Control.FOCUS_NONE

	if item_data == null:
		push_warning("WorldItem: не назначен item_data!")
		return

	sprite.texture = item_data.icon
	name_button.text = item_data.display_name
	name_button.visible = true
	name_button.show()
	name_button.z_index = 10
	name_button.custom_minimum_size = Vector2(140, 30)
	name_button.position = Vector2(-70, -55)
	print("Название предмета: ", item_data.display_name)
	print("Кнопка существует: ", name_button)
	print("Кнопка видима: ", name_button.visible)


func _process(_delta: float) -> void:
	if not can_pick_up:
		return

	if player_in_range and Input.is_action_just_pressed("pickup"):
		pick_up()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false


func _on_name_button_pressed() -> void:
	if not player_in_range:
		return

	pick_up()


func pick_up() -> void:
	if not can_pick_up or item_data == null:
		return

	if inventory_ui == null:
		inventory_ui = get_tree().get_first_node_in_group("inventory_ui")

	if inventory_ui == null:
		push_warning("WorldItem: InventoryUI не найден!")
		return

	var success: bool = inventory_ui.try_add_item(item_data)

	if success:
		can_pick_up = false
		queue_free()
	else:
		print("inventory is full")
