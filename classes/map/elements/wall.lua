--- Wall element.
-- Represents an impassable wall tile on the map grid.
-- Draws itself using a shared wall sprite passed in by the Map.

local MapElement = require("classes.map.elements.mapElement")

--- @class Wall : MapElement
--- @field sprite love.Image Shared wall sprite image
local Wall = MapElement:extend()

--- Creates a new Wall element.
--- @param col number Column index (1-based)
--- @param row number Row index (1-based)
--- @param sprite love.Image Shared wall sprite image (loaded once by Map)
--- @param gameConfig table|nil Shared game configuration
function Wall:new(col, row, sprite, gameConfig)
	Wall.super.new(self, col, row, false, gameConfig)
	self.sprite = sprite
end

--- Draws the wall sprite at this element's pixel position.
function Wall:draw()
	love.graphics.draw(self.sprite, self.x, self.y)
end

return Wall
