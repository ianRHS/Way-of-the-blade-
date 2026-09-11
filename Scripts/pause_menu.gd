extends Control

@onready var resume_button: Button = $VBoxContainer/ResumeButton
@onready var restart_button: Button = $VBoxContainer/RestartButton
@onready var main_menu_button: Button = $VBoxContainer/MainMenuButton

func _ready() -> void:
	visible = false
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): # Escape Key
		visible = not visible
		get_tree().paused = visible
		if visible:
			resume_button.grab_focus()
			
func _on_resume_pressed() -> void:
	visible = false
	get_tree().paused = false
	
func _on_restart_pressed() -> void:
	get_tree().paused = false
	Global.reset_match()
	get_tree().reload_current_scene()
	
func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	Global.reset_match()
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	
