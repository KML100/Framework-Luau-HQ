------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: ScheduleService
-- VERSION: 2.1
-- AUTHOR: KML100

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)

local ConfigService = FLHQ("ConfigService") ConfigService:Load("ScheduleService")

local ScheduleClass = require(script.ScheduleClass)

local Schedulers = {}

local function New(_, ScheduleState :string)
	
	local TranslatedState = ConfigService.STATE_TRANSLATION[ScheduleState]
	if not TranslatedState then ConfigService:Halt(ConfigService.STATE_NIL, ScheduleState) end

	local Scheduler = Schedulers[TranslatedState]
	if Scheduler then return Scheduler end
	
	Scheduler = ScheduleClass.New(TranslatedState) 
	Schedulers[TranslatedState] = Scheduler
	
	return Scheduler
end

local ScheduleService = setmetatable({}, {__call = New})

return ScheduleService

