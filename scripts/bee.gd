extends Area2D

const SPEED = 30.0
const PATROL_RANGE = 20.0
var direction = 1
var dead = false
var start_x = 0.0

@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready():
	start_x = position.x

func _physics_process(delta):
	if dead:
		return
	position.x += direction * SPEED * delta
	
	if position.x > start_x + PATROL_RANGE:
		direction = -1
	elif position.x < start_x - PATROL_RANGE:
		direction = 1
	
	if direction > 0:
		animated_sprite_2d.flip_h = false
	else:
		animated_sprite_2d.flip_h = true


func die():
	if dead:
		return
	dead = true
	$CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(0.4).timeout
	queue_free()
