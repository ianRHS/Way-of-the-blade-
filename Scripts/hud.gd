extends CanvasLayer

@onready var p1_health_bar: TextureProgressBar = $P1HealthBar
@onready var p2_health_bar: TextureProgressBar = $P2HealthBar
@onready var victory_panel: PanelContainer = $VictoryPanel
@onready var winner_label: Label = $VictoryPanel/VBoxContainer/WinnerLabel
@onready var restart_button: Button = $VictoryPanel/VBoxContainer/RestartButton

func _ready() -> void:
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
	get_tree().reload_current_scene()
