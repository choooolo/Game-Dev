extends Node

var current_level = 1
var player_start_position = Vector3(0, 1, 0)

@onready var player = get_node("../Player")
@onready var level_text = get_node("../LevelText")

func _ready():
	print("Level Manager Ready")
	if player:
		print("Player found at: ", player.position)
	else:
		print("ERROR: Player not found!")
	
	if level_text:
		level_text.text = "LEVEL " + str(current_level)

func restart_level():
	print("!!! RESTARTING LEVEL ", current_level, " !!!")
	
	if player:
		# Call the player's reset function
		player.reset_position()
		print("Player reset to start")
	else:
		print("ERROR: Cannot restart - player not found")

func next_level():
	current_level += 1
	print("Advancing to Level ", current_level)
	if level_text:
		level_text.text = "LEVEL " + str(current_level)
	
	# Reset player position when entering new level
	if player:
		player.reset_position()
