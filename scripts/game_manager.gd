extends Node

@export var enemy_scene: PackedScene
@export var min_enemy_distance: float = 120.0
@export var min_player_distance: float = 200.0
@export var spawn_attempts: int = 30
@export var initial_enemy_count: int = 5
@export var respawn_delay: float = 1.5
@export_group("Loot Settings")
@export var world_item_scene: PackedScene
@export_range(0.0, 1.0) var loot_drop_chance: float = 0.3
@export var loot_items: Array[EquipItemData] = []
@export var loot_spawn_radius: float = 25.0
@export var target_kills: int = 100
@export var min_enemy_scale: float = 0.8
@export var max_enemy_scale: float = 1.5
@onready var enemies_container: Node2D = $"../Enemies"
@onready var spawn_points: Node2D = $"../SpawnPoints"
@onready var win_screen: CanvasGroup = $"../WinScreen"

var kills: int = 0
var game_won: bool = false
var player: CharacterBody2D = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

	if not is_instance_valid(player):
		push_error("GameManager: Игрок не найден в группе 'player'!")
		return

	win_screen.hide()

	for i in range(initial_enemy_count):
		spawn_enemy()


func spawn_enemy() -> void:
	if game_won:
		return

	if enemy_scene == null:
		push_error("Enemy Scene не назначена!")
		return

	var points = spawn_points.get_children()

	if points.is_empty():
		push_error("Нет точек появления врагов!")
		return

	var valid_points: Array[Node2D] = []

	for point in points:
		var valid = true

		# Проверяем расстояние до игрока
		if is_instance_valid(player):
			if point.global_position.distance_to(player.global_position) < min_player_distance:
				valid = false

		# Проверяем расстояние до других врагов
		for enemy in enemies_container.get_children():
			if not is_instance_valid(enemy):
				continue

			if enemy.is_dead:
				continue

			if point.global_position.distance_to(enemy.global_position) < min_enemy_distance:
				valid = false
				break

		if valid:
			valid_points.append(point)

	if valid_points.is_empty():
		print("Нет свободных точек появления. Повторяем попытку.")

		await get_tree().create_timer(1.0).timeout

		if not game_won:
			spawn_enemy()

		return

	var spawn_point = valid_points.pick_random()

	var enemy = enemy_scene.instantiate()

	var random_scale = randf_range(
		min_enemy_scale,
		max_enemy_scale
	)

	enemy.scale = Vector2.ONE * random_scale

	enemies_container.add_child(enemy)
	enemy.global_position = spawn_point.global_position

	enemy.died.connect(_on_enemy_died)


func _on_enemy_died(death_position: Vector2) -> void:
	if game_won:
		return

	spawn_loot(death_position)

	kills += 1

	print("Убито врагов: ", kills, "/", target_kills)

	if kills >= target_kills:
		win_game()
		return

	await get_tree().create_timer(respawn_delay).timeout

	if not game_won:
		spawn_enemy()


func win_game() -> void:
	game_won = true

	print("YOU WON!")

	win_screen.show()


func spawn_loot(death_position: Vector2) -> void:
	if randf() > loot_drop_chance:
		return

	if world_item_scene == null:
		push_warning("WorldItem Scene не назначена!")
		return

	if loot_items.is_empty():
		push_warning("Список предметов для выпадения пуст!")
		return

	var selected_item: EquipItemData = loot_items.pick_random()

	if selected_item == null:
		return

	var world_item = world_item_scene.instantiate()

	world_item.item_data = selected_item.duplicate(true)

	var random_offset := Vector2(
		randf_range(-loot_spawn_radius, loot_spawn_radius),
		randf_range(-loot_spawn_radius, loot_spawn_radius)
	)

	call_deferred(
		"_add_world_item",
		world_item,
		death_position + random_offset
		)

	print("Выпал предмет: ", selected_item.display_name)
	
	
func _add_world_item(world_item: Node2D, spawn_position: Vector2) -> void:
	get_tree().current_scene.add_child(world_item)
	world_item.global_position = spawn_position
