local Mesh = class('Mesh')

local obj_loader = require('loader')

function Mesh:initialize()
	self.vertices = {}
	self.triangles = {}
	self.index = {}
end

function Mesh:addVertex(x, y, z)
	if not self.index[x] then self.index[x] = {} end
	if not self.index[x][y] then self.index[x][y] = {} end
	if not self.index[x][y][z] then
		table.insert(self.vertices, x)
		table.insert(self.vertices, y)
		table.insert(self.vertices, z)
		self.index[x][y][z] = #self.vertices / 3
	end
end

function Mesh:addPolygonXZ(polygon)
	if #polygon > 4 then
		local tris = love.math.triangulate(polygon)
		for i, t in ipairs(tris) do
			self:addVertex(t[1], 0, t[2])
			self:addVertex(t[3], 0, t[4])
			self:addVertex(t[5], 0, t[6])
			table.insert(self.triangles, self.index[t[1]][0][t[2]])
			table.insert(self.triangles, self.index[t[3]][0][t[4]])
			table.insert(self.triangles, self.index[t[5]][0][t[6]])
		end
	end
end

function Mesh:drawXZ()
	for i = 1, #self.triangles, 3 do
		love.graphics.polygon('fill',
			self.vertices[3 * self.triangles[i + 0] - 2], self.vertices[3 * self.triangles[i + 0]],
			self.vertices[3 * self.triangles[i + 1] - 2], self.vertices[3 * self.triangles[i + 1]],
			self.vertices[3 * self.triangles[i + 2] - 2], self.vertices[3 * self.triangles[i + 2]]
		)
	end
end

function Mesh:import(filename)
	local obj = obj_loader.load(filename)

	for i, v in ipairs(obj.v) do
		self:addVertex(v.x, v.y, v.z)
	end

	for i, f in ipairs(obj.f) do
		table.insert(self.triangles, f[1].v)
		table.insert(self.triangles, f[2].v)
		table.insert(self.triangles, f[3].v)
	end
end

function Mesh:export(filename)
	print(string.format('exporting to %s', filename))

	local file = io.open(filename, 'w+')

	for i = 1, #self.vertices, 3 do
		file:write(string.format('v %d %d %d\n', self.vertices[i], self.vertices[i + 1], self.vertices[i + 2]))
	end

	for i = 1, #self.triangles, 3 do
		file:write(string.format('f %d %d %d\n', self.triangles[i], self.triangles[i + 1], self.triangles[i + 2]))
	end

	file:close()
end

return Mesh
