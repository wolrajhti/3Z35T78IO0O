local recastlua = require('recastlua')

local rl = require('rl')

local context = rl.newRcContext()

-- local min = rl.newVector3f(0, 0, 0)
-- local max = rl.newVector3f(800, 2, 600)
local min = {0, 0, 0}
local max = {800, 2, 600}
--
local heightfield = rl.newRcHeightfield(context, 800, 600, min, max, 1, 1)

-- local obj = obj_loader.load('test.obj')
--
-- for i, f in ipairs(obj.f) do
-- 	print('---')
-- 	print(f[1].v, obj.v[f[1].v].x, obj.v[f[1].v].y, obj.v[f[1].v].z)
-- 	print(f[2].v, obj.v[f[2].v].x, obj.v[f[2].v].y, obj.v[f[2].v].z)
-- 	print(f[3].v, obj.v[f[3].v].x, obj.v[f[3].v].y, obj.v[f[3].v].z)
-- 	heightfield:rcRasterizeTriangle(
-- 		context,
-- 		rl.newVector3f(obj.v[f[1].v].x, obj.v[f[1].v].y, obj.v[f[1].v].z),
-- 		rl.newVector3f(obj.v[f[2].v].x, obj.v[f[2].v].y, obj.v[f[2].v].z),
-- 		rl.newVector3f(obj.v[f[3].v].x, obj.v[f[3].v].y, obj.v[f[3].v].z)
-- 	)
-- end

heightfield:rcRasterizeTriangles(context, 1, {
	0, 0, 0,   400, 0, 0,   400, 0, 300,
	0, 0, 0,   400, 0, 300,   0, 0, 300,
	100, 0, 100,   200, 0, 100,   200, 0, 500,
	100, 0, 100,  200, 0, 500,   100, 0, 500,
	50, 0, 400,   400, 0, 400,   400, 0, 450,
	50, 0, 400,   400, 0, 450,   50, 0, 450
})

heightfield:rcRasterizeTriangles(context, 2, {
	250, 0, 100,   350, 0, 100,   350, 0, 500,
	250, 0, 100,   350, 0, 500,   250, 0, 500
})

-- local rcSx, rcSy, rcEx, rcEy = 300, 150, 300, 425
local rcSx, rcSy, rcEx, rcEy = 150, 65, 300, 425

-- heightfield:printSpans()

local compactHeightfield = rl.newRcCompactHeightfield(context, 0, 0, heightfield)

compactHeightfield:rcErodeWalkableArea(context, 5)
compactHeightfield:rcBuildDistanceField(context)
compactHeightfield:rcBuildRegions(context)

local contourSet = rl.newRcContourSet(context, compactHeightfield, 10, 50)

local polyMesh = rl.newRcPolyMesh(context, contourSet)

local rawVerts = {polyMesh:getVerts()}
local rawPolys = {polyMesh:getPolys()}
local areas = {polyMesh:getAreas()}
-- print(unpack(areas))
local nvp = polyMesh:getNvp()
local rcPolys = {}

for i = 1, #rawPolys, nvp do
	local poly = {}
	for j = 0, nvp - 1 do
		if rawPolys[i + j] == 65536 then break end
		table.insert(poly, rawVerts[rawPolys[i + j] * 2 - 1])
		table.insert(poly, rawVerts[rawPolys[i + j] * 2 + 0])
	end
	-- print('poly', unpack(poly))
	table.insert(rcPolys, poly)
end

local navMesh = rl.newDtNavMesh(polyMesh, {
	-- x, y, z, x, y, z, radius, dir, area, flag, userId
	150, 1, 75, 150, 1, 475, 10, 2, 5, 12, 666
})

local offMeshConCount, offMeshConnections = navMesh:getOffMeshConnections()

print('offMeshConCount = ', offMeshConCount)

local queryFilter = rl.newDtQueryFilter()

queryFilter:setAreaCost(1, 5)
queryFilter:setAreaCost(2, 10000)
queryFilter:setAreaCost(5, 1)

local navMeshQuery = rl.newDtNavMeshQuery(navMesh)

-- local rcSx, rcSy, rcEx, rcEy = 320, 80, 75, 425

