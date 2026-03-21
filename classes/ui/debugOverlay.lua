--- Debug overlay HUD.
-- Displays diagnostic information (player coordinates) in the bottom-left
-- corner of the screen. Only visible when `gameConfig.debug` is true.
-- Drawn in screen space (outside the map translate) so it stays fixed on screen.

local gameConfig = require("classes.game.config")

--- @class DebugOverlay : Object
--- @field padding number Inner padding in pixels
--- @field lineHeight number Vertical spacing per text line in pixels
local DebugOverlay = Object:extend()

--- Creates a new DebugOverlay instance.
function DebugOverlay:new()
	self.padding = 6
	self.lineHeight = 16
end

--- Draws the debug overlay if debug mode is enabled.
-- Renders a semi-transparent black background with player coordinate text
-- in the bottom-left corner of the screen.
--- @param player Player The player whose coordinates to display
function DebugOverlay:draw(player)
	if not gameConfig.debug then
		return
	end

	local lines = {
		string.format("Player X: %.1f", player.x),
		string.format("Player Y: %.1f", player.y),
	}

	local font = love.graphics.getFont()
	local textWidth = 0
	for _, line in ipairs(lines) do
		local w = font:getWidth(line)
		if w > textWidth then
			textWidth = w
		end
	end

	local boxWidth = textWidth + self.padding * 2
	local boxHeight = #lines * self.lineHeight + self.padding * 2
	local screenHeight = love.graphics.getHeight()
	local boxX = 0
	local boxY = screenHeight - boxHeight

	-- Semi-transparent black background
	love.graphics.setColor(0, 0, 0, 0.5)
	love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight)

	-- White text
	love.graphics.setColor(1, 1, 1, 1)
	for i, line in ipairs(lines) do
		love.graphics.print(line, boxX + self.padding, boxY + self.padding + (i - 1) * self.lineHeight)
	end

	-- Reset color
	love.graphics.setColor(1, 1, 1, 1)
end

return DebugOverlay
