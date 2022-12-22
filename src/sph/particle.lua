Object = require "src/classic"
Particle = Object:extend()

function Particle:new(position,velocity)
	self.x = {position,position} -- [m] particle position
	self.v = velocity -- [m/s] particle velocity
	self.a = 0 -- [m/s2] particle acceleration
	self.m = 1 -- [kg] particle mass
	self.p = 0 -- [Pa] particle pressure
	self.rho = 1000 -- [kg/m3] particle density
end

function Particle:update(position,velocity,acceleration)
	self.x = {self.x[2],position}
	self.v = velocity
	self.a = acceleration
end

function Particle:find_nearest(particle_list,maximum_radius)
	local neighbor_list = {}
	local distance_list = {}
	local c = 0
	for p, particle in pairs(particle_list) do
		local r = particle.x[2]-self.x[2]
		local norm_r = r:len()
		if norm_r <= maximum_radius then
			neighbor_list[c] = particle
			distance_list[c] = norm_r
			c = c + 1
		end
	end
	return neighbor_list, distance_list
end