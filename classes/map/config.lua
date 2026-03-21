--- Configuration constants for the map system.
-- Defines tile dimensions, grid size, and rendering scale.
local mapConfig = {
	--- Native size of each tile in pixels (width and height), as defined in the Tiled map.
	tile_size = 16,

	--- Render scale factor applied when drawing the map.
	-- Tiles are rendered at tile_size * scale pixels on screen.
	scale = 2,

	--- Number of tile columns in the grid.
	grid_width = 45,

	--- Number of tile rows in the grid.
	grid_height = 28,
}

return mapConfig
