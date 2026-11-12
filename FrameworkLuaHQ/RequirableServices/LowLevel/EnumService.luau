------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: EnumService
-- VERSION: 1.2
-- AUTHOR: KML100

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)

local ConfigService = FLHQ("ConfigService") ConfigService:Load("EnumService")

local function CreateCustomEnum(EnumNameList)
	
	local CustomEnums = {}
	for _, CustomEnum in pairs(EnumNameList) do
		CustomEnums[CustomEnum] = CustomEnum
	end
	
	local Restrictions = {}
	Restrictions.__index = function() ConfigService:Halt(ConfigService.NIL_ENUM) end
	Restrictions.__newindex = function() ConfigService:Halt(ConfigService.NEW_ENUM) end

	setmetatable(CustomEnums, Restrictions)

	return CustomEnums
end

local GlobalDictionary = {}

local function New(_, EnumType :string?, EnumNameList :{[number] :any})
	
	if not EnumType then return CreateCustomEnum(EnumNameList) end
	
	local CustomEnum = GlobalDictionary[EnumType] or {}
	if not (next(CustomEnum) == nil) then return CustomEnum end

	local CustomEnum = CreateCustomEnum(EnumNameList)
	GlobalDictionary[EnumType] = CustomEnum
	
	return CustomEnum
end

local EnumService = setmetatable({}, {__call = New})

function EnumService:Add(EnumType :string | {}, Name :any)
	
	if type(EnumType) == "table" then rawset(EnumType, Name, Name) return end
	
	local CustomEnum = GlobalDictionary[EnumType]	
	if not CustomEnum then return end

	rawset(CustomEnum, Name, Name)
end

function EnumService:Remove(EnumType :string | {}, Name :any)

	if type(EnumType) == "table" then rawset(EnumType, Name, nil) return end
	
	local CustomEnum = GlobalDictionary[EnumType]
	if not CustomEnum then return end

	rawset(CustomEnum, Name, nil)

	if next(CustomEnum) == nil then GlobalDictionary[EnumType] = nil end
end

return EnumService
