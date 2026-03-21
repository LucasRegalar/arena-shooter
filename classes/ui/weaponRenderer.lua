--- Weapon renderer.
-- Owns weapon rendering assets and reproduces the previous weapon draw behavior
-- while reading position and scale from the Weapon model.
local WeaponRenderer = Object:extend()

--- Creates a new WeaponRenderer.
-- Loads the same weapon sprite and quad data that the Weapon model used before
-- the renderer split, so the visual output stays unchanged.
function WeaponRenderer:new(weapon)
	self.weapon = weapon
	self.spriteSheet = love.graphics.newImage("sprites/weapons/1 (1).png")

	local sheetW, sheetH = self.spriteSheet:getDimensions()
	self.quad = love.graphics.newQuad(64, 85, 32, 11, sheetW, sheetH)

	return self
end

--- Draws the weapon in world space.
-- Uses the same position, rotation, and scale behavior as the previous
-- Weapon:draw implementation.
function WeaponRenderer:draw()
	love.graphics.draw(self.spriteSheet, self.quad, self.weapon.x, self.weapon.y, 0, self.weapon.scale, self.weapon.scale)
end

return WeaponRenderer
