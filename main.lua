class = require('middleclass.middleclass')
Vector = require('geometry.vector')
VerticesConverter = require('geometry.verticesConverter')
Curve = require('geometry.curve')

local recast = require('recast')

love.graphics.setLineWidth(2)
love.graphics.setLineStyle('rough')

function love.load()
	-- c1 = Curve({
	-- 	Vector(100, 100),
	-- 	Vector(400, 200),
	-- 	Vector(700, 500)
	-- })
	-- c2 = Curve({
	-- 	Vector(100, 100),
	-- 	Vector(300, 300)
	-- })
	-- t1, t2 = 0, 0
end

function love.update(dt)
	recast.update(dt)
	-- t1 = (t1 +  25 * dt / c1.length) % 1
	-- t2 = (t2 +  25 * dt / c2.length) % 1
end

function love.draw()
	recast.drawVertices()
	recast.drawTriangles()
	recast.drawCurrentVertices()
	recast.drawRCPolys()
	recast.drawRCPath()
	recast.drawRCSPath()
	recast.drawStartEnd()
	-- love.graphics.setColor(255, 255, 255)
	-- c1:draw()
	-- local x1, y1 = c1:getPosition(t1):unpack()
	-- love.graphics.circle('fill', x1, y1, 15)
	-- c2:draw()
	-- local x2, y2 = c2:getPosition(t2):unpack()
	-- love.graphics.circle('fill', x2, y2, 15)
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
	end
end
