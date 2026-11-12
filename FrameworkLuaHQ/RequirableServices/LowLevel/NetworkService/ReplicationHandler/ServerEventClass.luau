------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--// NAME: ServerEventClass

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
	
	_EventName :string,
	_EventId :string,
	_RemoteEvent :RemoteEvent,
}

local ServerEventClass = {}

function ServerEventClass.New(EventName :string, RemoteEventFolder :Folder)

	local self :SelfType = {}
	
	self["<RL>_Callbacks"] = {}

	self["<Rl>_EventName"] = EventName
	self["<RL>_EventId"] = InternalService:NewUUID()
	self["<RL>_RemoteEvent"] = "__ALLOC__"

	return ObjectService(script, self, RemoteEventFolder)
end

ServerEventClass["<M>Initialize"] = function(self :SelfType, RemoteEventFolder :Folder)

	local Event = Instance.new("RemoteEvent", RemoteEventFolder)
	Event.Name = self._EventId
	
	self._RemoteEvent = Event

	Event.OnServerEvent:Connect(function(Player :Player, Data) -- memory leak
		InternalService:FireCallbacks(self._Callbacks, Player, table.unpack(Data))
	end)
end

ServerEventClass["<I>Send"] = function(self :SelfType, Target :Player, ...)
	local Payload = table.pack(...)

	if not Target then self._RemoteEvent:FireAllClients(Payload) return end
	if not Players[Target.Name] then error("Tried To Target A Non Existing Player") end

	self._RemoteEvent:FireClient(Target, Payload)
end

ServerEventClass["<M>Call"] = function(self :SelfType, Callback)

	local Id = InternalService:NewUUID()
	self._Callbacks[Id] = {Callback = Callback, Async = true}

	return {
		Disconnect = function()
			self._Callbacks[Id] = nil	
		end,
	}
end

ServerEventClass["<I>GetData"] = function(self :SelfType)
	return self._EventId, self._EventName
end

return ServerEventClass
