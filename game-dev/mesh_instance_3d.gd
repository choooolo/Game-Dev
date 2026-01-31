extends MeshInstance3D

var blink_timer = 0.0
var is_blinking = false
var is_winking = false
var eye_closed_timer = 0.0
var original_scale = Vector3(0.1, 0.1, 0.1)
var wink_chance = 0.2  # 20% chance to wink
var time_between_blinks = 3.0  # How often to check for blink

func _ready():
	# Make eye black
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0, 0, 0)  # Black
	set_surface_override_material(0, material)

func _process(delta):
	# UPDATE: Only count timer when NOT blinking/winking
	if not is_blinking and not is_winking:
		blink_timer += delta
	
	# Check if it's time for a new blink/wink
	if blink_timer > time_between_blinks and not is_blinking and not is_winking:
		blink_timer = 0.0
		
		# Random choice: wink or blink
		if randf() < wink_chance:  # 20% wink
			is_winking = true
			eye_closed_timer = 0.5
		else:  # 80% blink
			is_blinking = true
			eye_closed_timer = 0.5
	
	# BLINKING ANIMATION
	if is_blinking:
		eye_closed_timer += delta
		
		# Phase 1: Close eye (0.1 seconds)
		if eye_closed_timer < 0.1:
			scale.y = original_scale.y * (1.0 - (eye_closed_timer / 0.1) * 0.8)
		
		# Phase 2: Keep closed (0.2 seconds)
		elif eye_closed_timer < 0.3:
			scale.y = original_scale.y * 0.2
		
		# Phase 3: Open eye (0.1 seconds)
		elif eye_closed_timer < 0.4:
			scale.y = original_scale.y * (0.2 + ((eye_closed_timer - 0.3) / 0.1) * 0.8)
		
		# Phase 4: Done blinking
		else:
			scale.y = original_scale.y
			is_blinking = false
	
	# WINKING ANIMATION (same as blink but longer closed time)
	elif is_winking:
		eye_closed_timer += delta
		
		# Phase 1: Close eye (0.1 seconds)
		if eye_closed_timer < 0.1:
			scale.y = original_scale.y * (1.0 - (eye_closed_timer / 0.1) * 0.8)
		
		# Phase 2: Keep closed longer for wink (0.5 seconds)
		elif eye_closed_timer < 0.6:
			scale.y = original_scale.y * 0.2
		
		# Phase 3: Open eye (0.1 seconds)
		elif eye_closed_timer < 0.7:
			scale.y = original_scale.y * (0.2 + ((eye_closed_timer - 0.6) / 0.1) * 0.8)
		
		# Phase 4: Done winking
		else:
			scale.y = original_scale.y
			is_winking = false

	# DEBUG: Press B to force blink, W to force wink
	if Input.is_action_just_pressed("ui_accept"):  # Press Enter key
		is_blinking = true
		eye_closed_timer = 0.5
	if Input.is_action_just_pressed("ui_cancel"):  # Press Escape key
		is_winking = true
		eye_closed_timer = 0.5
