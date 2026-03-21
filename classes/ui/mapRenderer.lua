--- Map renderer.
-- Handles all visual representation of the tile-based map.
-- Loads textures, creates quads, and draws the tiled background, wall sprites, and water sprites.
-- Reads map data (grid integers) but never modifies it.

local mapConfig = require("classes.map.config")

--- @class MapRenderer : Object
--- @field map Map Read-only reference to the map data
--- @field background love.Image Tiled floor texture
--- @field backgroundQuad love.Quad Quad spanning full map area for tiled background drawing
--- @field wallSprite love.Image Wall tile sprite
--- @field wallPositions table Pre-computed {x, y} pairs for all wall tiles
--- @field waterSprite love.Image Water tile sprite
--- @field waterPositions table Pre-computed {x, y} pairs for all water tiles
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

	-- Load tile sprites
	self.wallSprite = love.graphics.newImage("sprites/wall.png")
	self.waterSprite = love.graphics.newImage("sprites/water.png")

	-- Pre-compute tile pixel positions from the raw grid data
	self.wallPositions = {}
	self.waterPositions = {}
	for row = 1, map.rows do
		for col = 1, map.cols do
			local tile = map.grid[row][col]
			local x = (col - 1) * mapConfig.tile_size
			local y = (row - 1) * mapConfig.tile_size
			if tile == mapConfig.WALL then
				self.wallPositions[#self.wallPositions + 1] = { x = x, y = y }
			elseif tile == mapConfig.WATER then
				self.waterPositions[#self.waterPositions + 1] = { x = x, y = y }
			end
		end
	end
end

--- Draws the map: tiled background first, then tile sprites on top.
-- Assumes a shared love.graphics.translate() has already been applied by the caller.
function MapRenderer:draw()
	-- Draw tiled background across the full map area
	love.graphics.draw(self.background, self.backgroundQuad, 0, 0)

	-- Draw all wall sprites at their pre-computed positions
	for i = 1, #self.wallPositions do
		local pos = self.wallPositions[i]
		love.graphics.draw(self.wallSprite, pos.x, pos.y)
	end

	-- Draw all water sprites at their pre-computed positions
	for i = 1, #self.waterPositions do
		local pos = self.waterPositions[i]
		love.graphics.draw(self.waterSprite, pos.x, pos.y)
	end
end

return MapRenderer
