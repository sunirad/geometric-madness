extends Node

# ============================================================
# Скрипт главной сцены. Связывает PlayerStats с игроком.
# ============================================================

@export var player_stats_node: PlayerStats

func _ready() -> void:
	# Ждем два кадра, чтобы LevelRoot точно загрузился
	await get_tree().process_frame
	await get_tree().process_frame
	link_player_stats()

func link_player_stats() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		push_warning("Main: Игрок не найден в группе 'player'!")
		return
		
	var player = players[0]
	
	if not player_stats_node:
		push_warning("Main: player_stats_node не назначен в инспекторе!")
		return
		
	# Передаем ссылку на ресурс данных игроку
	player.player_stats = player_stats_node
