------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: SignalServiceType

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--## CollectionClass

type TypeCollectionClassCall = (Object :Instance | RBXScriptConnection | any) -> TypeCollectionClass

type TypeCollectionClassMethods = {	
	Destroy :(unknown) -> (),
}

export type TypeCollectionClass = TypeCollectionClassMethods & TypeCollectionClassCall

--## CollectService

type TypeCollectServiceCall = (GroupId :string) -> TypeCollectionClass

type TypeCollectServiceMethods = {
	Destroy :(unknown) -> (),
}

export type TypeCollectService = TypeCollectServiceMethods & TypeCollectServiceCall

local FILLER = {} return FILLER