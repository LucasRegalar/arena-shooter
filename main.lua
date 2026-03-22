local Player = require("classes.player.init")
-- local Weapon = require("classes.weapon.init")

function love.load()
	Player = Player:new(300, 300, 1)
	-- local weapon = Weapon:new(player)
end

function love.update(dt)
	Player:update(dt)
end

function love.draw()
	Player:draw()
end
