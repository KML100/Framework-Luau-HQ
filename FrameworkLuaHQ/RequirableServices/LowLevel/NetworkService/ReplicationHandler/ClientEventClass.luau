------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--// NAME: ClientEventClass

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)

local InternalService = FLHQ("InternalService")
local ObjectService = FLHQ("ObjectService")

local IsClient = RunService:IsClient()

type SelfType = {

	_Callbacks :any,

	_RemoteEvent :RemoteEvent,
}

local ClientEventClass = {}

function ClientEventClass.New(RemoteEvent)

	local self :SelfType = {}

	self["<RL>_Callbacks"] = {}

	self["<RL>_RemoteEvent"] = RemoteEvent

	return ObjectService(script, self)
end

ClientEventClass["<M>Initialize"] = function(self :SelfType)

	self._RemoteEvent.OnClientEvent:Connect(function(Data) -- memory leak
		InternalService:FireCallbacks(self._Callbacks, table.unpack(Data))
	end)
end

ClientEventClass["<I>Send"] = function(self :SelfType, ...)
	local Payload = table.pack(...)
	self._RemoteEvent:FireServer(Payload)
end

ClientEventClass["<M>Call"] = function(self :SelfType, Callback)
	
	local Id = InternalService:NewUUID()
	self._Callbacks[Id] = {Callback = Callback, Async = true}

	return {
		Disconnect = function()
			self._Callbacks[Id] = nil	
		end,
	}
end

return ClientEventClass
