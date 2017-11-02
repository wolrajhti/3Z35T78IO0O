package.cpath = package.cpath .. ';./SharedLibrary/?.so'

class = require('middleclass.middleclass')
Vector = require('geometry.vector')
VerticesConverter = require('geometry.verticesConverter')
Curve = require('geometry.curve')

local NavMesh = require('NavMesh')

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
	navMesh = NavMesh(800, 600)

	navMesh.areas['GROUND'] = 10
	navMesh.areas['JUMP'] = 25
	navMesh.areas['DIRT'] = 50

	navMesh:addTriangles('GROUND', {
		0, 0,   400, 0,   400, 300,
		0, 0,   400, 300,   0, 300,
		100, 100,   200, 100,   200, 500,
		100, 100,  200, 500,   100, 500,
		50, 400,   400, 400,   400, 450,
		50, 400,   400, 450,   50, 450
	})

	navMesh:addTriangles('DIRT', {
		250, 100,   350, 100,   350, 500,
		250, 100,   350, 500,   250, 500
	})

	navMesh:addOffmeshConnection('JUMP', {
		startPos = {150, 75},
		endPos = {150, 475},
		radius = 10,
		dir = 2
	})

	navMesh:build(10)
	-- navMesh:build(5)
	-- navMesh:build(2)

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
	love.graphics.setColor(255, 0, 0, 100)
	love.graphics.circle('fill', 150,  75, 10)
	love.graphics.circle('fill', 150, 475, 10)
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
