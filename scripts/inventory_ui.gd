extends CanvasLayer

@export var slot_scene: PackedScene 
var bag_grid: GridContainer
var equip_grid: GridContainer

func _ready() -> void:
	visible = false 
	
	# Ищем сетки по имени во всей сцене
	for node in find_children("*", "GridContainer", true, false):
		if "Bag" in node.name:
			bag_grid = node
		elif "Equip" in node.name:
			equip_grid = node
	
	# Заполняем слоты рюкзака (15 колонок * 3 ряда = 45)
	if bag_grid:
		for i in range(45):
			var slot = slot_scene.instantiate()
			bag_grid.add_child(slot)
		
	# Заполняем слоты экипировки (4 штуки)
	if equip_grid:
		for i in range(4):
			var slot = slot_scene.instantiate()
			equip_grid.add_child(slot)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_inventory()

func toggle_inventory() -> void:
	visible = not visible
	get_tree().paused = visible
