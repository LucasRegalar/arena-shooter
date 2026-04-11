Object = require "lib.classic"
push = require "lib.push"

local Game = require("classes.datamodel.game.init")
local GameRenderer = require("classes.ui.gameRenderer")
local game
local gameRenderer

function love.load()
	local screenW, screenH = love.window.getDesktopDimensions()
	push:setupScreen(720, 448, screenW, screenH, {
		fullscreen = true,
		fullscreentype = "desktop",
		resizable = false,
	})

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

function love.resize(w, h)
	push:resize(w, h)
end
