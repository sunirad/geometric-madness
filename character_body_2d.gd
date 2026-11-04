extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var bite: AudioStreamPlayer2D = $bite
@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var hitbox: Area2D = $WeaponPivot/Hitbox
@onready var sword_sprite: Sprite2D = $WeaponPivot/SwordSprite
@export var weapon_orbit_radius: float = 35.0
const SPEED = 300.0
const ATTACK_TIME = 0.3
var last_direction : Vector2 = Vector2.RIGHT
var is_attacking: bool = false

func _ready() -> void:
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	hitbox.monitoring = false 

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()
		
	process_movement()
	process_animation()
	
	if not is_attacking:
		rotate_weapon_to_mouse()
		
	move_and_slide()

func process_movement() -> void: 
	var direction := Input.get_vector("left","right","up","down")
	var current_speed = SPEED * (0.3 if is_attacking else 1.0)
	
	if direction != Vector2.ZERO:
		velocity = direction * current_speed
		last_direction = direction
	else: 
		velocity = Vector2.ZERO

func process_animation() -> void:
	if is_attacking:
		return
	if velocity != Vector2.ZERO:
		play_animation("move", last_direction)
	else: 
		play_animation("idle", last_direction)	
		
func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		animated_sprite_2d.flip_h = dir.x < 0
	animated_sprite_2d.play(prefix)

func rotate_weapon_to_mouse() -> void:
	var mouse_pos = get_global_mouse_position()

	# Направление от персонажа к мышке
	var direction = to_local(mouse_pos)

	if direction.length_squared() == 0:
		return

	# Перемещаем рукоять по орбите
	weapon_pivot.position = direction.normalized() * weapon_orbit_radius

	# Направляем меч на мышку
	weapon_pivot.rotation = direction.angle()

func attack() -> void:
	is_attacking = true
	bite.play()
	animated_sprite_2d.play("attack")
	
	rotate_weapon_to_mouse()
	
	var base_angle = weapon_pivot.rotation
	
	hitbox.monitoring = true 
	
	var tween = create_tween()
	tween.tween_property(weapon_pivot, "rotation", base_angle - 1.04, 0.05)
	tween.tween_property(weapon_pivot, "rotation", base_angle + 1.04, 0.1)
	tween.tween_property(weapon_pivot, "rotation", base_angle, 0.15)
	
	await tween.finished
	
	hitbox.monitoring = false
	is_attacking = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and is_attacking:
		body.take_damage(10)
