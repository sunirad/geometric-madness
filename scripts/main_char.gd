extends CharacterBody2D

@onready var animated_sprite_2d_2: AnimatedSprite2D = $AnimatedSprite2D2
const SPEED = 300.0
var last_direction : Vector2 = Vector2.RIGHT
const JUMP_VELOCITY = -400.0
var is_attacking: bool = false


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		attack()
	process_movement()
	process_animation()
	move_and_slide()
	
	
func process_movement () -> void: 
	var direction := Input.get_vector("left","right","up","down")
	if direction!= Vector2.ZERO:
		velocity = direction * SPEED
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
		if dir.x!=0:
			animated_sprite_2d.flip_h = dir.x < 0
			animated_sprite_2d.play(prefix)
		elif dir.y>0:
			animated_sprite_2d.play(prefix)
		elif dir.y>0:
			animated_sprite_2d.play(prefix)
func attack() -> void:
	is_attacking = true
	play_animation("attack", last_direction)
