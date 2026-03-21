local GameObject = require('classes.gameObject')

--- Weapon entity.
-- Stores weapon world state while inheriting shared position state from
-- `GameObject`. Rendering is handled by `WeaponRenderer`.
--- @class Weapon : GameObject
--- @field scale number Weapon sprite scale multiplier
local Weapon = GameObject:extend()

--- Creates a new weapon instance.
--- @param x number|nil Initial world x position
--- @param y number|nil Initial world y position
--- @param gameConfig GameConfig Shared game configuration table
function Weapon:new(x, y, gameConfig)
	Weapon.super.new(self, x or 100, y or 100, gameConfig)

	self.scale = 2

	return self
end

return Weapon
