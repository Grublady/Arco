@tool
class_name ArcSegment2D extends Node2D

const FEATHER_SIZE := 1.25 # from renderer_canvas_cull.cpp

#region Properties

## Number of segments to use when computing an arc.
## Higher segment counts increase the resulting shape's fidelity
## but are more expensive.
## [br][br]
## [b]Note:[/b] Segments are computed for both the inside and outside of the
## arc, so the total number of points in the element's polygon is roughly double
## this value.
@export var segments: int = 64:
	set(new_value):
		if new_value == segments:
			return
		segments = new_value
		queue_redraw()

## Color that this element uses to fill its visible shape.
## Draws underneath [member texture].
@export var background_color := Color.WHITE:
	set(new_value):
		if new_value == background_color:
			return
		background_color = new_value
		queue_redraw()

## Texture that this element projects onto its visible shape.
## Draws on top of [member background_color] and underneath
## [member overlay_texture].
@export var texture: Texture:
	set(new_value):
		if new_value == texture:
			return
		if is_instance_valid(texture):
			texture.changed.disconnect(queue_redraw)
		texture = new_value
		if is_instance_valid(texture):
			texture.changed.connect(queue_redraw)
		queue_redraw()

## Texture that this element draws, centered, on top of its shape.
## Unlike [member texture], it keeps its own dimensions and is not projected
## onto the element's arc. Draws on top of [member texture].
@export var overlay_texture: Texture2D:
	set(new_value):
		if new_value == overlay_texture:
			return
		if is_instance_valid(overlay_texture):
			overlay_texture.changed.disconnect(queue_redraw)
		overlay_texture = new_value
		if is_instance_valid(overlay_texture):
			overlay_texture.changed.connect(queue_redraw)
		queue_redraw()

## Difference between the inner and outer arcs' lengths.
@export var taper: float = 0:
	set(new_value):
		if new_value == taper:
			return
		taper = new_value
		queue_redraw()

## Vector in local space that displaces the element's shape.
@export var offset := Vector2.ZERO:
	set(new_value):
		if new_value == offset:
			return
		offset = new_value
		queue_redraw()

@export var _outer_radius: float = 10:
	set(new_value):
		if new_value == _outer_radius:
			return
		_outer_radius = new_value
		queue_redraw()

@export var _inner_radius: float = 0:
	set(new_value):
		if new_value == _inner_radius:
			return
		_inner_radius = new_value
		queue_redraw()

@export_range(-1, 1, 0.01) var arc_offset: float = 0:
	set(new_value):
		if new_value == arc_offset:
			return
		arc_offset = new_value
		_arc_offset = TAU * arc_offset

var _arc_offset: float = 0:
	set(new_value):
		if new_value == _arc_offset:
			return
		_arc_offset = new_value
		queue_redraw()

@export_range(0, 1, 0.01) var arc_length: float = 1:
	set(new_value):
		if new_value == arc_length:
			return
		arc_length = new_value
		_arc_length = TAU * arc_length

var _arc_length: float = TAU:
	set(new_value):
		if new_value == _arc_length:
			return
		_arc_length = new_value
		queue_redraw()

@export_range(-1, 1, 0.01) var inner_arc_offset: float = 0:
	set(new_value):
		if new_value == inner_arc_offset:
			return
		inner_arc_offset = new_value
		_inner_arc_offset = TAU * inner_arc_offset

var _inner_arc_offset: float = 0:
	set(new_value):
		if new_value == _inner_arc_offset:
			return
		_inner_arc_offset = new_value
		queue_redraw()

@export var _antialiased: bool = true:
	set(new_value):
		if new_value == _antialiased:
			return
		_antialiased = new_value
		queue_redraw()

#endregion

#region Method Overrides

func _draw() -> void:
	if get_outer_radius() == get_inner_radius():
		return
	
	var points: Array = _get_outline_points()
	
	if _antialiased:
		var indices := _triangulate_outline(points)
		@warning_ignore("integer_division")
		var colors := _get_outline_color_pairs(points.size() / 2)
		RenderingServer.canvas_item_add_triangle_array(
			get_canvas_item(),
			indices,
			points,
			colors
		)
	
	# Convert outline to polygon
	points = points.slice(0, (points.size() - 2), 2)
	
	# Remove duplicates
	points.remove_at(segments + 1)
	points.remove_at(segments + 1)
	points.remove_at(points.size() - 1)
	points.remove_at(points.size() - 1)
	
	draw_colored_polygon(points, background_color)
	
	if is_instance_valid(texture):
		RenderingServer.canvas_item_add_triangle_array(
			get_canvas_item(),
			_triangulate_polygon(),
			points,
			PackedColorArray(),
			_get_polygon_uvs(),
			PackedInt32Array(), # bones
			PackedFloat32Array(), # weights
			texture.get_rid()
		)
	
	if is_instance_valid(overlay_texture):
		var texture_center := overlay_texture.get_size() / 2
		var average_radius := (get_inner_radius() + get_outer_radius()) / 2
		var average_span := (get_inner_arc_span() + get_outer_arc_span()) / 2
		var width := average_radius * average_span
		var arc_center := (
			(Vector2.UP * average_radius)
			+ (Vector2.RIGHT * width * _inner_arc_offset / 2)
		)
		var draw_position := get_center() - texture_center + arc_center
		draw_texture(overlay_texture, draw_position)

#endregion

#region Methods

