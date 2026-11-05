extends Node

# ============================================================
# Глобальный менеджер паузы (Autoload).
# Считает количество открытых окон. Если открыто хотя бы одно,
# игра ставится на паузу.
# Также перехватывает клавишу Esc для закрытия всех окон.
# ============================================================

var _open_ui_count: int = 0

func _ready() -> void:
	# Менеджер должен работать всегда, даже когда игра на паузе
	process_mode = Node.PROCESS_MODE_ALWAYS

# Вызывается окнами при открытии
func register_open() -> void:
	_open_ui_count += 1
	_update_pause()

# Вызывается окнами при закрытии
func register_close() -> void:
	_open_ui_count = max(0, _open_ui_count - 1)
	_update_pause()

# Обновляет состояние паузы в зависимости от количества окон
func _update_pause() -> void:
	get_tree().paused = _open_ui_count > 0

func _input(event: InputEvent) -> void:
	# Проверяем, что это нажатие клавиши (не зажатие, не отпускание)
	if event is InputEventKey and event.pressed and not event.echo:
		# Проверяем физический код клавиши Esc
		# Используем KEY_ESCAPE напрямую, чтобы UI-элементы не перехватывали ввод
		if event.keycode == KEY_ESCAPE:
			var any_closed = false
			
			# Проходимся по всем окнам, добавленным в группу closable_ui
			for ui_node in get_tree().get_nodes_in_group("closable_ui"):
				# Если окно открыто и умеет закрываться - закрываем
				if ui_node.has_method("is_open") and ui_node.is_open():
					ui_node.call("close")
					any_closed = true
			
			# Если мы что-то закрыли, помечаем ввод обработанным
			if any_closed:
				get_viewport().set_input_as_handled()
