------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--// NAME: SignalService
-- VERSION: 1.5
-- AUTHOR: KML100

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local SignalClass = require(script.SignalClass)

type SelfType = {
}

local Signals = {}

local function New(_, SignalName)
	if not SignalName then return SignalClass.New() end
	
	local Signal = Signals[SignalName]
	if Signal then return Signal end

	Signal = SignalClass.New()
	Signals[SignalName] = Signal

	return Signal
end

local SignalService = setmetatable({}, {__call = New})

return SignalService
