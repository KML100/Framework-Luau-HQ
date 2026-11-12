------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: ParallelInterpreter

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local RunService = game:GetService("RunService")

local INITIALIZATION_RETRY_COUNT = 120
local SYSTEM_MODULE_NAME = "SystemModule"

local Connection = nil

local ParallelInterpreter = {}

function ParallelInterpreter.Main(MainContainer)

	local ParallelSystem = nil
	local TryCount = 0
	repeat
		if TryCount > INITIALIZATION_RETRY_COUNT then error("This should not happen, seek help!") end
		RunService.Stepped:Wait()
		TryCount += 1
		
		ParallelSystem = script:FindFirstChild(SYSTEM_MODULE_NAME)
	until ParallelSystem
	
	local RequiredSystem = require(ParallelSystem)
	
	Connection = RunService.Stepped:ConnectParallel(function(_, DeltaTime)
		
		local Memory = MainContainer.Memory
		
		local SystemContainer = {
			AllEntities = Memory.AllEntities or {},
			SharedMemory = Memory.SharedMemory or {},
			OwnEntities = Memory.OwnEntities or {},
		}

		RequiredSystem:Update(SystemContainer, DeltaTime)
	end)
end

function ParallelInterpreter:Disconnect()
	if not Connection then return end
	Connection:Disconnect()
end

return ParallelInterpreter
