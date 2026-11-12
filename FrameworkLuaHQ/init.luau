------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--// NAME: FrameworkLuaHQ (FLHQ)
-- VERSION: 2.0
-- AUTHOR: KML100

--[[ 

--// NOTE //--

Core Services: No outside dependencies
Low Level Services: Only Core Service Usage
High Level Services: All Services Expect High Level Services Are Allowed

--]]
 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local TypeService = require(script.TypeService)

local RequirableServices = script.RequirableServices

local RequiredLibraries = {}

local function Get(_, LibraryName :string)

	local Library = RequiredLibraries[LibraryName]
	if Library then return Library end
	
	local LibraryModule = RequirableServices.Core:FindFirstChild(LibraryName)
		or RequirableServices.LowLevel:FindFirstChild(LibraryName)
		or RequirableServices.HighLevel:FindFirstChild(LibraryName)
	
	if not LibraryModule then error("No Library Found In FLHQ! "..tostring(LibraryName)) end
	
	Library = require(LibraryModule)
	RequiredLibraries[LibraryName] = Library
	
	return Library
end

local FrameworkLuaHQ = setmetatable({}, {__call = Get}) ::TypeService.TypeFLHQ

return FrameworkLuaHQ