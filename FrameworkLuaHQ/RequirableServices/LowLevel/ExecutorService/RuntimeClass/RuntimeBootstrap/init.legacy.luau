------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: RuntimeBootstrap

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)

local ConfigService = FLHQ("ConfigService") ConfigService:Load("ExecutorService")

local Actor = script:GetActor()
if not Actor then ConfigService:Halt(ConfigService.RUNTIME_ACTOR_NIL) end

local RuntimeModule = require(script.RuntimeModule)
local RuntimeInstance = nil
local InitializationStarted = false

local function SafeCallRuntime(FunctionName, ...)
	if not RuntimeInstance then return end
	RuntimeInstance[FunctionName](RuntimeInstance, ...)
end

Actor:BindToMessage("Initialize", function(CommunicationChannel)
	if InitializationStarted then return end
	InitializationStarted = true
	
	RuntimeInstance = RuntimeModule.New(Actor, CommunicationChannel)
end)

Actor:BindToMessageParallel("TryCallParallel", function(...)
	SafeCallRuntime("TryCallParallel", ...)
end)

Actor:BindToMessage("TryCallSerial", function(...)
	SafeCallRuntime("TryCallSerial", ...)
end)

Actor:BindToMessage("NewMemory", function(...)
	SafeCallRuntime("NewMemory", ...)
end)

Actor:BindToMessage("NewBootModule", function(...)
	SafeCallRuntime("NewBootModule", ...)
end)

Actor:BindToMessage("Clear", function(...)
	SafeCallRuntime("Clear", ...)
end)