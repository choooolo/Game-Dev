extends Area3D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("Player hit a spike! Restarting level...")
	
	# Get the root node (which is your scene name)
	var root = get_tree().current_scene
	print("Root node name: ", root.name)  # This should print "Week2_EndlessRunner"
	
	# Find LevelManager as a child of the root
	var level_manager = root.get_node_or_null("LevelManager")
	
	if level_manager:
		print("Found LevelManager, restarting...")
		level_manager.restart_level()
	else:
		print("ERROR: Could not find LevelManager!")
		
		# Print all children of root to see what's there
		print("Children of root:")
		for child in root.get_children():
			print(" - ", child.name)
