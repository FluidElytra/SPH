Object = require "src/classic"
Boundary = Object:extend()

function Boundary:new(ID,vertex1,vertex2,BC_type)
	self.ID = ID
	self.vertex1 = vertex1
	self.vertex2 = vertex2
	self.type = BC_type
	self.pair = nil -- must be specified if the boundary is of type periodicity
end

function Boundary:periodicity(particle,position,velocity)
	local new_velocity = velocity
	local new_position = position

	return new_position, new_velocity
end

function Boundary:set(pressure,rho)
	if self.type == 'wall' or self.type == 'fixed_velocity' then
		self:fixed_velocity(self.velocity)
	end
end






