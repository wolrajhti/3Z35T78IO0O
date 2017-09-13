require('recastlua_cmod')

local currentVertices = {}

local vertices = {}
local triangles = {}
local index = {}
local walkableRadius = 5

local rcPolys = {}
-- local rcCenters = {}
local rcWalkableRadius = -1
local rcSx, rcSy, rcEx, rcEy = nil, nil, nil, nil
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
		setVerts(unpack(vertices))
	end,
	setTriangles = function()
		local tm = imap(triangles, function(i, t) return t - 1 end)
		setTris(unpack(tm))
	end,
	setPolyMesh = function(self)
		if rcWalkableRadius == -1 then
			self.setVertices()
			self.setTriangles()
		end
		setPolyMesh(walkableRadius)

		local nvp = getRcNVP()
		local vertices = {getRcVerts()}
		local rawPolys = {getRcPolys()}

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
		setNavMesh()
	end,
	setStart = function(x, y)
		rcSx, rcSy = x, y
	end,
	setEnd = function(x, y)
		rcEx, rcEy = x, y
	end,
	--queryPath
	setPath = function()
		local data = {queryNavMesh(rcSx, rcSy, rcEx, rcEy)}
		local sCount = getRcSCount()
		rcSx, rcSy = data[1], data[2]
		rcEx, rcEy = data[3], data[4]
		rcThrough = {}
		rcPath = {}
		rcSPath = {}
		rcCurve = {}
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
		rcCurve = Curve(verts)
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
	end
}

return recast
