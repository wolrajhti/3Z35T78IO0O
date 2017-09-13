local Vector = class('Vector')

function Vector:initialize(X, y)
	if y then self.x, self.y = X, y
	elseif X then self.x, self.y = X.x, X.y
	else self.x, self.y = 0, 0 end
end

function Vector:clone() return Vector(self.x, self.y) end

function Vector:polar(angle, norm, X, y) return Vector((norm or 1), 0):rotate(angle):add(X, y) end

function Vector:unpack() return self.x, self.y end

function Vector.__unm(a) return Vector(-a.x, -a.y) end
function Vector.__add(a, b) return Vector(a.x + b.x, a.y + b.y) end
function Vector.__sub(a, b) return Vector(a.x - b.x, a.y - b.y) end
function Vector.__mul(a, b)
	if type(a) == 'number' then return Vector(a * b.x, a * b.y)
	elseif type(b) == 'number' then return Vector(a.x * b, a.y * b)
	else return Vector(a.x * b.x, a.y * b.y) end
end
function Vector.__div(a, b)
	if type(a) == 'number' then return Vector(a / b.x, a / b.y)
	elseif type(b) == 'number' then return Vector(a.x / b, a.y / b)
	else return Vector(a.x / b.x, a.y / b.y) end
end

function Vector:unm()
	self.x, self.y = -self.x, -self.y
	return self
end
function Vector:add(X, y)
	if y then self.x, self.y = self.x + X, self.y + y
	elseif X then self.x, self.y = self.x + X.x, self.y + X.y
	end
	return self
end
function Vector:sub(X, y)
	if y then self.x, self.y = self.x - X, self.y - y
	elseif X then self.x, self.y = self.x - X.x, self.y - X.y
	end
	return self
end
function Vector:mul(X, y)
	if y then self.x, self.y = self.x * X, self.y * y
	elseif X then
		if type(X) == 'number' then self.x, self.y = self.x * X, self.y * X
		else self.x, self.y = self.x * X.x, self.y * X.y
		end
	end
	return self
end
function Vector:div(X, y)
	if y then self.x, self.y = self.x / X, self.y / y
	elseif X then
		if type(X) == 'number' then self.x, self.y = self.x / X, self.y / X
		else self.x, self.y = self.x / X.x, self.y / X.y
		end
	end
	return self
end

function Vector:dot(X, y)
	if y then
		return self.x * X + self.y * y
	else
		return self.x * X.x + self.y * X.y
	end
end

function Vector:cross(X, y)
	if y then
		return self.x * y - X * self.y
	else
		return self.x * X.y - X.x * self.y
	end
end

function Vector:norm()
	return math.sqrt(self:norm2())
end

function Vector:norm2()
	return math.pow(self.x, 2) + math.pow(self.y, 2)
end

function Vector:normalize(by)
	if self:norm() == 0 then return self end
	return self:mul((by or 1) / self:norm())
end

function Vector:angle(X, y)
	if X then
		local a1 = self:angle()
		local a2 = Vector(X, y):angle()
		if a2 < a1 then return a2 + 2 * math.pi - a1
		else return a2 - a1 end
		-- if a1 < a2 then return a1 + 2 * math.pi - a2
		-- else return a1 - a2 end
	else
		if self.y > 0 then return math.acos(self.x / self:norm())
		else return 2 * math.pi - math.acos(self.x / self:norm()) end
	end
end

function Vector:dist(X, y)
	if y then return math.sqrt(math.pow(self.x - X, 2) + math.pow(self.y - y, 2))
	elseif X then return math.sqrt(math.pow(self.x - X.x, 2) + math.pow(self.y - X.y, 2))
	else return self:norm() end
end

function Vector:dist2(X, y)
	if y then return math.pow(self.x - X, 2) + math.pow(self.y - y, 2)
	elseif X then return math.pow(self.x - X.x, 2) + math.pow(self.y - X.y, 2)
	else return self:norm2() end
end

function Vector:move(X, y) return self:add(X, y) end

function Vector:scale(by, X, y) return self:sub(X, y):mul(by or 1):add(X, y) end

function Vector:rotate(by, X, y)
	self:sub(X, y)
	self.x, self.y = self.x * math.cos(by) - self.y * math.sin(by), self.x * math.sin(by) + self.y * math.cos(by)
	return self:add(X, y)
end

function Vector:project(X, y)
	-- TODO
end

function Vector:symmetric(X, y)
	return self:clone():rotate(2 * self:angle(X, y))
end

function Vector:testSide(X, y)
	-- TODO
end

function Vector:getTangent(by)
	return self:clone():rotate():normalize(by)
end

function Vector:getNormal(by)
	return self:clone():rotate(math.pi / 2):normalize(by)
end

function Vector.__tostring(a)
	return string.format('(%f, %f)', a.x, a.y)
end

function Vector:tostring()
	return string.format('(%f, %f)', self.x, self.y)
end

function Vector:draw(radius)
	love.graphics.circle('fill', self.x, self.y, radius or 4)
	return self
end

return Vector