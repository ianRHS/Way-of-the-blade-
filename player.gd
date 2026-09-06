extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

@export var player_prefix: String = "p1"

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_attacking: bool = false
var is_dead: bool = false

# Ensure node paths match your Scene dock exactly (Case Sensitive)
@onready var HitBox_Shape: CollisionShape2D = $Pivot/Hitbox/HitBoxShape
@onready var sword_visual: ColorRect = $Pivot/Hitbox/SwordVisual

func _ready() -> void:
	# Ensure hitbox and visual start disabled
	HitBox_Shape.set_deferred("disabled", true)
	sword_visual.visible = false

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# Handle Attack Input
	if Input.is_action_just_pressed(player_prefix + "_attack") and not is_attacking:
		attack()
	
	# Handle Movement
	if not is_attacking:
		if Input.is_action_just_pressed(player_prefix + "_jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		var direction := Input.get_axis(player_prefix + "_left", player_prefix + "_right")
		if direction != 0:
			velocity.x = direction * SPEED
			$Pivot.scale.x = direction
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
		
	# Single move_and_slide call at the end of physics processing
	move_and_slide()
	
func attack() -> void:
	is_attacking = true
	
	# set_deferred ensures physics engine processes the shape toggle safely
	HitBox_Shape.set_deferred("disabled", false)
	sword_visual.visible = true
	
	# Swing duration
	await get_tree().create_timer(0.2).timeout
	
	HitBox_Shape.set_deferred("disabled", true)
	sword_visual.visible = false
	is_attacking = false

func _on_hurtbox_area_entered(area: Area2D) -> void:
	print(">>> SOMETHING ENTERED THE HURTBOX: ", area.name)
	
	if area.name.to_lower() == "hitbox":
		var attacker = area.get_parent().get_parent()
		if attacker != self and not is_dead:
			take_damage()
		
func take_damage() -> void:
	is_dead = true
	set_physics_process(false)
	
	# Give ppoint to the opponent
	Global.record_defeat(player_prefix)
	
	print("P1: ", Global.p1_score, " | P2: ", Global.p2_score)
	
	await get_tree().create_timer(0.8).timeout
	
	if Global.is_match_over():
		print("MATCH OVER! Resetting match. . .")
		Global.reset_match()
		
	get_tree().reload_current_scene()
	
	
