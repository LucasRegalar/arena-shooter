--- Map class.
-- Manages a tile-based grid world with background rendering and element drawing.
-- Loads map data from an external Lua file, builds a grid of MapElement objects
-- (Floor/Wall), and computes centering offsets so the map is pixel-perfectly
-- centered on screen.

local config = require("classes.map.config")
local Floor = require("classes.map.elements.floor")
local Wall = require("classes.map.elements.wall")

--- @class Map
--- @field grid table 2D array of raw tile type integers (0 = floor, 1 = wall)
--- @field elements table 2D array of MapElement instances (Floor or Wall)
--- @field rows number Number of tile rows in the grid
--- @field cols number Number of tile columns in the grid
--- @field offset_x number Horizontal pixel offset to center the map on screen
--- @field offset_y number Vertical pixel offset to center the map on screen
--- @field background love.Image Tiled background texture
--- @field backgroundQuad love.Quad Quad spanning the full map area for tiled background drawing
--- @field wallSprite love.Image Wall tile sprite (shared across all Wall instances)
local Map = Object:extend()

--- Creates a new Map instance.
-- Loads grid data from the given module path, builds MapElement objects for each
-- cell, sets up the tiled background, and computes the centering offset.
--- @param mapDataPath string Module path to a Lua file returning a 2D grid table (e.g. "maps.default")
function Map:new(mapDataPath)
	-- Load raw tile grid from external data file
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

	-- Load wall tile sprite (shared by all Wall instances)
	self.wallSprite = love.graphics.newImage("sprites/wall.png")

	-- Build element grid: convert raw integers into MapElement objects
	self.elements = {}
	for row = 1, self.rows do
		self.elements[row] = {}
		for col = 1, self.cols do
			if self.grid[row][col] == config.WALL then
				self.elements[row][col] = Wall(col, row, self.wallSprite)
			else
				self.elements[row][col] = Floor(col, row)
			end
		end
	end

	-- Compute centering offset to position the map in the middle of the window
	local windowWidth, windowHeight = love.graphics.getDimensions()
	self.offset_x = math.floor((windowWidth - mapPixelWidth) / 2)
	self.offset_y = math.floor((windowHeight - mapPixelHeight) / 2)
end

--- Draws the map: tiled background first, then map elements on top.
-- Floor elements are no-ops (background Quad handles their rendering).
-- Wall elements draw their sprites individually.
-- Assumes a shared love.graphics.translate() has already been applied by the caller.
function Map:draw()
	-- Draw tiled background across the full map area
	love.graphics.draw(self.background, self.backgroundQuad, 0, 0)

	-- Draw all map elements (Floor.draw is a no-op, Wall.draw renders the sprite)
	for row = 1, self.rows do
		for col = 1, self.cols do
			self.elements[row][col]:draw()
		end
	end
end

--- Returns the raw tile type integer at the given grid coordinates.
--- @param grid_x number Column index (1-based)
--- @param grid_y number Row index (1-based)
--- @return number|nil Tile type value, or nil if out of bounds
function Map:getTileAt(grid_x, grid_y)
	if grid_y < 1 or grid_y > self.rows or grid_x < 1 or grid_x > self.cols then
		return nil
	end
	return self.grid[grid_y][grid_x]
end

--- Returns the MapElement instance at the given grid coordinates.
--- @param grid_x number Column index (1-based)
--- @param grid_y number Row index (1-based)
--- @return MapElement|nil The element at that position, or nil if out of bounds
function Map:getElementAt(grid_x, grid_y)
	if grid_y < 1 or grid_y > self.rows or grid_x < 1 or grid_x > self.cols then
		return nil
	end
	return self.elements[grid_y][grid_x]
end

--- Returns whether the tile at the given grid coordinates is passable.
--- @param grid_x number Column index (1-based)
--- @param grid_y number Row index (1-based)
--- @return boolean False if out of bounds or impassable, true if passable
function Map:isPassable(grid_x, grid_y)
	local element = self:getElementAt(grid_x, grid_y)
	if element == nil then
		return false
	end
	return element:isPassable()
end

--- Returns the pixel offset used to center the map on screen.
--- @return number offset_x Horizontal offset in pixels
--- @return number offset_y Vertical offset in pixels
function Map:getOffset()
	return self.offset_x, self.offset_y
end

return Map
