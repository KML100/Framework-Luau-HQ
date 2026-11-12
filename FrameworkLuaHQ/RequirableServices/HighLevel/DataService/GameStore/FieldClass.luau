------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: FieldClass

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)

local InternalService = FLHQ("InternalService") 
local ObjectService = FLHQ("ObjectService")
local TaskService = FLHQ("TaskService")

local RETRY_TIME = 1

type SelfType = {
	_DataStore :DataStore,
}

local function DecodeData(Data)
	if not Data then return nil end
	return InternalService:DecodeTable(Data)
end

local function EncodeData(...)
	return InternalService:EncodeTable(...)
end

local function UpdateAction(DataStore, Key, Callback)
	DataStore:UpdateAsync(Key, function(CurrentData) -- sometimes does not get called when closing, not 
		return EncodeData(Callback(DecodeData(CurrentData)))
	end)
end

local function SetAction(DataStore, Key, ...)
	DataStore:SetAsync(Key, EncodeData(...))
end

local FieldClass = {}

function FieldClass.New(DataStore)

	local self = {}
	
	self["<RL>_DataStore"] = DataStore

	return ObjectService(script, self)
end

FieldClass["<I>GetAsyncData"] = function(self :SelfType, Key :string, Callback, FailCallback)
	local DataStore = self._DataStore
	
	local Data = nil
	TaskService(function()
		Data = DataStore:GetAsync(Key)
	end):OnFail(function()
		task.wait(RETRY_TIME)
		Data = DataStore:GetAsync(Key)
	end):OnFail(function()
		warn("GetAsyncData Failed!")
		if FailCallback then FailCallback() end
	end):Do()
	
	if Callback then Callback(DecodeData(Data)) return end
	
	return DecodeData(Data)
end

FieldClass["<I>SetAsyncData"] = function(self :SelfType, Key :string, FailCallback, ...)
	local DataStore = self._DataStore
	
	local Payload = table.pack(...)
	TaskService(function()
		SetAction(DataStore, Key, table.unpack(Payload))
	end):OnFail(function()
		task.wait(RETRY_TIME)
		SetAction(DataStore, Key, table.unpack(Payload))
	end):OnFail(function()
		warn("SetAsyncData Failed!")
		if FailCallback then FailCallback() end
	end):Do()
end

FieldClass["<I>GetSetAtomicData"] = function(self :SelfType, Key :string, Callback, FailCallback)
	local DataStore = self._DataStore

	TaskService(function()
		UpdateAction(DataStore, Key, Callback)
	end):OnFail(function()
		task.wait(RETRY_TIME)
		UpdateAction(DataStore, Key, Callback)
	end):OnFail(function()
		warn("GetSetAtomicData Failed!")
		if FailCallback then FailCallback() end
	end):Do()
end

FieldClass["<I>RemoveAsyncData"] = function(self :SelfType, Key :string, FailCallback)
	local DataStore = self._DataStore

	TaskService(function()
		DataStore:RemoveAsync(Key)
	end):OnFail(function()
		task.wait(RETRY_TIME)
		DataStore:RemoveAsync(Key)
	end):OnFail(function()
		warn("RemoveAsyncData Failed!")
		if FailCallback then FailCallback() end
	end):Do()
end

return FieldClass
