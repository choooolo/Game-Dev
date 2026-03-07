extends CanvasLayer

@onready var health_bar = $HealthBar
@onready var health_label = $HealthLabel
@onready var score_label = $ScoreLabel
@onready var pause_menu = $PauseMenu
@onready var intro_label = $IntroLabel

var score = 0
var intro_showing = true

func _ready():
	# Original UI setup
	update_health_display(100, 100)
	update_score(0)
	
	# Make sure pause menu starts hidden
	if pause_menu:
		pause_menu.visible = false
	
	# Intro setup
	intro_showing = true
	
	if intro_label:
		intro_label.visible = true
		intro_label.text = "PRESS SPACE OR ENTER TO START"
	
	# PAUSE the game to stop enemies
	get_tree().paused = true
	
	# But we need this UI to still process input
	process_mode = PROCESS_MODE_ALWAYS

func _process(delta):
	# Always check for intro input when showing
	if intro_showing:
		check_intro_input()
	else:
		# Game is running normally
		if Input.is_action_just_pressed("ui_cancel"):
			toggle_pause()

func _input(event):
	# Extra input checking
	if intro_showing:
		check_intro_input()

func check_intro_input():
	# Check if any start key is pressed
	if Input.is_action_just_pressed("ui_accept") or \
	   Input.is_key_pressed(KEY_SPACE) or \
	   Input.is_key_pressed(KEY_ENTER):
		print("Start key detected!")
		dismiss_intro()

func dismiss_intro():
	print("Dismissing intro - starting game")
	intro_showing = false
	
	if intro_label:
		intro_label.visible = false
	
	# UNPAUSE the game to let enemies move
	get_tree().paused = false

func update_health_display(current, max_hp):
	if health_bar:
		health_bar.value = current
	if health_label:
		health_label.text = "HP: " + str(current) + "/" + str(max_hp)

func update_score(new_score):
	score = new_score
	if score_label:
		score_label.text = "Score: " + str(score)

func add_score(amount):
	score += amount
	update_score(score)

func toggle_pause():
	if pause_menu:
		pause_menu.visible = !pause_menu.visible
		get_tree().paused = pause_menu.visible

func _on_resume_button_pressed():
	toggle_pause()