-- vS = rl.newVector3f(rcSx, 0, rcSy)
-- vE = rl.newVector3f(rcEx, 0, rcEy)
vS = {rcSx, 0, rcSy}
vE = {rcSx, 0, rcSy}

local pS = navMeshQuery:findNearestPoly(vS, navMesh, queryFilter)
local pE = navMeshQuery:findNearestPoly(vE, navMesh, queryFilter)

local npath, path = navMeshQuery:findPath(vS, vE, pS, pE, queryFilter)

local pathCorridor = rl.newDtPathCorridor()

pathCorridor:reset(pS, vS, navMesh)

pathCorridor:setCorridor(vE, path, npath, navMesh, navMeshQuery, queryFilter)

local corridorCorners = pathCorridor:findCorners(navMeshQuery, queryFilter)

-- local movePos = rl.newVector3f(0, 0, 0)
-- local moveTargetPos = rl.newVector3f(0, 0, 0)
local movePos = {0, 0, 0}
local moveTargetPos = {0, 0, 0}

-- print('corridorCorners', corridorCorners)
--
-- for k, v in ipairs(corridorCorners) do
-- 	print(k, v)
-- end

local currentVertices = {}

local vertices = {}
local triangles = {}
local index = {}
local walkableRadius = 5

-- local rcPolys = {}
-- local rcCenters = {}
local rcWalkableRadius = -1
-- local rcSx, rcSy, rcEx, rcEy = nil, nil, nil, nil
local rcThrough = {}
local rcPath = {}
local rcSPath = {}
local rcCurve = nil
local rcT = 0

local function imap(t, func)
	local tm = {}
	for i, v in ipairs(t) do
		table.insert(tm, func(i, v))
	end
	return tm
end

local TIME = 0

