extends Area3D

func _ready():
	body_entered.connect(_on_body_entered)
	print("Level Trigger ready at: ", global_position)

func _on_body_entered(body):
	print("Trigger entered by: ", body.name)
	
	if body.name == "Player" or body.is_in_group("player"):
		print("PLAYER entered level trigger!")
		
		var level_manager = get_node_or_null("/root/EndlessRunner/LevelManager")
		if not level_manager:
			level_manager = get_node_or_null("../../LevelManager")
		
		if level_manager and level_manager.current_level == 1:
			level_manager.next_level()
			print("Advanced to Level 2!")
