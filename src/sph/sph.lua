Object = require "src/classic"
require "src/sph/kernel"
SPH = Object:extend()

function SPH:new()
	self.particle_list = {} -- load particle list
	self.rho_0 = 1000 -- [kg/m3] rest density
	self.h = 0.1 -- [m] kernel action radius
	self.k = 0.8 -- [?] state equation coefficient
	self.mu = 0.001 -- [Pa.s] dynamic viscosity
	self.kernel = Kernel(self.h,'gaussian') -- instanciate the Kernel object to smooth fields
	self.dt = 0.05 -- [s] time step
	self.boudaries = {}
end

function SPH:solver()
	for i,particle in pairs(self.particle_list) do		
		-- find nearest particles
		nearest_particles,distance_list = particle:find_nearest(self.particle_list, self.h)
		
		-- compute particle's density and pressure
		local rho = 0 -- particle density
		local f_press = Vector(0,0) -- [N] pressure force
		local f_visc = Vector(0,0) -- [N] viscosity force
		for j,neighbor in pairs(nearest_particles) do
			local r = particle.x[2]-neighbor.x[2] -- [m] distance between the particle and one of its neighbors
			rho = rho + neighbor.m * self.kernel:kernel(r) -- [kg/m3] particle density
			local f_press_norm = - neighbor.m*(particle.p+neighbor.p)/2/neighbor.rho 
			f_press = f_press + f_press_norm * self.kernel:gradient(r) -- [N] pressure force
			f_visc = f_visc + self.mu*neighbor.m*(neighbor.v-particle.v)/neighbor.rho*self.kernel:laplacian(r) -- [N] viscosity force
		end
		
		-- update particle density and pressure
		particle.rho = rho -- [kg/m3]
		particle.p = self.k * (rho - self.rho_0) -- [Pa]

		-- integrate acceleration to obtain position
		-- local acceleration = (f_press+f_visc+Vector(0,-9.81))/particle.rho -- [m/s2]
		local acceleration = (f_press+f_visc+Vector(0,0))/particle.rho -- [m/s2]
		local velocity = particle.v + acceleration*self.dt -- [m/s]
		local position = particle.x[2] + velocity*self.dt -- [m]

		-- apply boundary conditions
		local new_position,new_velocity = self:boundary_conditions(particle,position,velocity)
		-- update particle dynamic properties
		particle:update(new_position,new_velocity,acceleration)
	end
end

function SPH:boundary_conditions(particle,position,velocity)
	-- inelastic boundary conditions
	local new_velocity = velocity
	local new_position = position
	local wall_damping = 0.9
	for i,boundary in pairs(self.boundaries) do
		local l1p1 = particle.x[2] -- last recorded position
		local l1p2 = position -- computed position
		local l2p1 = boundary[1]
		local l2p2 = boundary[2]

		out = checkIntersect(l1p1, l1p2, l2p1, l2p2)
		if out then
			-- find the intersection point
			l1p1x,l1p1y = particle.x[2].x, particle.x[2].y
			l1p2x,l1p2y = position.x,      position.y
			l2p1x,l2p1y = boundary[1].x,   boundary[1].y
			l2p2x,l2p2y = boundary[2].x,   boundary[2].y

			x,y = findIntersect(l1p1x,l1p1y, l1p2x,l1p2y, l2p1x,l2p1y, l2p2x,l2p2y, true, true)

			local bound_vect = boundary[1]-boundary[2]
			local traj_vect = particle.x[1]-particle.x[2]
			local theta = traj_vect:angleTo(bound_vect)
			local new_angle = math.pi+2*theta
			new_velocity = wall_damping*particle.v:rotated(new_angle)
			-- new_position = particle.x[1]
			new_position = Vector(x,y) - 0.001*velocity
		end
	end
	return new_position, new_velocity
end

-- function SPH:out_of_domain(particle)
-- 	for i,boundary in pairs(self.boudaries) do

-- 	end
-- 	return out, crossed_boundary
-- end







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