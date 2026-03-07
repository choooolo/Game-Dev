extends CharacterBody3D

# Enemy states
enum State { PATROL, CHASE, ATTACK }
var current_state = State.PATROL

# Movement
var speed = 2.0
var gravity = 10.0

# Patrol points
var patrol_points = []
var current_patrol_index = 0
var patrol_range = 5.0

# Chase variables
var player = null
var chase_speed = 3.5

# Attack variables
var attack_damage = 15
var attack_cooldown = 1.0
var can_attack = true

# Health
var max_health = 50
var current_health = 50

@onready var detection_area = $DetectionArea
@onready var audio_player = $AudioStreamPlayer3D

# SOUND FILES - Preload enemy sounds
var enemy_hit_sound = preload("res://Week3_UI_Audio_AI/Audio/hit.wav")  # Using same hit.wav
var enemy_attack_sound = preload("res://Week3_UI_Audio_AI/Audio/hit.wav")
var enemy_death_sound = preload("res://Week3_UI_Audio_AI/Audio/death.wav")  # Using same death.wav

func _ready():
	# Set up patrol points
	patrol_points = [
		global_position + Vector3(3, 0, 0),
		global_position + Vector3(-3, 0, 0),
		global_position + Vector3(0, 0, 3),
		global_position + Vector3(0, 0, -3)
	]
	
	# Connect detection signals
	detection_area.body_entered.connect(_on_player_detected)
	detection_area.body_exited.connect(_on_player_lost)

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	match current_state:
		State.PATROL:
			patrol(delta)
		State.CHASE:
			chase(delta)
		State.ATTACK:
			attack_player(delta)
	
	move_and_slide()

func patrol(delta):
	var target = patrol_points[current_patrol_index]
	var direction = (target - global_position).normalized()
	direction.y = 0
	
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	# Rotate to face movement
	if direction.length() > 0:
		look_at(global_position + direction, Vector3.UP)
	
	# Check if reached patrol point
	if global_position.distance_to(target) < 1.0:
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()

func chase(delta):
	if not player:
		current_state = State.PATROL
		return
	
	var direction = (player.global_position - global_position).normalized()
	direction.y = 0
	
	velocity.x = direction.x * chase_speed
	velocity.z = direction.z * chase_speed
	
	# Rotate to face player
	look_at(player.global_position, Vector3.UP)
	
	# Check if in attack range
	if global_position.distance_to(player.global_position) < 2.0:
		current_state = State.ATTACK

func attack_player(delta):
	if not player:
		current_state = State.PATROL
		return
	
	# Stop moving
	velocity.x = 0
	velocity.z = 0
	
	# Face player
	look_at(player.global_position, Vector3.UP)
	
	# Attack if cooldown is ready
	if can_attack and global_position.distance_to(player.global_position) < 2.5:
		perform_attack()

func perform_attack():
	can_attack = false
	print("Enemy attacks!")
	play_sound(enemy_attack_sound)
	
	if player:
		player.take_damage(attack_damage)
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _on_player_detected(body):
	if body.is_in_group("player") or body.name == "Player":
		player = body
		current_state = State.CHASE
		print("Enemy detected player!")

func _on_player_lost(body):
	if body == player:
		player = null
		current_state = State.PATROL
		print("Enemy lost player")

func take_damage(amount):
	current_health -= amount
	print("Enemy took ", amount, " damage! Health: ", current_health)
	play_sound(enemy_hit_sound)
	
	if current_health <= 0:
		die()

func die():
	print("Enemy defeated!")
	play_sound(enemy_death_sound)
	
	# Add score to player
	var ui = get_node("/root/Week3_Main/UI")
	if ui and ui.has_method("add_score"):
		ui.add_score(100)
	
	queue_free()

# Updated play_sound function for enemy
func play_sound(sound, volume_db = 0):
	if audio_player and sound:
		audio_player.stream = sound
		audio_player.volume_db = volume_db
		audio_player.play()
	else:
		print("Enemy sound not available")
