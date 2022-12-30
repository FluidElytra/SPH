Object = require "src/classic"
Boundary = Object:extend()

function Boundary:new(ID,vertex1,vertex2,BC_type)
	self.ID = ID
	self.vertex1 = vertex1
	self.vertex2 = vertex2
	self.type = BC_type
	self.pair = nil -- must be specified if the boundary is of type periodicity
	self.velocity = 0
end

function Boundary:periodicity(particle,position,velocity)
	local new_velocity = velocity
	local new_position = position

	return new_position, new_velocity
end

function Boundary:set(pressure,rho,mass)
	if self.type == 'wall' or self.type == 'fixed_velocity' then
		self:fixed_velocity(pressure,rho,mass)
	end
end

function Boundary:fixed_velocity(pressure,rho,mass)
	-- geometry
	

	-- generate particles
	local N = 15
	local particle_list = {}
	for i = 1:N do
		local x =
		local y = 
		local position = Vector(x,y)
		local velocity = self.velocity
		particle_list[i] = Particle(position,velocity)
		particle_list[i].mass = mass
		particle_list[i].rho = rho
		particle_list[i].p = pressure
	end
	return particle_list
end