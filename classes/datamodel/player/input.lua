-- - input.lua should only deal with reading controls and returning values
--  - it should not know how to animate or draw the player

local input = {}

local function getGamepad(playerIndex)

	local joysticks = love.joystick.getJoysticks()
	local gamepad = joysticks[playerIndex]

	return gamepad;
end

function input.getMovementVector(config, playerIndex)

	local moveX, moveY = 0, 0

	if love.keyboard.isDown("o") or love.keyboard.isDown("d")  then
		moveX = moveX + 1
	end
	if love.keyboard.isDown("8") or love.keyboard.isDown("w") then
		moveY = moveY - 1
	end
	if love.keyboard.isDown("i") or love.keyboard.isDown("s") then
		moveY = moveY + 1
	end
	if love.keyboard.isDown("u") or love.keyboard.isDown("a") then
		moveX = moveX - 1
	end

	local gamepad = getGamepad(playerIndex)

	if gamepad then
		local stickX = gamepad:getGamepadAxis("leftx")
		-- this has to be - y or the controls feel inverted
		local stickY = - gamepad:getGamepadAxis("lefty")

		if math.abs(stickX) >= config.gamepad_deadzone then
			moveX = moveX + stickX
		end

		if math.abs(stickY) >= config.gamepad_deadzone then
			moveY = moveY + stickY
		end
	end

	local magnitude = math.sqrt(moveX * moveX + moveY * moveY)
	if magnitude > 1 then
		moveX = moveX / magnitude
		moveY = moveY / magnitude
	end

	return moveX, moveY
end

function input.getAimVector(config, playerIndex)

	local directionX = 0
	local directionY = 0
	local distance = 0

	local gamepad = getGamepad(playerIndex)

	if not gamepad then

		return directionX, directionY, distance
	end

	local aimX = gamepad:getGamepadAxis("rightx")
	-- this has to be - y or the controls feel inverted
	local aimY = - gamepad:getGamepadAxis("righty")
	local magnitude = math.sqrt(aimX * aimX + aimY * aimY)

	if magnitude < config.gamepad_deadzone then

		return directionX, directionY, distance

	end

	-- This makes aiming distance begin smoothly after the deadzone instead of jumping.
	local normalizedMagnitude = (magnitude - config.gamepad_deadzone) / (1 - config.gamepad_deadzone)
	-- safty clamp to have max 1 magnitude. Just in case
	if normalizedMagnitude > 1 then
		normalizedMagnitude = 1
	end

	-- convert raw stick vector into pure direction vector
	directionX = aimX / magnitude
	-- convert raw stick vector into pure direction vector
	directionY = aimY / magnitude
	distance = normalizedMagnitude

	return directionX, directionY, distance
end

--- Returns whether the fire button is currently pressed.
-- Checks left mouse button and gamepad right shoulder.
--- @param config table Player config with fire_gamepad_button
--- @param playerIndex number The player index for gamepad lookup
--- @return boolean True if any fire input is active
function input.isFirePressed(config, playerIndex)
	if love.mouse.isDown(1) then
		return true
	end

	local gamepad = getGamepad(playerIndex)
	if gamepad and gamepad:isGamepadDown(config.fire_gamepad_button) then
		return true
	end

	return false
end

--- Returns an aim vector from the mouse cursor position in world space.
-- Converts the mouse screen position to world coordinates via the viewport,
-- then computes a direction vector from the player to the cursor.
-- Returns the same (directionX, directionY, distance) signature as getAimVector
-- so the two can be used interchangeably.
--- @param playerX number Player center X in world coordinates
--- @param playerY number Player center Y in world coordinates
--- @param viewport Viewport The viewport for screen-to-world conversion
--- @return number directionX Normalized X component of the aim direction
--- @return number directionY Normalized Y component of the aim direction
--- @return number distance Normalized aim distance (0 to 1, relative to crosshair_max_distance)
function input.getMouseAimVector(playerX, playerY, viewport, config)
	local mouseScreenX, mouseScreenY = love.mouse.getPosition()
	local mouseWorldX, mouseWorldY = viewport:screenToWorld(mouseScreenX, mouseScreenY)

	local dx = mouseWorldX - playerX
	local dy = mouseWorldY - playerY
	local magnitude = math.sqrt(dx * dx + dy * dy)

	if magnitude < 1 then
		return 0, 0, 0
	end

	local directionX = dx / magnitude
	local directionY = dy / magnitude

	-- Normalize distance to 0-1 range relative to crosshair_max_distance,
	-- matching the gamepad aim vector convention
	local distance = math.min(magnitude / config.crosshair_max_distance, 1)

	return directionX, directionY, distance
end

return input

