extends Area2D

@export var damage: int = 10

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var hit_targets: Array[Node2D] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)

	animated_sprite.play("small_explosions")

	await get_tree().physics_frame

	for body in get_overlapping_bodies():
		damage_enemy(body)


func _on_body_entered(body: Node2D) -> void:
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


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
