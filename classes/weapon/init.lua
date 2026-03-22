local Object = require('lib.classic')
local Weapon = Object:extend()

function Weapon:new(player)
	self.x = player.x
	self.y = player.y
	self.player = player
	self.scale = 2.5
	self.angle = 0
	self.isFacingLeft = false

	self.spriteSheet = love.graphics.newImage("sprites/weapons/1 (1).png")
	self.spriteSizeX = 32
	self.spriteSizeY = 11

	local sheetW, sheetH = self.spriteSheet:getDimensions()
	self.quad = love.graphics.newQuad(64, 85, self.spriteSizeX, self.spriteSizeY, sheetW, sheetH)

	return self
end

function Weapon:update()
	self.x = self.player.handX
	self.y = self.player.handY

	local aimDeltaX = self.player.crossHairX - self.x
	local aimDeltaY = self.player.crossHairY - self.y
	self.isFacingLeft = aimDeltaX < 0
	self.angle = math.atan2(aimDeltaY, aimDeltaX)
end

-- todo: use anim8
-- todo: extract into render file
function Weapon:draw()
	local scaleY = self.isFacingLeft and -self.scale or self.scale

	love.graphics.draw(
		self.spriteSheet,
		self.quad,
		self.x,
		self.y,
		self.angle,
		self.scale,
		scaleY,
		self.spriteSizeX / 2,
		self.spriteSizeY / 2
	)
end

return Weapon
