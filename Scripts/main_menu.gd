extends Control

@onready var start_button: Button = $VBoxContainer/StartButton
@onready var tutorial_button: Button = $VBoxContainer/TutorialButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready() -> void:
	start_button.grab_focus()
	start_button.pressed.connect(_on_start_pressed)
	tutorial_button.pressed.connect(_on_tutorial_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed() -> void:
	# Change this to point to your new Map Select scene
	get_tree().change_scene_to_file("res://Scenes/map_select.tscn")
	
func _on_tutorial_pressed() -> void:
	# Adjust this path if your tutorial menu is saved in a different folder
	get_tree().change_scene_to_file("res://scenes/tutorial_menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
