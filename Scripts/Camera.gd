extends Camera2D

var shake_intensity: float = 0.0

# Zoom & Position Tracking
var default_zoom: Vector2 = Vector2.ONE
var target_zoom: Vector2 = Vector2.ONE
var default_pos: Vector2 = Vector2.ZERO
var target_pos: Vector2 = Vector2.ZERO

@export var arena_left: int = 0
@export var arena_right: int = 1152
@export var arena_top: int = 0
@export var arena_bottom: int = 648

func _ready() -> void:
	# Register self with Global manager on load
	Global.camera = self
	default_zoom = zoom
	target_zoom = zoom
	default_pos = global_position
	target_pos = global_position
	
	# Add limits to camera zoom
	limit_left = arena_left
	limit_right = arena_right
	limit_top = arena_top
	limit_bottom = arena_bottom
	
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
	var viewport_size = get_viewport_rect().size / target_zoom
	var min_x = arena_left + (viewport_size.x / 2.0)
	var max_x = arena_right - (viewport_size.x / 2.0)
	var min_y = arena_top + (viewport_size.y / 2.0)
	var max_y = arena_bottom - (viewport_size.y / 2.0)
	
	target_pos.x = clamp(focus_pos.x, min_x, max_x)
	target_pos.y = clamp(focus_pos.y, min_y, max_y)

		
# Reset camera position and zoom level back to neutral
func reset_zoom() -> void:
	target_zoom = default_zoom
	target_pos = default_pos
