extends Node3D

# Player reference
var player_scene = preload("res://player.tscn")
var player_instance = null

# Letters
var letters = []
var text = "HELLO WORLD"

func _ready():
	spawn_player()
	create_letters()
	create_obstacles()
	create_lights()

func spawn_player():
	player_instance = player_scene.instantiate()
	player_instance.position = Vector3(0, 1, 0)
	add_child(player_instance)

func create_letters():
	var spacing = 0.8
	var start_x = -(text.length() * spacing) / 2
	
	for i in range(text.length()):
		var char = text[i]
		if char == " ":
			continue
			
		# Create rigid body for letter
		var rb = RigidBody3D.new()
		rb.position = Vector3(start_x + i * spacing, 2, -5)
		rb.name = "Letter_" + char
		
		# Create text mesh
		var text_mesh = TextMesh.new()
		text_mesh.text = char
		text_mesh.font_size = 0.5
		text_mesh.depth = 0.1
		
		var mesh_inst = MeshInstance3D.new()
		mesh_inst.mesh = text_mesh
		
		# Color each letter
		var material = StandardMaterial3D.new()
		material.albedo_color = Color.from_hsv(i * 0.1, 0.8, 1.0)
		mesh_inst.set_surface_override_material(0, material)
		
		# Add collision
		var collision = CollisionShape3D.new()
		collision.shape = BoxShape3D.new()
		collision.shape.size = Vector3(0.4, 0.4, 0.1)
		
		# Assemble
		rb.add_child(collision)
		rb.add_child(mesh_inst)
		add_child(rb)
		
		# Make interactive
		rb.contact_monitor = true
		rb.max_contacts_reported = 5
		rb.body_entered.connect(_on_letter_hit.bind(rb))
		
		letters.append(rb)

func create_obstacles():
	# Create some obstacles to jump over
	var colors = [Color.RED, Color.BLUE, Color.YELLOW]
	var positions = [-4, 0, 4]
	
	for i in range(3):
		var obstacle = RigidBody3D.new()
		obstacle.position = Vector3(positions[i], 0.5, -8)
		
		var mesh = MeshInstance3D.new()
		mesh.mesh = BoxMesh.new()
		mesh.scale = Vector3(1, 1, 2)
		
		var collision = CollisionShape3D.new()
		collision.shape = BoxShape3D.new()
		collision.shape.size = Vector3(1, 1, 2)
		
		var material = StandardMaterial3D.new()
		material.albedo_color = colors[i]
		mesh.set_surface_override_material(0, material)
		
		obstacle.add_child(collision)
		obstacle.add_child(mesh)
		add_child(obstacle)

func create_lights():
	# Directional light
	var light = DirectionalLight3D.new()
	light.position = Vector3(5, 10, 5)
	light.look_at(Vector3(0, 0, -5))
	add_child(light)
	
	# Ambient light
	var ambient = OmniLight3D.new()
	ambient.position = Vector3(0, 5, 0)
	ambient.light_energy = 0.5
	add_child(ambient)

func _on_letter_hit(body, letter):
	if body.is_in_group("player"):
		print("Player hit: ", letter.name)
		
		# Push the letter
		var direction = (letter.global_position - body.global_position).normalized()
		letter.apply_central_impulse(direction * 5 + Vector3(0, 2, 0))
		
		# Flash white
		if letter.get_child_count() > 1:
			var mesh = letter.get_child(1)
			if mesh and mesh is MeshInstance3D:
				var mat = mesh.get_surface_override_material(0)
				if mat:
					mat.albedo_color = Color.WHITE
					await get_tree().create_timer(0.1).timeout
					# Restore color
					for i in range(letters.size()):
						if letters[i] == letter:
							mat.albedo_color = Color.from_hsv(i * 0.1, 0.8, 1.0)
							break

func _process(delta):
	# Optional: Reset letters if they fall too far
	for letter in letters:
		if letter.global_position.y < -5:
			letter.global_position = Vector3(letter.global_position.x, 2, -5)
			letter.linear_velocity = Vector3.ZERO

func _input(event):
	# Press R to reset all letters
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		for i in range(letters.size()):
			var spacing = 0.8
			var start_x = -(text.length() * spacing) / 2
			var char_index = 0
			var letter_index = 0
			
			# Find actual letter index (skip spaces)
			for j in range(text.length()):
				if text[j] != " ":
					if letters[letter_index] == letters[i]:
						char_index = j
						break
					letter_index += 1
			
			letters[i].global_position = Vector3(start_x + char_index * spacing, 2, -5)
			letters[i].linear_velocity = Vector3.ZERO
			letters[i].angular_velocity = Vector3.ZERO
