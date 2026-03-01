extends CharacterBody3D

var speed = 7.0
var jump_velocity = 4.0
var gravity = 9.8
var should_reset = false  # Add this flag

func _physics_process(delta):
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump (Space bar)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		print("JUMP!")

	# AUTO-RUN FORWARD - but only if not resetting
	if not should_reset:
		velocity.z = speed
	else:
		velocity.z = 0
		should_reset = false

	# Left/Right movement
	var horizontal = 0.0
	
	if Input.is_action_pressed("move_right"):
		horizontal -= 1
	if Input.is_action_pressed("move_left"):
		horizontal += 1
	
	velocity.x = horizontal * 3.0

	move_and_slide()

# Add this function to be called from LevelManager
func reset_position():
	print("Player resetting position")
	position = Vector3(0, 1, 0)
	velocity = Vector3.ZERO
	should_reset = true
