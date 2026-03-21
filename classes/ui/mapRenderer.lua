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
-- We bypass tiledMap:draw() because it calls love.graphics.origin() internally,
-- which resets the centering translate. Instead we draw layers directly within
-- the existing transform and apply scale ourselves.
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

	-- Draw tile layers within the existing transform at render scale.
	-- SpriteBatches contain native positions (16px tiles), so the scale
	-- maps them to game coordinates (32px tiles).
	love.graphics.push()
	love.graphics.scale(mapConfig.scale, mapConfig.scale)

	for _, layer in ipairs(self.map.tiledMap.layers) do
		if layer.visible and layer.opacity > 0 then
			layer:draw()
		end
	end

	love.graphics.pop()
end

return MapRenderer
