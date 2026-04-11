--- Configuration constants for the map system.
-- Defines tile dimensions and grid size. The game operates in native Tiled
-- coordinates (16px tiles). push.lua handles all scaling to screen resolution.
local mapConfig = {
	--- Size of each tile in pixels (width and height).
	-- This is both the native Tiled tile size and the game coordinate unit.
	tile_size = 16,

	--- Number of tile columns in the grid.
	grid_width = 45,

	--- Number of tile rows in the grid.
	grid_height = 28,
}

return mapConfig