func _get_outline_color_pairs(pair_count: int) -> PackedColorArray:
	var transparent_color := background_color
	transparent_color.a = 0.0
	
	var result := PackedColorArray()
	result.resize(pair_count * 2)
	
	for i in range(pair_count):
		result[i * 2] = background_color
		result[i * 2 + 1] = transparent_color
	
	return result

func _get_outline_points() -> PackedVector2Array:
	var points := PackedVector2Array()
	
	# Outer arc
	var outer_arc_step := get_outer_arc_span() / float(segments)
	for i in range(segments + 1):
		var angle := get_outer_arc_start() + (i * outer_arc_step)
		var dir := Vector2(cos(angle), sin(angle))
		
		points.append(get_center() + dir * get_outer_radius())
		points.append(get_center() + dir * (get_outer_radius() + FEATHER_SIZE))
	
	# Inward line
	var line_1_start := get_center() + Vector2(
		cos(get_outer_arc_end()),
		sin(get_outer_arc_end())
	) * get_outer_radius()
	var line_1_end := get_center() + Vector2(
		cos(get_inner_arc_end()),
		sin(get_inner_arc_end())
	) * get_inner_radius()
	var line_1_vec := (line_1_end - line_1_start).normalized()
	var line_1_normal := line_1_vec.orthogonal()
	points.append(line_1_start)
	points.append(
		line_1_start
		- line_1_vec * FEATHER_SIZE
		+ line_1_normal * FEATHER_SIZE
	)
	points.append(line_1_end)
	points.append(
		line_1_end
		+ line_1_vec * FEATHER_SIZE
		+ line_1_normal * FEATHER_SIZE
	)
	
	# Inner arc
	var inner_arc_step := get_inner_arc_span() / float(segments)
	for i in range(segments, -1, -1):
		var angle := get_inner_arc_start() + (i * inner_arc_step)
		var dir := Vector2(cos(angle), sin(angle))
		
		points.append(get_center() + dir * get_inner_radius())
		points.append(get_center() + dir * maxf(get_inner_radius() - FEATHER_SIZE, 0))
	
	# Outward line
	var line_2_start := get_center() + Vector2(
		cos(get_inner_arc_start()),
		sin(get_inner_arc_start())
	) * get_inner_radius()
	var line_2_end := get_center() + Vector2(
		cos(get_outer_arc_start()),
		sin(get_outer_arc_start())
	) * get_outer_radius()
	var line_2_vec := (line_2_end - line_2_start).normalized()
	var line_2_normal := line_2_vec.orthogonal()
	points.append(line_2_start)
	points.append(
		line_2_start
		- line_2_vec * FEATHER_SIZE
		+ line_2_normal * FEATHER_SIZE
	)
	points.append(line_2_end)
	points.append(
		line_2_end
		+ line_2_vec * FEATHER_SIZE
		+ line_2_normal * FEATHER_SIZE
	)
	
	points.append(line_2_end)
	points.append(points[1])
	
	return points

func _get_polygon_uvs() -> PackedVector2Array:
	var result := PackedVector2Array()
	var step := 1 / float(segments)
	for i in range(segments + 1):
		result.append(Vector2(i * step, 0))
	for i in range(segments, -1, -1):
		result.append(Vector2(i * step, 1))
	return result

func _triangulate_outline(points: PackedVector2Array) -> PackedInt32Array:
	var indices := PackedInt32Array()
	
	for i in range(0, points.size() - 2, 2):
		indices.append(i)
		indices.append(i + 1)
		indices.append(i + 2)
		
		indices.append(i + 1)
		indices.append(i + 3)
		indices.append(i + 2)
	
	return indices

func _triangulate_polygon() -> PackedInt32Array:
	var result := PackedInt32Array()
	result.resize((segments + 1) * 6)
	for i in range(segments + 1):
		result[(i * 6)] = i
		result[(i * 6) + 1] = (segments * 2) + 1 - i
		result[(i * 6) + 2] = i + 1
		
		result[(i * 6) + 3] = ((segments * 2) + 1 - i)
		result[(i * 6) + 4] = ((segments * 2) - i)
		result[(i * 6) + 5] = (i + 1)
	return result

## Returns the point around which this element's shape is computed.
func get_center() -> Vector2:
	return offset

## Returns the angle at which the outer arc begins.
func get_outer_arc_start() -> float:
	return _arc_offset + (TAU-_arc_length)/2
## Returns the angle at which the outer arc ends.
func get_outer_arc_end() -> float:
	return _arc_offset + _arc_length + (TAU-_arc_length)/2
## Returns the total length of the outer arc.
func get_outer_arc_span() -> float:
	return _arc_length
## Returns the radius of the circle bounding
## the outside of this element's shape.
func get_outer_radius() -> float:
	return _outer_radius

## Returns the angle at which the inner arc begins.
func get_inner_arc_start() -> float:
	return _arc_offset + _inner_arc_offset + (taper / 2) + (TAU-_arc_length)/2
## Returns the angle at which the inner arc ends.
func get_inner_arc_end() -> float:
	return _arc_offset + _inner_arc_offset + _arc_length - (taper / 2) + (TAU-_arc_length)/2
## Returns the total length of the inner arc.
func get_inner_arc_span() -> float:
	return _arc_length - taper
## Returns the radius of the circle bounding
## the inside of this element's shape.
func get_inner_radius() -> float:
	return _inner_radius

#endregion
