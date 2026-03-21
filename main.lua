Object = require "lib/classic"

local Game = require("classes.game.init")
local game

function love.load()
	-- important for pixel art
	love.graphics.setDefaultFilter("nearest", "nearest")

	game = Game()
end

function love.update(dt)
	game:update(dt)
end

function love.draw()
	love.graphics.push()
	love.graphics.translate(game:getMapOffset())
	game:draw()
	love.graphics.pop()
end
