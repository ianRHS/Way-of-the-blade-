extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

# Exported variable allows setting 'p1' or 'p2' per instance in the inspector
@export var player_prefix: String = "p1"

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_attacking: bool = false
var is_dead: bool = false

@onready var hitbox_shape: CollisionShape2D = $Pivot/Hitbox/HitBoxShape
@onready var sword_visual: ColorRect = $Pivot/Hitbox/SwordVisual


func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	# add gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# Add print statement to check input press
	if Input.is_action_just_pressed(player_prefix + "_attack"):
		print(player_prefix + " attack button pressed!")
		if not is_attacking:
			attack()
	# Handle Attack
	if Input.is_action_just_pressed(player_prefix + "_attack") and not is_attacking:
		attack()
	
	
	# Handle Jump and prevent movement while swinging sword
	if not is_attacking:
		if Input.is_action_just_pressed(player_prefix + "_jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		var direction := Input.get_axis(player_prefix + "_left", player_prefix + "_right")
		if direction != 0:
			velocity.x = direction * SPEED
			$Pivot.scale.x = direction
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			move_and_slide()
	else:
		velocity.x = move_toward(velocity.x, 0,  SPEED)
	move_and_slide()
	
func attack() -> void:
	is_attacking = true
	hitbox_shape.disabled = false # Activate sword hitbox
	sword_visual.visible = true
	
	# Wait 0.2 seconds for the swing duration
	await get_tree().create_timer(0.2).timeout
	
	hitbox_shape.disabled = true # Deactivate sword hitbox
	sword_visual.visible = false
	is_attacking = false
	


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.name == "Hitbox" and not is_dead:
		take_damage()
		
func take_damage() -> void:
	is_dead = true
	set_physics_process(false)
	print(player_prefix + " Defeated!")
	
	#pause brief moment before reloading the arena for next round
	await get_tree().create_timer(0.8).timeout
	get_tree().reload_current_scene()
