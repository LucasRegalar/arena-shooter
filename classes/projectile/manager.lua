--- ProjectileManager class.
-- Owns the full projectile lifecycle: spawning, movement, collision resolution,
-- range tracking, and cleanup. Decoupled from Player and Weapon — receives
-- player state as parameters rather than storing a permanent reference.

local Projectile = require("classes.projectile.init")
local projectileConfig = require("classes.projectile.config")
local playerConfig = require("classes.player.config")
local input = require("classes.player.input")

--- @class ProjectileManager : Object
--- @field bumpWorld table Shared Bump collision world
--- @field projectiles table List of active Projectile instances
--- @field fireCooldownTimer number Seconds remaining before the next shot is allowed
local ProjectileManager = Object:extend()

--- Collision filter for projectiles.
-- Walls use "touch" response (stop at contact point).
-- Everything else (player, other projectiles) is ignored.
local function projectileCollisionFilter(item, other)
	if other.layer == "walls" then
		return "touch"
	end
	return nil
end

--- Creates a new ProjectileManager.
--- @param bumpWorld table The shared Bump collision world from the Map
function ProjectileManager:new(bumpWorld)
	self.bumpWorld = bumpWorld
	self.projectiles = {}
	self.fireCooldownTimer = 0
end

--- Updates all projectiles and handles firing.
-- Checks fire input, spawns new projectiles, moves existing ones through
-- the Bump collision world, and removes dead projectiles.
--- @param dt number Delta time since the last frame
--- @param player Player The player entity (read for position and aim direction)
function ProjectileManager:update(dt, player)
	self.fireCooldownTimer = math.max(self.fireCooldownTimer - dt, 0)
	self:tryFire(player)
	self:moveProjectiles(dt)
	self:removeDeadProjectiles()
end

--- Attempts to fire a new projectile if input is active and cooldown has elapsed.
--- @param player Player The player entity
function ProjectileManager:tryFire(player)
	if self.fireCooldownTimer > 0 then
		return
	end

	if not input.isFirePressed(playerConfig, player.playerIndex) then
		return
	end

	self:spawnProjectile(player)
	self.fireCooldownTimer = projectileConfig.fire_rate
end

--- Spawns a new projectile at the hand position, flying toward the crosshair.
-- The direction vector is computed from hand → crosshair, not from the raw aim
-- direction, so the projectile visually originates from the weapon.
--- @param player Player The player entity
function ProjectileManager:spawnProjectile(player)
	local dx = player.crossHairX - player.handX
	local dy = player.crossHairY - player.handY
	local magnitude = math.sqrt(dx * dx + dy * dy)

	-- Fall back to the stored aim direction if hand and crosshair overlap
	local dirX, dirY
	if magnitude < 1 then
		dirX = player.aimDirectionX
		dirY = player.aimDirectionY
	else
		dirX = dx / magnitude
		dirY = dy / magnitude
	end

	local projectile = Projectile(
		player.handX, player.handY,
		dirX, dirY,
		projectileConfig
	)

	-- Register in the Bump world using top-left coordinates
	self.bumpWorld:add(
		projectile,
		projectile.x - projectile.halfSize,
		projectile.y - projectile.halfSize,
		projectile.size,
		projectile.size
	)
	
	table.insert(self.projectiles, projectile)
end

--- Moves all active projectiles through the Bump collision world.
-- Destroys projectiles that hit a wall or exceed their max range.
--- @param dt number Delta time since the last frame
function ProjectileManager:moveProjectiles(dt)
	for _, projectile in ipairs(self.projectiles) do
		local dx, dy = projectile:getMovementDelta(dt)
		local hs = projectile.halfSize

		-- Convert center coords to top-left for Bump
		local goalX = projectile.x - hs + dx
		local goalY = projectile.y - hs + dy

		local actualX, actualY, cols, colCount = self.bumpWorld:move(
			projectile, goalX, goalY, projectileCollisionFilter
		)

		-- Convert back to center coords
		projectile.x = actualX + hs
		projectile.y = actualY + hs

		-- Track distance traveled for range-based lifetime
		local movedDist = math.sqrt(dx * dx + dy * dy)
		projectile.distanceTraveled = projectile.distanceTraveled + movedDist

		if colCount > 0 or projectile.distanceTraveled >= projectile.maxRange then
			projectile:destroy()
		end
	end
end

--- Removes destroyed projectiles from the list and the Bump world.
-- Iterates in reverse to avoid index shifting during removal.
function ProjectileManager:removeDeadProjectiles()
	for i = #self.projectiles, 1, -1 do
		local projectile = self.projectiles[i]
		if not projectile.alive then
			self.bumpWorld:remove(projectile)
			table.remove(self.projectiles, i)
		end
	end
end

--- Returns the list of active projectiles (read-only access for the renderer).
--- @return table List of active Projectile instances
function ProjectileManager:getProjectiles()
	return self.projectiles
end

return ProjectileManager
