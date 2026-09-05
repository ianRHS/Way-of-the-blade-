extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

# Exported variable allows setting 'p1' or 'p2' per instance in the inspector
@export var player_prefix: String = "p1"

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_attacking: bool = false

@onready var hitbox_shape: CollisionShape2D = $Pivot/Hitbox/HitboxShape


func _physics_process(delta: float) -> void:
	# add gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# Handle Attack
	if Input.is_action_just_pressed(player_prefix + "_attack") and not is_attacking:
		attack()
	
	
	# Handle Jump and prevent movement while swinging sword
	if not is_attacking:
		if Input.is_action_just_pressed(player_prefix + "_jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
	
	# Get horizontal movement direction (-1, 0, or 1)
	var direction := Input.get_axis(player_prefix + "_left", player_prefix + "_right")
	if direction != 0:
		velocity.x = direction * SPEED
		# flip character pivot to face movement direction
		$Pivot.scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	
func attack() -> void:
	is_attacking = true
	hitbox_shape.disabled = false # Activate sword hitbox
	
	# Wait 0.2 seconds for the swing duration
	await get_tree().create_timer(0.2).timeout
	
	hitbox_shape.disabled = true # Deactivate sword hitbox
	is_attacking = false
	
