local GameObject = require('classes.gameObject')

local Weapon = GameObject:extend()

function Weapon:new(player, gameConfig)
	Weapon.super.new(self, player.x, player.y, gameConfig)

	self.player = player
	self.scale = 2

	return self
end

function Weapon:update()
	self.x = self.player.handX
	self.y = self.player.handY
end

return Weapon
