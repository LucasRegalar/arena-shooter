local render = {}

local playerConfig = require('classes.player.config')
local gameConfig = require('config')

-- todo: continue the refactor of the render / animation process
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
	local boundsX = playerX - spriteCenterX * scale
	-- boundsX/boundsY = “where is the sprite’s real top-left after scaling and origin are applied?”
	local boundsY = playerY - spriteCenterY * scale
	local boundsSize = spriteSize * scale
	local boundsCenterX = boundsX + boundsSize / 2
	local boundsCenterY = boundsY + boundsSize / 2
	local visualOffsetY = playerConfig.sprite_offset_y * scale
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
		boundsCenterX = boundsCenterX,
		boundsCenterY = boundsCenterY,
		visualOffsetY = visualOffsetY,
		sprite_sheet = sprite_sheet,
	}
end

local function drawPlayer(
	renderData
)
	local scaleX = renderData.isFacingLeft and - renderData.scale or renderData.scale

	renderData.animation:draw(
		renderData.sprite_sheet,
		renderData.playerX,
		renderData.playerY - renderData.visualOffsetY,
		0,
		scaleX,
		renderData.scale,
		renderData.spriteCenterX,
		renderData.spriteCenterY
	)
end

local function drawAim(renderData)
	love.graphics.circle("line", renderData.crossHairX, renderData.crossHairY, playerConfig.crosshair_radius)
	love.graphics.line(renderData.crossHairX - playerConfig.crosshair_line, renderData.crossHairY, renderData.crossHairX + playerConfig.crosshair_line, renderData.crossHairY)
	love.graphics.line(renderData.crossHairX, renderData.crossHairY - playerConfig.crosshair_line, renderData.crossHairX, renderData.crossHairY + playerConfig.crosshair_line)
end

local function drawDebug(renderData)
	love.graphics.setColor(0, 1, 0) -- rgp green
	love.graphics.rectangle("line", renderData.boundsX, renderData.boundsY, renderData.boundsSize, renderData.boundsSize)

	love.graphics.setColor(1, 0, 0) -- rgp red
	love.graphics.circle("fill", renderData.playerX, renderData.playerY, 3)

	love.graphics.setColor(0, 0.8, 1) -- cyan
	love.graphics.circle("fill", renderData.boundsCenterX, renderData.boundsCenterY, 3)

	love.graphics.setColor(1, 1, 0) -- yellow
	love.graphics.circle("fill", renderData.boundsX, renderData.boundsY, 2)

	love.graphics.setColor(1, 1, 1) -- white
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
