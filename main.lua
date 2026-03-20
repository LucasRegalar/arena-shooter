local Player = require("classes.player")
local Weapon = require("classes.weapon")
local player
local weapon

function love.load()
	-- important for pixel art
	love.graphics.setDefaultFilter("nearest", "nearest")
	player = Player:new(300, 300)
	weapon = Weapon:new(100, 100)
end

function love.update(dt)
	player:update(dt)
end

function love.draw()
	player:draw()
	weapon:draw()
end
