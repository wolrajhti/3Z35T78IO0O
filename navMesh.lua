local NavMesh = class('NavMesh')

local rl = require('rl')

function NavMesh:initialize(w, h, min, max, cs, ch)
	self.w = w
	self.h = h
	self.min = min or {0, 0, 0}
	self.max = max or {w, 1, h}
	self.cs = cs or 1
	self.ch = ch or 1
	self.ctx = rl.newRcContext()
	self.hf = rl.newRcHeightfield(self.ctx, self.w, self.h, self.min, self.max, self.cs, self.ch)
	self.oc = {} -- offmesh connections
	self.ac = {} -- area costs
end

function NavMesh:addTriangles(area, cost, triangles)
	self.ac[area] = cost
	self.hf:rcRasterizeTriangles(self.ctx, area, triangles)
end

function NavMesh:addOffmeshConnection(start, end, radius, dir, area, flag, userId)
	table.insert(self.oc, {
		start[1], start[2], start[3],
		end[1], end[2], end[3],
		radius, dir, area, flag, userId
	})
end

function NavMesh:build(radius)
	self.chf[radius] = rl.newRcCompactHeightfield(self.ctx, 0, 0, self.hf)

	self.chf[radius]:rcErodeWalkableArea(self.ctx, radius)
	self.chf[radius]:rcBuildDistanceField(self.ctx)
	self.chf[radius]:rcBuildRegions(self.ctx)

	self.cs[radius] = rl.newRcContourSet(self.ctx, self.chf[radius], 10, 50)

	self.pm[radius] = rl.newRcPolyMesh(self.ctx, self.cs[radius])

	self.nm[radius] = rl.newDtNavMesh(self.pm[radius], self.oc)
end
