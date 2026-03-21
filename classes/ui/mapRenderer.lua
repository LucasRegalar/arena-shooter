--- Map renderer.
-- Handles all visual representation of the tile-based map.
-- Loads textures, creates quads, and draws the tiled background and wall sprites.
-- Reads map data (grid integers) but never modifies it.

local mapConfig = require("classes.map.config")

--- @class MapRenderer : Object
--- @field map Map Read-only reference to the map data
--- @field background love.Image Tiled floor texture
--- @field backgroundQuad love.Quad Quad spanning full map area for tiled background drawing
--- @field wallSprite love.Image Wall tile sprite
--- @field wallPositions table Pre-computed {x, y} pairs for all wall tiles
local MapRenderer = Object:extend()

--- Creates a new MapRenderer.
-- Loads all map-related textures, creates the background quad, and pre-computes
-- wall positions by scanning the map's raw grid data once.
--- @param map Map The map model to render (read-only data source)
function MapRenderer:new(map)
	self.map = map

	-- Load background texture with repeat wrapping for tiling
	self.background = love.graphics.newImage("sprites/background.png")
	self.background:setWrap("repeat", "repeat")

	-- Create a quad that spans the full map pixel area so the texture tiles across it
	local mapPixelWidth = map:getPixelWidth()
	local mapPixelHeight = map:getPixelHeight()
	self.backgroundQuad = love.graphics.newQuad(
		0, 0,
		mapPixelWidth, mapPixelHeight,
		self.background:getWidth(), self.background:getHeight()
	)

	-- Load wall tile sprite
	self.wallSprite = love.graphics.newImage("sprites/wall.png")

	-- Pre-compute wall pixel positions from the raw grid data
	self.wallPositions = {}
	for row = 1, map.rows do
		for col = 1, map.cols do
			if map.grid[row][col] == mapConfig.WALL then
				local x = (col - 1) * mapConfig.tile_size
				local y = (row - 1) * mapConfig.tile_size
				self.wallPositions[#self.wallPositions + 1] = { x = x, y = y }
			end
		end
	end
end

--- Draws the map: tiled background first, then wall sprites on top.
-- Assumes a shared love.graphics.translate() has already been applied by the caller.
function MapRenderer:draw()
	-- Draw tiled background across the full map area
	love.graphics.draw(self.background, self.backgroundQuad, 0, 0)

	-- Draw all wall sprites at their pre-computed positions
	for i = 1, #self.wallPositions do
		local pos = self.wallPositions[i]
		love.graphics.draw(self.wallSprite, pos.x, pos.y)
	end
end

return MapRenderer
