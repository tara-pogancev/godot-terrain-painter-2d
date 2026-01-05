extends Node2D

@onready var terrain_chunk_2d: TerrainChunk2D = $TerrainChunk2D

func _ready() -> void:
	print(terrain_chunk_2d.get_class())
