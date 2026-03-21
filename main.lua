Object = require "lib.classic"

local Game = require("classes.game.init")
local GameRenderer = require("classes.ui.gameRenderer")
local game
local gameRenderer

function love.load()
	game = Game()
	gameRenderer = GameRenderer(game)
end

function love.update(dt)
	game:update(dt)
	gameRenderer:update(dt)
end

function love.draw()
	gameRenderer:draw()
end
