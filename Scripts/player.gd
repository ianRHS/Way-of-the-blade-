extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

@export var player_prefix: String = "p1"
@export var opponent: CharacterBody2D
@export var max_health: int = 3

signal player_died(loser_prefix: String)



var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_attacking: bool = false
var is_guarding: bool = false
var is_staggered: bool = false
var is_dead: bool = false
var is_dashing: bool = false
var can_dash_left: bool = false
var can_dash_right: bool = false
var current_health: int




# Ensure node paths match your Scene dock exactly (Case Sensitive)
@onready var HitBox_Shape: CollisionShape2D = $Pivot/Hitbox/HitBoxShape
@onready var sword_visual: ColorRect = $Pivot/Hitbox/SwordVisual
@onready var anim: AnimatedSprite2D = $Pivot/CharacterAnim


func _ready() -> void:
	current_health = max_health
	
	# Ensure hitbox and visual start disabled
	HitBox_Shape.set_deferred("disabled", true)
	sword_visual.visible = false
	Global.update_health(player_prefix, current_health, max_health)

func _physics_process(delta: float) -> void:
	if not Global.round_active:
		return
	
	
	if is_dead:
		return
		
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		
	
	#Block Inputs while staggered, attacking, or guarding
	if not is_staggered:
		# Handle Attack Input
		if Input.is_action_just_pressed(player_prefix + "_attack") \
		 and not is_attacking and not is_guarding and not is_dashing:
			attack()
			
		# Handle Guard / Parry Input
		if Input.is_action_just_pressed(player_prefix + "_guard") \
		 and not is_attacking and not is_guarding and not is_dashing:
			guard()
			
		# Double tap left to Dash left
		if Input.is_action_just_pressed(player_prefix + "_left") \
		 and not is_attacking and not is_guarding and not is_dashing:
			if can_dash_left:
				dash(-1.0)
				can_dash_left = false
			else:
				can_dash_left = true
				await get_tree().create_timer(0.25).timeout
				can_dash_left = false
		
		
		# Double Tap right to Dash Right
		if Input.is_action_just_pressed(player_prefix + "_right") \
		 and not is_attacking and not is_guarding and not is_dashing:
			if can_dash_right:
				dash(1.0)
				can_dash_right = false
				
			else:
				can_dash_right = true
				await get_tree().create_timer(0.25).timeout
				can_dash_right = false




	# Handle Movement
	if is_staggered:
		# Let knockback decay smoothly over frames
		velocity.x = move_toward(velocity.x, 0, 800.0 * delta)
	elif is_dashing:
		velocity.x = move_toward(velocity.x, 0, 2000.0 * delta)
	elif not is_attacking and not is_guarding:
		if Input.is_action_just_pressed(player_prefix + "_jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			
		var direction := Input.get_axis(player_prefix + "_left", player_prefix + "_right")
		if direction != 0:
			velocity.x = direction * SPEED
			$Pivot.scale.x = direction
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * 10.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 10.0 * delta)
		
		# Auto face opponent when moving or idle
		if opponent and is_instance_valid(opponent):
			var dir_to_opp = opponent.global_position.x - global_position.x
			if dir_to_opp != 0:
				$Pivot.scale.x = sign(dir_to_opp)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * 10.0 * delta)
		
	move_and_slide()
	
	# Update ground movement visuals when not performing an action
	if not is_attacking and not is_guarding and not is_staggered:
		if abs(velocity.x) > 10.0:
			anim.play("Walk")
		else:
			anim.play("Idle")
			
		

func dash(forced_dir: float = 0.0) -> void:
	is_dashing = true
	var dash_dir = forced_dir
	if dash_dir == 0.0:
		var direction := Input.get_axis(player_prefix + "_left", player_prefix + "_right")
		dash_dir = direction if direction != 0 else $Pivot.scale.x
	velocity.x = dash_dir * 900.0
	if dash_dir != 0:
		$Pivot.scale.x = sign(dash_dir)
		
	await get_tree().create_timer(0.2).timeout
	if not is_staggered:
		is_dashing = false


