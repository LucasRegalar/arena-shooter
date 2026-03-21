--- MapElement base class.
-- Base type for all objects that occupy a cell on the tile grid.
-- Extends GameObject to inherit world position and gameConfig.
-- Subclasses (Floor, Wall) define specific passability behavior.

local GameObject = require("classes.gameObject")
local mapConfig = require("classes.map.config")

--- @class MapElement : GameObject
--- @field col number Column index in the grid (1-based)
--- @field row number Row index in the grid (1-based)
--- @field passable boolean Whether entities can move through this element
local MapElement = GameObject:extend()

--- Creates a new MapElement.
-- Computes pixel position from grid coordinates using the configured tile size.
--- @param col number Column index (1-based)
--- @param row number Row index (1-based)
--- @param passable boolean Whether this element is passable
--- @param gameConfig table|nil Shared game configuration
function MapElement:new(col, row, passable, gameConfig)
	local x = (col - 1) * mapConfig.tile_size
	local y = (row - 1) * mapConfig.tile_size
	MapElement.super.new(self, x, y, gameConfig)

	self.col = col
	self.row = row
	self.passable = passable
end

--- Returns whether entities can move through this element.
--- @return boolean
function MapElement:isPassable()
	return self.passable
end

--- Updates this element. No-op by default; subclasses override as needed.
--- @param dt number Delta time since the last frame
function MapElement:update(dt)
end

return MapElement
