extends Node

var p1_score: int = 0
var p2_score: int = 0
const WINS_NEEDED: int = 3

func record_defeat(defeated_player: String) -> void:
	if defeated_player == "p1":
		p2_score += 1
	else:
		p1_score += 1
		
		
func is_match_over() -> bool:
	return p1_score >= WINS_NEEDED or p2_score >= WINS_NEEDED
	
func reset_match() -> void:
	p1_score = 0
	p2_score = 0
	
func trigger_hitstop(duration: float = 0.15, scale: float = 0.05) -> void:
	Engine.time_scale = scale
	# Must use process_always or scale down the timer duration
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
	
func show_victory_screen(winner_text: String) -> void:
		var canvas = CanvasLayer.new()
		canvas.layer = 100
		
		
		# Semi-transparent dark background
		var bg = ColorRect.new()
		bg.color = Color(0, 0, 0,)
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		canvas.add_child(bg)
		
		# Center alignment container
		var center = CenterContainer.new()
		center.set_anchors_preset(Control.PRESET_FULL_RECT)
		canvas.add_child(center)
		
		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 30)
		center.add_child(vbox)
		
		# Winner announcement label
		var label = Label.new()
		label.text = winner_text + " WINS THE MATCH!"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		# Scale up text appearance if needed via the theme settings
		vbox.add_child(label)
		
		# Rematch button 
		var btn = Button.new()
		btn.text = "REMATCH"
		btn.custom_minimum_size = Vector2(220, 55)
		
		# Reset score, unpause, and reload when clicked
		btn.pressed.connect(func():
			reset_match()
			canvas.queue_free() # Destroy the UI
			get_tree().reload_current_scene()
		)
		vbox.add_child(btn)
		get_tree().current_scene.add_child(canvas)
