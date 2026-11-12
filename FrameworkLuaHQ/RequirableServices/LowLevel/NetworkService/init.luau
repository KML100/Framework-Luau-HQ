------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: NetworkService
-- VERSION: 1.5
-- AUTHOR: KML100

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)

local InternalService = FLHQ("InternalService")

local IsServer = RunService:IsServer()

local ReplicationHandler = require(script.ReplicationHandler)

local EventReplicationInstance = nil

local function New(_, RequestedEventName :string, MaxYieldTime :number?)
	
	if not EventReplicationInstance then EventReplicationInstance = (IsServer and ReplicationHandler:InitializeServer()) or ReplicationHandler:InitializeClient() end
	if not EventReplicationInstance then error("Network Service could not Initialized Properly! Check that both server and client have proficient endpoints!") end
	
	return EventReplicationInstance:GetEventInstance(RequestedEventName, MaxYieldTime)
end

local NetworkService = setmetatable({}, {__call = New})

return NetworkService