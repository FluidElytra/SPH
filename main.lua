--[[
]]


Vector = require 'src/hump.vector'
require 'src/odonata/figure' -- odonata helps plotting graphs
require 'src/sph/particle'
require 'src/sph/sph'
require 'src/sph/boundary'
love.window.setMode(750, 750) -- window size
love.window.setTitle('SPH simulation') -- window title


function love.load()
	-- initialize the SPH instance
	sph = SPH()

	-- simulation parameters
	sph.rho_0 = 1000 -- [kg/m3] density of the fluid at rest
	local Lx = 1 -- [m] computation domain size along the x-axis
	local Ly = 1 -- [m] computation domain size along the y-axis
	local Nx = 15 -- [-] number of particles along the x axis
	local Ny = 15 -- [-] number of particles along the y axis
	local chi_s = 0.75 -- [-] ratio between fluid and "vacuum" within the domain

	-- adjust secondary parameters
	local N_part = Nx*Ny -- [-] total number of particles
	local dx = Lx/(Nx+1) -- [m] x-axis step
	local dy = Ly/(Ny+1) -- [m] y-axis step
	local mass = sph.rho_0 * 4/3 * math.pi * (Lx*Ly*chi_s/math.pi/N_part)^(3/2) -- [kg] one particle mass

	-- initialiaze the particle list
	particle_list = {}	
	local c = 1
	for i=1,Nx do
		for j=1,Ny do
			local position = Vector(i*dx,j*dy)
			local velocity = Vector(0,0) -- zero velocity initialization
			particle_list[c] = Particle(position,velocity)
			particle_list[c].mass = mass
			c=c+1
		end
	end

	-- set up sph
	sph.particle_list = particle_list -- add the particle to be simulated by SPH
	wall0 = Boundary(0,Vector(0,Ly)  , Vector(Lx,Ly),'wall')
	wall1 = Boundary(1,Vector(Lx,Ly) , Vector(Lx,0) ,'wall')
	wall2 = Boundary(2,Vector(Lx,0)  , Vector(0,0)  ,'wall')
	wall3 = Boundary(3,Vector(0,0)   , Vector(0,Ly) ,'wall')
	sph.boundaries = {wall0,wall1,wall2,wall3}

	-- initialiaze the Figure instance
	fig = Figure(Vector(50,50), Vector(650,650), Vector(0,Lx), Vector(0,Ly))
end


function love.update(dt)
	-- love.timer.sleep(0.5)
	sph:solver() -- compute particle locations	
end


function love.draw()
	-- draw the figure
	fig:draw()

	-- plot particles
	for j,particle in pairs(particle_list) do
		fig:plot(particle.x[1],{0.5,0,1})
	end
end
