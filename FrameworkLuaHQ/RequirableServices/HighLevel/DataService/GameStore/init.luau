------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: GameStore

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)

local FieldClass = require(script.FieldClass)

local ObjectService = FLHQ("ObjectService")

type SelfType = {
	_CachedFieldInstances :{},
}

local GameStore = {}

function GameStore.New()

	local self = {}
	
	self["<RL>_CachedFieldInstances"] = {}
	
	return ObjectService(script, self)
end

GameStore["<I>LoadField"] = function(self :SelfType, FieldName :string)
	
	local CachedFieldInstances = self._CachedFieldInstances
	local CachedFieldInstance = CachedFieldInstances[FieldName]
	if CachedFieldInstance then return CachedFieldInstance end
	
	local DataStore = DataStoreService:GetDataStore(FieldName)
	local NewFieldInstance = FieldClass.New(DataStore)
	
	CachedFieldInstances[FieldName] = NewFieldInstance
	
	return NewFieldInstance
end

return GameStore
