local GameObject = require('classes.gameObject')

--- Weapon entity.
-- Stores weapon rendering state while inheriting shared world state from
-- `GameObject`.
--- @class Weapon : GameObject
--- @field scale number Weapon sprite scale multiplier
--- @field spriteSheet love.Image Weapon sprite sheet image
--- @field quad love.Quad Weapon sprite quad
local Weapon = GameObject:extend()

--- Creates a new weapon instance.
--- @param x number|nil Initial world x position
--- @param y number|nil Initial world y position
--- @param gameConfig GameConfig Shared game configuration table
function Weapon:new(x, y, gameConfig)
	Weapon.super.new(self, x or 100, y or 100, gameConfig)

	self.scale = 2
	self.spriteSheet = love.graphics.newImage("sprites/weapons/1 (1).png")

	local sheetW, sheetH = self.spriteSheet:getDimensions()
	self.quad = love.graphics.newQuad(64, 85, 32, 11, sheetW, sheetH)

	return self
end

function Weapon:draw()
	love.graphics.draw(self.spriteSheet, self.quad, self.x, self.y, 0, self.scale, self.scale)
end

return Weapon
