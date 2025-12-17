--!optimize 2
--!native

-- by omnivoore

local RunService = game:GetService("RunService")

-- types
export type SwayInstance = {
	Speed: number,
	Intensity: vector,
	RotationMultiplier: number,

	YPush: number,
	Elapsed: number,
	Origin: CFrame,
	Instance: Attachment | Motor6D | Weld,
	_isM6D: boolean,
}

export type VariableSwayInstance = {
	Speed: number,
	Intensity: vector,
	RotationMultiplier: number,

	YPush: number,
	Elapsed: number,
	Value: CFrame,
}

export type ValueParameters = {
	Speed: number?,
	Intensity: vector?,
	RotationMultiplier: number?,
}?

export type Sway = {
	Create: typeof(
		-- Creates a sway instance.
		function(instance: Attachment | Motor6D | Weld, data: ValueParameters): SwayInstance end
	),
	
	CreateVariable: typeof(
		-- Creates a variable sway instance.
		-- Access using module._variables[x].Value
		function(data: ValueParameters): VariableSwayInstance end
	),

	_instances: { SwayInstance },
	_instDict: { [Attachment | Motor6D | Weld]: SwayInstance },
	_variables: { VariableSwayInstance },
}

local rad = math.rad
local sin, cos = math.sin, math.cos
local wave = 2 * math.pi
local random = Random.new()

local defaultValues = {
	Speed = 1,
	Intensity = vector.one,
	RotationMultiplier = 1,
}

local module: Sway = {
	_instances = {},
	_instDict = {},
	_variables = {},
}

local connection: RBXScriptConnection?

local function start()
	connection = RunService.Heartbeat:Connect(function(dt)
		for _, data in module._instances do
			local elapsed = data.Elapsed + dt * data.Speed
			data.Elapsed = elapsed

			local rSin = sin(elapsed)
			local rCos = cos(elapsed)
			local uSin = sin(elapsed + data.YPush)

			local rotMult = data.RotationMultiplier
			local int = data.Intensity
			local origin = data.Origin

			local new = origin * CFrame.Angles(
				rad(rSin * rotMult),
				rad(uSin * rotMult),
				rad(rCos * rotMult)
			) + vector.create(
				rSin * int.x,
				uSin * int.y,
				rCos * int.z
			)

			if data._isM6D then
				data.Instance.C0 = new
			else
				data.Instance.CFrame = new
			end
		end
		
		for _, data in module._variables do
			local elapsed = data.Elapsed + dt * data.Speed
			data.Elapsed = elapsed
			
			local rSin = sin(elapsed)
			local rCos = cos(elapsed)
			local uSin = sin(elapsed + data.YPush)

			local rotMult = data.RotationMultiplier
			local int = data.Intensity
			local origin = data.Origin
			
			data.Value = CFrame.Angles(
				rad(rSin * rotMult),
				rad(uSin * rotMult),
				rad(rCos * rotMult)
			) + vector.create(
				rSin * int.x,
				uSin * int.y,
				rCos * int.z
			)
		end
	end)
end

function module.Create(instance: Attachment | Motor6D, data): SwayInstance
	local d: SwayInstance = {} :: any

	for k, v in defaultValues do
		local nv = data and data[k]
		d[k] = nv or v
	end

	d.Elapsed = random:NextNumber(0, wave)
	d.YPush = random:NextNumber(0, wave)
	d.Instance = instance

	if instance:IsA("Motor6D") or instance:IsA('Weld') then
		d.Origin = instance.C0
		d._isM6D = true
	else
		d.Origin = instance.CFrame
		d._isM6D = false
	end

	module._instDict[instance] = d
	table.insert(module._instances, d)

	if not connection then
		start()
	end

	return d
end

function module.CreateVariable(data): SwayInstance
	local d: SwayInstance = {} :: any

	for k, v in defaultValues do
		local nv = data and data[k]
		d[k] = nv or v
	end

	d.Elapsed = random:NextNumber(0, wave)
	d.YPush = random:NextNumber(0, wave)

	table.insert(module._variables, d)

	if not connection then
		start()
	end

	return d
end

return module
