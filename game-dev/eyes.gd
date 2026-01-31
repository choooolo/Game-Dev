extends MeshInstance3D

var blink_timer = 0.0
var is_blinking = false
var blink_progress = 0.0
var original_rotation = rotation.x

func _ready():
	# Make eye color (adjust as needed)
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.8, 0.8, 0.8)  # Light gray for eyelid
	set_surface_override_material(0, material)
	
	# Start first blink after 2 seconds
	blink_timer = 2.0

func _process(delta):
	blink_timer -= delta
	
	# Start a blink when timer reaches 0
	if blink_timer <= 0 and not is_blinking:
		is_blinking = true
		blink_progress = 0.0
	
	# Handle blinking animation
	if is_blinking:
		blink_progress += delta
		
		if blink_progress < 0.1:  # Closing phase (0.1 seconds)
			# Rotate closed: 0° → 90°
			var close_amount = blink_progress / 0.1  # 0 to 1
			rotation.x = original_rotation + close_amount * 1.57  # 90 degrees in radians
			
		elif blink_progress < 0.25:  # Closed phase (0.15 seconds)
			# Keep closed at 90° rotation
			rotation.x = original_rotation + 1.57
			
		elif blink_progress < 0.35:  # Opening phase (0.1 seconds)
			# Rotate open: 90° → 0°
			var open_amount = (blink_progress - 0.25) / 0.1  # 0 to 1
			rotation.x = original_rotation + (1 - open_amount) * 1.57
			
		else:  # Blink finished
			rotation.x = original_rotation  # Reset to original
			is_blinking = false
			blink_timer = randf_range(2.0, 4.0)  # Next blink in 2-4 seconds
