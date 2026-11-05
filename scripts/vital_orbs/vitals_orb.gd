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
	
	# 1. Темный фон
	draw_circle(center, radius, Color(0.1, 0.1, 0.1, 0.9))
	
	# 2. Процент
	var ratio = 0.0
	if _max_value > 0:
		ratio = clamp(float(_current_value) / float(_max_value), 0.0, 1.0)
	
	# 3. Заливка
	if ratio > 0.0:
		var points: PackedVector2Array = []
		var segments = 32
		
		# Если шар полный - просто заливаем весь круг
		if ratio >= 0.999:
			draw_circle(center, radius, fill_color)
		else:
			# Координата Y ровной линии (уровень жидкости)
			var fill_height = radius * 2.0 * ratio
			var y_offset = center.y + radius - fill_height
			
			# Находим X координаты на круге для этого Y
			# Уравнение окружности: (x - cx)^2 + (y - cy)^2 = r^2
			# x = cx +- sqrt(r^2 - (y - cy)^2)
			var dy = y_offset - center.y
			var dx = sqrt(max(0.0, radius * radius - dy * dy))
			
			var left_x = center.x - dx
			var right_x = center.x + dx
			
			# Начинаем полигон с левого верхнего угла (на линии жидкости)
			points.append(Vector2(left_x, y_offset))
			points.append(Vector2(right_x, y_offset))
			
			# Теперь идем по нижней дуге круга от правого края к левому
			# Угол правого края на линии жидкости
			var start_angle = atan2(dy, dx) 
			# Нам нужна дуга снизу, поэтому идем по часовой стрелке (от start_angle до PI - start_angle)
			var end_angle = PI - start_angle
			
			for i in range(segments + 1):
				var angle = lerp(start_angle, end_angle, float(i) / segments)
				var p = center + Vector2(cos(angle), sin(angle)) * radius
				points.append(p)
				
			draw_colored_polygon(points, fill_color)
			
	# 4. Рамка
	draw_arc(center, radius, 0, TAU, 64, Color.BLACK, 4.0, true)
