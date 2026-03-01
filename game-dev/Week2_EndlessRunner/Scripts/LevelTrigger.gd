extends Area3D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		var level_manager = get_node("/root/EndlessRunner/LevelManager")
		if level_manager and level_manager.current_level == 1:
			level_manager.next_level()
