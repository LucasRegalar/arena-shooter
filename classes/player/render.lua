local render = {}

local playerConfig = require('classes.player.config')
local gameConfig = require('config')

-- todo: continue the refactor of the render / animation process
-- todo: fix blur when drawing sprite
local function getRenderData(
	playerX,
	playerY,
	crossHairX,
	crossHairY,
	isFacingLeft,
	animation
)
	local spriteSize = playerConfig.sprite_size
	local spriteCenterX = spriteSize / 2
	local spriteCenterY = spriteSize / 2

	local scale = playerConfig.sprite_scale
	-- bounds = sprite rectangle ater scaling
	local boundsX = spriteCenterX
	-- boundsX/boundsY = “where is the sprite’s real top-left after scaling and origin are applied?”
	local boundsY = spriteCenterY
	local boundsSize = spriteSize
	local visualOffsetY = playerConfig.sprite_offset_y
	local sprite_sheet = playerConfig.sprite_sheet

	return {
		playerX = playerX,
		playerY = playerY,
		crossHairX = crossHairX,
		crossHairY = crossHairY,
		isFacingLeft = isFacingLeft,
		animation = animation,
		scale = scale,
		spriteCenterX = spriteCenterX,
		spriteCenterY = spriteCenterY,
		boundsX = boundsX,
		boundsY = boundsY,
		boundsSize = boundsSize,
		visualOffsetY = visualOffsetY,
		sprite_sheet = sprite_sheet,
		spriteSize = spriteSize
	}
end

local function drawPlayer(
	renderData
)
	local scaleX = renderData.isFacingLeft and - renderData.scale or renderData.scale

	love.graphics.push()
	love.graphics.translate(renderData.playerX, renderData.playerY)
	love.graphics.scale(scaleX, renderData.scale)

	renderData.animation:draw(
		renderData.sprite_sheet,
		0,
		0 - renderData.visualOffsetY,
		0,
		1,
		1,
		renderData.spriteCenterX,
		renderData.spriteCenterY
	)

	love.graphics.pop()
end

local function drawAim(renderData)
	love.graphics.push()
	love.graphics.translate(renderData.crossHairX, renderData.crossHairY)

	love.graphics.circle("line", 0, 0, playerConfig.crosshair_radius)
	love.graphics.line(- playerConfig.crosshair_line, 0, playerConfig.crosshair_line, 0)
	love.graphics.line(0, - playerConfig.crosshair_line, 0, playerConfig.crosshair_line)

	love.graphics.pop()
end

local function drawDebug(renderData)
	local scaleX = renderData.isFacingLeft and - renderData.scale or renderData.scale

	love.graphics.push()
	love.graphics.translate(renderData.playerX, renderData.playerY)
	love.graphics.scale(scaleX, renderData.scale)

	-- rectangle displaying the acutal sprite width
	love.graphics.rectangle("line", - renderData.spriteSize / 2, - renderData.spriteSize / 2, renderData.spriteSize, renderData.spriteSize)

	-- player position
	love.graphics.circle("fill", 0, 0, 1)

	love.graphics.pop()
end

function render.draw(
	playerX,
	playerY,
	crossHairX,
	crossHairY,
	isFacingLeft,
	animation
)
	local renderData = getRenderData(
		playerX,
		playerY,
		crossHairX,
		crossHairY,
		isFacingLeft,
		animation
	)
	drawPlayer(renderData)
	drawAim(renderData)
	if gameConfig.debug then
		drawDebug(renderData)
	end
end

return render
