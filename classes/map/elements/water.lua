--- Water element.
-- Represents an impassable water tile on the map grid.

local MapElement = require("classes.map.elements.mapElement")

--- @class Water : MapElement
local Water = MapElement:extend()

--- Creates a new Water element.
--- @param col number Column index (1-based)
--- @param row number Row index (1-based)
--- @param gameConfig table|nil Shared game configuration
function Water:new(col, row, gameConfig)
	Water.super.new(self, col, row, false, gameConfig)
end

return Water
