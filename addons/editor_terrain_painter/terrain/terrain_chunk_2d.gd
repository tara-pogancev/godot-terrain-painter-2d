@tool
extends Node2D
class_name TerrainChunk2D

const GRASS = preload("uid://ov37xepe02p1")
const STONE_PATH_1 = preload("uid://7qvomux41l70")

@export var size: Vector2i = Vector2i(1024, 1024) :
	set(value):
		if value == size:
			return
		size = value
		_rebuild()
		
@export var materials: Array[TerrainMaterial] = [
	GRASS,
	STONE_PATH_1
]

@onready var sprite: Sprite2D = $TerrainTexture

var masks: Array[Image] = []
var mask_textures: Array[ImageTexture] = []

var shader_material: ShaderMaterial

const TERRAIN_PAINTER_SHADER = preload("uid://byiiy22ewy1o2")

func _ready():
	sprite.centered = false
	sprite.position = Vector2.ZERO
	sprite.scale = Vector2.ONE

	shader_material = ShaderMaterial.new()
	shader_material.shader = TERRAIN_PAINTER_SHADER
	sprite.material = shader_material

	_rebuild()

	# Bind terrain textures
	for i in materials.size():
		shader_material.set_shader_parameter("tex%d" % i, materials[i].texture)


var brush_radius := 32
var brush_strength := 0.2
var soft := true
var erase : bool = false


func paint(material_index: int, world_pos: Vector2) -> void:
	if material_index < 0 or material_index >= materials.size():
		return

	var mask = masks[material_index]
	var tex = mask_textures[material_index]

	# Convert world position to local sprite coordinates
	var local = to_local(world_pos)
	var center = Vector2i(local)

	# Paint loop
	for y in range(-brush_radius, brush_radius):
		for x in range(-brush_radius, brush_radius):
			var p = center + Vector2i(x, y)

			# Skip out-of-bounds
			if p.x < 0 or p.y < 0 or p.x >= size.x or p.y >= size.y:
				continue

			# Distance from brush center
			var dist = Vector2(x, y).length()
			if dist > brush_radius:
				continue

			# Brush falloff
			var falloff := 1.0
			if soft:
				falloff = 1.0 - (dist / brush_radius)

			# Read current mask value
			var value = mask.get_pixelv(p).r

			# Paint / erase
			value = clamp(value + brush_strength * falloff * (-1 if erase else 1), 0, 1)

			mask.set_pixelv(p, Color(value, 0, 0))

	# Update the texture
	tex.update(mask)
	shader_material.set_shader_parameter("mask%d" % material_index, tex)
	queue_redraw()


func _rebuild() -> void:
	if !is_inside_tree():
		return

	# --- Base texture ---
	var base := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	base.fill(Color.BLACK)
	sprite.texture = ImageTexture.create_from_image(base)

	# --- Resize masks safely ---
	var new_masks: Array[Image] = []
	var new_mask_textures: Array[ImageTexture] = []

	for i in materials.size():
		var old_mask: Image = masks[i] if i < masks.size() else null

		var new_mask := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
		new_mask.fill(Color(0, 0, 0))

		if old_mask:
			var copy_w = min(old_mask.get_width(), size.x)
			var copy_h = min(old_mask.get_height(), size.y)

			new_mask.blit_rect(
				old_mask,
				Rect2i(0, 0, copy_w, copy_h),
				Vector2i.ZERO
			)

		new_masks.append(new_mask)
		new_mask_textures.append(ImageTexture.create_from_image(new_mask))

	masks = new_masks
	mask_textures = new_mask_textures

	# --- Rebind shader params ---
	for i in materials.size():
		shader_material.set_shader_parameter("mask%d" % i, mask_textures[i])
