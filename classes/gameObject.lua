local GameObject = Object:extend()

function GameObject:new(x, y, gameConfig)
	self.x = x or 0
	self.y = y or 0
	self.gameConfig = gameConfig
end

return GameObject
