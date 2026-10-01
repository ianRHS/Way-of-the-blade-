extends Control

@onready var btn_bamboo: Button = $VBoxContainer/Arena1Button
@onready var btn_dojo: Button = $VBoxContainer/Arena2Button
@onready var btn_cave: Button = $VBoxContainer/Arena3Button
@onready var btn_back: Button = $VBoxContainer/BackButton

func _ready() -> void:
	# Focus the first button by default for keyboard/controller navigation
	btn_bamboo.grab_focus()
	
	# Connect button signals
	btn_bamboo.pressed.connect(_on_bamboo_pressed)
	btn_dojo.pressed.connect(_on_dojo_pressed)
	btn_cave.pressed.connect(_on_cave_pressed)
	btn_back.pressed.connect(_on_back_pressed)

func _on_bamboo_pressed() -> void:
	GameManager.selected_arena_path = "res://Scenes/Arenas/Arena1.tscn"
	get_tree().change_scene_to_file("res://Scenes/Arenas/Arena1.tscn")

func _on_dojo_pressed() -> void:
	GameManager.selected_arena_path = "res://Scenes/Arenas/Arena2.tscn"
	get_tree().change_scene_to_file("res://Scenes/Arenas/Arena2.tscn")

func _on_cave_pressed() -> void:
	GameManager.selected_arena_path = "res://Scenes/Arenas/Arena3.tscn"
	get_tree().change_scene_to_file("res://Scenes/Arenas/Arena3.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
