------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: ProfileStore

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)

local ProfileClass = require(script.ProfileClass)

local ConfigService = FLHQ("ConfigService") ConfigService:Load("DataService")
local ObjectService = FLHQ("ObjectService")
local DataService = FLHQ("DataService")

type SelfType = {
	_OpenProfiles :{},
	
	_DataFieldInstance :any,
}

local ProfileStore = {}

function ProfileStore.New()

	local self = {}
	
	self["<RL>_OpenProfiles"] = {}
	
	self["<RL>_DataFieldInstance"] = DataService("GameStore"):LoadField(ConfigService.DATA_FIELD_NAME)

	return ObjectService(script, self)
end

ProfileStore["<M>Initialize"] = function(self :SelfType)
	game:BindToClose(function()
		self:CloseAllProfiles()
	end)
end

ProfileStore["<I>OpenProfile"] = function(self :SelfType, Player :Player)
	local OpenProfiles = self._OpenProfiles
	
	local NewProfile = ProfileClass.New(Player)
	
	OpenProfiles[Player.UserId] = NewProfile
	
	return NewProfile
end

ProfileStore["<I>CloseProfile"] = function(self :SelfType, Player :Player)
	local OpenProfiles = self._OpenProfiles
	
	local ProfileInstance = OpenProfiles[Player.UserId]
	if not ProfileInstance then return end
	
	ProfileInstance:Close()
	OpenProfiles[Player.UserId] = nil
end

ProfileStore["<I>CloseAllProfiles"] = function(self :SelfType)
	local OpenProfiles = self._OpenProfiles
	
	for _, ProfileInstance in pairs(OpenProfiles) do
		ProfileInstance:Close()
	end
end

ProfileStore["<I>InspectProfile"] = function(self :SelfType, UserId :string)
	local DataFieldInstance = self._DataFieldInstance
	
	return DataFieldInstance:GetAsyncData(UserId, nil)
end

return ProfileStore
