------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: SignalServiceType

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--## EventClass

type TypeEventClassCall = (Callback :(...any) -> (...any)) -> TypeEventClass

type TypeEventClassMethods = {
	Send: (...any) -> (),
	Disconnect: (unknown) -> (),
}

export type TypeEventClass = TypeEventClassMethods & TypeEventClassCall

--## NetworkService

type TypeNetworkServiceCall = (EventName :string) -> TypeEventClass

type TypeNetworkServiceMethods = {}

export type TypeNetworkService = TypeNetworkServiceMethods & TypeNetworkServiceCall

local FILLER = {} return FILLER