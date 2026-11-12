------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: ProfileClass

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)

local InternalService = FLHQ("InternalService")
local ConfigService = FLHQ("ConfigService") ConfigService:Load("DataService")
local ObjectService = FLHQ("ObjectService")
local SignalService = FLHQ("SignalService")
local DataService = FLHQ("DataService")

local ACTIVE_PROFILE_TIMEFRAME = 60
local TIMEFRAME_SAVE_STAGGER = 0.1

type SelfType = {
	_DataFieldInstance :any,
	
	_Player :Player,
	_PlayerData :any,
	
	_LoadSignal :any,

	_ProfileClosed :boolean,
	_ProfileOpen :boolean,
	_NewProfile :boolean,	
}

local ProfileClass = {}

function ProfileClass.New(Player)

	local self = {}

	self["<RL>_DataFieldInstance"] = DataService("GameStore"):LoadField(ConfigService.DATA_FIELD_NAME)
	
	self["<RL>_Player"] = Player	
	self["<L>_PlayerData"] = "__ALLOC__"

	self["<RL>_LoadSignal"] = SignalService(nil)

	self["<L>_ProfileClosed"] = false
	self["<L>_ProfileOpen"] = false
	self["<L>_NewProfile"] = false

	return ObjectService(script, self)
end

local function UpdatePlayerData(self :SelfType, HasOpenProfile)
	self._DataFieldInstance:GetSetAtomicData(self._Player.UserId, function(_,_)
		
		print(self._PlayerData) -- debug
		
		return self._PlayerData, {HasOpenProfile = HasOpenProfile, LastSeen = os.time()}
	end)
end

ProfileClass["<M>Initialize"] = function(self :SelfType)
	
	local DataFieldInstance = self._DataFieldInstance
	local Player = self._Player

	DataFieldInstance:GetSetAtomicData(Player.UserId, function(SavedPlayerData, ActivityData)
		
		if not ActivityData then ActivityData = {HasOpenProfile = false, LastSeen = 0} end
		if not SavedPlayerData then self._NewProfile = true end
		
		local HasOpenProfile = ActivityData.HasOpenProfile
		local LastSeen = ActivityData.LastSeen
		
		local IsInActiveWindow = (os.time() - LastSeen) < ACTIVE_PROFILE_TIMEFRAME
		if HasOpenProfile and IsInActiveWindow then Player:Kick(ConfigService.KICK_MESSAGE_ACTIVE_PROFILE) return true, LastSeen end

		print("Loaded Player Data: ", SavedPlayerData)  -- debug

		ActivityData.LastSeen = os.clock()
		ActivityData.HasOpenProfile = true
		
		self._PlayerData = SavedPlayerData
		self._ProfileOpen = true
		
		self._LoadSignal:Fire()
	
		return SavedPlayerData, ActivityData
	end, function()
		self._LoadSignal:Fire()
	end)
	
	InternalService:TaskPooledThread(function()

		if not self._ProfileOpen then self._LoadSignal:SpinYield() end
		if not self._NewProfile and not self._PlayerData then Player:Kick(ConfigService.KICK_MESSAGE_DATA_LOAD_FAILED) return end
	
		while task.wait(ACTIVE_PROFILE_TIMEFRAME - ACTIVE_PROFILE_TIMEFRAME * TIMEFRAME_SAVE_STAGGER) do
			if self._ProfileClosing then return end

			UpdatePlayerData(self, true)
		end
	end)
end

ProfileClass["<I>IfNewThen"] = function(self :SelfType, Callback)

	if not self._ProfileOpen then self._LoadSignal:SpinYield() end
	if not self._NewProfile then return end
	
	return Callback()
end

ProfileClass["<I>GetData"] = function(self :SelfType)
	if not self._ProfileOpen then self._LoadSignal:SpinYield() end
	return self._PlayerData
end

ProfileClass["<I>SetData"] = function(self :SelfType, NewData)
	if not self._ProfileOpen then self._LoadSignal:SpinYield() end
	self._PlayerData = NewData
end

ProfileClass["<I>Close"] = function(self :SelfType)
	if self._ProfileClosed then return end
	self._ProfileClosed = true
	
	if not self._ProfileOpen then self._LoadSignal:SpinYield() end
	
	UpdatePlayerData(self, false)
end

return ProfileClass
