------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: SignalServiceType

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--## AtomClass

type TypeAtomClassCall<ExistingTable> = () -> ()

type TypeAtomClassMethods<ExistingTable> = {
	
	OnIndex: ((Key :string | number)->()) -> ExistingTable,
	OnNewIndex: ((Key :string | number, Value :any)->()) -> ExistingTable,
	
	GetProxy: (unknown) -> ExistingTable,
	GetAtom: (unknown) -> ExistingTable,
}

export type TypeAtomClass<ExistingTable> = TypeAtomClassMethods<ExistingTable> & TypeAtomClassCall<ExistingTable>

--## AtomService

type TypeAtomServiceCall = <ExistingTable>(ExistingTable :ExistingTable?) -> TypeAtomClass<ExistingTable>

type TypeAtomServiceMethods = {}

export type TypeAtomService = TypeAtomServiceMethods & TypeAtomServiceCall

local FILLER = {} return FILLER