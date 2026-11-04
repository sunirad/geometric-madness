extends CharacterBody2D

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
		
	print("Distance: ", distance)
	print("In attack range: ", distance <= ATTACK_RANGE)
	print("Can attack (cooldown): ", can_attack)
	move_and_slide()


func attack() -> void:
	print("ENEMY ATTACK!")
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
	print("Обнаружен объект: ", body.name)

	if body.is_in_group("player"):
		player = body
		current_state = State.CHASE
		print("ИГРОК ОБНАРУЖЕН!")


func _on_detection_body_exited(body: Node2D) -> void:
	if body == player:
		player = null


func _on_attack_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and is_attacking:
		body.take_damage(ATTACK_DAMAGE)
		
func take_damage(amount: int) -> void:
	if is_dead:
		return

	health -= amount
	print("Enemy HP: ", health, "/", max_health)

	if health <= 0:
		die()
		
func die() -> void:
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO

	# Отключаем физику и обнаружение
	set_physics_process(false)
	set_process(false)
	detection_area.set_deferred("monitoring", false)
	attack_area.set_deferred("monitoring", false)
	$CollisionShape2D.set_deferred("disabled", true)

	 # Проигрываем смерть один раз
	animated_sprite.play("death")

	# Ждём завершения анимации
	await animated_sprite.animation_finished

	# Оставляем труп на 15 секунд
	await get_tree().create_timer(15.0).timeout

	# Удаляем врага
	queue_free()
