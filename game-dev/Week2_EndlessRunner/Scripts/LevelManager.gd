extends Node

var current_level = 1
var player_start_position = Vector3(0, 1, 0)

@onready var player = $"../Player"
@onready var level_text = $"../LevelText"

func _ready():
	update_level_display()

func update_level_display():
	if level_text:
		level_text.text = "LEVEL " + str(current_level)
		# Flash effect
		level_text.scale = Vector3(1.5, 1.5, 1.5)
		await get_tree().create_timer(0.3).timeout
		level_text.scale = Vector3(1, 1, 1)

func show_level_notification():
	print("=== LEVEL ", current_level, " ===")
	update_level_display()

func restart_level():
	print("Restarting Level ", current_level)
	player.position = player_start_position
	player.velocity = Vector3.ZERO

func next_level():
	current_level += 1
	print("Advancing to Level ", current_level)
	show_level_notification()
	player.position = player_start_position
