extends CharacterBody2D

# Player identifier (1 = Fireboy/Red, 2 = Watergirl/Blue)
@export var player_id = 1

# Movement speed
var speed = 200

# Movement keys based on player_id
var move_up = KEY_W
var move_down = KEY_S
var move_left = KEY_A
var move_right = KEY_D

# Colors
var player_colors = {
	1: Color(1, 0.3, 0.2),  # Red/Fireboy
	2: Color(0.2, 0.5, 1)    # Blue/Watergirl
}

func _ready():
	# Set different keys for each player
	if player_id == 1:
		# Player 1: WASD
		move_up = KEY_W
		move_down = KEY_S
		move_left = KEY_A
		move_right = KEY_D
	else:
		# Player 2: Arrow Keys
		move_up = KEY_UP
		move_down = KEY_DOWN
		move_left = KEY_LEFT
		move_right = KEY_RIGHT
	
	# Set color
	var sprite = $Sprite2D
	if sprite:
		var material = StandardMaterial3D.new()
		material.albedo_color = player_colors[player_id]
		sprite.material = material
	
	# Add label to show player number
	var label = Label.new()
	label.text = "P" + str(player_id)
	label.position = Vector2(-10, -30)
	add_child(label)

func _physics_process(delta):
	var input_dir = Vector2.ZERO
	
	if Input.is_key_pressed(move_left): input_dir.x -= 1
	if Input.is_key_pressed(move_right): input_dir.x += 1
	if Input.is_key_pressed(move_up): input_dir.y -= 1
	if Input.is_key_pressed(move_down): input_dir.y += 1
	
	input_dir = input_dir.normalized()
	velocity = input_dir * speed
	move_and_slide()
