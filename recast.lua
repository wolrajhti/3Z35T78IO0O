local recastlua = require('recastlua')

local rl = require('rl')

local context = rl.newRcContext()

local min = rl.newVector3f(0, 0, 0)
local max = rl.newVector3f(800, 2, 600)

local heightfield = rl.newRcHeightfield(context, 800, 600, min, max, 1, 1)

heightfield:rcRasterizeTriangle(
	context,
	rl.newVector3f(0, 0, 0),
	rl.newVector3f(400, 0, 0),
	rl.newVector3f(400, 0, 300)
)

heightfield:rcRasterizeTriangle(
	context,
	rl.newVector3f(0, 0, 0),
	rl.newVector3f(400, 0, 300),
	rl.newVector3f(0, 0, 300)
)

heightfield:rcRasterizeTriangle(
	context,
	rl.newVector3f(100, 0, 100),
	rl.newVector3f(200, 0, 100),
	rl.newVector3f(200, 0, 500)
)

heightfield:rcRasterizeTriangle(
	context,
	rl.newVector3f(100, 0, 100),
	rl.newVector3f(200, 0, 500),
	rl.newVector3f(100, 0, 500)
)

heightfield:rcRasterizeTriangle(
	context,
	rl.newVector3f(50, 0, 400),
	rl.newVector3f(400, 0, 400),
	rl.newVector3f(400, 0, 450)
)

heightfield:rcRasterizeTriangle(
	context,
	rl.newVector3f(50, 0, 400),
	rl.newVector3f(400, 0, 450),
	rl.newVector3f(50, 0, 450)
)

-- heightfield:printSpans()

local compactHeightfield = rl.newRcCompactHeightfield(context, 3, 0, heightfield)

compactHeightfield:rcErodeWalkableArea(context, 20)
compactHeightfield:rcBuildDistanceField(context)
compactHeightfield:rcBuildRegions(context)

local contourSet = rl.newRcContourSet(context, compactHeightfield, 5, 50)

local polyMesh = rl.newRcPolyMesh(context, contourSet)

local path = rl.newPath(32)

local rawVerts = {polyMesh:getVerts()}
local rawPolys = {polyMesh:getPolys()}
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

local navMesh = rl.newDtNavMesh(polyMesh)

local navMeshQuery = rl.newDtNavMeshQuery(navMesh)

local rcSx, rcSy, rcEx, rcEy = 320, 80, 75, 425

local vS = rl.newVector3f(rcSx, 0, rcSy)
local vE = rl.newVector3f(rcEx, 0, rcEy)

local pS = navMeshQuery:findNearestPoly(vS, navMesh)
local pE = navMeshQuery:findNearestPoly(vE, navMesh)

local npath, path = navMeshQuery:findPath(vS, vE, pS, pE)

print('FROM LUA npath', npath)

print('FROM LUA vS', vS:getX(), vS:getY(), vS:getZ())

local pathCorridor = rl.newDtPathCorridor()

pathCorridor:reset(pS, vS, navMesh)

pathCorridor:setCorridor(vE, path, npath, navMesh, navMeshQuery)

local corridorCorners = pathCorridor:findCorners(navMeshQuery)

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
		if corridorCorners then
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
	--update
	update = function(dt)
		if rcCurve then
			rcT = (rcT + 50 * dt / rcCurve.length) % 1
		end
	end,
	--export
	export = function()
		local tm = imap(triangles, function(i, t) return vertices[t]..'\n' end)
		print(unpack(tm))
	end
}

return recast
