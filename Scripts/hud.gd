extends CanvasLayer


@onready var p1_round_dots: Array = [$P1RoundIcons/Dot1, $P1RoundIcons/Dot2, $P1RoundIcons/Dot3]
@onready var p2_round_dots: Array = [$P2RoundIcons/Dot1, $P2RoundIcons/Dot2, $P2RoundIcons/Dot3]
@onready var p1_health_bar: TextureProgressBar = $P1HealthBar
@onready var p2_health_bar: TextureProgressBar = $P2HealthBar
@onready var victory_panel: PanelContainer = $VictoryPanel
@onready var winner_label: Label = $VictoryPanel/VBoxContainer/WinnerLabel
@onready var restart_button: Button = $VictoryPanel/VBoxContainer/RestartButton

@export var filled_dot_texture: Texture2D
@export var empty_dot_texture: Texture2D

func update_round_display(p1_wins: int, p2_wins: int) -> void:
	for i in range(p1_round_dots.size()):
		if i < p1_wins:
			p1_round_dots[i].texture = filled_dot_texture
		else:
			p1_round_dots[i].texture = empty_dot_texture
			
	for i in range(p2_round_dots.size()):
		if i < p2_wins:
			p2_round_dots[i].texture = filled_dot_texture
		else:
			p2_round_dots[i].texture = empty_dot_texture




func _ready() -> void:
	update_round_display(Global.p1_rounds, Global.p2_rounds)
	Global.hud = self
	victory_panel.visible = false
	restart_button.pressed.connect(_on_restart_pressed)
	
func update_health_ui(player: String, current: int, maximum: int) -> void:
	print("HUD updating for ", player, " -> Value: ", current)
	var clean_prefix = player.strip_edges().to_lower()
	if clean_prefix == "p1":
		p1_health_bar.max_value = maximum
		p1_health_bar.value = current
	elif clean_prefix == "p2":
		p2_health_bar.max_value = maximum
		p2_health_bar.value = current
		
	
func show_victory(winner_name: String) -> void:
	winner_label.text = winner_name + " WINS!"
	victory_panel.visible = true

func _on_restart_pressed() -> void:
	Global.reset_match()
	get_tree().reload_current_scene()
