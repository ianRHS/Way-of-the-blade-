extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

@export var player_prefix: String = "p1"

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_attacking: bool = false
var is_guarding: bool = false
var is_staggered: bool = false
var is_dead: bool = false
var is_dashing: bool = false
var can_dash_left: bool = false
var can_dash_right: bool = false



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
		
	move_and_slide()
		

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
	
	# 1. Active Swing phase
	
	HitBox_Shape.set_deferred("disabled", false)
	sword_visual.visible = true
	await get_tree().create_timer(0.2).timeout
	
	
	# 2. Disable Hitbox ( Sword swing finishes)
	HitBox_Shape.set_deferred("disabled", true)
	sword_visual.visible = false
	
	# Recovery phase ( Player is locked in place briefly after missing)
	if not is_staggered:
		modulate = Color(0.5, 0.5, 0.5) # Dims character gray during recovery
		await get_tree().create_timer(0.25).timeout
		
	# 4 Return to neutral
	if not is_staggered:
		modulate = Color.WHITE
		is_attacking = false
		
		
		

func guard() -> void:
	is_guarding = true
	modulate = Color.CYAN # Visual feedback : Parrying
	
	await get_tree().create_timer(0.2).timeout
	
	if not is_staggered and is_guarding:
		is_guarding = false
		modulate = Color(0.3, 0.3, 0.8) # Dark blue during missed guard recovery
		
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
	
	# Knockback recoil ( Push backward based on facing direction)
	velocity.x = - $Pivot.scale.x * 350.0
	
	# 0.5s stagger lockout window
	await get_tree().create_timer(0.5).timeout
	
	modulate = Color.WHITE
	is_staggered = false


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.name.to_lower() ==  "hitbox":
		var attacker = area.get_parent().get_parent()
		
		if attacker != self and not is_dead:
			var impact_pos = (global_position + area.global_position) / 2.0
			
			if is_guarding:
				print(player_prefix.to_upper() + " PARRIED THE ATTACK!")
				
				# Spawn yellow parry sparks
				Global.spawn_impact_particles(impact_pos, true)
				
				
				# Sharp freeze frame on clash
				Global.trigger_hitstop(0.1, 0.05)
				
				# Stagger the opponent who attempted the strike
				if attacker.has_method("get_staggered"):
					attacker.get_staggered()
			else:
				# Spawn red hit particles
				Global.spawn_impact_particles(impact_pos, false)
				
				take_damage()
		
		
		
func take_damage() -> void:
	is_dead = true
	set_physics_process(false)
	# Freeze frames briefly for fatal hit weight
	Global.trigger_hitstop(0.18, 0.02)
	
	# Give point to the opponent
	Global.record_defeat(player_prefix)
	print("P1: ", Global.p1_score, " | P2: ", Global.p2_score)
	
	await get_tree().create_timer(0.8).timeout
	
	if Global.is_match_over():
		print("MATCH OVER!")
		var winner = "PLAYER 2" if player_prefix == "p1" else "PLAYER 1"
		Global.show_victory_screen(winner)
	else:
		get_tree().reload_current_scene()
	
	
	
