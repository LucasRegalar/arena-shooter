--- Projectile renderer.
-- Draws all active projectiles as simple filled circles.
-- Reads projectile data from the ProjectileManager.

--- @class ProjectileRenderer : Object
--- @field projectileManager ProjectileManager Source of active projectile data
local ProjectileRenderer = Object:extend()

--- Creates a new ProjectileRenderer.
--- @param projectileManager ProjectileManager The manager that owns the projectile list
function ProjectileRenderer:new(projectileManager)
	self.projectileManager = projectileManager
end

--- Draws all active projectiles in world space.
-- Uses a filled circle with a bright yellow color for visibility.
function ProjectileRenderer:draw()
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(1, 1, 0, 1)

	for _, projectile in ipairs(self.projectileManager:getProjectiles()) do
		love.graphics.circle("fill", projectile.x, projectile.y, projectile.halfSize)
	end

	love.graphics.setColor(r, g, b, a)
end

return ProjectileRenderer
