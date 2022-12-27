Object = require "src/classic"
Boundary = Object:extend()

function Boundary:new(ID,vertex1,vertex2,BC_type)
	self.ID = ID
	self.vertex1 = vertex1
	self.vertex2 = vertex2
	self.type = BC_type
	self.pair = nil -- must be specified if the boundary is of type periodicity
end

function Boundary:isApplicable(particle,position)
	return checkIntersect(particle.x[2], position, self.vertex1, self.vertex2)
end

function Boundary:apply(particle,position,velocity)
	if self.type == 'wall' then
		position, velocity = self:wall(particle,position,velocity)
	elseif self.type == 'periodicity' then
		position, velocity = self:periodicity(particle,position,velocity)
	end
	return position,velocity
end

function Boundary:wall(particle,position,velocity)
	-- inelastic boundary conditions
	local new_velocity = velocity
	local new_position = position
	local wall_damping = 0.9

	-- find the intersection point
	l1p1x,l1p1y = particle.x[2].x, particle.x[2].y
	l1p2x,l1p2y = position.x,      position.y
	l2p1x,l2p1y = self.vertex1.x,  self.vertex1.y
	l2p2x,l2p2y = self.vertex2.x,  self.vertex2.y

	x,y = findIntersect(l1p1x,l1p1y, l1p2x,l1p2y, l2p1x,l2p1y, l2p2x,l2p2y, true, true)

	local bound_vect = self.vertex1-self.vertex2
	local traj_vect = particle.x[1]-particle.x[2]
	local theta = traj_vect:angleTo(bound_vect)
	local new_angle = math.pi+2*theta
	new_velocity = wall_damping*particle.v:rotated(new_angle)
	new_position = Vector(x,y) - 0.001*velocity

	return new_position, new_velocity
end

function Boundary:periodicity(particle,position,velocity)
	local new_velocity = velocity
	local new_position = position

	return new_position, new_velocity
end







-- Checks if two line segments intersect. Line segments are given in form of ({x,y},{x,y}, {x,y},{x,y}).
function checkIntersect(l1p1, l1p2, l2p1, l2p2)
	local function checkDir(pt1, pt2, pt3) return math.sign(((pt2.x-pt1.x)*(pt3.y-pt1.y)) - ((pt3.x-pt1.x)*(pt2.y-pt1.y))) end
	return (checkDir(l1p1,l1p2,l2p1) ~= checkDir(l1p1,l1p2,l2p2)) and (checkDir(l2p1,l2p2,l1p1) ~= checkDir(l2p1,l2p2,l1p2))
end

-- Checks if two lines intersect (or line segments if seg is true)
-- Lines are given as four numbers (two coordinates)
function findIntersect(l1p1x,l1p1y, l1p2x,l1p2y, l2p1x,l2p1y, l2p2x,l2p2y, seg1, seg2)
	local a1,b1,a2,b2 = l1p2y-l1p1y, l1p1x-l1p2x, l2p2y-l2p1y, l2p1x-l2p2x
	local c1,c2 = a1*l1p1x+b1*l1p1y, a2*l2p1x+b2*l2p1y
	local det,x,y = a1*b2 - a2*b1
	if det==0 then return false, "The lines are parallel." end
	x,y = (b2*c1-b1*c2)/det, (a1*c2-a2*c1)/det
	if seg1 or seg2 then
		local min,max = math.min, math.max
		if seg1 and not (min(l1p1x,l1p2x) <= x and x <= max(l1p1x,l1p2x) and min(l1p1y,l1p2y) <= y and y <= max(l1p1y,l1p2y)) or
		   seg2 and not (min(l2p1x,l2p2x) <= x and x <= max(l2p1x,l2p2x) and min(l2p1y,l2p2y) <= y and y <= max(l2p1y,l2p2y)) then
			return false, "The lines don't intersect."
		end
	end
	return x,y
end

function math.sign(n) return n>0 and 1 or n<0 and -1 or 0 end