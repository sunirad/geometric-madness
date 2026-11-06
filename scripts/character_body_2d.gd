extends CharacterBody2D

@export var explosion_scene: PackedScene
@export var explosion_distance: float = 150.0
@export var player_stats: PlayerStats
@export var weapon_orbit_radius: float = 35.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var hitbox: Area2D = $WeaponPivot/Hitbox
@onready var sword_sprite: Sprite2D = $WeaponPivot/SwordSprite

const BASE_SPEED: float = 300.0
const BASE_ATTACK_TIME: float = 0.3

var physical_damage_multiplier: float = 1.0
var max_health_increase: float = 1.0
var movement_speed_multiplier: float = 1.0
var attack_speed_multiplier: float = 1.0
var critical_chance: float = 0.05
var critical_multiplier: float = 2.0
var magic_damage_multiplier: float = 1.0

var last_direction : Vector2 = Vector2.RIGHT
var is_attacking: bool = false
var hit_targets: Array[Node2D] = []
var _attack_tween: Tween = null
var _current_skill: SkillData = null # <-- Храним скилл, которым бьем

func _enter_tree() -> void:
	add_to_group("player")

func _ready() -> void:
	hitbox.monitoring = false

	if not player_stats:
		var stats_nodes = get_tree().get_nodes_in_group("player_stats")
		if stats_nodes.size() > 0:
			player_stats = stats_nodes[0]

	if player_stats and player_stats.stats:
		player_stats.stats.stats_changed.connect(_recalculate_attributes)
		_recalculate_attributes()

func _physics_process(_delta: float) -> void:
	if get_tree().paused:
		return
		
	process_movement()
	process_animation()
	
	if not is_attacking:
		rotate_weapon_to_mouse()
		
	move_and_slide()

func process_movement() -> void:
	var direction := Input.get_vector("left", "right", "up", "down")

	var current_speed = BASE_SPEED * movement_speed_multiplier

	if is_attacking:
		current_speed *= 0.3

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
	var direction = to_local(mouse_pos)

	if direction.length_squared() == 0:
		return

	weapon_pivot.position = direction.normalized() * weapon_orbit_radius
	weapon_pivot.rotation = direction.angle()

# Добавили параметр skill_data
func attack(skill_data: SkillData = null) -> void:
	if get_tree().paused:
		return
	if is_attacking:
		return
		
	_current_skill = skill_data # Запоминаем, каким скиллом бьем
	
	hit_targets.clear()
	is_attacking = true
	animated_sprite_2d.play("attack")

	rotate_weapon_to_mouse()

	var base_angle = weapon_pivot.rotation
	hitbox.monitoring = true

	_attack_tween = create_tween()
	_attack_tween.tween_property(weapon_pivot, "rotation", base_angle - 1.04, 0.05)
	_attack_tween.tween_property(weapon_pivot, "rotation", base_angle + 1.04, 0.1)
	_attack_tween.tween_property(weapon_pivot, "rotation", base_angle, 0.15)

	var actual_attack_time = BASE_ATTACK_TIME / attack_speed_multiplier

	await get_tree().create_timer(actual_attack_time, false).timeout
	
	if not get_tree().paused:
		create_ground_explosion()
		hitbox.monitoring = false
		is_attacking = false
#При попадании:
func _on_hitbox_body_entered(body: Node2D) -> void:
	if not is_attacking:
		return

	if not body.is_in_group("enemy"):
		return

	if body in hit_targets:
		return

	if not body.has_method("take_damage"):
		return

	hit_targets.append(body)

	var damage: float = 0.0

	if _current_skill:
		damage = _current_skill.damage

		if _current_skill.damage_type == SkillData.DamageType.MAGICAL:
			damage *= magic_damage_multiplier
		else:
			damage *= physical_damage_multiplier

		if _current_skill.can_crit and randf() < critical_chance:
			damage *= critical_multiplier
			print("КРИТИЧЕСКИЙ УДАР!")

	body.take_damage(roundi(damage))
	
func die() -> void:
	print("Player died!")
	velocity = Vector2.ZERO
	set_physics_process(false)
	animated_sprite_2d.play("death")
	
func take_damage(amount: int) -> void:
	if not player_stats or not player_stats.stats:
		return
	player_stats.stats.current_health -= amount
	if player_stats.stats.current_health <= 0:
		die()
		
func create_ground_explosion() -> void:
	if explosion_scene == null: return
	var explosion = explosion_scene.instantiate()
	get_tree().current_scene.add_child(explosion)
	var direction = weapon_pivot.position.normalized()
	explosion.global_position = global_position + direction * explosion_distance


func _recalculate_attributes() -> void:
	if not player_stats or not player_stats.stats:
		return

	var stats = player_stats.stats

	var strength = stats.get_total_strength()
	var agility = stats.get_total_agility()
	var intelligence = stats.get_total_intelligence()

	physical_damage_multiplier = 1.0 + (strength - 10) * 0.02
	movement_speed_multiplier = 1.0 + (agility - 10) * 0.005
	attack_speed_multiplier = 1.0 + (agility - 10) * 0.01

	critical_chance = clampf(
		0.05 + (agility - 10) * 0.005,
		0.0,
		0.75
	)

	magic_damage_multiplier = 1.0 + (intelligence - 10) * 0.02

	print("Характеристики пересчитаны:")
	print("Сила: ", strength)
	print("Ловкость: ", agility)
	print("Интеллект: ", intelligence)
