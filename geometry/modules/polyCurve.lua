local PolyCurve = class('PolyCurve', require 'src.geometry.curve')

local Vector = require 'src.geometry.vector'
-- local VerticesConverter = require 'src.geometry.verticesConverter'

function PolyCurve:initialize(curves, signs) -- OK
	signs = signs or {}
	self.curves, self.signs, self.times, self.length = curves or {},{}, {}, 0
	for i, curve in ipairs(self.curves) do
		table.insert(self.times, self.length)
		self.length = self.length + curve.length
		self.signs[i] = signs[i] or 1
	end
	for i, time in ipairs(self.times) do
		self.times[i] = time / self.length
	end
	table.insert(self.times, 1)
end

function PolyCurve:reverse() -- OK
	local curves, signs, times = {}, {}, {}
	for i, curve in ipairs(self.curves) do table.insert(curve, 1, curve) end
	for i, sign in ipairs(self.signs) do table.insert(signs, 1, -sign) end
	for i, time in ipairs(self.times) do table.insert(times, 1, time) end
	self.curves, self.signs, self.times = curves, signs, times
end

function PolyCurve:getCoordinates(t0, t1) -- OK
	local flag, t0, t1 = nil, t0 or 0, t1 or 1
	if t1 < t0 then flag, t0, t1 = true, t1, t0 end
	local tc0, i0 = self:interpolateTime(t0)
	local tc1, i1 = self:interpolateTime(t1)
	local line = {}
	if i0 == i1 then
		local coordinates = self.curves[i0]:getCoordinates(tc0, tc1)
		for j, coordinate in ipairs(coordinates) do
			table.insert(line, coordinate)
		end
	else
		for i = i0, i1 do
			local coordinates = {}
			if i == i0 then
				if self.signs[i] == 1 then coordinates = self.curves[i]:getCoordinates(tc0, 1)
				else coordinates = self.curves[i]:getCoordinates(tc0, 0) end
			elseif i == i1 then
				if self.signs[i] == 1 then coordinates = self.curves[i]:getCoordinates(0, tc1)
				else coordinates = self.curves[i]:getCoordinates(1, tc1) end
			else
				if self.signs[i] == 1 then coordinates = self.curves[i]:getCoordinates(0, 1)
				else coordinates = self.curves[i]:getCoordinates(1, 0) end
			end
			for j, coordinate in ipairs(coordinates) do
				if ((i0 ~= i1 and i ~= i1) or (i == i1)) and (j ~= #coordinates and j ~= #coordinates - 1) then
					table.insert(line, coordinate)
				end
			end
		end
	end
	if flag then
		local l = {}
		for i = 1, #line - 1, 2 do
			table.insert(l, 1, line[i + 1])
			table.insert(l, 1, line[i])
		end
		line = l
	end
	return line
end

function PolyCurve:interpolateTime(t, i) -- OK
	i = i or self:getTimeIndex(t)
	if self.signs[i] == 1 then
		return (t - self.times[i]) / (self.times[i + 1] - self.times[i]), i
	elseif self.signs[i] == -1 then
		return 1 - (t - self.times[i]) / (self.times[i + 1] - self.times[i]), i
	end
end

function PolyCurve:getPosition(t) -- OK
	local t, i = self:interpolateTime(t)
	return self.curves[i]:getPosition(t)
end

function PolyCurve:getTangent(t, norm) -- OK
	local t, i = self:interpolateTime(t)
	return self.signs[i] * self.curves[i]:getTangent(t, norm)
end

function PolyCurve:getNormal(t, norm) -- OK
	local t, i = self:interpolateTime(t)
	return self.signs[i] * self.curves[i]:getNormal(t, norm)
end

function PolyCurve:getParallelVertices(offset) -- OK
	local vertices = vertices or {}
	for i, curve in ipairs(self.curves) do
		local ver = curve:getParallelVertices(self.signs[i] * offset)
		if self.signs[i] == 1 then
			if i == #self.curves then
				for j = 1, #ver do table.insert(vertices, ver[j]) end
			else
				for j = 1, #ver - 1 do table.insert(vertices, ver[j]) end
			end
		elseif self.signs[i] == -1 then
			if i == #self.curves then
				for j = #ver, 1, -1 do table.insert(vertices, ver[j]) end
			else
				for j = #ver - 1, 1, -1 do table.insert(vertices, ver[j]) end
			end
		end
	end
	return vertices
end

function PolyCurve:getIntersectionsWithCurve(other) -- OK
	-- debug:write('function PolyCurve:getIntersectionsWithCurve(other)\n')
	local inters = {}
	for i, curve in ipairs(self.curves) do
		-- debug:write('\tfor i, curve in ipairs(self.curves) do\n')
		local cInters = curve:getIntersectionsWithCurve(other)
		if self.signs[i] == 1 then
		-- debug:write('\t\tif self.signs[i] == 1 then\n')
			for j, cInter in ipairs(cInters) do
				-- debug:write('\t\t\tfor j, cInter in ipairs(cInters) do\n')
				local inter = {}
				inter[curve] = cInter[curve]
				inter[other] = cInter[other]
				inter[self] = self.times[i] + cInter[curve] * (self.times[i + 1] - self.times[i])
				table.insert(inters, inter)
			end
		elseif self.signs[i] == -1 then
			-- debug:write('\t\tif self.signs[i] == -1 then\n')
			for j, cInter in ipairs(cInters) do
				-- debug:write('\t\t\tfor j, cInter in ipairs(cInters) do\n')
				local inter = {}
				inter[curve] = cInter[curve]
				inter[other] = cInter[other]
				inter[self] = self.times[i] + (1 - cInter[curve]) * (self.times[i + 1] - self.times[i])
				table.insert(inters, inter)
			end
		end		
	end
	table.sort(inters, function(a, b) return a[self] < b[self] end)
	return inters
end

function PolyCurve:getIntersectionsWithCircle(r, X, y) -- OK
-- debug:write('function PolyCurve:getIntersectionsWithCircle('..r..', '..X:tostring()..', '..(y or '')..')\n')
	X = Vector(X, y)
	local r2, inters = math.pow(r, 2), {}
	for i, curve in ipairs(self.curves) do
		local cInters = curve:getIntersectionsWithCircle(r, X.x, X.y)
		if self.signs[i] == 1 then
			for j, cInter in ipairs(cInters) do
				local inter = {}
				-- debug:write('\t\ti = '..i..'\n')
				-- debug:write('\t\t#self.curves = '..#self.curves..'\n')
				-- debug:write('\t\t#self.times = '..#self.times..'\n')
				-- debug:write('\t\tself.times[i] = '..self.times[i]..'\n')
				-- debug:write('\t\tcInter[curve] = '..cInter[curve]..'\n')
				-- debug:write('\t\t(self.times[i + 1] - self.times[i]) = '..(self.times[i + 1] - self.times[i])..'\n')
				inter[self] = self.times[i] + cInter[curve] * (self.times[i + 1] - self.times[i])
				table.insert(inters, inter)
			end
		elseif self.signs[i] == -1 then
			for j, cInter in ipairs(cInters) do
				local inter = {}
				-- debug:write('\t\ti = '..i..'\n')
				-- debug:write('\t\t#self.curves = '..#self.curves..'\n')
				-- debug:write('\t\t#self.times = '..#self.times..'\n')
				-- debug:write('\t\tself.times[i] = '..self.times[i]..'\n')
				-- debug:write('\t\t(1 - cInter[curve]) = '..(1 - cInter[curve])..'\n')
				-- debug:write('\t\t(self.times[i + 1] - self.times[i]) = '..(self.times[i + 1] - self.times[i])..'\n')
				inter[self] = self.times[i] + (1 - cInter[curve]) * (self.times[i + 1] - self.times[i])
				table.insert(inters, inter)
			end
		end
	end
	table.sort(inters, function(a, b) return a[self] < b[self] end)
	return inters
end

-- A DEBUGGER
function PolyCurve:getPrevPos(t, r)
-- debug:write('function PolyCurve:getPrevPos('..(t or '')..', '..(r or '')..')\n')
	if t then
		local inters = self:getIntersectionsWithCircle(r, self:getPosition(t))
		-- debug:write('#inters = '..#inters..'\n')
		if #inters ~= 0 then
			local i = #inters
			-- while inters[i] and inters[i][self] > t do i = i - 1 debug:write('i = '..i..'\n') end
			while inters[i] and inters[i][self] > t do i = i - 1 end
			-- if inters[i] then debug:write('inters['..i..'][self] = '..inters[i][self]..'\n') return inters[i][self] end
			if inters[i] then return inters[i][self] end
		end
	end
end

function PolyCurve:getNextPos(t, r)
-- debug:write('function PolyCurve:getNextPos('..(t or '')..', '..(r or '')..')\n')
	if t then
		local inters = self:getIntersectionsWithCircle(r, self:getPosition(t))
		-- debug:write('#inters = '..#inters..'\n')
		if #inters ~= 0 then
			local i = 1
			-- while inters[i] and inters[i][self] < t do i = i + 1 debug:write('i = '..i..'\n')end
			while inters[i] and inters[i][self] < t do i = i + 1 end
			-- if inters[i] then debug:write('inters['..i..'][self] = '..inters[i][self]..'\n') return inters[i][self] end
			if inters[i] then return inters[i][self] end
		end
	end
end
---

function PolyCurve:getProjection(X, y) -- OK -- TODO : utiliser l'implémentation de vector.lua
	local proj = {}
	for i, curve in ipairs(self.curves) do
		local time, cIndex, minDist = curve:getProjection(X, y)
--		 debug:write('time '..time..'\n')
--		 debug:write('cIndex '..cIndex..'\n')
--		 debug:write('minDist '..minDist..'\n')
--		 debug:write(i..'\n')
		if self.signs[i] == 1 then
			table.insert(proj, {time = self.times[i] + time * (self.times[i + 1] - self.times[i]), cIndex = cIndex, index = i, minDist = minDist})
			-- debug:write('proj.time '..proj[#proj].time..'\n')
			-- debug:write('proj.cIndex '..proj[#proj].cIndex..'\n')
			-- debug:write('proj.index '..proj[#proj].index..'\n')
		elseif self.signs[i] == -1 then
			table.insert(proj, {time = self.times[i] + (1 - time) * (self.times[i + 1] - self.times[i]), cIndex = cIndex, index = i, minDist = minDist})
			-- debug:write('proj.time '..proj[#proj].time..'\n')
			-- debug:write('proj.cIndex '..proj[#proj].cIndex..'\n')
			-- debug:write('proj.index '..proj[#proj].index..'\n')
		end
	end
	table.sort(proj, function(a, b) return a.minDist < b.minDist end)
	-- debug:write(#proj..'\n')
	return proj[1].time, proj[1].index, proj[1].cIndex
end

function PolyCurve:testSide(cI, i, X, y) -- OK -- TODO : utiliser l'implémentation de vector.lua
	if y then
		X = Vector(X, y)
	elseif not X then
		X = Vector(cI, i)
		local t
		t, i, cI = self:getProjection(X)
	end
	return self.signs[i] * (X - self.curves[i].vertices[cI]):cross(self.curves[i].vertices[cI + 1] - self.curves[i].vertices[cI]) < 0
end

function PolyCurve:updateTime(t, dt) -- OK
	-- debug:write('function PolyCurve:update('..t..', '..dt..')\n')
	if dt > 0 then
	-- debug:write('if dt > 0 then\n')	
		if t == 1 then
		-- debug:write('if t == 1 then\n')
			return t, dt
		else
		-- debug:write('else\n')
			local i = self:getTimeIndex(t)
			-- debug:write('i = '..i..'\n')
			local count = 0
			while dt > 0 and t < 1 do
				count = count + 1
				if count > 1e3 then love.event.quit() end
				-- debug:write('début de la boucle while dt > 0 and t < 1 do avec t = '..t..', dt = '..dt..'\n')
				-- debug:write('BOUCLE\n')
				-- debug:write('\tsigns['..i..'] = '..self.signs[i]..'\n')
				-- debug:write('\ttimes['..i..'] = '..self.times[i]..'\n')
				-- debug:write('\ttimes['..(i + 1)..'] = '..self.times[i + 1]..'\n')
				-- debug:write('\tt = '..t..', dt = '..dt..'\n')
				-- debug:write('\tself:interpolateTime(t) = '..self:interpolateTime(t)..', self.signs[i] * dt = '..self.signs[i] * dt..'\n')
				t, dt = self.curves[i]:updateTime(self:interpolateTime(t, i), self.signs[i] * dt)
				-- debug:write('\tt = '..t..', dt = '..dt..'\n')
				-- debug:write(t..', '..dt..' = self.curves[i]:updateTime('..self:interpolateTime(t)..', '..self.signs[i] * dt..')\n')
				if self.signs[i] == 1 then
				-- debug:write('if self.signs[i] == 1 then\n')
					t, dt = self.times[i] + t * (self.times[i + 1] - self.times[i]), self.signs[i] * dt
				elseif self.signs[i] == -1 then
				-- debug:write('elseif self.signs[i] == -1 then\n')
					t, dt = self.times[i] + (1 - t) * (self.times[i + 1] - self.times[i]), self.signs[i] * dt
				end
				-- debug:write('t = '..t..', dt = '..dt..'\n')
				-- if t == self.times[i + 1] then
				-- debug:write('if t == self.times[i + 1] then\n')
					i = i + 1
					-- t = self.times[i + 1]
				-- end
				-- debug:write('fin de la boucle while dt > 0 and t < 1 do avec t = '..t..', dt = '..dt..'\n')
			end
			-- debug:write('return t = '..t..', dt = '..dt..'\n')
			return t, dt
		end
	else
	-- debug:write('else\n')
		if t == 0 then
		-- debug:write('if t == 0 then\n')
			return t, dt
		else
		-- debug:write('else\n')
			local i = self:getTimeIndex(t)
			-- debug:write('i = '..i..'\n')
			local count = 0
			while dt < 0 and t > 0 do
				count = count + 1
				if count > 1e3 then love.event.quit() end
				-- debug:write('début de la boucle while dt > 0 and t < 1 do avec t = '..t..', dt = '..dt..'\n')
				t, dt = self.curves[i]:updateTime(self:interpolateTime(t), self.signs[i] * dt)
				if self.signs[i] == 1 then
					t, dt = self.times[i] + t * (self.times[i + 1] - self.times[i]), self.signs[i] * dt
				elseif self.signs[i] == -1 then
					t, dt = self.times[i] + (1 - t) * (self.times[i + 1] - self.times[i]), self.signs[i] * dt
				end
				if t == self.times[i] then i = i - 1 end
				-- debug:write('i = '..i..'\n')
				-- debug:write('fin de la boucle while dt > 0 and t < 1 do avec t = '..t..', dt = '..dt..'\n')
			end
			return t, dt
		end
	end
	return t, dt
end

return PolyCurve