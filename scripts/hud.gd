extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var lives_label = $LivesLabel
@onready var pause_label = $PauseLabel
@onready var win_panel = $WinPanel
@onready var final_score_label = $WinPanel/FinalScore
@onready var back_button = $WinPanel/BackButton
@onready var death_panel = $DeathPanel
@onready var death_score_label = $DeathPanel/DeathVBox/DeathFinalScore
@onready var retry_button = $DeathPanel/DeathVBox/RetryButton

var is_paused = false

func _ready():
	win_panel.visible = false
	back_button.pressed.connect(_on_back_pressed)
	retry_button.pressed.connect(_on_retry_pressed)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()

func _toggle_pause():
	is_paused = !is_paused
	get_tree().paused = is_paused
	pause_label.visible = is_paused

func update_score(value):
	score_label.text = str(value)

func update_lives(value):
	lives_label.text = str(value)

func show_win(final_score):
	get_tree().paused = true
	final_score_label.text = "Puntaje Final: " + str(final_score)
	win_panel.visible = true

func show_death(final_score):
	get_tree().paused = true
	death_score_label.text = "Puntaje Final: " + str(final_score)
	death_panel.visible = true

func _on_back_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_retry_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/world.tscn")
