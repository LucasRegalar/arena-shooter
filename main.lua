local Player = require("classes.player.init")
local Weapon = require("classes.weapon.init")

function love.load()
	Player = Player:new(300, 300, 1)
	Weapon = Weapon:new(Player)
end

function love.update(dt)
	Player:update(dt)
	Weapon:update()
end

function love.draw()
	Player:draw()
	Weapon:draw()
end
