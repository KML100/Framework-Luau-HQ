------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: DataService
-- VERSION: 1.0
-- AUTHOR: KML100

--// No Ordered DataStore Abstraction Implemented. No need for one yet.

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local CachedInstances = {}

local function New(_, UsageType :string)
	
	local CachedInstance = CachedInstances[UsageType]
	if CachedInstance then return CachedInstance end
	
	local Module = script:FindFirstChild(UsageType)
	local RequiredModule = require(Module)
	local NewInstance = RequiredModule.New()
	
	CachedInstances[UsageType] = NewInstance
	
	return NewInstance
end

local DataService = setmetatable({}, {__call = New})

return DataService
