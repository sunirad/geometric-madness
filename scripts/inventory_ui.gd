extends CanvasLayer

@export var slot_scene: PackedScene 
@export var start_weapon: ItemData 
@export var start_ring: ItemData   

var bag_grid: GridContainer

func _ready() -> void:
	visible = false 
	
	var empty_image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	empty_image.fill(Color(0, 0, 0, 0))
	var invisible_cursor = ImageTexture.create_from_image(empty_image)
	
	Input.set_custom_mouse_cursor(invisible_cursor, Input.CURSOR_CAN_DROP)
	Input.set_custom_mouse_cursor(invisible_cursor, Input.CURSOR_FORBIDDEN)
	
	for node in find_children("*", "GridContainer", true, false):
		if "Bag" in node.name:
			bag_grid = node
			break
	
	if bag_grid:
		for i in range(45):
			var slot = slot_scene.instantiate()
			bag_grid.add_child(slot)
		
		await get_tree().process_frame
		
		if start_weapon:
			bag_grid.get_child(0).set_item(start_weapon)
		if start_ring:
			bag_grid.get_child(1).set_item(start_ring) 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_inventory()

func toggle_inventory() -> void:
	visible = not visible
	get_tree().paused = visible
