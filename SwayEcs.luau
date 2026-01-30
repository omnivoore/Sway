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

---- components
local swaySpeed = {}                -- [entity] = number
local swayIntensity = {}            -- [entity] = vector
local swayRotationMultiplier = {}   -- [entity] = number
local swayElapsed = {}              -- [entity] = number
local swayYPush = {}                -- [entity] = number

local swayOrigin = {}               -- [entity] = CFrame
local swayInstance = {}             -- [entity] = Attachment | Motor6D | Weld
local swayIsMotor = {}              -- [entity] = boolean

local swayVariableValue = {}        -- [entity] = CFrame

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
		-- instance
		for entity in instanceEntities do
			local elapsed = swayElapsed[entity] + dt * swaySpeed[entity]
			swayElapsed[entity] = elapsed

			local rSin = sin(elapsed)
			local rCos = cos(elapsed)
			local uSin = sin(elapsed + swayYPush[entity])

			local rotMult = swayRotationMultiplier[entity]
			local int = swayIntensity[entity]
			local origin = swayOrigin[entity]

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

			if swayIsMotor[entity] then
				swayInstance[entity].C0 = cf
			else
				swayInstance[entity].CFrame = cf
			end
		end

		-- variables
		for entity in variableEntities do
			local elapsed = swayElapsed[entity] + dt * swaySpeed[entity]
			swayElapsed[entity] = elapsed

			local rSin = sin(elapsed)
			local rCos = cos(elapsed)
			local uSin = sin(elapsed + swayYPush[entity])

			local rotMult = swayRotationMultiplier[entity]
			local int = swayIntensity[entity]

			swayVariableValue[entity] =
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

function Sway.Create(instance: Attachment | Motor6D | Weld, data)
	local entity = newEntity()

	swaySpeed[entity] = data.Speed or defaultSpeed
	swayIntensity[entity] = data.Intensity or defaultIntensity
	swayRotationMultiplier[entity] = data.RotationMultiplier or defaultRotationMultiplier

	swayElapsed[entity] = random:NextNumber(0, wave)
	swayYPush[entity] = random:NextNumber(0, wave)

	local isMotor = instance:IsA("Motor6D") or instance:IsA("Weld")

	swayInstance[entity] = instance
	swayOrigin[entity] = isMotor and instance.C0 or instance.CFrame
	swayIsMotor[entity] = isMotor

	instanceEntities[entity] = true

	if not connection then
		startSystem()
	end

	return entity
end

function Sway.CreateVariable(data)
	local entity = newEntity()

	swaySpeed[entity] = data.Speed or defaultSpeed
	swayIntensity[entity] = data.Intensity or defaultIntensity
	swayRotationMultiplier[entity] = data.RotationMultiplier or defaultRotationMultiplier

	swayElapsed[entity] = random:NextNumber(0, wave)
	swayYPush[entity] = random:NextNumber(0, wave)

	swayVariableValue[entity] = CFrame.identity
	variableEntities[entity] = true

	if not connection then
		startSystem()
	end

	return entity
end

function Sway.GetVariable(entity): CFrame
	return swayVariableValue[entity]
end

function Sway.Remove(entity)
	swaySpeed[entity] = nil
	swayIntensity[entity] = nil
	swayRotationMultiplier[entity] = nil
	swayElapsed[entity] = nil
	swayYPush[entity] = nil

	swayOrigin[entity] = nil
	swayInstance[entity] = nil
	swayIsMotor[entity] = nil

	swayVariableValue[entity] = nil

	instanceEntities[entity] = nil
	variableEntities[entity] = nil
end

return Sway
