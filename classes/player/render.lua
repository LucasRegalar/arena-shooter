local anim8 = require('lib.anim8')

local playerConfig = require('classes.player.config')

local render = {}

local spriteSheet
local animationGrid

local function ensureSharedAssets()
	if spriteSheet ~= nil then
		return
	end

	spriteSheet = love.graphics.newImage('sprites/NuclearLeak_CharacterAnim_1.2/character_20x20_pink.png')

	local spriteSheetWidth, spriteSheetHeight = spriteSheet:getDimensions()
	animationGrid = anim8.newGrid(
		playerConfig.sprite_size,
		playerConfig.sprite_size,
		spriteSheetWidth,
		spriteSheetHeight
	)
end

function render.init(player)
	ensureSharedAssets()

	player.renderOriginX = playerConfig.sprite_size / 2
	player.renderOriginY = playerConfig.sprite_size / 2
	player.renderAnimation = anim8.newAnimation(animationGrid('1-4', 2), 0.25)
end

function render.update(player, dt)
	if player.renderAnimation == nil then
		render.init(player)
	end

	player.renderAnimation:update(dt)
end

function render.getData(player)
	local drawX = player.x
	local drawY = player.y
	local boundsX = drawX - player.renderOriginX * player.scale
	local boundsY = drawY - player.renderOriginY * player.scale
	local boundsSize = playerConfig.sprite_size * player.scale
	local visualOffsetY = playerConfig.sprite_offset_y * player.scale

	return {
		drawX = drawX,
		drawY = drawY,
		boundsX = boundsX,
		boundsY = boundsY,
		boundsSize = boundsSize,
		visualOffsetY = visualOffsetY
	}
end

function render.draw(player)
	if player.renderAnimation == nil then
		render.init(player)
	end

	local renderData = render.getData(player)
	local scaleX = player.isFacingLeft and -player.scale or player.scale

	player.renderAnimation:draw(
		spriteSheet,
		renderData.drawX,
		renderData.drawY - renderData.visualOffsetY,
		0,
		scaleX,
		player.scale,
		player.renderOriginX,
		player.renderOriginY
	)

	return renderData
end

return render
