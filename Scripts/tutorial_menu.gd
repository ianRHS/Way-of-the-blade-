extends Control

# Preload your tutorial images (adjust paths to match where you saved them)
const IMG_MOVEMENT = preload("res://Assets/Textures/Movement.jpg")
const IMG_COMBAT = preload("res://Assets/Textures/Combat.jpg")
const IMG_RULES = preload("res://Assets/Textures/Rules.jpg")

@onready var display_image: TextureRect = $DisplayImage
@onready var btn_movement: Button = $Buttons/MovementButton
@onready var btn_combat: Button = $Buttons/CombatButton
@onready var btn_rules: Button = $Buttons/RulesButton
@onready var btn_back: Button = $Buttons/BackButton

func _ready() -> void:
	# Default to showing movement first
	display_image.texture = IMG_MOVEMENT
	
	# Connect button signals
	btn_movement.pressed.connect(func(): display_image.texture = IMG_MOVEMENT)
	btn_combat.pressed.connect(func(): display_image.texture = IMG_COMBAT)
	btn_rules.pressed.connect(func(): display_image.texture = IMG_RULES)
	btn_back.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	# Change back to your main menu scene path
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
