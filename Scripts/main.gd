extends Node2D

@export var wins_to_match: int = 3

var current_round: int = 1
var p1_wins: int = 0
var p2_wins: int = 0
var match_over: bool = false
var is_transitioning: bool = false

@onready var player_1: CharacterBody2D = $Player1
@onready var player_2: CharacterBody2D = $Player2
@onready var hud: CanvasLayer = $HUD

func _ready() -> void:
	Global.round_active = true
	match_over = false
	is_transitioning = false
	
	
	if player_1 and player_2:
		player_1.opponent = player_2
		player_2.opponent = player_1
		
		# Tells main script to listen for deaths
		player_1.player_died.connect(_on_player_died)
		player_2.player_died.connect(_on_player_died)
		
	if hud and hud.has_signal("time_over"):
		if not hud.is_connected("time_over", _on_time_over):
			hud.time_over.connect(_on_time_over)
		
	if hud and hud.has_method("Update_round_display"):
		hud.update_round_display(p1_wins, p2_wins)
		
func _on_player_died(loser_prefix: String) -> void:
	if match_over or is_transitioning: return
	is_transitioning = true
	# Stop players from moving
	Global.round_active = false
	
	# Give the point to the winner
	if loser_prefix == "p1":
		p2_wins += 1
	elif loser_prefix == "p2":
		p1_wins += 1
		
	if hud and hud.has_method("update_round_display"):
		hud.update_round_display(p1_wins, p2_wins)
		
	if p1_wins >= wins_to_match or p2_wins >= wins_to_match:
		match_over = true
		_show_game_over()
	else:
		_advance_to_next_round()

	

func _on_time_over() -> void:
	if match_over or is_transitioning: return
	is_transitioning = true
	Global.round_active = false
	
	if hud and hud.has_method("stop_round_timer"):
		hud.stop_round_timer()
	
	var winner = _determine_hp_winner()
	if winner == "p1":
		p1_wins += 1
	elif winner == "p2":
		p2_wins += 1
		
	if hud and hud.has_method("update_round_display"):
		hud.update_round_display(p1_wins, p2_wins)
		
	if p1_wins >= wins_to_match or p2_wins >= wins_to_match:
		match_over = true
		_show_game_over()
	else:
		_advance_to_next_round()

func _advance_to_next_round() -> void:
	# 2-second delay without pausing the tree
	await get_tree().create_timer(2.0).timeout
	
	current_round += 1
	
	# Reset player health & UI
	player_1.current_health = player_1.max_health
	player_2.current_health = player_2.max_health
	Global.update_health("p1", player_1.current_health, player_1.max_health)
	Global.update_health("p2", player_2.current_health, player_2.max_health)
	
	player_1.reset_player()
	player_2.reset_player()
	
	# Reset positions if spawn markers are present
	if has_node("SpawnP1") and has_node("SpawnP2"):
		player_1.global_position = $SpawnP1.global_position
		player_2.global_position = $SpawnP2.global_position
	
	# Restart timer and reactivate player inputs
	if hud and hud.has_method("start_round_timer"):
		hud.start_round_timer()
		
	Global.round_active = true
	is_transitioning = false

func _determine_hp_winner() -> String:
	if player_1.current_health > player_2.current_health:
		return "p1"
	elif player_2.current_health > player_1.current_health:
		return "p2"
	else:
		return "draw"

func _show_game_over() -> void:
	Global.round_active = false
	
	# Hide the combat HUD elements
	if hud:
		hud.hide()
		
	# Calculate match victor
	var match_winner = "Player 1"
	if p2_wins > p1_wins:
		match_winner = "Player 2"
	elif p1_wins == p2_wins:
		match_winner = "Draw"
		
	# Show Victory Overlay
	if has_node("VictoryMenu"):
		$VictoryMenu.setup_victory(match_winner)
	else:
		print("ERROR: VictoryMenu node missing from scene tree!")
		
	get_tree().paused = true
