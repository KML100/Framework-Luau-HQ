------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: ClientHandling

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)

local Player = Players.LocalPlayer

local ObjectService = FLHQ("ObjectService")
local ConfigService = FLHQ("ConfigService") ConfigService:Load("ReplicationService")
local NetworkService = FLHQ("NetworkService")
local AtomService = FLHQ("AtomService")
local CollectService = FLHQ("CollectService")

type SelfType = {
	
	_Data :any,
	
	_ChannelRemote :any,
	
	_CollectionInstance :any,
	
	_CanReplicate :boolean,
	_Disconnected :boolean,
}

local function RepeatUntill(BooleanCallback, CountCallback)
	if BooleanCallback() then return true end
	
	local Count = 0
	repeat
		if CountCallback(Count) then return false end
		RunService.Stepped:Wait()
		Count += 1
		
	until BooleanCallback()
	
	return true
end

local ReguestHandling = {
	[ConfigService.REQUEST_TYPE_PERMISSION] = function(self :SelfType, CanReplicate, ...)
		if not CanReplicate then self:Disconnect() return end
		
		print(self, CanReplicate, ...)
		print("CAN REPLICATE")
		
		self._CanReplicate = true
	end,
	
	[ConfigService.REQUEST_TYPE_SNAPSHOT] = function(self :SelfType, Data, ...)
		if self._Data then return end
		
		print(self, Data, ...)
		print("GOT DATA: ", Data)
		
		-- wrap here
		
		self._Data = Data
	end,
	
	[ConfigService.REQUEST_TYPE_REPLICATION] = function(self :SelfType, Path, Index, Value)
		
		if not RepeatUntill(function()
				if self._Data then return true end
			end, function()
				if self._Disconnected then return true end
			end) 
		then return end

		print(Path, Index, Value)

	end,	
}

local ClientHandling = {}

function ClientHandling.New(Channel :string)

	local self :SelfType = {}
	
	self["<RL>_Data"] = "__ALLOC__"
	
	self["<RL>_ChannelRemote"] = NetworkService(Channel, ConfigService.NETWORK_MAX_YIELD_TIME)
	
	self["<RL>_CollectionInstance"] = CollectService(nil)
	
	self["<L>_CanReplicate"] = false
	self["<L>_Disconnected"] = false
	
	return ObjectService(script, self)
end

ClientHandling["<M>Initialize"] = function(self :SelfType)
	
	self._CollectionInstance(self._ChannelRemote(function(RequestType, ...)
		local HandlingFunction = ReguestHandling[RequestType]
		if not HandlingFunction then return end
		
		HandlingFunction(self, ...)
	end))
	
	if not RepeatUntill(function() if self._CanReplicate then return true end end, 
		function(Count)
			if self._Disconnected then return true end
			if Count >= ConfigService.HANDSHAKE_MAX_YIELD_TIME then Player:Kick(ConfigService.HANDSHAKE_TIMEOUT_KICK_MSG) return true end
			if not (Count%ConfigService.HANDSHAKE_INTERVALTS == 0) then return false end
		
			self._ChannelRemote:Send(ConfigService.REQUEST_TYPE_PERMISSION)
		end) 
	then return end
	
	if not RepeatUntill(function() if self._Data then return true end end, 
		function(Count)
			if self._Disconnected then return true end
			if Count >= ConfigService.HANDSHAKE_MAX_YIELD_TIME then Player:Kick(ConfigService.HANDSHAKE_TIMEOUT_KICK_MSG) return true end
			if not (Count%ConfigService.HANDSHAKE_INTERVALTS == 0) then return false end

			self._ChannelRemote:Send(ConfigService.REQUEST_TYPE_SNAPSHOT)
		end) 
	then return end
	
	print("Initialized")
	print(self._Data)
end

ClientHandling["<I>Observe"] = function(self :SelfType, Path, Index, Callback)
	
end

ClientHandling["<I>GetData"] = function(self :SelfType)
	
	if not RepeatUntill(function()
			if self._Data then return true end
		end, function()
			if self._Disconnected then return true end
		end) 
	then return {} end
	print(self._Data)
	
	return self._Data
end

ClientHandling["<I>Disconnect"] = function(self :SelfType)
	if self._Disconnected then return end
	self._Disconnected = true
	
	self._CollectionInstance:Destroy()
end

return ClientHandling
