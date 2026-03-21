--- Map renderer.
-- Handles visual representation of the tile-based map using STI.
-- Draws a background fill color for the floor area, then delegates tile
-- rendering to the STI map instance owned by the Map model.

local mapConfig = require("classes.map.config")

--- @class MapRenderer : Object
--- @field map Map Read-only reference to the map data
local MapRenderer = Object:extend()

--- Creates a new MapRenderer.
--- @param map Map The map model to render (read-only data source)
function MapRenderer:new(map)
	self.map = map
end

--- Draws the map: background fill first, then STI tile layers at render scale.
-- Assumes a shared love.graphics.translate() has already been applied by the caller.
function MapRenderer:draw()
	-- Fill the map area with a dark background color for the transparent floor tiles
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(0x94 / 255, 0x94 / 255, 0x9D / 255, 1)
	love.graphics.rectangle(
		"fill", 0, 0,
		self.map:getPixelWidth(),
		self.map:getPixelHeight()
	)
	love.graphics.setColor(r, g, b, a)

	-- Draw all tile layers via STI at the configured render scale
	self.map.tiledMap:draw(0, 0, mapConfig.scale, mapConfig.scale)
end

return MapRenderer
