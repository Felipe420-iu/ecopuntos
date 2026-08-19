extends Node2D

const TILE_SIZE := Vector2i(64, 64)
const MAP_WIDTH := 24
const MAP_HEIGHT := 14

@onready var tilemap: TileMap = $Ground

var _grass_id: int
var _path_id: int
var _water_id: int
var _source_id: int = -1

func _ready():
	_build_tileset()
	_generate_layout()

func _build_tileset():
	# Create a TileSet with a ScenesCollectionSource so we don't depend on atlases
	var ts := TileSet.new()
	var scenes_source := TileSetScenesCollectionSource.new()
	_grass_id = scenes_source.create_scene_tile(load("res://assets/tiles/grass_tile.tscn"))
	_path_id = scenes_source.create_scene_tile(load("res://assets/tiles/path_tile.tscn"))
	_water_id = scenes_source.create_scene_tile(load("res://assets/tiles/water_tile.tscn"))
	_source_id = ts.add_source(scenes_source)
	ts.tile_size = TILE_SIZE
	tilemap.tile_set = ts
	tilemap.tile_set.tile_size = TILE_SIZE
	tilemap.set_layer_enabled(0, true)
	tilemap.y_sort_enabled = false
	tilemap.rendering_quadrant_size = TILE_SIZE.x
	tilemap.cell_quadrant_size = TILE_SIZE.x

func _generate_layout():
	if _source_id == -1:
		return
	# Fill with grass
	for x in range(MAP_WIDTH):
		for y in range(MAP_HEIGHT):
			tilemap.set_cell(0, Vector2i(x, y), _source_id, Vector2i.ZERO, _grass_id)
	# Main path (horizontal)
	var path_y := int(MAP_HEIGHT / 2)
	for x in range(2, MAP_WIDTH - 2):
		tilemap.set_cell(0, Vector2i(x, path_y), _source_id, Vector2i.ZERO, _path_id)
	# Small curve upward
	tilemap.set_cell(0, Vector2i(10, path_y - 1), _source_id, Vector2i.ZERO, _path_id)
	tilemap.set_cell(0, Vector2i(11, path_y - 2), _source_id, Vector2i.ZERO, _path_id)
	tilemap.set_cell(0, Vector2i(12, path_y - 2), _source_id, Vector2i.ZERO, _path_id)
	tilemap.set_cell(0, Vector2i(13, path_y - 2), _source_id, Vector2i.ZERO, _path_id)
	# Water pond
	for x in range(3, 6):
		for y in range(path_y + 2, path_y + 5):
			tilemap.set_cell(0, Vector2i(x, y), _source_id, Vector2i.ZERO, _water_id)

func get_entry_point() -> Vector2:
	return tilemap.map_to_local(Vector2i(2, MAP_HEIGHT / 2)) + TILE_SIZE / 2.0

func get_exit_point() -> Vector2:
	return tilemap.map_to_local(Vector2i(MAP_WIDTH - 3, MAP_HEIGHT / 2)) + TILE_SIZE / 2.0

func get_center_point() -> Vector2:
	return tilemap.map_to_local(Vector2i(MAP_WIDTH / 2, MAP_HEIGHT / 2)) + TILE_SIZE / 2.0
