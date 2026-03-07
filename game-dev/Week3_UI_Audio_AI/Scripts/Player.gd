extends CharacterBody3D

# Movement variables
var speed = 5.0
var sprint_speed = 8.0
var jump_velocity = 5.0
var gravity = 10.0
var current_speed = 5.0

# Attack variables
var can_attack = true
var attack_cooldown = 0.5

# Health variables
var max_health = 100
var current_health = 100

# Footstep timing
var footstep_timer = 0.0
var footstep_interval = 0.4

# UI references
@onready var health_bar = get_node("/root/Week3_Main/UI/HealthBar")
@onready var score_label = get_node("/root/Week3_Main/UI/ScoreLabel")
@onready var audio_player = $AudioStreamPlayer3D

# SOUND FILES - Preload all your sounds
var footstep_sound = preload("res://Week3_UI_Audio_AI/Audio/footstep.wav")
var jump_sound = preload("res://Week3_UI_Audio_AI/Audio/jump.wav")
var slash_sound = preload("res://Week3_UI_Audio_AI/Audio/slash.ogg")
var hit_sound = preload("res://Week3_UI_Audio_AI/Audio/hit.wav")
var hurt_sound = preload("res://Week3_UI_Audio_AI/Audio/hurt.mp3")
var death_sound = preload("res://Week3_UI_Audio_AI/Audio/death.wav")

func _ready():
	print("Player ready! Health: ", current_health)
	update_health_bar()

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Sprint with Shift
	current_speed = sprint_speed if Input.is_key_pressed(KEY_SHIFT) else speed
	
	# Movement input
	var input_dir = Vector3.ZERO
	if Input.is_action_pressed("move_forward"): input_dir.z -= 1
	if Input.is_action_pressed("move_back"): input_dir.z += 1
	if Input.is_action_pressed("move_left"): input_dir.x -= 1
	if Input.is_action_pressed("move_right"): input_dir.x += 1
	
	input_dir = input_dir.normalized()
	var direction = (transform.basis * input_dir).normalized()
	
	# Check if moving for footsteps
	var is_moving = direction.length() > 0 and is_on_floor()
	
	if is_moving:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
		# Footstep sounds
		footstep_timer += delta
		if footstep_timer >= footstep_interval:
			footstep_timer = 0.0
			play_sound(footstep_sound, -5)  # Quieter footsteps
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		footstep_timer = footstep_interval  # Reset timer when stopped
	
	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		play_sound(jump_sound)
	
	move_and_slide()
	
	# Attack with mouse click
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_attack:
		attack()

func attack():
	can_attack = false
	print("ATTACK!")
	play_sound(slash_sound)
	
	# Check for enemies in front
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, global_position - transform.basis.z * 3)
	query.collision_mask = 2  # Enemy layer
	var result = space_state.intersect_ray(query)
	
	if result:
		var enemy = result.collider
		if enemy.has_method("take_damage"):
			enemy.take_damage(25)
			play_sound(hit_sound)
	
	# Attack cooldown
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func take_damage(amount):
	current_health -= amount
	print("Player took ", amount, " damage! Health: ", current_health)
	play_sound(hurt_sound)
	update_health_bar()
	
	if current_health <= 0:
		die()

func die():
	print("PLAYER DIED!")
	play_sound(death_sound)
	# Reset game logic here
	await get_tree().create_timer(2.0).timeout
	current_health = max_health
	position = Vector3(0, 1, 0)
	update_health_bar()

func update_health_bar():
	if health_bar:
		health_bar.value = current_health

# Updated play_sound function that uses actual sound files
func play_sound(sound, volume_db = 0):
	if audio_player and sound:
		audio_player.stream = sound
		audio_player.volume_db = volume_db
		audio_player.play()
	else:
		print("Sound not available: ", sound)
