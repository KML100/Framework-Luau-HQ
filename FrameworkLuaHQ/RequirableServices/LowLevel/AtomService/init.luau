------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--// NAME: AtomService
-- VERSION: 1.3
-- AUTHOR: KML100

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)

local ConfigService = FLHQ("ConfigService") ConfigService:Load("AtomService")

local AtomClass = require(script.AtomClass)

type SelfType = {
}

local function New(_, ExistingTable)

	if getmetatable(ExistingTable) then print(ExistingTable, getmetatable(ExistingTable)) ConfigService:Halt(ConfigService.EXISTING_METATABLE) end
	
	return AtomClass.New(ExistingTable)
end

local AtomService = setmetatable({}, {__call = New})

return AtomService
