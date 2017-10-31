-- local NavMesh = class('NavMesh')
--
-- local rl = require('rl')
--
-- function NavMesh:initialize(w, h[, min, max][, cs[, ch]])
-- 	self.w = w
-- 	self.h = h
-- 	self.min = min or {0, 0, 0}
-- 	self.max = max or {w, 1, h}
-- 	self.cs = cs or 1
-- 	self.ch = ch or 1
-- 	self.ctx = rl.newRcContext()
-- 	self.hf = rl.newRcHeightfield(self.ctx, self.w, self.h, self.min, self.max, self.cs, self.ch)
-- end
--
-- function NavMesh:addTriangles(...)
-- 	self.hf:rcRasterizeTriangles(context, ...)
-- end
--
-- function NavMesh:build()
-- 	self.chf = rl.newRcCompactHeightfield(context, 0, 0, heightfield)
--
-- 	compactHeightfield:rcErodeWalkableArea(context, 5)
-- 	compactHeightfield:rcBuildDistanceField(context)
-- 	compactHeightfield:rcBuildRegions(context)
--
-- 	local contourSet = rl.newRcContourSet(context, compactHeightfield, 10, 50)
--
-- 	local polyMesh = rl.newRcPolyMesh(context, contourSet)
-- end
