local Weapon = {}
Weapon.__index = Weapon

function Weapon:new(x, y)
	local self = setmetatable({}, Weapon)
	self.x = x or 100
	self.y = y or 100
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
