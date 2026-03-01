extends CharacterBody3D

var speed = 7.0
var jump_velocity = 4.0
var gravity = 9.8

func _physics_process(delta):
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump (Space bar)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		print("JUMP!")

	# AUTO-RUN FORWARD
	velocity.z = speed  # This runs forward
	print("Running forward. Z position: ", position.z)

	# Left/Right movement with DEBUG
	var horizontal = 0.0
	
	if Input.is_action_pressed("move_right"):
		horizontal -= 1
		print("LEFT key detected!")  # See if this prints
	if Input.is_action_pressed("move_left"):
		horizontal += 1
		print("RIGHT key detected!")  # See if this prints
	
	velocity.x = horizontal * 3.0
	
	if horizontal != 0:
		print("Moving horizontally: ", horizontal)

	move_and_slide()
