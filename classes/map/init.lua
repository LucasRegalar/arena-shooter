--- Map class.
-- Manages a tile-based grid world as a pure data model.
-- Loads map data from an external Lua file and builds a grid of MapElement
-- objects (Floor/Wall/Water) for game logic such as passability checks.

local config = require("classes.map.config")
local Floor = require("classes.map.elements.floor")
local Wall = require("classes.map.elements.wall")
local Water = require("classes.map.elements.water")

--- @class Map
--- @field grid table 2D array of raw tile type integers (0 = floor, 1 = wall, 2 = water)
--- @field elements table 2D array of MapElement instances (Floor or Wall)
--- @field rows number Number of tile rows in the grid
--- @field cols number Number of tile columns in the grid
local Map = Object:extend()

--- Creates a new Map instance.
-- Loads grid data from the given module path and builds MapElement objects
-- for each cell.
--- @param mapDataPath string Module path to a Lua file returning a 2D grid table (e.g. "maps.default")
function Map:new(mapDataPath)
	-- Load raw tile grid from external data file
	self.grid = require(mapDataPath)
	self.rows = #self.grid
	self.cols = #self.grid[1]

	-- Build element grid: convert raw integers into MapElement objects
	self.elements = {}
	for row = 1, self.rows do
		self.elements[row] = {}
		for col = 1, self.cols do
			local tile = self.grid[row][col]
			if tile == config.WALL then
				self.elements[row][col] = Wall(col, row)
			elseif tile == config.WATER then
				self.elements[row][col] = Water(col, row)
			else
				self.elements[row][col] = Floor(col, row)
			end
		end
	end
end

--- Returns the total pixel width of the map.
--- @return number Width in pixels
function Map:getPixelWidth()
	return self.cols * config.tile_size
end

--- Returns the total pixel height of the map.
--- @return number Height in pixels
function Map:getPixelHeight()
	return self.rows * config.tile_size
end

--- Returns the raw tile type integer at the given grid coordinates.
--- @param grid_x number Column index (1-based)
--- @param grid_y number Row index (1-based)
--- @return number|nil Tile type value, or nil if out of bounds
function Map:getTileAt(grid_x, grid_y)
	if grid_y < 1 or grid_y > self.rows or grid_x < 1 or grid_x > self.cols then
		return nil
	end
	return self.grid[grid_y][grid_x]
end

--- Returns the MapElement instance at the given grid coordinates.
--- @param grid_x number Column index (1-based)
--- @param grid_y number Row index (1-based)
--- @return MapElement|nil The element at that position, or nil if out of bounds
function Map:getElementAt(grid_x, grid_y)
	if grid_y < 1 or grid_y > self.rows or grid_x < 1 or grid_x > self.cols then
		return nil
	end
	return self.elements[grid_y][grid_x]
end

--- Returns whether the tile at the given grid coordinates is passable.
--- @param grid_x number Column index (1-based)
--- @param grid_y number Row index (1-based)
--- @return boolean False if out of bounds or impassable, true if passable
function Map:isPassable(grid_x, grid_y)
	local element = self:getElementAt(grid_x, grid_y)
	if element == nil then
		return false
	end
	return element:isPassable()
end

return Map
