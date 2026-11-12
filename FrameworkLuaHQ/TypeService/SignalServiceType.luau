------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: SignalServiceType

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--## SignalClass

type TypeSignalClassConnection = {
	SetLimit :(FireLimit :number) -> (TypeSignalClassConnection),
	Disconnect: (unknown) -> (),
}

type TypeSignalClassCall = (Callback :(...any) -> (...any)) -> TypeSignalClassConnection

type TypeSignalClassMethods = {	
	Fire: (...any) -> (),
	Yield: (unknown) -> (),
	DisconnectAll: (unknown) -> (),
}

export type TypeSignalClass = TypeSignalClassMethods & TypeSignalClassCall

--## SignalSerivce

type TypeSignalServiceCall = (SignalName: string) -> TypeSignalClass

type TypeSignalServiceMethods = {}

export type TypeSignalService = TypeSignalServiceMethods & TypeSignalServiceCall

local FILLER = {} return FILLER