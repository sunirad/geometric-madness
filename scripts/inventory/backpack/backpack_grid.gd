class_name BackpackGrid
extends RefCounted

signal item_placed(item: EquipItemData, origin: Vector2i)
signal item_removed(item: EquipItemData)

const COLUMNS: int = 15
const ROWS: int = 5

# Клетка сетки -> предмет, занимающий её (или null).
var _cells: Dictionary = {}
# Предмет -> его левый верхний угол (origin) в сетке.
var _origins: Dictionary = {}

func _init() -> void:
	for x in COLUMNS:
		for y in ROWS:
			_cells[Vector2i(x, y)] = null

# Возвращает предмет в клетке, либо null.
func get_item_at(cell: Vector2i) -> EquipItemData:
	return _cells.get(cell, null)

# Возвращает origin предмета, либо Vector2i(-1, -1), если предмета нет в сетке.
func get_origin(item: EquipItemData) -> Vector2i:
	return _origins.get(item, Vector2i(-1, -1))

# Проверяет, что прямоугольник помещается и все клетки свободны.
func can_place(item: EquipItemData, origin: Vector2i) -> bool:
	if item == null:
		return false
	if origin.x < 0 or origin.y < 0:
		return false
	if origin.x + item.grid_size.x > COLUMNS:
		return false
	if origin.y + item.grid_size.y > ROWS:
		return false
	for x in item.grid_size.x:
		for y in item.grid_size.y:
			var cell := origin + Vector2i(x, y)
			if _cells[cell] != null and _cells[cell] != item:
				return false
	return true

# Кладёт предмет в сетку. Возвращает true при успехе.
# Если предмет уже лежит в сетке — сначала снимает его со старых клеток.
func place(item: EquipItemData, origin: Vector2i) -> bool:
	if not can_place(item, origin):
		return false
	# Если предмет уже был размещён — очищаем старые клетки (перемещение).
	if _origins.has(item):
		_clear_cells(item)
	_occupy_cells(item, origin)
	_origins[item] = origin
	item_placed.emit(item, origin)
	return true

# Убирает предмет из сетки. Возвращает true, если он там был.
func remove(item: EquipItemData) -> bool:
	if not _origins.has(item):
		return false
	_clear_cells(item)
	_origins.erase(item)
	item_removed.emit(item)
	return true

# --- Внутренняя логика ---

func _occupy_cells(item: EquipItemData, origin: Vector2i) -> void:
	for x in item.grid_size.x:
		for y in item.grid_size.y:
			_cells[origin + Vector2i(x, y)] = item

func _clear_cells(item: EquipItemData) -> void:
	for cell in _cells.keys():
		if _cells[cell] == item:
			_cells[cell] = null
			
# Возвращает массив всех предметов в рюкзаке.
func get_all_items() -> Array:
	return _origins.keys()
