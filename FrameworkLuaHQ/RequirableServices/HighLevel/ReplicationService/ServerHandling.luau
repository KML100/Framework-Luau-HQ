------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: ServerHandling

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)

local InternalService = FLHQ("InternalService")
local ObjectService = FLHQ("ObjectService")
local ConfigService = FLHQ("ConfigService") ConfigService:Load("ReplicationService")
local NetworkService = FLHQ("NetworkService")
local CollectService = FLHQ("CollectService")

type SelfType = {
	_ReplicationTable :any,
	_ProxyTable :any,
	
	_CollectionInstance :any,
	
	_ChannelRemote :any,

	_AllowedPlayers :any,
}

local ServerHandling = {}

function ServerHandling.New(Channel :string, Table, GuardCallback)

	local self :SelfType = {}
	
	self["<RL>_ReplicationTable"] = Table
	self["<RL>_ProxyTable"] = "__ALLOC__"
	
	self["<RL>_CollectionInstance"] = CollectService(nil)
	
	self["<RL>_ChannelRemote"] = NetworkService(Channel, ConfigService.NETWORK_MAX_YIELD_TIME)

	self["<RL>_AllowedPlayers"] = {}

	return ObjectService(script, self, Channel, GuardCallback)
end

local function ReplicateData(self :SelfType, Path, Index, Value)
	for _, Player in pairs(self._AllowedPlayers) do
		self._ChannelRemote:Send(Player, ConfigService.REQUEST_TYPE_REPLICATION, Path, Index, Value)
	end
end

local function CreateProxyTable(self :SelfType, Path, Data, ProxyTable)
	
	local Internal = {}
	local OwnProxy = ProxyTable or {}
	local NextProxies = {}
	
	for Key, Value in pairs(Data) do
		if not (type(Value) == "table") then continue end
		
		local NewPath = table.clone(Path)
		table.insert(NewPath, Key)
		
		NextProxies[Key] = CreateProxyTable(self, NewPath, Value)
	end

	Internal.__index = function(_, Index)
		
		local NextProxy = NextProxies[Index]
		if NextProxy then return NextProxy end
		
		return Data[Index]
	end

	Internal.__newindex = function(_, Index, Value)
		
		
		-- WORK IN PROGRESSS 
		
		-- when new table added it currently becomes apart of the original table
		-- however, it should be converted to a proxy and a copy should be placed into the original

		
		if not (type(Value) == "table") then Data[Index] = Value return end
		
		local CloneTable = InternalService:DeepCloneTable(Value)
		table.clear(Value)  -- most likely does not work since now only the first table is a proxy and last arent? Not sure check.
		
		local NewPath = table.clone(Path)
		table.insert(NewPath, Index)
		
		NextProxies[Index] = CreateProxyTable(self, NewPath, CloneTable, Value)
	end

	setmetatable(OwnProxy, Internal)

	return OwnProxy
end

ServerHandling["<M>Initialize"] = function(self :SelfType, Channel, GuardCallback)
	
	local HasSnapshot = {}
	local AllowedPlayers = self._AllowedPlayers
	self._CollectionInstance(Players.PlayerRemoving:Connect(function(Player)
		HasSnapshot[Player.UserId] = nil
		AllowedPlayers[Player.UserId] = nil
	end))

	self._CollectionInstance(self._ChannelRemote(function(Player :Player, RequestType)
		if RequestType == ConfigService.REQUEST_TYPE_PERMISSION then
			if AllowedPlayers[Player.UserId] then return end
			
			print(Player)
			local Allowed = GuardCallback(Player)
			if not Allowed then 
				warn("Player Not Allowed In Channel! ", Player.Name, Channel)
				
				self._ChannelRemote:Send(Player, ConfigService.REQUEST_TYPE_PERMISSION, true)
				
				return
			end
			
			AllowedPlayers[Player.UserId] = Player
		
			self._ChannelRemote:Send(Player, ConfigService.REQUEST_TYPE_PERMISSION, true)
		
			return
		end
		
		if RequestType == ConfigService.REQUEST_TYPE_SNAPSHOT then
			if not AllowedPlayers[Player.UserId] then return end
			if HasSnapshot[Player.UserId] then return end
			HasSnapshot[Player.UserId] = Player
			
			self._ChannelRemote:Send(Player, ConfigService.REQUEST_TYPE_SNAPSHOT, self._ReplicationTable)
			
			return
		end
		
		Player:Kick("Are we probing now? Good idea, may I suggest you a ban?")
	end))
	
	self._ProxyTable = CreateProxyTable(self, {}, self._ReplicationTable)
end

ServerHandling["<I>GetProxy"] = function(self :SelfType)
	return self._ProxyTable
end

ServerHandling["<I>Disconnect"] = function(self :SelfType)
	table.clear(self._AllowedPlayers)
	self._CollectionInstance:Destroy()
end

return ServerHandling
