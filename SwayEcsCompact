--!optimize 2
--!native
local RunService = game:GetService("RunService")

-- by omnivoore (ecs rewrite)

---- functions
local rad = math.rad
local sin, cos = math.sin, math.cos
local wave = 2 * math.pi
local random = Random.new()

---- ecs state
local nextEntityId = 0
local connection: RBXScriptConnection?

local instanceCount = 0
local variableCount = 0

---- components
local swaySpeed = {}
local swayIntensity = {}
local swayRotationMultiplier = {}
local swayElapsed = {}
local swayYPush = {}

local swayOrigin = {}
local swayInstance = {}
local swayIsMotor = {}

local swayVariableValue = {}

---- entities
local instanceEntities = {}         -- [entity] = true
local variableEntities = {}         -- [entity] = true

---- defaults
local defaultSpeed = 1
local defaultIntensity = vector.one
local defaultRotationMultiplier = 1
---- ecs helpers
local function newEntity(): number
	nextEntityId += 1
	return nextEntityId

end

---- core
local function startSystem()
	connection = RunService.Heartbeat:Connect(function(dt)

		for i = 1, instanceCount do
			local elapsed = swayElapsed[i] + dt * swaySpeed[i]
			swayElapsed[i] = elapsed

			local rSin = sin(elapsed)
			local rCos = cos(elapsed)
			local uSin = sin(elapsed + swayYPush[i])

			local rotMult = swayRotationMultiplier[i]
			local int = swayIntensity[i]
			local origin = swayOrigin[i]

			local cf =
				origin * CFrame.Angles(
					rad(rSin * rotMult),
					rad(uSin * rotMult),
					rad(rCos * rotMult)
				)
				+ vector.create(
					rSin * int.x,
					uSin * int.y,
					rCos * int.z
				)

			if swayIsMotor[i] then
				swayInstance[i].C0 = cf
			else
				swayInstance[i].CFrame = cf
			end
		end


		for i = 1, variableCount do
			local elapsed = swayElapsed[i] + dt * swaySpeed[i]
			swayElapsed[i] = elapsed

			local rSin = sin(elapsed)
			local rCos = cos(elapsed)
			local uSin = sin(elapsed + swayYPush[i])

			local rotMult = swayRotationMultiplier[i]
			local int = swayIntensity[i]

			swayVariableValue[i] =
				CFrame.Angles(
					rad(rSin * rotMult),
					rad(uSin * rotMult),
					rad(rCos * rotMult)
				)
				+ vector.create(
					rSin * int.x,
					uSin * int.y,
					rCos * int.z
				)
		end
	end)
end

---- main api
local Sway = {}

function Sway.Create(instance, data)
	instanceCount += 1
	local i = instanceCount

	swaySpeed[i] = data.Speed or defaultSpeed
	swayIntensity[i] = data.Intensity or defaultIntensity
	swayRotationMultiplier[i] = data.RotationMultiplier or defaultRotationMultiplier

	swayElapsed[i] = random:NextNumber(0, wave)
	swayYPush[i] = random:NextNumber(0, wave)

	local isMotor = instance:IsA("Motor6D") or instance:IsA("Weld")

	swayInstance[i] = instance
	swayOrigin[i] = isMotor and instance.C0 or instance.CFrame
	swayIsMotor[i] = isMotor

	if not connection then
		startSystem()
	end

	return i
end

function Sway.CreateVariable(data)
	variableCount += 1
	local i = variableCount

	swaySpeed[i] = data.Speed or defaultSpeed
	swayIntensity[i] = data.Intensity or defaultIntensity
	swayRotationMultiplier[i] = data.RotationMultiplier or defaultRotationMultiplier

	swayElapsed[i] = random:NextNumber(0, wave)
	swayYPush[i] = random:NextNumber(0, wave)

	swayVariableValue[i] = CFrame.identity

	if not connection then
		startSystem()
	end

	return i
end

function Sway.GetVariable(i)
	return swayVariableValue[i]
end

startSystem()

return Sway
