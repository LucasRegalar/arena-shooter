local Object = require('lib.classic')

--- Base class for world objects that need shared game configuration.
-- This stays intentionally small for now and will grow as we add more
-- shared entity behavior.
--- @class GameObject : Object
--- @field x number World x position in pixels
--- @field y number World y position in pixels
--- @field gameConfig GameConfig Shared game-wide configuration reference
local GameObject = Object:extend()

--- Creates a new game object with shared game configuration.
--- @param x number|nil Initial world x position
--- @param y number|nil Initial world y position
--- @param gameConfig GameConfig Shared game configuration table
function GameObject:new(x, y, gameConfig)
	self.x = x or 0
	self.y = y or 0
	self.gameConfig = gameConfig
end

return GameObject
