--- Wall element.
-- Represents an impassable wall tile on the map grid.

local MapElement = require("classes.map.elements.mapElement")

--- @class Wall : MapElement
local Wall = MapElement:extend()

--- Creates a new Wall element.
--- @param col number Column index (1-based)
--- @param row number Row index (1-based)
--- @param gameConfig table|nil Shared game configuration
function Wall:new(col, row, gameConfig)
	Wall.super.new(self, col, row, false, gameConfig)
end

return Wall
