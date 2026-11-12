------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: SignalServiceType

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--## ScheduleClass

type TypeScheduleDisconnect = {
	Disconnect: (unknown) -> (),
}

type TypeScheduleClassCall = (Callback :(DeltaTime :number) -> (...any), Priority :number, MustConnect :boolean) -> TypeScheduleDisconnect

type TypeScheduleClassMethods = {}

export type TypeScheduleClass = TypeScheduleClassMethods & TypeScheduleClassCall

--## ScheduleService

type TypeScheduleServiceCall = (ScheduleState :string) -> TypeScheduleClass

type TypeScheduleServiceMethods = {}

export type TypeScheduleService = TypeScheduleServiceMethods & TypeScheduleServiceCall

local FILLER = {} return FILLER