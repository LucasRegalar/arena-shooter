--- Projectile class.
-- Represents a single bullet in flight. Stores position, direction, speed,
-- and tracks distance traveled for range-based lifetime.
-- Movement and collision are resolved externally by the ProjectileManager,
-- following the same pattern as Player (which doesn't call bumpWorld:move itself).

local GameObject = require("classes.gameObject")

--- @class Projectile : GameObject
--- @field dirX number Normalized X component of the travel direction
--- @field dirY number Normalized Y component of the travel direction
--- @field speed number Movement speed in pixels per second
--- @field size number Side length of the square collision hitbox
--- @field halfSize number Half the hitbox size, for center-to-topleft conversion
--- @field alive boolean Whether the projectile is still active
--- @field distanceTraveled number Accumulated travel distance in pixels
--- @field maxRange number Maximum travel distance before auto-destroy
local Projectile = GameObject:extend()

--- Creates a new Projectile.
--- @param x number Spawn X position (center-based, in game-world coordinates)
--- @param y number Spawn Y position (center-based, in game-world coordinates)
--- @param dirX number Normalized X direction
--- @param dirY number Normalized Y direction
--- @param config table Projectile config with speed, size, and max_range
function Projectile:new(x, y, dirX, dirY, config)
	Projectile.super.new(self, x, y)

	self.dirX = dirX
	self.dirY = dirY
	self.speed = config.speed
	self.size = config.size
	self.halfSize = config.size / 2
	self.maxRange = config.max_range
	self.alive = true
	self.distanceTraveled = 0
end

--- Returns the desired movement delta for this frame.
-- Does not apply the movement — the ProjectileManager resolves collision.
--- @param dt number Delta time since the last frame
--- @return number dx Desired horizontal movement in pixels
--- @return number dy Desired vertical movement in pixels
function Projectile:getMovementDelta(dt)
	return self.dirX * self.speed * dt, self.dirY * self.speed * dt
end

--- Marks the projectile for removal.
function Projectile:destroy()
	self.alive = false
end

return Projectile
