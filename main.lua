local Player = require("classes.player")
local player

function love.load()
	-- important for pixel art
	love.graphics.setDefaultFilter("nearest", "nearest")
	player = Player:new(300, 300)
end

function love.update(dt)
	player:update(dt)
end

function love.draw()
	player:draw()
end
