--- Map class.
-- Manages a tile-based map as a pure data model, powered by STI (Simple Tiled Implementation).
-- Loads a Tiled-exported Lua map via STI, initializes a Bump collision world from
-- tiles marked as collidable in Tiled, and derives a passability grid from tile data.

local sti = require("lib.sti")
local bump = require("lib.bump")
local config = require("classes.map.config")

--- @class Map
--- @field tiledMap table STI map instance (handles tileset loading and rendering)
--- @field bumpWorld table Bump collision world for AABB collision detection
--- @field passability table 2D boolean grid (true = passable, false = impassable)
--- @field rows number Number of tile rows in the grid
--- @field cols number Number of tile columns in the grid
local Map = Object:extend()

--- Creates a new Map instance.
-- Loads a Tiled map via STI, builds a passability grid by scanning the "walls" layer,
-- and creates a Bump collision world with scaled collision rects for each impassable tile.
--- @param mapPath string File path to a Tiled-exported Lua map (e.g. "assets/maps/map.lua")
function Map:new(mapPath)
	self.tiledMap = sti(mapPath)
	self.cols = self.tiledMap.width
	self.rows = self.tiledMap.height

	-- Build passability grid from the "walls" layer.
	-- Start with all tiles passable, then mark non-empty tiles as impassable.
	self.passability = {}
	for y = 1, self.rows do
		self.passability[y] = {}
		for x = 1, self.cols do
			self.passability[y][x] = true
		end
	end

	local wallsLayer = self.tiledMap.layers["walls"]
	if wallsLayer then
		if wallsLayer.chunks then
			-- Chunked map: iterate each chunk's local data and map to global coordinates
			for _, chunk in ipairs(wallsLayer.chunks) do
				for localY = 1, chunk.height do
					for localX = 1, chunk.width do
						if chunk.data[localY][localX] then
							local globalX = chunk.x + localX
							local globalY = chunk.y + localY
							if globalY >= 1 and globalY <= self.rows and globalX >= 1 and globalX <= self.cols then
								self.passability[globalY][globalX] = false
							end
						end
					end
				end
			end
		elseif wallsLayer.data then
			-- Non-chunked map: data is a flat 2D grid
			for y = 1, self.rows do
				for x = 1, self.cols do
					if wallsLayer.data[y] and wallsLayer.data[y][x] then
						self.passability[y][x] = false
					end
				end
			end
		end
	end

	-- Create Bump collision world from the passability grid.
	-- We build this ourselves rather than using STI's bump_init because
	-- bump_init doesn't support chunked maps (layer.data is nil for chunks).
	-- Cell size matches the scaled tile size for optimal spatial hashing.
	local tilePixels = config.tile_size * config.scale
	self.bumpWorld = bump.newWorld(tilePixels)
	for y = 1, self.rows do
		for x = 1, self.cols do
			if not self.passability[y][x] then
				local obj = { x = x, y = y, layer = "walls" }
				self.bumpWorld:add(obj, (x - 1) * tilePixels, (y - 1) * tilePixels, tilePixels, tilePixels)
			end
		end
	end
end

--- Updates the STI map (handles tile animations).
--- @param dt number Delta time since the last frame
function Map:update(dt)
	self.tiledMap:update(dt)
end

--- Returns the total pixel width of the map at render scale.
--- @return number Width in pixels (scaled)
function Map:getPixelWidth()
	return self.cols * config.tile_size * config.scale
end

--- Returns the total pixel height of the map at render scale.
--- @return number Height in pixels (scaled)
function Map:getPixelHeight()
	return self.rows * config.tile_size * config.scale
end

--- Returns whether the tile at the given grid coordinates is passable.
--- @param grid_x number Column index (1-based)
--- @param grid_y number Row index (1-based)
--- @return boolean False if out of bounds or impassable, true if passable
function Map:isPassable(grid_x, grid_y)
	if grid_y < 1 or grid_y > self.rows or grid_x < 1 or grid_x > self.cols then
		return false
	end
	return self.passability[grid_y][grid_x]
end

--- Returns the tile GID at the given grid coordinates from the "walls" layer.
--- @param grid_x number Column index (1-based)
--- @param grid_y number Row index (1-based)
--- @return number|nil Tile GID, or nil if out of bounds or empty
function Map:getTileAt(grid_x, grid_y)
	if grid_y < 1 or grid_y > self.rows or grid_x < 1 or grid_x > self.cols then
		return nil
	end
	local wallsLayer = self.tiledMap.layers["walls"]
	if not wallsLayer then
		return nil
	end
	if wallsLayer.data and wallsLayer.data[grid_y] then
		local tile = wallsLayer.data[grid_y][grid_x]
		return tile and tile.gid or 0
	end
	return 0
end

return Map
