extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const FRICTION = 25
const HORIZONTAL_ACCELERATION = 30
const MAX_SPEED = 5

# Get the gravity from the project settings
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera = $Camera3D

# Camera position - FIXED in world space
var camera_position_fixed = Vector3(0, 5, 10)  # X, Y, Z fixed position

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Position camera at fixed location
	camera.global_position = camera_position_fixed
	
	# Make camera look at player
	camera.look_at(global_position, Vector3.UP)

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * .005)
		# Camera doesn't move with mouse now

func _unhandled_key_input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: 
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		velocity.y += JUMP_VELOCITY

	# --- FIXED MOVEMENT CODE - ALL DIRECTIONS WORK ---
	# Get input for all 4 directions
	var input_dir = Vector3.ZERO
	
	# Forward/Backward (Z axis)
	if Input.is_action_pressed("move_back"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_forward"):
		input_dir.z += 1
	
	# Left/Right (X axis)
	if Input.is_action_pressed("move_right"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_left"):
		input_dir.x += 1
	
	# Normalize for diagonal movement (so you don't go faster diagonally)
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
	
	# Convert to world direction based on player rotation
	var direction = (transform.basis * input_dir).normalized()
	direction *= SPEED
	
	# Apply movement with acceleration
	velocity.x = move_toward(velocity.x, direction.x, HORIZONTAL_ACCELERATION * delta)
	velocity.z = move_toward(velocity.z, direction.z, HORIZONTAL_ACCELERATION * delta)
	# --- END OF FIXED MOVEMENT CODE ---

	var angle = 5
	var t = delta * 6
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: 
		rotation_degrees = rotation_degrees.lerp(Vector3(input_dir.normalized().y * angle, rotation_degrees.y, -input_dir.normalized().x * angle), t)
	  
		move_and_slide()
	force_update_transform()
	
	# Keep camera looking at player (but don't move it)
	camera.look_at(global_position, Vector3.UP)
