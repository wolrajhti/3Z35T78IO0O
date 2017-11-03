local NavMesh = class('NavMesh')

local rl = require('rl')

local function imap(t, func)
	local tm = {}
	for i, v in ipairs(t) do
		table.insert(tm, func(i, v))
	end
	return tm
end

function NavMesh:initialize(w, h, min, max, cs, ch)
	self.w = w
	self.h = h
	self.min = min or {0, 0, 0}
	self.max = max or {w, 2, h}
	self.cs = cs or 1
	self.ch = ch or 1
	self.ctx = rl.newRcContext()
	self.hf = rl.newRcHeightfield(self.ctx, self.w, self.h, self.min, self.max, self.cs, self.ch)
	self.chf = {}
	self.contourSets = {}
	self.pm = {}
	self.nm = {}
	self.oc = {} -- offmesh connections
	self.areas = setmetatable({__data = {}, __count = 0}, {
		__index = function(t, k)
			return rawget(t.__data, k).area
		end,
		__newindex = function(t, k, v)
			t.__count = t.__count + 1
			rawset(t.__data, k, {area = t.__count, cost = v})
		end
	}) -- area costs
end

function NavMesh:addTriangles(areaName, triangles)
	local tris = {}
	for i = 1, #triangles, 2 do
		table.insert(tris, triangles[i])
		table.insert(tris, 0)
		table.insert(tris, triangles[i + 1])
	end
	self.hf:rcRasterizeTriangles(self.ctx, self.areas[areaName], tris)
end

function NavMesh:addOffmeshConnection(areaName, params)
	table.insert(self.oc, params.startPos[1])
	table.insert(self.oc, 1)
	table.insert(self.oc, params.startPos[2])
	table.insert(self.oc, params.endPos[1])
	table.insert(self.oc, 1)
	table.insert(self.oc, params.endPos[2])
	table.insert(self.oc, params.radius)
	table.insert(self.oc, params.dir or 2)
	table.insert(self.oc, self.areas[areaName])
	table.insert(self.oc, flag or 12)
	table.insert(self.oc, userId or 666)
end

function NavMesh:build(radius)
	self.chf[radius] = rl.newRcCompactHeightfield(self.ctx, 0, 0, self.hf)

	self.chf[radius]:rcErodeWalkableArea(self.ctx, radius)
	self.chf[radius]:rcBuildDistanceField(self.ctx)
	self.chf[radius]:rcBuildRegions(self.ctx)

	self.contourSets[radius] = rl.newRcContourSet(self.ctx, self.chf[radius], 10, 50)

	self.pm[radius] = rl.newRcPolyMesh(self.ctx, self.contourSets[radius])
	
	self.nm[radius] = rl.newDtNavMesh(self.pm[radius], self.oc)
end

return NavMesh
