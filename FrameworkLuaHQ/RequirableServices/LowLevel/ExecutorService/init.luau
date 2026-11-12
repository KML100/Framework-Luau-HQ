------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: ExecutorService
-- VERSION: 2.0
-- AUTHOR: KML100

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local RuntimeClass = require(script.RuntimeClass)

local RuntimeInstancePool = {}

local function New(_, BootModule, BootMemory)
	
	local RuntimeInstanceCount = #RuntimeInstancePool
	if RuntimeInstanceCount > 0 then
		local RuntimeInstance = RuntimeInstancePool[RuntimeInstanceCount]
		
		table.remove(RuntimeInstancePool, RuntimeInstanceCount)

		RuntimeInstance:SetNewBootModule(BootModule, BootMemory)
		
		return RuntimeInstance
	end

	local RuntimeInstance = RuntimeClass.New(BootModule, BootMemory)
	
	RuntimeInstance:OnDecommission(function()
		table.insert(RuntimeInstancePool, RuntimeInstance)
	end)
	
	return RuntimeInstance
end

local ExecutorService = setmetatable({}, {__call = New})

return ExecutorService
