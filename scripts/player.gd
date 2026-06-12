extends CharacterBody2D

const SPEED = 110.0
const JUMP_VELOCITY = -200.0
var gravity = 300

@onready var animated_sprite_2d = $AnimatedSprite2D

var shuriken_scene = preload("res://scenes/shuriken.tscn")
var can_shoot = true

var score = 0
var lives = 3:
	set(value):
		lives = value
		var gui = _get_hud()
		if gui:
			gui.update_lives(lives)
var is_hurt = false

func _get_hud():
	return get_tree().get_first_node_in_group("hud")

func _physics_process(delta):
	if is_hurt:
		if not is_on_floor():
			velocity.y += gravity * delta
		velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_axis = Input.get_axis("ui_left", "ui_right")
	if input_axis:
		velocity.x = input_axis * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	_check_overlaps()
	_handle_shoot()
	update_animations(input_axis)

func _handle_shoot():
	if Input.is_action_just_pressed("shoot") and can_shoot:
		can_shoot = false
		var s = shuriken_scene.instantiate()
		s.direction = -1 if animated_sprite_2d.flip_h else 1
		s.global_position = global_position + Vector2(20 * s.direction, 0)
		s.player = self
		get_parent().add_child(s)
		await get_tree().create_timer(0.4).timeout
		can_shoot = true

func _check_overlaps():
	var areas = $Hitbox.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("star"):
			add_score(5)
			area.queue_free()
			var gui = _get_hud()
			if gui:
				gui.show_win(score)
			return
		if area.is_in_group("pickups"):
			add_score(1)
			area.queue_free()
		elif area.is_in_group("enemies"):
			_check_enemy_collision(area)
	
	var bodies = $Hitbox.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			_check_enemy_collision(body)

func update_animations(input_axis):
	if is_hurt:
		return
	if input_axis < 0:
		animated_sprite_2d.flip_h = true
	elif input_axis > 0:
		animated_sprite_2d.flip_h = false
	if is_on_floor():
		if input_axis != 0:
			animated_sprite_2d.play("run")
		else:
			animated_sprite_2d.play("idle")
	else:
		animated_sprite_2d.play("jump")

func add_score(amount):
	score += amount
	var gui = _get_hud()
	if gui:
		gui.update_score(score)

func take_damage():
	if is_hurt:
		return
	lives -= 1
	print("Lives: ", lives)
	if lives <= 0:
		var gui = _get_hud()
		if gui:
			gui.show_death(score)
		return
	is_hurt = true
	animated_sprite_2d.play("hurt")
	velocity.y = JUMP_VELOCITY * 0.5
	await get_tree().create_timer(0.5).timeout
	is_hurt = false

func _on_hitbox_area_entered(area):
	print("area_entered: ", area.name, " groups: ", area.get_groups())
	if area.is_in_group("star"):
		add_score(5)
		area.queue_free()
		var gui = _get_hud()
		if gui:
			gui.show_win(score)
		return
	if area.is_in_group("pickups"):
		add_score(1)
		area.queue_free()
	elif area.is_in_group("enemies"):
		_check_enemy_collision(area)

func _on_hitbox_body_entered(body):
	if body.is_in_group("enemies"):
		_check_enemy_collision(body)

func _check_enemy_collision(enemy):
	if global_position.y + 18 < enemy.global_position.y:
		if enemy.has_method("die"):
			enemy.die()
		else:
			enemy.queue_free()
		add_score(3)
		velocity.y = JUMP_VELOCITY * 0.5
	else:
		take_damage()
