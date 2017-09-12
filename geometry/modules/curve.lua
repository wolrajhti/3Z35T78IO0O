local Curve = class('Curve')

local Vector = require 'src.geometry.vector'
local VerticesConverter = require 'src.geometry.verticesConverter'

function Curve:initialize(vertices)
	VerticesConverter.clean(vertices)
	self.vertices, self.times, self.length = vertices or {}, {}, 0
	for i = 1, #self.vertices - 1 do
		table.insert(self.times, self.length)
		self.length = self.length + self.vertices[i]:dist(self.vertices[i + 1])
	end
	for i = 1, #self.times do
		self.times[i] = self.times[i] / self.length
	end
	table.insert(self.times, 1)
  --mais oui mais c'est biensûr !
end

function Curve:reverse()
	local vertices, times = {}, {}
	for i, vertex in ipairs(self.vertices) do table.insert(vertices, 1, vertex) end
	for i, time in ipairs(self.times) do table.insert(times, 1, time) end
	self.vertices, self.times = vertices, times
end

function Curve:getRightLine(offset) -- n'a rien à faire là
	offset = (offset or 0) / self.length
	if offset < 1 then
		return self:getCoordinates(0, 0 + offset)
	else
		return self:getCoordinates()
	end
end

function Curve:getLeftLine(offset) -- n'a rien à faire là
	offset = (offset or 0) / self.length
	if offset < 1 then
		return self:getCoordinates(1 - offset, 1)
	else
		return self:getCoordinates()
	end
end

function Curve:getCenterLine(offset) -- n'a rien à faire là
	offset = (offset or 0) / self.length
	if offset < 0.5 then
		return self:getCoordinates(0 + offset, 1 - offset)
	else
		return self:getCoordinates()
	end
end

function Curve:getCoordinates(t0, t1)
	local flag, t0, t1 = nil, t0 or 0, t1 or 1
	if t1 < t0 then flag, t0, t1 = true, t1, t0 end
	local line = {}
	local v0 = self:getPosition(t0)
	table.insert(line, v0.x)
	table.insert(line, v0.y)
	for i, time in ipairs(self.times) do
		if t0 < time and time < t1 then
			table.insert(line, self.vertices[i].x)
			table.insert(line, self.vertices[i].y)			
		end
	end
	local v1 = self:getPosition(t1)
	table.insert(line, v1.x)
	table.insert(line, v1.y)
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

function Curve:draw()
	love.graphics.line(self:getCoordinates())
end

function Curve:getTimeIndex(t)
	for i = 1, #self.times - 1 do
		if self.times[i] <= t and t <= self.times[i + 1] then
			return i
		end
	end
end

function Curve:interpolateTime(t, i)
	i = i or self:getTimeIndex(t)
	return (t - self.times[i]) / (self.times[i + 1] - self.times[i]), i
	
end

function Curve:getPosition(t)
	local i = self:getTimeIndex(t)
	return self.vertices[i] + self:interpolateTime(t, i) * (self.vertices[i + 1] - self.vertices[i])
end

function Curve:getTangent(t, norm)
	local i = self:getTimeIndex(t)
	return (self.vertices[i + 1] - self.vertices[i]):normalize(norm)
end

function Curve:getNormal(t, norm)
	return self:getTangent(t, norm):rotate(math.pi / 2)
end

function Curve:getMeanNormal(i, norm)
	if i == 1 then
		return self:getNormal(0, norm)
	elseif 1 < i and i < #self.vertices then
		return ((self:getNormal(self.times[i]) + self:getNormal(self.times[i + 1])) / 2):normalize(norm)
	elseif i == #self.vertices then
		return self:getNormal(1, norm)
	end
end

function Curve:getParallelVertices(offset)
	local vertices = {}
	for i, time in ipairs(self.times) do
		table.insert(vertices, self.vertices[i] + self:getNormal(time, offset))
	end
	return vertices
end

