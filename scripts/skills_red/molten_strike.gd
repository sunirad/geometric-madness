extends Area2D

@export var damage: int = 20
@export var small_explosion_scene: PackedScene
@export var small_explosion_count: int = 5
@export var spread_radius: float = 80.0

var hit_targets: Array[Node2D] = []
var explosion_finished: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)

	animated_sprite.play("molten_strike")

	await get_tree().physics_frame

	for body in get_overlapping_bodies():
		damage_enemy(body)

	await get_tree().create_timer(0.25).timeout

	spawn_small_explosions()

	# После первичного удара больше не принимаем новых целей
	explosion_finished = true
	monitoring = false


func _on_body_entered(body: Node2D) -> void:
	if explosion_finished:
		return

	damage_enemy(body)


func damage_enemy(body: Node2D) -> void:
	if not body.is_in_group("enemy"):
		return

	if body in hit_targets:
		return

	if not body.has_method("take_damage"):
		return

	hit_targets.append(body)
	body.take_damage(damage)


func spawn_small_explosions() -> void:
	if small_explosion_scene == null:
		return

	for i in range(small_explosion_count):
		var small_explosion = small_explosion_scene.instantiate()

		var angle = randf_range(0.0, TAU)
		var distance = randf_range(20.0, spread_radius)
		var offset = Vector2.RIGHT.rotated(angle) * distance

		get_tree().current_scene.add_child(small_explosion)
		small_explosion.global_position = global_position + offset


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
