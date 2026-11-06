@tool
extends Control

@export var fill_color: Color = Color.RED

var _current_value: int = 100
var _max_value: int = 100

func update_value(current: int, maximum: int) -> void:
	_current_value = current
	_max_value = maximum
	queue_redraw()

func _draw() -> void:
	var center = size / 2.0
	var radius = min(size.x, size.y) / 2.0

	if radius <= 0.0:
		return

	# Темный фон сферы
	draw_circle(center, radius, Color(0.1, 0.1, 0.1, 0.9))

	# Рассчитываем заполнение
	var ratio := 0.0

	if _max_value > 0:
		ratio = clampf(
			float(_current_value) / float(_max_value),
			0.0,
			1.0
		)

	# Полностью заполненная сфера
	if ratio >= 0.999:
		draw_circle(center, radius, fill_color)

	# Частично заполненная сфера
	elif ratio > 0.001:
		var fill_height = radius * 2.0 * ratio
		var y_start = center.y + radius - fill_height
		var y_end = center.y + radius

		# Рисуем жидкость горизонтальными полосами
		var step = 2.0
		var y = y_start

		while y < y_end:
			var row_y = y + step / 2.0
			var dy = row_y - center.y

			var inside = radius * radius - dy * dy

			if inside > 0.0:
				var half_width = sqrt(inside)

				draw_rect(
					Rect2(
						Vector2(center.x - half_width, y),
						Vector2(half_width * 2.0, step + 0.5)
					),
					fill_color
				)

			y += step

	# Черная рамка
	draw_arc(
		center,
		radius,
		0.0,
		TAU,
		64,
		Color.BLACK,
		4.0,
		true
	)
