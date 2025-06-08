--!strict
local RunService = game:GetService("RunService")

-- types
type SwayInstance = {
	Speed: number,
	Intensity: vector,
	RotationMultiplier: number,
	
	YPush: number,
	Elapsed: number,
	Origin: CFrame,
}

export type Sway = {
	Create: (self: Sway, Motor6D|Attachment,{
		Speed: number?,
		Intensity: vector?,
		RotationMultiplier: number?,
	}?) -> (),
	Disconnect: (self: Sway, Motor6D|Attachment) -> (),
	DisconnectAll: (self: Sway) -> (),
	
	_instances: {[Motor6D|Attachment]: SwayInstance}
}

-- variables
local random = Random.new()
local defaultValues = {
	Speed = 1,
	Intensity = vector.one,
	RotationMultiplier = 1
} :: SwayInstance
local module: Sway = {} :: Sway
module._instances = {}

-- functions
local connection: RBXScriptConnection?

local function link(bool: boolean)
	if not bool then
		if not connection then
			warn("There is no connection.")
			return
		end
		connection:Disconnect()
		connection = nil
	elseif bool then
		if connection then
			warn('There is already a connection.')
			return
		end
		connection = RunService.RenderStepped:Connect(function(dt: number)
			for instance, data in module._instances do
				data.Elapsed += (dt * data.Speed)
				local rSin, rCos, uSin = math.sin(data.Elapsed), math.cos(data.Elapsed), math.sin(data.Elapsed + data.YPush)
				
				local rotation = CFrame.Angles(
					math.rad(rSin * data.RotationMultiplier),
					math.rad(uSin * data.RotationMultiplier),
					math.rad(rCos * data.RotationMultiplier)
				)
				
				local offset = vector.create(rSin, uSin, rCos) * data.Intensity
				local newOrigin = data.Origin * rotation + (offset :: any)
				
				if instance:IsA('Attachment') then
					instance.CFrame = newOrigin
				elseif instance:IsA('Motor6D') then
					instance.C0 = newOrigin
				end
			end
		end)
	end
end

-- module functions
function module:Create(instance, data)
	assert(instance:IsA('Motor6D') or instance:IsA('Attachment'), "Instance has to be an attachment OR motor6D.")
	
	local instanceData = {} :: SwayInstance
	if data then
		for key, value in defaultValues do
			instanceData[key] = data[key] or value
		end
	else
		instanceData = table.clone(defaultValues)
	end
	instanceData.Elapsed = random:NextNumber(0, 100)
	instanceData.YPush = random:NextNumber(0, 30)
	if instance:IsA("Motor6D") then
		instanceData.Origin = instance.C0
	elseif instance:IsA("Attachment") then
		instanceData.Origin = instance.CFrame
	end
	
	self._instances[instance] = instanceData
	if not connection then
		link(true)
	end
end

function module:Disconnect(instance)
	local data = self._instances[instance]
	if not data then
		warn('Instance invalid.')
		return
	end
	
	if instance:IsA('Motor6D') then
		instance.C0 = data.Origin
	elseif instance:IsA('Attachment') then
		instance.CFrame = data.Origin
	end
	
	self._instances[instance] = nil
	
	if next(self._instances) == nil then
		print("No sway instances found, disconnecting loop.")
		link(false)
	end
end

function module:DisconnectAll()
	for instance, data in self._instances do
		if instance:IsA('Motor6D') then
			instance.C0 = data.Origin
		elseif instance:IsA('Attachment') then
			instance.CFrame = data.Origin
		end
	end
	
	self._instances = {}
	link(false)
end

return module
