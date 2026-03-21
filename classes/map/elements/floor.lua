--- Floor element.
-- Represents a walkable floor tile on the map grid.
-- Rendering is handled by the Map's background Quad, so draw() is a no-op.

local MapElement = require("classes.map.elements.mapElement")

--- @class Floor : MapElement
local Floor = MapElement:extend()

--- Creates a new Floor element.
--- @param col number Column index (1-based)
--- @param row number Row index (1-based)
--- @param gameConfig table|nil Shared game configuration
function Floor:new(col, row, gameConfig)
	Floor.super.new(self, col, row, true, gameConfig)
end

return Floor
