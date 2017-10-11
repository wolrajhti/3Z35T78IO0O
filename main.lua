package.cpath = package.cpath .. ';./SharedLibrary/?.so'

class = require('middleclass.middleclass')
Vector = require('geometry.vector')
VerticesConverter = require('geometry.verticesConverter')
Curve = require('geometry.curve')

local recast = require('recast')

love.graphics.setLineWidth(2)
love.graphics.setLineStyle('rough')

-- local Mesh = require('mesh')
--
-- local mesh = Mesh()
-- local buffer = {}
--
-- mesh:import('test.obj')

function love.load()
end

function love.update(dt)
	local needsCornersUpdate = false
	recast.update(dt)
	if love.keyboard.isDown('up') then
		needsCornersUpdate = recast.moveTargetPosition(0, -4)
	end
	if love.keyboard.isDown('down') then
		needsCornersUpdate = recast.moveTargetPosition(0, 4)
	end
	if love.keyboard.isDown('left') then
		needsCornersUpdate = recast.moveTargetPosition(-4, 0)
	end
	if love.keyboard.isDown('right') then
		needsCornersUpdate = recast.moveTargetPosition(4, 0)
	end
	needsCornersUpdate = recast:updatePos(dt) or needsCornersUpdate
	if needsCornersUpdate then
		recast.findCorners()
	end
	recast.optimizePathTopology(dt)
end

function love.draw()
	-- if #buffer > 4 then
	-- 	love.graphics.line(buffer)
	-- 	love.graphics.line(buffer[#buffer - 1], buffer[#buffer], buffer[1], buffer[2])
	-- end
	-- mesh:drawXZ()
	recast.drawVertices()
	recast.drawTriangles()
	recast.drawCurrentVertices()
	recast.drawRCPolys()
	recast.drawRCPath()
	recast.drawRCSPath()
	recast.drawStartEnd()
	recast.drawCorridorCorners()
end

function love.mousepressed(x, y, button)
	recast.addVertex(x, y)
	-- table.insert(buffer, x)
	-- table.insert(buffer, y)
end

function love.keypressed(key)
	if key == 'i' then
		recast.addPolygon()
	elseif key == 's' then
		recast.setStart(love.mouse.getPosition())
	elseif key == 'e' then
		recast.setEnd(love.mouse.getPosition())
	elseif key == 'o' then
		recast.decreaseWalkableRadius()
	elseif key == 'p' then
		recast.increaseWalkableRadius()
	elseif key == 'u' then
		recast:setPolyMesh()
		recast.setNavMesh()
	elseif key == 'space' then
		recast.setPath()
	elseif key == 'x' then
		recast.export('test.obj')
	end
	-- if key == 'space' then
	-- 	mesh:addPolygonXZ(buffer)
	-- 	buffer = {}
	-- elseif key == 'x' then
	-- 	mesh:export('test.obj')
	-- end
end
