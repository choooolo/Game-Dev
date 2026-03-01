extends Area3D

func _ready():
	# Connect the body entered signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		print("Player hit a spike! Restarting level...")
		# Get the level manager and restart
		var level_manager = get_node("/root/EndlessRunner/LevelManager")
		if level_manager:
			level_manager.restart_level()
