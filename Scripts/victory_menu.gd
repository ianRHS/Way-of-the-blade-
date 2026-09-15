extends CanvasLayer

@onready var winner_label: Label = $Control/WinnerText
@onready var rematch_button: Button = $Control/ButtonContainer/RematchButton
@onready var main_menu_button: Button = $Control/ButtonContainer/MainMenuButton
@onready var exit_button: Button = $Control/ButtonContainer/ExitButton

func _ready() -> void:
	hide()
	
	rematch_button.pressed.connect(_on_rematch_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func setup_victory(winner_name: String) -> void:
	winner_label.text = winner_name.to_upper() + " WINS!"
	show()

func _on_rematch_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	# Ensure this file path matches your actual MainMenu scene path in FileSystem
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
