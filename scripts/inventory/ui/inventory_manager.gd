extends Node

@export var start_sword: OneHandData
@export var start_two_hand: TwoHandData
@export var start_ring: RingData
@export var start_helmet: HelmetData

var equipment: Equipment
var backpack: BackpackGrid

func _ready() -> void:
	equipment = Equipment.new()
	backpack = BackpackGrid.new()
	
	# Ищем InventoryUI в дереве сцены (он уникален).
	# Мы используем find_child, чтобы не привязываться к жесткому пути.
	var inv_ui = get_tree().root.find_child("InventoryUI", true, false)
	
	if inv_ui:
		inv_ui.call("setup_inventory", equipment, backpack)
	else:
		print("ERROR: InventoryUI not found in scene tree!")

	_spawn_starting_items()

func _spawn_starting_items() -> void:
	if start_sword == null or start_two_hand == null or start_ring == null or start_helmet == null:
		print("ERROR: Item resources not assigned!")
		return
		
	backpack.place(start_sword, Vector2i(0, 0))
	backpack.place(start_two_hand, Vector2i(3, 0))
	backpack.place(start_ring, Vector2i(6, 0))
	backpack.place(start_helmet, Vector2i(8, 0))
