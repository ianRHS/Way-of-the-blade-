extends Node


var hud = null	
var camera: Camera2D = null

func shake_camera(amount: float = 8.0) -> void:
	if camera and is_instance_valid(camera):
		camera.apply_shake(amount)


			
		

	
func trigger_fatal_zoom(focus_pos: Vector2, zoom_factor: float = 1.4) -> void:
	if camera and is_instance_valid(camera):
		camera.trigger_fatal_zoom(focus_pos, zoom_factor)
		
func reset_camera_zoom() -> void:
	if camera and is_instance_valid(camera):
		camera.reset_zoom()
		
func update_health(player: String, current_health: int, max_health: int) -> void:
	if hud and is_instance_valid(hud):
		if hud.has_method("update_health_ui"):
			hud.update_health_ui(player, current_health, max_health)





# === Dynamic Particle System === 
# This generates and destroys particles in code, no setup required in the editor.

func spawn_impact_particles(global_pos: Vector2, is_parry: bool) -> void:
	var particles = CPUParticles2D.new()
	# the parent needs to be the current scene, not the Global autoload
	get_tree().current_scene.add_child(particles)
	particles.global_position = global_pos
	
	# === Configure General Behaviour ===
	particles.one_shot = true
	particles.amount = 25 # Number of particles
	particles.explosiveness = 0.95 # All at once
	particles.lifetime = 0.4 # Quick burst
	
	# === Set radial physics ===
	particles.spread = 180.0 # Full circle blast
	particles.gravity = Vector2(0, 0) # No gravity drift
	particles.initial_velocity_min = 250.0 # Fast start
	particles.initial_velocity_max = 500.0
	particles.damping_min = 100.0 # Slow down fast
	particles.damping_max = 200.0
	
	# === Add juice: Scale curve (Start big, end invisible) ===
	var curve = Curve.new()
	curve.add_point(Vector2(0, 1)) # Start scale
	curve.add_point(Vector2(1, 0)) # End scale
	particles.scale_amount_curve = curve
	particles.scale_amount_min = 6.0 # Base scale
	particles.scale_amount_max = 12.0
	
	# === Set Color Profile ===
	var color_ramp = Gradient.new()
	if is_parry:
		# Parry profile: Fast yellow to white sparks
		particles.initial_velocity_min = 400.0
		particles.initial_velocity_max = 700.0
		color_ramp.add_point(0.0, Color(1, 1, 0.5)) # Bright yellow center
		color_ramp.add_point(1.0, Color(1, 1, 1, 0)) # Fades to invisible white
	else:
		# Hit profile: Slower, heavy red/orange blood trail
		particles.lifetime = 0.6
		particles.initial_velocity_min = 150.0
		particles.initial_velocity_max = 300.0
		particles.damping_min = 50.0
		particles.damping_max = 100.0
		color_ramp.add_point(0.0, Color(0.8, 0.1, 0.1)) # Deep red
		color_ramp.add_point(0.5, Color(1, 0.4, 0.2)) # Transitions to orange
		color_ramp.add_point(1.0, Color(0, 0, 0, 0)) # Fades to black/transparent
	particles.color_ramp = color_ramp
	
	# Lifetime management
	particles.emitting = true
	# Automatic deletion after lifetime complete
	await get_tree().create_timer(particles.lifetime + 0.1, true, false, true).timeout
	if is_instance_valid(particles):
		particles.queue_free()
	
	
func trigger_hitstop(duration: float = 0.15, scale: float = 0.05) -> void:
	Engine.time_scale = scale
	# Must use process_always or scale down the timer duration
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
	
func show_victory_screen(winner_name: String) -> void:
	if hud and is_instance_valid(hud):
		hud.show_victory(winner_name)
		
