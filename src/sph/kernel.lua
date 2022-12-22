Object = require "src/classic"
Kernel = Object:extend()

function Kernel:new(h,func)
	--[[
	description : constructor of the Kernel class
	input 		: h <float> radius of the kernel
	output 		: func <str> a string that specify kernel analytical expression
	]]
	self.h = h -- kernel parameter
	self.func = func -- kernel function
end

function Kernel:kernel(r)
	--[[
	description : order 0 of the kernel
	input 		: r <Vector> 
	output 		: kernel <float> 
	]]
	local kernel = 0
	local norm_r = r:len()
	if self.func == 'gaussian' then
		if norm_r <= self.h and norm_r >= 0 then
			kernel = 1/self.h^3/math.pi^(3/2) * math.exp(-norm_r^2/self.h^2)
		end
	end
	return kernel
end

function Kernel:gradient(r)
	--[[
	description : computes the gradient of the chosen kernel
	input 		: r <Vector>
	output 		: kernel <Vector>
	]]
	local kernel = Vector(0,0)
	local norm_r = r:len()
	if self.func == 'gaussian' then
		if norm_r <= self.h and norm_r >= 0 then			
			local kernel_norm = -2/self.h^5/math.pi^(3/2) * norm_r * math.exp(-norm_r^2/self.h^2)			
			kernel.x = r.x * kernel_norm			
			kernel.y = r.y * kernel_norm
		end
	end
	return kernel
end

function Kernel:laplacian(r)
	--[[
	description : computes the laplacian of the chosen kernel
	input 		: r <Vector>
	output 		: kernel <float>
	]]
	local kernel = 0
	local norm_r = r:len()
	if self.func == 'gaussian' then
		if norm_r <= self.h and norm_r >= 0 then
			kernel = 2/self.h^5/math.pi^(3/2) * math.exp(-norm_r^2/self.h^2) * (2/self.h^2*norm_r^2 - 1)
		end
	end
	return kernel
end




-- other kernels
-- function kernel_poly6(r,h)
-- 	if r <= h and r >= 0 then
-- 		return (315/(64*math.pi*h^9))*(h^2-r^2)^3
-- 	else
-- 		return 0
-- 	end
-- end

-- function kernel_spiky(r,h)
-- 	if r <= h and r >= 0 then
-- 		return (15/(math.pi*h^6))*(h-r)^3
-- 	else
-- 		return 0
-- 	end
-- end

-- function kernel_viscosity(r,h,order)
-- 	if r <= h and r >= 0 then
-- 		if order == 0 then
-- 			return (15/(2*math.pi*h^3)) * (-(r^3)/(2*h^3) + (r^2)/(h^2) + (h)/(2*r) - 1)
-- 		elseif order == 2 then
-- 			return 45/math.pi/h^6*(h-r)
-- 		end
-- 	else
-- 		return 0
-- 	end
-- end
