extends CharacterBody2D
signal died
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea
@export var max_health: int = 30
const SPEED = 100.0
const ATTACK_RANGE = 55.0
const ATTACK_DAMAGE = 10
var health: int = 30
var is_dead: bool = false
var player: CharacterBody2D = null
var is_attacking: bool = false
var can_attack: bool = true

enum State {
	IDLE,
	CHASE,
	ATTACK
}

var current_state: State = State.IDLE


func _ready() -> void:
	health = max_health
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)

	attack_area.body_entered.connect(_on_attack_body_entered)

	attack_area.monitoring = false


func _physics_process(_delta: float) -> void:
	if player == null or not is_instance_valid(player):
		current_state = State.IDLE
		velocity = Vector2.ZERO
		animated_sprite.play("idle")
		move_and_slide()
		return

	var direction = global_position.direction_to(
		player.global_position
	)

	# Поворачиваемся к игроку
	if direction.x != 0:
		animated_sprite.flip_h = direction.x < 0

	var distance = global_position.distance_to(
		player.global_position
	)

	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Определяем состояние
	if distance <= ATTACK_RANGE and can_attack:
		current_state = State.ATTACK
		attack()
		return

	if distance > ATTACK_RANGE:
		current_state = State.CHASE
		velocity = direction * SPEED
		animated_sprite.play("move")
	else:
		current_state = State.IDLE
		velocity = Vector2.ZERO
		animated_sprite.play("idle")
		
	move_and_slide()


func attack() -> void:
	if is_attacking or not can_attack:
		return

	is_attacking = true
	can_attack = false
	current_state = State.ATTACK

	velocity = Vector2.ZERO

	animated_sprite.play("attack")

	# Направляем хитбокс к игроку
	var direction = (
	player.global_position - global_position
).normalized()

	attack_area.position = direction * 22.0
	attack_area.rotation = direction.angle()

	# Небольшая задержка перед попаданием
	await get_tree().create_timer(0.15).timeout

	if not is_instance_valid(self):
		return

	attack_area.monitoring = true

	# Активное окно удара
	await get_tree().create_timer(0.2).timeout

	if not is_instance_valid(self):
		return

	attack_area.monitoring = false

	# Завершение атаки
	await get_tree().create_timer(0.15).timeout

	if not is_instance_valid(self):
		return

	is_attacking = false

	# Перезарядка
	await get_tree().create_timer(0.7).timeout

	if not is_instance_valid(self):
		return

	can_attack = true


func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		current_state = State.CHASE


func _on_detection_body_exited(body: Node2D) -> void:
	if body == player:
		player = null


func _on_attack_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and is_attacking:
		body.take_damage(ATTACK_DAMAGE)
		
func take_damage(amount: int) -> void:
	if is_dead:
		return

	print("--------------------------------")
	print("ENEMY: ", name)
	print("DAMAGE RECEIVED: ", amount)
	print("HP BEFORE: ", health)
	print("HP AFTER: ", health - amount)
	print("TIME: ", Time.get_ticks_msec())
	print("--------------------------------")

	health -= amount

	if health <= 0:
		die()
		
func die() -> void:
	if is_dead:
		return

	is_dead = true
	died.emit()

	velocity = Vector2.ZERO
	set_physics_process(false)

	$CollisionShape2D.set_deferred("disabled", true)

	if has_node("DetectionArea"):
		$DetectionArea.monitoring = false

	if has_node("AttackArea"):
		$AttackArea.monitoring = false

	animated_sprite.play("death")
	await animated_sprite.animation_finished

	await get_tree().create_timer(15.0).timeout

	queue_free()
