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
	self.boudaries = {} -- list of boundary conditions
	self.gravity = true -- if gravity must be taken into account
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
		local acceleration = 0
		if self.gravity == true then
			acceleration = (f_press+f_visc+Vector(0,-9.81))/particle.rho -- [m/s2]
		else
			acceleration = (f_press+f_visc+Vector(0,0))/particle.rho -- [m/s2]
		end
		local velocity = particle.v + acceleration*self.dt -- [m/s]
		local position = particle.x[2] + velocity*self.dt -- [m]

		-- update particle dynamic properties
		particle:update(new_position,new_velocity,acceleration)
	end
end

function SPH:set_boundaries()
	-- compute the density, velocity, pressure for particles
	local rho = self.rho_0
	local pressure = 0

	-- set the boundary using dynamic method
	for i,boundary in ipairs(self.set_boundaries) do
		boundary:set(pressure,self.rho_0)
	end
end