extends CharacterBody2D

const SPEED = 250.0
const MAX_DISTANCE = 15.0
var direction = 1
var player = null
var start_x = 0.0
var stopped = false

func _ready():
	start_x = global_position.x
	$Timer.timeout.connect(queue_free)
	$Hitbox.body_entered.connect(_on_hit)
	$Hitbox.area_entered.connect(_on_hit)

func _physics_process(_delta):
	if stopped:
		return
	velocity.x = direction * SPEED
	move_and_slide()
	if get_slide_collision_count() > 0:
		queue_free()
	if abs(global_position.x - start_x) >= MAX_DISTANCE:
		stopped = true
		velocity.x = 0

func _on_hit(target):
	if is_queued_for_deletion():
		return
	if target.has_method("die"):
		target.die()
	elif target.is_in_group("enemies"):
		target.queue_free()
	else:
		return
	if player and player.has_method("add_score"):
		player.add_score(1)
	queue_free()
