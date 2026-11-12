------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: CollectionClass

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)

local ConfigService = FLHQ("ConfigService") ConfigService:Load("CollectService")
local ObjectService = FLHQ("ObjectService")

local CollectionFunctionList = require(script.CollectionFunctionList)

type SelfType = {
	_CollectionDatas :{},
}

local CollectionClass = {}

function CollectionClass.New()

	local self :SelfType = {}
	
	self["<RL>_CollectionDatas"] = {}

	return FLHQ("ObjectService")(script, self)
end

CollectionClass["<M>Call"] = function(self :SelfType, Object :any)

	if not Object then ConfigService:Halt(ConfigService.COLLECTION_NIL) end

	local ObjectType = typeof(Object)
	local CollectionFunction = CollectionFunctionList[ObjectType]

	if not CollectionFunction then ConfigService:Halt(ConfigService.COLLECTION_FUNCTION_NIL, ObjectType) end

	table.insert(self._CollectionDatas, {Object = Object, CollectionFunction = CollectionFunction})

	return self
end

CollectionClass["<I>Destroy"] = function(self :SelfType)
	for _, CollectionData in pairs(self._CollectionDatas) do
		if not CollectionData.CollectionFunction then continue end

		CollectionData.CollectionFunction(CollectionData.Object)
	end

	table.clear(self._CollectionDatas)
end

return CollectionClass
