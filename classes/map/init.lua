--- Map class.
-- Manages a tile-based grid world with background rendering and wall drawing.
-- Loads map data from an external Lua file and computes centering offsets
-- so the map is pixel-perfectly centered on screen.

local config = require("classes.map.config")

--- @class Map
--- @field grid table 2D array of tile type values (0 = floor, 1 = wall)
--- @field rows number Number of tile rows in the grid
--- @field cols number Number of tile columns in the grid
--- @field offset_x number Horizontal pixel offset to center the map on screen
--- @field offset_y number Vertical pixel offset to center the map on screen
--- @field background love.Image Tiled background texture
--- @field backgroundQuad love.Quad Quad spanning the full map area for tiled background drawing
--- @field wallSprite love.Image Wall tile sprite
local Map = Object:extend()

--- Creates a new Map instance.
-- Loads grid data from the given module path, sets up the tiled background,
-- and computes the centering offset based on the current window size.
-- @param mapDataPath string Module path to a Lua file returning a 2D grid table (e.g. "maps.default")
function Map:new(mapDataPath)
	-- Load tile grid from external data file
	self.grid = require(mapDataPath)
	self.rows = #self.grid
	self.cols = #self.grid[1]

	-- Load background texture with repeat wrapping for tiling
	self.background = love.graphics.newImage("sprites/background.png")
	self.background:setWrap("repeat", "repeat")

	-- Create a quad that spans the full map pixel area so the texture tiles across it
	local mapPixelWidth = self.cols * config.tile_size
	local mapPixelHeight = self.rows * config.tile_size
	self.backgroundQuad = love.graphics.newQuad(
		0, 0,
		mapPixelWidth, mapPixelHeight,
		self.background:getWidth(), self.background:getHeight()
	)

	-- Load wall tile sprite
	self.wallSprite = love.graphics.newImage("sprites/wall.png")

	-- Compute centering offset to position the map in the middle of the window
	local windowWidth, windowHeight = love.graphics.getDimensions()
	self.offset_x = math.floor((windowWidth - mapPixelWidth) / 2)
	self.offset_y = math.floor((windowHeight - mapPixelHeight) / 2)
end

--- Draws the map: tiled background first, then wall tiles on top.
-- Assumes a shared love.graphics.translate() has already been applied by the caller.
function Map:draw()
	-- Draw tiled background across the full map area
	love.graphics.draw(self.background, self.backgroundQuad, 0, 0)

	-- Draw wall tiles using wall sprite
	for row = 1, self.rows do
		for col = 1, self.cols do
			if self.grid[row][col] == config.WALL then
				love.graphics.draw(
					self.wallSprite,
					(col - 1) * config.tile_size,
					(row - 1) * config.tile_size
				)
			end
		end
	end
end

--- Returns the tile type at the given grid coordinates.
-- @param grid_x number Column index (1-based)
-- @param grid_y number Row index (1-based)
-- @return number|nil Tile type value, or nil if out of bounds
function Map:getTileAt(grid_x, grid_y)
	if grid_y < 1 or grid_y > self.rows or grid_x < 1 or grid_x > self.cols then
		return nil
	end
	return self.grid[grid_y][grid_x]
end

--- Returns the pixel offset used to center the map on screen.
-- @return number offset_x Horizontal offset in pixels
-- @return number offset_y Vertical offset in pixels
function Map:getOffset()
	return self.offset_x, self.offset_y
end

return Map