local recast = {
	-- construction
	addVertex = function(x, y)
		if not index[x] then index[x] = {} end
		if not index[x][y] then
			table.insert(vertices, x)
			table.insert(vertices, y)
			index[x][y] = #vertices / 2
		end
		table.insert(currentVertices, x)
		table.insert(currentVertices, y)
	end,
	addPolygon = function()
		if #currentVertices > 4 then
			local currentTriangles = love.math.triangulate(currentVertices)
			for i, t in ipairs(currentTriangles) do
				table.insert(triangles, index[t[1]][t[2]])
				table.insert(triangles, index[t[3]][t[4]])
				table.insert(triangles, index[t[5]][t[6]])
			end
			currentVertices = {}
		end
	end,
	-- io recast
	setVertices = function()
		recastlua.setVerts(unpack(vertices))
	end,
	setTriangles = function()
		local tm = imap(triangles, function(i, t) return t - 1 end)
		recastlua.setTris(unpack(tm))
	end,
	setPolyMesh = function(self)
		if rcWalkableRadius == -1 then
			self.setVertices()
			self.setTriangles()
		end
		recastlua.setPolyMesh(walkableRadius)

		local nvp = recastlua.getRcNVP()
		local vertices = {recastlua.getRcVerts()}
		local rawPolys = {recastlua.getRcPolys()}

		rcPolys = {}
		-- rcCenters = {}
		rcWalkableRadius = walkableRadius

		for i = 1, #rawPolys, nvp do
			local poly = {}
			-- local centerX, centerY, nverts = 0, 0, 0
			for j = 0, nvp - 1 do
				if rawPolys[i + j] == 65536 then break end
				table.insert(poly, vertices[rawPolys[i + j] * 2 - 1])
				table.insert(poly, vertices[rawPolys[i + j] * 2 + 0])

				-- centerX = centerX + vertices[rawPolys[i + j] * 2 - 1]
				-- centerY = centerY + vertices[rawPolys[i + j] * 2 + 0]

				-- nverts = nverts + 1
			end
			table.insert(rcPolys, poly)
			-- table.insert(rcCenters,{ x = centerX / nverts, y = centerY / nverts})
		end
	end,
	setNavMesh = function()
		recastlua.setNavMesh()
	end,
	setStart = function(x, y)
		rcSx, rcSy = x, y
	end,
	setEnd = function(x, y)
		rcEx, rcEy = x, y
	end,
	--queryPath
	setPath = function()
		local data = {recastlua.queryNavMesh(rcSx, rcSy, rcEx, rcEy)}
		local sCount = recastlua.getRcSCount()
		rcSx, rcSy = data[1], data[2]
		rcEx, rcEy = data[3], data[4]
		rcThrough = {}
		rcPath = {}
		rcSPath = {}
		rcCurve = nil
		for i = 6, #data - 2 * sCount do
			rcThrough[data[i] + 1] = true
			table.insert(rcPath, data[i] + 1)
		end
		for i = #data - 2 * sCount + 1, #data do
			table.insert(rcSPath, data[i])
		end
		local verts = {}
		for i = #data - 2 * sCount + 1, #data, 2 do
			table.insert(verts, Vector(data[i + 0], data[i + 1]))
		end
		if #verts then
			rcCurve = Curve(verts)
		end
		rcT = 0
	end,
	-- graphics
	drawTriangles = function()
		love.graphics.setColor(75, 38, 18)
		for i = 1, #triangles, 3 do
			-- love.graphics.setColor(300 * i % 255, 100 * i % 255, 50 * i % 255)
			love.graphics.polygon('fill',
				vertices[2 * triangles[i + 0] - 1], vertices[2 * triangles[i + 0]],
				vertices[2 * triangles[i + 1] - 1], vertices[2 * triangles[i + 1]],
				vertices[2 * triangles[i + 2] - 1], vertices[2 * triangles[i + 2]]
			)
		end
	end,
	drawVertices = function()
		love.graphics.setColor(100, 50, 25)
		for i = 1, #vertices, 2 do
			love.graphics.circle('fill', vertices[i], vertices[i + 1], 2)
		end
	end,
	drawCurrentVertices = function()
		love.graphics.setColor(200, 100, 50)
		for i = 1, #currentVertices, 2 do
			love.graphics.circle('fill', currentVertices[i], currentVertices[i + 1], 3)
		end
	end,
	drawRCPolys = function()
		-- love.graphics.setColor(200, 100, 25)
		-- for i, t in ipairs(rcPolys) do
		-- 	for j = 1, #t, 2 do
		-- 		if j < #t - 2 then
		-- 			love.graphics.line(t[j + 0], t[j + 1], t[j + 2], t[j + 3])
		-- 		else
		-- 			love.graphics.line(t[j + 0], t[j + 1], t[1], t[2])
		-- 		end
		-- 	end
		-- end

		for i, t in ipairs(rcPolys) do
			love.graphics.setColor(areas[i] * 50, 0, 0)
			love.graphics.polygon('fill', t)
		end
		love.graphics.setColor(200, 100, 25)
		for i, t in ipairs(rcPolys) do
			for j = 1, #t, 2 do
				if j < #t - 2 then
					love.graphics.line(t[j + 0], t[j + 1], t[j + 2], t[j + 3])
				else
					love.graphics.line(t[j + 0], t[j + 1], t[1], t[2])
				end
			end
		end
	end,
	drawRCPath = function()
		love.graphics.setColor(0, 0, 200, 120)
		for i, t in ipairs(rcPolys) do
			if rcThrough[i] then
				love.graphics.polygon('fill', unpack(t))
			end
		end
		-- love.graphics.setColor(255, 255, 0)
		-- for i, p in ipairs(rcPath) do
		-- 	if i ~= 1 and i ~= #rcPath then
		-- 		love.graphics.circle('fill', rcCenters[p].x, rcCenters[p].y, 3)
		-- 	end
		-- end
	end,
	drawRCSPath = function()
		if #rcSPath > 3 then
			-- love.graphics.setColor(255, 200, 200)
			love.graphics.setColor(200, 200, 0)
			love.graphics.line(rcSPath)
		end
	end,
	drawStartEnd = function()
		if rcCurve then
			-- love.graphics.setColor(0, 0, 200)
			love.graphics.setColor(200 * rcT, 200 * (1 - rcT), 0)
			local x, y = rcCurve:getPosition(rcT):unpack()
			love.graphics.circle('fill', x, y, rcWalkableRadius)
			-- love.graphics.setColor(200, 100, 25)
			love.graphics.setColor(200, 200, 0)
			love.graphics.circle('line', x, y, rcWalkableRadius)
		else
			if rcSx and rcSy then
				love.graphics.setColor(0, 200, 0)
				love.graphics.circle('fill', rcSx, rcSy, rcWalkableRadius)
			end
			if rcEx and rcEy then
				love.graphics.setColor(200, 0, 0)
				love.graphics.circle('fill', rcEx, rcEy, rcWalkableRadius)
			end
		end
	end,
	drawCorridorCorners = function()
		if corridorCorners and #corridorCorners > 3 then
			love.graphics.setColor(200, 200, 0)
			love.graphics.line(corridorCorners)
		end
	end,
	-- io
	increaseWalkableRadius = function()
		walkableRadius = walkableRadius * 2
	end,
	decreaseWalkableRadius = function()
		walkableRadius = walkableRadius / 2
	end,
	movePosition = function(dx, dy)
		rcSx, rcSy = rcSx + dx, rcSy + dy

		movePos[1] = rcSx
		movePos[2] = 0
		movePos[3] = rcSy
		-- movePos:setX(rcSx)
		-- movePos:setY(0)
		-- movePos:setZ(rcSy)

		return pathCorridor:movePosition(movePos, navMeshQuery, queryFilter)
	end,
	moveTargetPosition = function(dx, dy)
		rcEx, rcEy = rcEx + dx, rcEy + dy
		moveTargetPos[1] = rcEx
		moveTargetPos[2] = 0
		moveTargetPos[3] = rcEy
		-- moveTargetPos:setX(rcEx)
		-- moveTargetPos:setY(0)
		-- moveTargetPos:setZ(rcEy)

		return pathCorridor:moveTargetPosition(moveTargetPos, navMeshQuery, queryFilter)
	end,
	findCorners = function()
		corridorCorners = pathCorridor:findCorners(navMeshQuery, queryFilter)
		-- print('corridorCorners', unpack(corridorCorners))
	end,
	optimizePathTopology = function(dt)
		if TIME + dt > 1 then
			print('optimizing path topology')
			pathCorridor:optimizePathTopology(navMeshQuery, queryFilter)
			-- if (Vector(150, 75) - Vector(rcSx, rcSy)):norm() < 10 or (Vector(150, 475) - Vector(rcSx, rcSy)):norm() < 10
			-- 	and pathCorridor:moveOverOffmeshConnection(offMeshConnections, navMeshQuery) then
			-- 	rcSx, LOL, rcSy = pathCorridor:getPos():getPosition()
			-- 	corridorCorners = pathCorridor:findCorners(navMeshQuery, queryFilter)
			-- end
			TIME = TIME + dt - 1
		else
			TIME = TIME + dt
		end
	end,
	updatePos = function(self, dt)
		local pos = Vector(rcSx, rcSy)
		local tar = Vector(corridorCorners[3], corridorCorners[4])

		local dPos = (tar - pos):normalize():mul(50 * dt)

		return self.movePosition(dPos.x, dPos.y)
	end,
	--update
	update = function(dt)
		if rcCurve then
			rcT = (rcT + 50 * dt / rcCurve.length) % 1
		end
	end,
	--export
	export = function(filename)
		if not string.match(filename, '%.obj$') then filename = filename .. '.obj' end

		print(string.format('exporting to %s', filename))

		local file = io.open(filename, 'w+')

		for i = 1, #vertices, 2 do
			file:write(string.format('v %d %d %d\n', vertices[i], 0, vertices[i + 1]))
		end

		for i = 1, #triangles, 3 do
			file:write(string.format('f %d %d %d\n', triangles[i], triangles[i + 1], triangles[i + 2]))
		end

		file:close()
	end
}

recast.context = context
recast.min = min
recast.max = max
recast.heightfield = heightfield
recast.compactHeightfield = compactHeightfield
recast.contourSet = contourSet
recast.polyMesh = polyMesh
recast.path = path
recast.navMesh = navMesh
-- recast.offMeshConnections = offMeshConnections
recast.queryFilter = queryFilter
recast.navMeshQuery = navMeshQuery
recast.vS = vS
recast.vE = vE
recast.pS = pS
recast.pE = pE
recast.pathCorridor = pathCorridor
recast.movePos = movePos
recast.moveTargetPos = moveTargetPos

return recast
