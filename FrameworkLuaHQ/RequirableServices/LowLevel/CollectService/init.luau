------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: CollectService
-- VERSION: 1.3
-- AUTHOR: KML100

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)

local InternalService = FLHQ("InternalService")

local CollectionClass = require(script.CollectionClass)

local CollectionGroups = {}

local function New(_, GroupId)
	if not GroupId then
		local PrivateGroup = CollectionClass.New()
		CollectionGroups[InternalService:NewUUID()] = PrivateGroup
		
		return PrivateGroup
	end
	
	local CollectionGroup = CollectionGroups[GroupId]
	if CollectionGroup then return CollectionGroup end
	
	local NewCollectionGroup = CollectionClass.New()
	CollectionGroups[GroupId] = NewCollectionGroup
	
	return NewCollectionGroup
end

local CollectService = setmetatable({}, {__call = New})

function CollectService:Destroy()
	for _, CollectionGroup in pairs(CollectionGroups) do
		CollectionGroup:Destroy()
	end
	
	table.clear(CollectionGroups)
end

return CollectService
