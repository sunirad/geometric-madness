extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var bite: AudioStreamPlayer2D = $bite

const SPEED = 300.0
var last_direction : Vector2 = Vector2.RIGHT
const JUMP_VELOCITY = -400.0
var is_attacking: bool = false


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()
	if is_attacking:
		velocity *= 0.3
		return
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
	bite.play()
	play_animation("attack", last_direction)

func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false