func attack() -> void:
	is_attacking = true
	velocity.x = 0
	
	# Play a random attack animation
	var attack_num = randi_range(1, 3)
	anim.play("attack_" + str(attack_num))
	
	# Set target strike frame based on variation (attack 2 hits on frame 4, others on frame 2)
	var _hit_frame: int = 4 if attack_num == 2 else 2
	
	
	# Wait until the blade actually swings forward (e.g., frame 1)
	while anim.frame < 2 and anim.is_playing():
		await anim.frame_changed
	
	
	# 1. Active Swing phase
	
	HitBox_Shape.set_deferred("disabled", false)
	sword_visual.visible = true
	
	# Keep hitbox active for 1 frame window
	await anim.frame_changed
	
	
	# 2. Disable Hitbox ( Sword swing finishes)
	HitBox_Shape.set_deferred("disabled", true)
	sword_visual.visible = false
	
	# Recovery phase ( Player is locked in place briefly after missing)
	if not is_staggered:
		modulate = Color(0.5, 0.5, 0.5) # Dims character gray during recovery
		
		# Wait for the rest of the animation to finish
		if anim.is_playing():
			await anim.animation_finished
			
			# Extra recovery lockout delay
			await get_tree().create_timer(0.2).timeout
		


	# 4 Return to neutral
	if not is_staggered:
		modulate = Color.WHITE
		is_attacking = false
		anim.play("Idle")
		
		
		

func guard() -> void:
	is_guarding = true
	modulate = Color.CYAN # Visual feedback : Parrying
	velocity.x = 0
	anim.play("guard")
	await get_tree().create_timer(0.2).timeout
	
	
	
	if not is_staggered and is_guarding:
		is_guarding = false
		modulate = Color(0.3, 0.3, 0.8) # Dark blue during missed guard recovery
		anim.play("Idle")
		
		# Lock inputs briefly after a whiffed parry
		is_attacking = true # Temporarily reuse Input lock
		await get_tree().create_timer(0.3).timeout
		is_attacking = false
		
	# Return to Neutral
	if not is_staggered:
		modulate = Color.WHITE
		
		
func get_staggered() -> void:
	# Immediately interrupt active states
	is_attacking = false
	is_guarding = false
	is_dashing = false
	is_staggered = true
	
	# Force disable active hitbox/visuals
	HitBox_Shape.set_deferred("disabled", true)
	sword_visual.visible = false
	
	# Flash yellow to indicate recoil/stun
	modulate = Color.YELLOW
	
	# Add This: Trigger stagger Animation
	anim.play("Stagger")
	
	# Knockback recoil ( Push backward based on facing direction)
	velocity.x = - $Pivot.scale.x * 350.0
	
	# 0.5s stagger lockout window
	await get_tree().create_timer(0.5).timeout
	
	modulate = Color.WHITE
	is_staggered = false
	anim.play("Idle")


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.name.to_lower() ==  "hitbox":
		var attacker = area.get_parent().get_parent()
		
		if attacker != self and not is_dead:
			var impact_pos = (global_position + area.global_position) / 2.0
			
			if is_guarding:
				print(player_prefix.to_upper() + " PARRIED THE ATTACK!")
				
				# Spawn yellow parry sparks
				Global.spawn_impact_particles(impact_pos, true)
				# Light shake for parry clash
				Global.shake_camera(5.0)
				
				
				# Sharp freeze frame on clash
				Global.trigger_hitstop(0.1, 0.05)
				
				# Stagger the opponent who attempted the strike
				if attacker.has_method("get_staggered"):
					attacker.get_staggered()
			else:
				# Spawn red hit particles
				Global.spawn_impact_particles(impact_pos, false)
				# Heavy shake on fatal strike
				Global.shake_camera(14.0)
			
				
				take_damage()
		
		
		
func take_damage() -> void:
	print("Taking damage! Current health: ", current_health)
	if is_dead:
		return
		
	current_health -= 1
	Global.update_health(player_prefix, current_health, max_health)
	
	if current_health <= 0:
		die()
	else:
		Global.trigger_hitstop(0.1, 0.05)
		get_staggered()
		
func die() -> void:
		is_dead = true
		HitBox_Shape.set_deferred("disabled", true)
		sword_visual.visible = false
		$CollisionShape2D.set_deferred("disabled", true)	
		# Trigger the death animation
		anim.play("death")
		set_physics_process(false)
		# 1. Trigger dramatic camera zoom centered on this player
		Global.trigger_fatal_zoom(global_position, 1.4)
		# Freeze frames briefly for fatal hit weight
		Global.trigger_hitstop(0.18, 0.02)
		await get_tree().create_timer(0.8, true, false, true).timeout
		# Fix Hud
		Engine.time_scale = 1.0
		# 2. Reset zoom before stage reload or victory screen
		Global.reset_camera_zoom()
		
		player_died.emit(player_prefix)
		
func reset_player() -> void:
	# 1. Reset all states
	is_dead = false
	is_staggered = false
	is_attacking = false
	is_guarding = false
	
	# 2. Turn physics and collisions back on
	set_physics_process(true)
	$CollisionShape2D.set_deferred("disabled", false)
	
	# 3. Disable hitboxes just in case
	HitBox_Shape.set_deferred("disabled", true)
	sword_visual.visible = false
	
	# 4. Reset visuals back to normal
	modulate = Color.WHITE
	anim.play("Idle")
