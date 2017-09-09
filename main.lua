local c = require('module')

love.graphics.setLineWidth(2)
love.graphics.setLineStyle('rough')

function love.load()
	verts = {}
	index = {}
	tris = {}

	love.mousepressed(100, 100)
	love.mousepressed(500, 100)
	love.mousepressed(500, 500)
	love.mousepressed(400, 500)
	love.mousepressed(400, 150)
	love.mousepressed(200, 150)
	love.mousepressed(200, 500)
	love.mousepressed(100, 500)
	-- love.keypressed('i')
	-- love.keypressed('t')
	-- love.keypressed('v')
end

function love.draw()
	for i, t in ipairs(tris) do
		love.graphics.setColor(15 * i, 10 * i, 5 * i)
		love.graphics.polygon('fill', unpack(t))
		-- love.graphics.print(index[t[1]][t[2]]..', '..index[t[3]][t[4]]..', '..index[t[5]][t[6]], 316, 16 * (i + 1))
	end
	love.graphics.setColor(255, 255, 255)

	if pmPolys then
		love.graphics.setColor(0, 0, 200, 120)
		for i, t in ipairs(pmPolys) do
			if through[i] then
				love.graphics.polygon('fill', unpack(t))
			end
		end
		love.graphics.setColor(255, 255, 255)
		for i, t in ipairs(pmPolys) do
			love.graphics.polygon('line', unpack(t))
		end
	end

	-- love.graphics.print('#verts = '..#verts, 16, 16)
	-- love.graphics.print('#tris = '..#tris  , 16, 32)

	local pos = 1
	for i = 1, #verts, 2 do
		love.graphics.circle('fill', verts[i], verts[i + 1], 3)
		-- love.graphics.print(string.format('%d %d', verts[i], verts[i + 1]), 116, 16 * (pos + 1))
		pos = pos + 1
	end

	if #verts > 4 then
		-- print('verts', unpack(verts))
		love.graphics.line(verts)
		love.graphics.line(verts[#verts - 1], verts[#verts], verts[1], verts[2])
	end

	-- if pmVerts then
	-- 	for i = 1, #pmVerts, 2 do
	-- 		love.graphics.circle('line', pmVerts[i], pmVerts[i + 1], 5)
	-- 	end
	-- end

	local rcVerts = {getVerts()}
	if rcVerts then
		local pos = 1
		for i = 1, #rcVerts, 3 do
			-- love.graphics.print(string.format('%d %d %d', rcVerts[i], rcVerts[i + 1], rcVerts[i + 2]), 216, 16 * (pos + 1))
			pos = pos + 1
		end
	end

	local rcTris = {getTris()}
	if rcTris then
		local pos = 1
		for i = 1, #rcTris, 3 do
			-- love.graphics.print(string.format('%d %d %d', rcTris[i], rcTris[i + 1], rcTris[i + 2]), 416, 16 * (pos + 1))
			pos = pos + 1
		end
	end

	-- love.graphics.print('getNVerts() = '..getNVerts(), 116, 16)
	-- love.graphics.print('getNTris() = '..getNTris(), 316, 16)

	if startX and startY and endX and endY then
		love.graphics.setColor(0, 200, 0)
		love.graphics.circle('fill', startX, startY, 5)
		love.graphics.setColor(200, 0, 0)
		love.graphics.circle('fill', endX, endY, 5)
		love.graphics.setColor(255, 255, 255)
	end
end

function love.mousepressed(x, y, button)
	if not index[x] then index[x] = {} end
	index[x][y] = #verts / 2

	table.insert(verts, x)
	table.insert(verts, y)
end

function love.keypressed(key)

	if key == 'v' then
		setVerts(unpack(verts))
	elseif key == 'i' then
		if #verts > 6 then
			tris = love.math.triangulate(verts)
		end
	elseif key == 's' then
		startX, startY = love.mouse.getPosition()
	elseif key == 'e' then
		endX, endY = love.mouse.getPosition()
	elseif key == 't' then
		local _tris = {}
		for i, t in ipairs(tris) do
			table.insert(_tris, index[t[1]][t[2]])
			table.insert(_tris, index[t[3]][t[4]])
			table.insert(_tris, index[t[5]][t[6]])
		end
		setTris(unpack(_tris))
	elseif key == 'space' then
		setPolyMesh()

		local nvp = getRcNVP()
		-- print('NVP = '..nvp)

		-- set Vertices from recast
		pmVerts = {getRcVerts()}
		-- print('#pmVerts', #pmVerts)
		-- print(unpack(pmVerts))

		-- set Polys from recast
		local rawPolys = {getRcPolys()}
		-- print('#rawPolys', #rawPolys, #rawPolys / nvp)
		-- print(unpack(rawPolys))

		pmPolys = {}
		for i = 1, #rawPolys, nvp do
			print('new poly')
			local poly = {}
			for j = 0, nvp - 1 do
				if rawPolys[i + j] == 65536 then break end
				-- print(rawPolys[i + j], 'pmVerts[', rawPolys[i + j] * 2 - 1, ']', 'pmVerts[', rawPolys[i + j] * 2, ']')
				table.insert(poly, pmVerts[rawPolys[i + j] * 2 - 1])
				table.insert(poly, pmVerts[rawPolys[i + j] * 2 + 0])
			end
			print(unpack(poly))
			table.insert(pmPolys, poly)
		end

		setNavMesh()
		local data = {queryNavMesh(startX, startY, endX, endY)}
		startX, startY = data[1], data[2]
		endX, endY = data[3], data[4]
		through = {}
		for i = 6, #data do
			-- print(data[i])
			through[data[i] + 1] = true
		end
		-- print('----------------------------------------------')
		-- for k, v in pairs(through) do
		-- 	print(k, v)
		-- end
		-- print('----------------------------------------------')
		-- for i, t in ipairs(pmPolys) do
		-- 	print(i, through[i])
		-- 	-- if through[i] then
		-- 	-- 	love.graphics.setColor(0, 0, 200)
		-- 	-- 	love.graphics.polygon('fill', unpack(t))
		-- 	-- 	love.graphics.setColor(255, 255, 255)
		-- 	-- else
		-- 	-- 	love.graphics.polygon('line', unpack(t))
		-- 	-- end
		-- end
		-- print('----------------------------------------------')
		-- print('data', unpack(data))
	end
end
