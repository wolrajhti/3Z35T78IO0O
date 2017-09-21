package.cpath = package.cpath .. ';./SharedLibrary/?.so'

class = require('middleclass.middleclass')
Vector = require('geometry.vector')
VerticesConverter = require('geometry.verticesConverter')
Curve = require('geometry.curve')

local recast = require('recast')

love.graphics.setLineWidth(2)
love.graphics.setLineStyle('rough')

function love.load()
end

function love.update(dt)
	recast.update(dt)
end

function love.draw()
	recast.drawVertices()
	recast.drawTriangles()
	recast.drawCurrentVertices()
	recast.drawRCPolys()
	recast.drawRCPath()
	recast.drawRCSPath()
	recast.drawStartEnd()
end

function love.mousepressed(x, y, button)
	recast.addVertex(x, y)
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
		recast.export()
	end
end
