local GameObject = require('classes.gameObject')

local Weapon = GameObject:extend()

function Weapon:new(player, gameConfig)
	Weapon.super.new(self, player.x, player.y, gameConfig)

	self.player = player
	self.scale = 1.5
	self.angle = 0
	self.isFacingLeft = false

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

return Weapon
