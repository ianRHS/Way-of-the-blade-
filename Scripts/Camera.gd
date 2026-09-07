extends Camera2D

var shake_intensity: float = 0.0

# Zoom & Position Tracking
var default_zoom: Vector2 = Vector2.ONE
var target_zoom: Vector2 = Vector2.ONE
var default_pos: Vector2 = Vector2.ZERO
var target_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Register self with Global manager on load
	Global.camera = self
	default_zoom = zoom
	target_zoom = zoom
	default_pos = global_position
	target_pos = global_position
	
func _process(delta: float) -> void:
	# Smoothly interpolate zoom level and position towards targets
	zoom = zoom.lerp(target_zoom, delta * 10.0)
	global_position = global_position.lerp(target_pos, delta * 10.0)
	
	# Camera shake
	if shake_intensity > 0:
		offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		# Smoothly decay shake back to zero
		shake_intensity = move_toward(shake_intensity, 0.0, delta * 30.0)
	else:
		offset = Vector2.ZERO
		
func apply_shake(amount: float = 8.0) -> void:
	shake_intensity = amount
	
func trigger_fatal_zoom(focus_pos: Vector2, zoom_factor: float = 1.4) -> void:
	target_zoom = default_zoom * zoom_factor
	target_pos = focus_pos
		
# Reset camera position and zoom level back to neutral
func reset_zoom() -> void:
	target_zoom = default_zoom
	target_pos = default_pos
