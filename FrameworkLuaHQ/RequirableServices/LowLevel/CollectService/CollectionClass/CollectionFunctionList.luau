------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: CollectionFunctionList
-- List for all types which can be collected and functions paired to the type to collect an object
-- New types can be added when you encounter them, good luck.

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)

local ConfigService = FLHQ("ConfigService") ConfigService:Load("CollectService")

local CollectionFunctionList = {
	
	Instance = function(Object)
		Object:Destroy()
	end,
	
	RBXScriptConnection = function(Object)
		Object:Disconnect() 
	end,
	
	table = function(Object)
		for _, MethodName in pairs(ConfigService.DESTROY_METHOD_NAMES) do
			local Method = Object[MethodName]
			if Method then pcall(Method, Object) end
		end
		
		table.clear(Object)
	end,
	
	thread = function(Object)
		if coroutine.status(Object) == "dead" then return end
		coroutine.close(Object)
	end,
}

return CollectionFunctionList
