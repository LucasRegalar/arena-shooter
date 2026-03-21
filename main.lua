local Player = require("classes.player.init")
local Weapon = require("classes.weapon")
local Map = require("classes.map.init")
local player
local weapon
local map

function love.load()
	love.window.setMode(0, 0, {fullscreen = true, fullscreentype = "desktop"})
	-- important for pixel art
	love.graphics.setDefaultFilter("nearest", "nearest")
	map = Map:new("maps.default")
	player = Player(300, 300, 1)
	weapon = Weapon:new(100, 100)
end

function love.update(dt)
	player:update(dt)
end

function love.draw()
	-- Shared translate so all objects use map-space coordinates
	love.graphics.push()
	love.graphics.translate(map:getOffset())
	map:draw()
	player:draw()
	player:drawAim()
	weapon:draw()
	love.graphics.pop()
end
