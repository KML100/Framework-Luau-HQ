------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: RuntimeClass

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)

local ConfigService = FLHQ("ConfigService") ConfigService:Load("ExecutorService")
local InternalService = FLHQ("InternalService")
local ObjectService = FLHQ("ObjectService")

type SelfType = {
	_Actor :Actor,
	_MainModule :ModuleScript,
	_Memory :SharedTable,
	
	_OnDecommisionEvent :{},
	
	_CommunicationChannel :SharedTable, 
	
	_Initialized :boolean,
}

local RuntimeClass = {}

function RuntimeClass.New(BootModule, BootMemory)

	local self :SelfType = {}

	self["<RL>_Actor"] = "__ALLOC__"
	self["<L>_MainModule"] = "__ALLOC__"
	self["<L>_Memory"] = "__ALLOC__"
	
	self["<RL>_OnDecommisionEvent"] = {}
	
	self["<RL>_CommunicationChannel"] = SharedTable.new()

	self["<L>_Initialized"] = false

	return ObjectService(script, self, BootModule, BootMemory)
end

RuntimeClass["<M>Initialize"] = function(self :SelfType, BootModule :ModuleScript, BootMemory: SharedTable?)
	
	local ActorFolder = workspace:FindFirstChild(ConfigService.ACTOR_FOLDER_NAME)
	if not ActorFolder then
		ActorFolder = Instance.new("Folder", workspace)
		ActorFolder.Name = ConfigService.ACTOR_FOLDER_NAME
	end
	
	local NewActor = Instance.new("Actor", ActorFolder)

	local NewBootModule = BootModule:Clone()
	NewBootModule.Name = ConfigService.BOOT_MODULE_NAME
	NewBootModule.Parent = NewActor
	
	local NewRuntime = script.RuntimeBootstrap:Clone()
	NewRuntime.Parent = NewActor
	NewRuntime.Enabled = true
	
	self._MainModule = NewBootModule
	self._Actor = NewActor
	
	local CommunicationChannel = self._CommunicationChannel
	
	InternalService:TaskPooledThread(function()
		local Attempts = 0
		while not CommunicationChannel.Initialized do
			NewActor:SendMessage("Initialize", CommunicationChannel)
			RunService.Stepped:Wait()

			Attempts += 1
			if Attempts >= ConfigService.MAX_INITIALIZATION_ATTEMPS then ConfigService:Halt(ConfigService.INITIALIZATION_FAILED_COUNT) end
		end

		local NewMemory = BootMemory or SharedTable.new()
		NewActor:SendMessage("NewMemory", NewMemory)

		self._Memory = NewMemory
		self._Initialized = true
	end)
end

RuntimeClass["<IL>_WaitUntillInitialized"] = function(self :SelfType)
	if self._Initialized then return end

	repeat RunService.Stepped:Wait() until self._Initialized
end

RuntimeClass["<I>TryCall"] = function(self :SelfType, ParallelCall :boolean, Index, ...)
	self._WaitUntillInitialized()

	if not self._Actor then return end
	if self._CommunicationChannel.Cleared then ConfigService:Halt(ConfigService.PREMATURE_CALL) end

	if ParallelCall then self._Actor:SendMessage("TryCallParallel", tostring(Index), ...) return end
	
	self._Actor:SendMessage("TryCallSerial", tostring(Index), ...)
end

RuntimeClass["<I>SetNewBootModule"] = function(self :SelfType, BootModule :ModuleScript, BootMemory: SharedTable?)
	self._WaitUntillInitialized()
	
	local CommunicationChannel = self._CommunicationChannel
	if not CommunicationChannel.Cleared then ConfigService:Halt(ConfigService.INITIALIZATION_FAILED_CLEAR) end
	
	local Actor = self._Actor
	if not self._Actor then return end
	
	local NewBootModule = BootModule:Clone()
	NewBootModule.Name = ConfigService.BOOT_MODULE_NAME
	NewBootModule.Parent = Actor
	
	self._MainModule = NewBootModule
	
	Actor:SendMessage("NewBootModule")
	
	local Attempts = 0
	while CommunicationChannel.Cleared do
		RunService.Stepped:Wait()
		Attempts += 1
		if Attempts >= ConfigService.MAX_INITIALIZATION_ATTEMPS then ConfigService:Halt(ConfigService.INITIALIZATION_FAILED_COUNT) end
	end
	
	local NewMemory = BootMemory or SharedTable.new()
	Actor:SendMessage("NewMemory", NewMemory)
	self._Memory = NewMemory
end

RuntimeClass["<I>SetNewMemory"] = function(self :SelfType, NewMemory :SharedTable)
	self._WaitUntillInitialized()

	self._Memory = NewMemory

	self._Actor:SendMessage("NewMemory", NewMemory)
end

RuntimeClass["<I>GetMemory"] = function(self :SelfType)
	self._WaitUntillInitialized()
	
	return self._Memory
end

RuntimeClass["<I>GetModule"] = function(self :SelfType)
	return self._MainModule
end


RuntimeClass["<I>Clear"] = function(self :SelfType)
	self._WaitUntillInitialized()
	
	if self._CommunicationChannel.Cleared then return end
	if not self._Actor then return end
	
	SharedTable.clear(self._Memory)
	self._Actor:SendMessage("Clear")
end

RuntimeClass["<I>Decommission"] = function(self :SelfType)
	self:Clear()
	
	InternalService:FireCallbacks(self._OnDecommisionEvent)
end

RuntimeClass["<I>OnDecommission"] = function(self :SelfType, Callback)
	table.insert(self._OnDecommisionEvent, {Callback = Callback, Async = true})
end

RuntimeClass["<I>Destroy"] = function(self :SelfType)
	if not self._Actor then return end
	
	self._Actor:Destroy()
end

return RuntimeClass