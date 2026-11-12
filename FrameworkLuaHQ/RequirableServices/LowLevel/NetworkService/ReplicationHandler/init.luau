------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--// NAME: ReplicationHandler

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local ClientEventClass = require(script.ClientEventClass)
local ServerEventClass = require(script.ServerEventClass)

local REMOTE_EVENT_FOLDER_NAME = "RemoteEvents"
local SYNC_REMOTE_EVENT_NAME = "SyncronizationEvent"

local ReplicationHandler = {}

function ReplicationHandler:InitializeServer()
	
	local NameToId = {}
	local EventInstances = {}
	
	local RemoteEventFolder = ReplicatedStorage:FindFirstChild(REMOTE_EVENT_FOLDER_NAME)
	if not RemoteEventFolder then
		RemoteEventFolder = Instance.new("Folder", ReplicatedStorage)
		RemoteEventFolder.Name = REMOTE_EVENT_FOLDER_NAME
	end

	local SyncRemoteEvent :RemoteEvent = RemoteEventFolder:FindFirstChild(SYNC_REMOTE_EVENT_NAME)
	if not SyncRemoteEvent then
		SyncRemoteEvent = Instance.new("RemoteEvent", RemoteEventFolder)
		SyncRemoteEvent.Name = SYNC_REMOTE_EVENT_NAME
	end
	
	local SyncedPlayers = {}
	Players.PlayerRemoving:Connect(function(Player)
		SyncedPlayers[Player] = nil
	end)
	
	SyncRemoteEvent.OnServerEvent:Connect(function(Player :Player)
		
		if SyncedPlayers[Player] then Player:Kick("Tsk, Tsk!") end
		SyncedPlayers[Player] = true
		
		SyncRemoteEvent:FireClient(Player, NameToId)
	end)
	
	return {
		GetEventInstance = function(_, RequestedEventName :string)
			
			local EventInstance = EventInstances[RequestedEventName]
			if EventInstance then return EventInstance end
			
			EventInstance = ServerEventClass.New(RequestedEventName, RemoteEventFolder)
			EventInstances[RequestedEventName] = EventInstance

			local EventId = EventInstance:GetData()
			
			local Payload = {}
			Payload[RequestedEventName] = EventId
			NameToId[RequestedEventName] = EventId
	
			SyncRemoteEvent:FireAllClients(Payload)
			
			return EventInstance
		end
	}
end

local function YieldUntill(Callback)
	
	if Callback() then return end
	repeat
		RunService.Heartbeat:Wait()
		
	until Callback()
end

function ReplicationHandler:InitializeClient()
	
	local Player = Players.LocalPlayer

	local EventInstances = {}

	local RemoteEventFolder = nil
	YieldUntill(function()
		RemoteEventFolder = ReplicatedStorage:FindFirstChild(REMOTE_EVENT_FOLDER_NAME)
		return RemoteEventFolder
	end)

	local SyncRemoteEvent :RemoteEvent = nil
	YieldUntill(function()
		SyncRemoteEvent = RemoteEventFolder:FindFirstChild(SYNC_REMOTE_EVENT_NAME)
		return SyncRemoteEvent
	end)
	
	SyncRemoteEvent.OnClientEvent:Connect(function(RemoteEventNameToId)
		for Name, Id in pairs(RemoteEventNameToId) do
			EventInstances[Name] = ClientEventClass.New(RemoteEventFolder:FindFirstChild(Id))
		end
	end)
	
	SyncRemoteEvent:FireServer()
	
	return {
		GetEventInstance = function(_, RequestedEventName :string, MaxYieldTime :number?)

			local EventInstance = EventInstances[RequestedEventName]
			if EventInstance then return EventInstance end
			
			if not MaxYieldTime then error("No Event Instance Found! "..tostring(RequestedEventName)) end
			
			local YieldedFor = 0
			repeat
				EventInstance = EventInstances[RequestedEventName]
				
				YieldedFor += RunService.Heartbeat:Wait()
				if YieldedFor > MaxYieldTime then error("No Event Instance Found! "..tostring(RequestedEventName)) end
				
			until EventInstance

			return EventInstance
		end,
	}
end

return ReplicationHandler
