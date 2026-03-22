--- Weapon renderer.
-- Owns weapon rendering assets and reproduces the previous weapon draw behavior
-- while reading position and scale from the Weapon model.
local WeaponRenderer = Object:extend()

--- Creates a new WeaponRenderer.
-- Loads the same weapon sprite and quad data that the Weapon model used before
-- the renderer split, so the visual output stays unchanged.
function WeaponRenderer:new(weapon)
	self.weapon = weapon
	self.spriteSheet = love.graphics.newImage("assets/sprites/weapons/weapons.png")
	self.spriteSizeX = 32
	self.spriteSizeY = 11

	local sheetW, sheetH = self.spriteSheet:getDimensions()
	self.quad = love.graphics.newQuad(64, 85, self.spriteSizeX, self.spriteSizeY, sheetW, sheetH)

	return self
end

--- Draws the weapon in world space.
-- Uses the same position, rotation, and scale behavior as the previous
-- Weapon:draw implementation.
function WeaponRenderer:draw()
	local scaleY = self.weapon.isFacingLeft and -self.weapon.scale or self.weapon.scale

	love.graphics.draw(
		self.spriteSheet,
		self.quad,
		self.weapon.x,
		self.weapon.y,
		self.weapon.angle,
		self.weapon.scale,
		scaleY,
		self.spriteSizeX / 2,
		self.spriteSizeY / 2
	)
end

return WeaponRenderer
