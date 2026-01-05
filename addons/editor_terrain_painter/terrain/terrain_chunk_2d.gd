@tool
extends Node2D
class_name TerrainChunk2D

const GRASS = preload("uid://ov37xepe02p1")
const STONE_PATH_1 = preload("uid://7qvomux41l70")

@export var size := 1024
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
	
	masks.clear()
	mask_textures.clear()

	# Create base texture
	var base = Image.create(size, size, false, Image.FORMAT_RGBA8)
	base.fill(Color.BLACK)

	var base_tex = ImageTexture.create_from_image(base)
	sprite.texture = base_tex

	# Shader material
	shader_material = ShaderMaterial.new()
	shader_material.shader = TERRAIN_PAINTER_SHADER
	sprite.material = shader_material

	_init_materials()

	shader_material.set_shader_parameter("mask0", mask_textures[0])
	shader_material.set_shader_parameter("mask1", mask_textures[1])



func _init_materials():
	for m in materials:
		var mask = Image.create(size, size, false, Image.FORMAT_RGBA8)
		mask.fill(Color(0,0,0))
		masks.append(mask)
		var tex = ImageTexture.create_from_image(mask)
		mask_textures.append(tex)


var brush_radius := 32
var brush_strength := 0.2
var soft := true
var erase : bool = false


func paint(material_index: int, world_pos: Vector2) -> void:
	print(material_index, world_pos)
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
			if p.x < 0 or p.y < 0 or p.x >= size or p.y >= size:
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
