extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

# Exported variable allows setting 'p1' or 'p2' per instance in the inspector
@export var player_prefix: String = "p1"

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	# add gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# Handle Jump
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
