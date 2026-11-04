extends Panel

@export var allowed_types: Array[ItemData.Type] = [] 

var current_item: ItemData = null
@onready var icon_rect: TextureRect = $ItemIcon

func set_item(item: ItemData) -> void:
	if item != null and allowed_types.size() > 0:
		if not item.item_type in allowed_types:
			print("Нельзя положить ", item.item_name, " в этот слот")
			return
			
	current_item = item
	
	if current_item and current_item.icon:
		icon_rect.texture = current_item.icon
		icon_rect.visible = true
	else:
		icon_rect.texture = null
		icon_rect.visible = false

func _get_drag_data(_at_position: Vector2) -> Variant:
	if current_item == null:
		return null
		
	# Создаем контейнер для центрирования
	var drag_preview = Control.new()
	
	# Создаем картинку
	var icon = TextureRect.new()
	icon.texture = current_item.icon
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.size = Vector2(48, 48)
	icon.modulate = Color(1, 1, 1, 0.5)
	
	# Смещаем картинку на половину её размера влево и вверх
	# Чтобы её центр оказался под мышкой
	icon.position = -icon.size / 2 
	
	drag_preview.add_child(icon)
	set_drag_preview(drag_preview)
	
	return self

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data is Panel:
		var source_slot = data
		var dragged_item = source_slot.current_item
		
		if dragged_item == null: return false
		if allowed_types.size() > 0 and not dragged_item.item_type in allowed_types:
			return false
			
		return true
	return false

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data is Panel:
		var source_slot = data
		var dragged_item = source_slot.current_item
		var item_in_target = current_item
		
		source_slot.set_item(null)
		set_item(dragged_item)
		
		if current_item == dragged_item and item_in_target != null:
			source_slot.set_item(item_in_target)
