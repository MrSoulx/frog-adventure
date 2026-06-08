extends Area2D

@onready var animated_sprite_2d = $AnimatedSprite2D

var dead = false

func _on_detection_zone_body_entered(body):
	if dead:
		return
	if body.has_method("take_damage"):
		animated_sprite_2d.play("attack")

func _on_detection_zone_body_exited(body):
	if dead:
		return
	if body.has_method("take_damage"):
		animated_sprite_2d.play("idle")

func die():
	if dead:
		return
	dead = true
	$CollisionShape2D.set_deferred("disabled", true)
	$DetectionZone/CollisionShape2D.set_deferred("disabled", true)
	animated_sprite_2d.play("attack")
	await get_tree().create_timer(0.6).timeout
	queue_free()