function Curve:getIntersectionsWithCurve(other)
	-- debug:write('function Curve:getIntersectionsWithCurve(other)\n')
	local inters = {}
	if other.class.name == 'Curve' then
		-- debug:write("\tif other.class.name == 'Curve' then\n")
		for i = 1, #self.times - 1 do
			local v = self.vertices[i + 1] - self.vertices[i]
			for j = 1, #other.times - 1 do
				local w = other.vertices[j + 1] - other.vertices[j]
				local u, det = self.vertices[i] - other.vertices[j], v:cross(w)
				local r, s = w:cross(u) / det, v:cross(u) / det
				if ((i == #self.times - 1 and 0 < r and r <= 1) or (0 <= r and r < 1)) and ((j == #other.times - 1 and 0 < s and s <= 1) or (0 <= s and s < 1)) then
					local inter = {}
					inter[self] = self.times[i] + r * (self.times[i + 1] - self.times[i])
					inter[other] = other.times[j] + s * (other.times[j + 1] - other.times[j])
					table.insert(inters, inter)
				end
			end
		end
	else--if other.class.name == 'PolyCurve' then
		-- debug:write("\telseif other.class.name == 'PolyCurve' then\n")
		inters = other:getIntersectionsWithCurve(self)
	end
	table.sort(inters, function(a, b) return a[self] < b[self] end)
	return inters
end

function Curve:getIntersectionsWithCircle(r, X, y)
	X = Vector(X, y)
	local r2, inters = math.pow(r, 2), {}
	for i = 1, #self.times - 1 do		
		local v, w = self.vertices[i + 1] - self.vertices[i], X - self.vertices[i]
		local n2 = v:norm2()
		local t = v:dot(w) / n2
		local h2 = (t * v - w):norm2()
		if h2 < r2 then
			local ta = t - math.sqrt(r2 - h2) / math.sqrt(n2)
			local tb = t + math.sqrt(r2 - h2) / math.sqrt(n2)
			if 0 <= ta and ta <= 1 then
				local inter = {}
				inter[self] = self.times[i] + ta * (self.times[i + 1] - self.times[i])
				table.insert(inters, inter)
			end
			if 0 <= tb and tb <= 1 then
				local inter = {}
				inter[self] = self.times[i] + tb * (self.times[i + 1] - self.times[i])
				table.insert(inters, inter)
			end
		end
	end
	table.sort(inters, function(a, b) return a[self] < b[self] end)
	return inters
end

function Curve:getProjection(X, y) -- TODO : utiliser l'implémentation de vector.lua
	X = Vector(X, y)
	local minDist, dist, time, index, t
	for i = 1, #self.times - 1 do
		local v = self.vertices[i + 1] - self.vertices[i]
		local n2 = v:norm2()
		if n2 == 0 then
			t = self.times[i]
		else
			t = self.times[i] + math.max(0, math.min(v:dot(X - self.vertices[i]) / n2, 1)) * (self.times[i + 1] - self.times[i])
		end
		dist = self:getPosition(t):dist(X)
		if not minDist or dist < minDist or (dist == minDist and index < i and self:getMeanNormal(i):cross(X - self.vertices[i]) < 0) then
			minDist, time, index = dist, t, i
		end
	end
	return time, index, minDist
end

function Curve:getSymmetric(X, y) -- TODO : utiliser l'implémentation de vector.lua
	X = Vector(X, y)
	local time = self:getProjection(X)
	local p = self:getPosition(time)
	return X:clone():rotate(-2 * self:getTangent(time):angle(X - p), p)
end

function Curve:testSide(i, X, y) -- TODO : utiliser l'implémentation de vector.lua
	if y then
		X = Vector(X, y)
	elseif type(X) == 'number' then
		X = Vector(i, X)
		i = select(-1, self:getProjection(X))
	end
	return (X - self.vertices[i]):cross(self.vertices[i + 1] - self.vertices[i]) < 0
end

function Curve:updateTime(t, dt)
	-- debug:write('début de la boucle Curve:update('..t..', '..dt..')\n')
	if dt > 0 then
	-- debug:write('if dt > 0 then\n')		
		if t == 1 then
		-- debug:write('if t == 1 then\n')
			return t, dt
		else
		-- debug:write('else\n')
			local v1 = self:getPosition(t)
			-- debug:write('v1 = '..v1:tostring()..'\n')
			local i = self:getTimeIndex(t)
			-- debug:write('i = '..i..'\n')
			if i < #self.times then
				local j = i + 1
				while dt > 0 and t < 1 do
					local v2 = self.vertices[j]
					local d = v1:dist(v2)
					if dt < d then
						return t + (self.times[j] - t) * dt / d, 0
					else
						t = self.times[j]
						dt = dt - d
						v1 = v2
						j = j + 1
					end
				end
				return t, dt
			end
		end
	else
	-- debug:write('else\n')
		if t == 0 then
		-- debug:write('if t == 0 then\n')
			return t, dt
		else
		-- debug:write('else\n')
			local v1 = self:getPosition(t)
			-- debug:write('v1 = '..v1:tostring()..'\n')
			local i = self:getTimeIndex(t) + 1
			-- debug:write('i = '..i..'\n')
			if i > 1 then
				local j = i - 1
				while dt < 0 and t > 0 do
				-- debug:write('while dt < 0 and t > 0 do\n')
					local v2 = self.vertices[j]
					-- debug:write('v2 = '..v2:tostring()..'\n')
					local d = v1:dist(v2)
					-- debug:write('d = '..d..'\n')
					if math.abs(dt) < d then
					-- debug:write('if math.abs(dt) < d then\n')
						return t + (t - self.times[j]) * dt / d, 0
					else
					-- debug:write('else\n')
						t = self.times[j]
						-- debug:write('t = '..t..'\n')
						dt = dt + d
						-- debug:write('dt = '..dt..'\n')
						v1 = v2
						-- debug:write('v1 = '..v1:tostring()..'\n')
						j = j - 1
						-- debug:write('j = '..j..'\n')
					end
				end
				return t, dt
			end
		end
	end
	return t, dt
end

return Curve