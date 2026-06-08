extends CharacterBody2D


const SPEED = 20.0
var direction = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var dead = false


func _physics_process(delta):
	if dead:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	velocity.x = direction * SPEED

	move_and_slide()
	
	# check wall collisions
	if $RayCast2D.is_colliding():
		direction *= -1
	
	# update raycast direction
	$RayCast2D.target_position.x = 20 * direction
	
	# change sprite direction
	if direction > 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false


func die():
	if dead:
		return
	dead = true
	$CollisionShape2D.set_deferred("disabled", true)
	$RayCast2D.enabled = false
	$AnimatedSprite2D.play("death")
	await $AnimatedSprite2D.animation_finished
	queue_free()
