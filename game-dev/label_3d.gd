extends Label3D

var time = 0.0

func _process(delta):
	time += delta
	
	# Make text gently rotate
	rotate_y(delta * 0.3)
	
	# Make text pulse (change size)
	var pulse = sin(time * 2) * 0.1 + 1.0
	scale = Vector3(pulse, pulse, pulse)
	
	# Change text color
	var hue = time * 0.2
	modulate = Color.from_hsv(hue, 0.8, 1.0)
	
