--- Configuration constants for the map system.
-- Defines tile dimensions, grid size, tile types, and visual properties.
local mapConfig = {
	--- Size of each tile in pixels (width and height).
	tile_size = 32,

	--- Number of tile columns in the grid.
	grid_width = 45,

	--- Number of tile rows in the grid.
	grid_height = 28,

	--- Tile type constant for walkable floor.
	FLOOR = 0,

	--- Tile type constant for impassable wall.
	WALL = 1,

	--- Tile type constant for impassable water.
	WATER = 2,
}

return mapConfig
