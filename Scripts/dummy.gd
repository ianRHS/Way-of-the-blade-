extends CharacterBody2D

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	# Basic gravity so the dummy stays on the ground
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	# Check if the thing hitting us is a sword hitbox
	if area.name.to_lower() == "hitbox":
		# Flash red for visual feedback
		modulate = Color.RED
		
		# Tell the tutorial manager (which will be the parent node) that a hit happened
		var tutorial_manager = get_parent()
		if tutorial_manager.has_method("register_dummy_hit"):
			tutorial_manager.register_dummy_hit()
			
		await get_tree().create_timer(0.15).timeout
		modulate = Color.WHITE
