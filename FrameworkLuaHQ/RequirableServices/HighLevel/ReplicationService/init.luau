------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: ReplicationService

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- start up handshake to initialize and confirm remotes are connected
-- client sends request to access channel / start replication
-- server validates request
-- replicationn start from server (based old ServerDataSystem and LocalDataSystem)
-- Client can start observing any path + index combat at anytime even before these indexes are replicated by just caching the path + index untill replication

local ClientHandling = require(script.ClientHandling)
local ServerHandling = require(script.ServerHandling)

local ReplicationService = {}

local CurrentlyReplicating = {}
function ReplicationService:StartReplication(Channel :string, Table, GuardCallback :(Player :Player) -> (boolean))
	if CurrentlyReplicating[Channel] then error("Tried To Replicate On One Channel Twice! ", Channel) end
	
	return ServerHandling.New(Channel, Table, GuardCallback)
end

local CachedChannels = {}
function ReplicationService:RequstReplication(Channel :string)
	
	local CachedChannel = CachedChannels[Channel]
	if CachedChannel then return CachedChannel end
	
	return ClientHandling.New(Channel)
end

return ReplicationService
