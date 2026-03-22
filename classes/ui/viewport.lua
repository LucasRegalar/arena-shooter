--- Viewport class.
-- Computes a stretch-to-fit transform that maps game-world coordinates to screen
-- pixels. Provides coordinate conversion between screen space and world space.
--
-- The viewport scale is independent of mapConfig.scale (which defines the game
-- coordinate grid). This class only controls how game coordinates appear on screen.

--- @class Viewport : Object
--- @field gameWidth number Width of the game world in game coordinates
--- @field gameHeight number Height of the game world in game coordinates
--- @field scale number Uniform scale factor to stretch the game world to fit the display
--- @field offsetX number Horizontal pixel offset for centering (letterboxing)
--- @field offsetY number Vertical pixel offset for centering (pillarboxing)
local Viewport = Object:extend()

--- Creates a new Viewport.
-- Computes a uniform scale factor so the game world fills as much of the window
-- as possible while preserving aspect ratio. Any remaining space is split evenly
-- as letterbox/pillarbox bars.
--- @param gameWidth number Width of the game world in game coordinates
--- @param gameHeight number Height of the game world in game coordinates
function Viewport:new(gameWidth, gameHeight)
	self.gameWidth = gameWidth
	self.gameHeight = gameHeight

	local windowWidth, windowHeight = love.graphics.getDimensions()

	-- Uniform scale: pick the axis that constrains first so nothing gets clipped
	self.scale = math.min(windowWidth / gameWidth, windowHeight / gameHeight)

	-- Center the scaled game world within the window
	self.offsetX = math.floor((windowWidth - gameWidth * self.scale) / 2)
	self.offsetY = math.floor((windowHeight - gameHeight * self.scale) / 2)
end

--- Applies the viewport transform to the Love2D graphics state.
-- Call this inside a love.graphics.push()/pop() pair before drawing world-space
-- entities. Translates to the centering offset, then scales to stretch-to-fit.
function Viewport:apply()
	love.graphics.translate(self.offsetX, self.offsetY)
	love.graphics.scale(self.scale, self.scale)
end

--- Converts screen-space coordinates to game-world coordinates.
-- Reverses the viewport transform: subtracts the centering offset, then divides
-- by the scale factor. Used for mouse input → world position conversion.
--- @param screenX number X position in screen pixels
--- @param screenY number Y position in screen pixels
--- @return number worldX X position in game-world coordinates
--- @return number worldY Y position in game-world coordinates
function Viewport:screenToWorld(screenX, screenY)
	local worldX = (screenX - self.offsetX) / self.scale
	local worldY = (screenY - self.offsetY) / self.scale
	return worldX, worldY
end

return Viewport
