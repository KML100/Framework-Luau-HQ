------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: RuntimeModule

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)

local ConfigService = FLHQ("ConfigService") ConfigService:Load("ExecutorService")
local ObjectService = FLHQ("ObjectService")

type SelfType = {
	
	_Actor :Actor,
	_RequiredBootModule :any,	
	
	_CommunicationsChannel :SharedTable,
	
	_MainContainer :{},	
	_MainReturn :any,

	_Memory :SharedTable,
}


local RuntimeModule = {}

function RuntimeModule.New(Actor :Actor, CommunicationsChannel :SharedTable)

	local self :SelfType = {}

	self["<RL>_Actor"] = Actor
	self["<L>_RequiredBootModule"] = "__ALLOC__"
	
	self["<RL>_CommunicationsChannel"] = CommunicationsChannel
	
	self["<RL>_MainContainer"] = {}
	self["<L>_MainReturn"] = {}

	self["<L>_Memory"] = SharedTable.new()
	
	return ObjectService(script, self)
end

RuntimeModule["<M>Initialize"] = function(self :SelfType)

	local BootModule = self._Actor:FindFirstChild(ConfigService.BOOT_MODULE_NAME)
	local RequiredBootModule = require(BootModule)

	self._RequiredBootModule = RequiredBootModule

	local MainContainer = self._MainContainer
	MainContainer.Memory = self._Memory
	MainContainer.ReturnSpace = SharedTable.new()

	local MainFunction = RequiredBootModule[ConfigService.MAIN_FUNCTION_NAME]
	self:CallMain(MainFunction)

	self._CommunicationsChannel.Initialized = true
end

RuntimeModule["<LI>CallMain"] = function(self :SelfType, MainFunction)
	
	local Success, Return = pcall(MainFunction, self._MainContainer)
	if not Success then ConfigService:Halt(ConfigService.MAIN_FAILURE, Return) return end

	self._MainReturn = Return
end


local function CallFunction(self, Index, ...)
	local MainReturn = self._MainReturn
	local RequiredBootModule = self._RequiredBootModule

	local Function = ((type(MainReturn) == "table") and MainReturn[Index]) or RequiredBootModule[Index]

	if not Function then ConfigService:Halt(ConfigService.CALL_ON_NIL, Index) end
	if not (type(Function) == "function") then ConfigService:Halt(ConfigService.CALL_ON_NONE_FUNCTION, Index) end

	local ReturnSpace = self._MainContainer.ReturnSpace
	SharedTable.clear(ReturnSpace)

	for Iteration, Data in {Function(...)} do
		ReturnSpace[Iteration] = Data
	end
end

RuntimeModule["<I>TryCallParallel"] = CallFunction
RuntimeModule["<I>TryCallSerial"] = CallFunction
	
RuntimeModule["<I>NewMemory"] = function(self :SelfType, NewMemory :SharedTable)

	local MainContainer = self._MainContainer
	MainContainer.Memory = NewMemory
	MainContainer.ReturnSpace =  SharedTable.new()

	self._Memory = NewMemory
	self._MainContainer.Memory = NewMemory
end

RuntimeModule["<I>NewBootModule"] = function(self :SelfType)
	self._CommunicationsChannel.Cleared = false
	
	local BootModule = self._Actor:FindFirstChild(ConfigService.BOOT_MODULE_NAME)
	local RequiredBootModule = require(BootModule)
	
	self._RequiredBootModule = RequiredBootModule
	
	local MainFunction = RequiredBootModule[ConfigService.MAIN_FUNCTION_NAME]
	
	self:CallMain(MainFunction)
end

RuntimeModule["<I>Clear"] = function(self :SelfType)
	self:NewMemory(SharedTable.new())

	local OldBootModule = self._Actor:FindFirstChild(ConfigService.BOOT_MODULE_NAME)
	if OldBootModule then OldBootModule:Destroy() end
	
	self._MainReturn = "__CLEARED__"

	self._CommunicationsChannel.Cleared = true
end

return RuntimeModule
