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

	--- RGBA color used to draw wall tiles (placeholder gray).
	wall_color = {0.4, 0.4, 0.4, 1},
}

return mapConfig
