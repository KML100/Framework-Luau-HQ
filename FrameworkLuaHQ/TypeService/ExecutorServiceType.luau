------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: SignalServiceType

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--## RuntimeClass

type RuntimeClassCall = () -> ()

type TypeRuntimeClassMethods = {
	SetNewBootModule :(BootModule :ModuleScript, BootMemory :SharedTable) -> (),
	SetNewMemory :(NewMemory :SharedTable) -> (),
	GetMemory: (unknown) -> SharedTable,
	GetModule: (unknown) -> ModuleScript,
	Clear: (unknown) -> (),
	Decommission: (unknown) -> (),
	OnDecommission: (Callback :()->()) -> (),
	Destroy: (unknown) -> ()
}

export type TypeActorManager = TypeRuntimeClassMethods & RuntimeClassCall

--## ExecutorService

type TypeExecutorServiceCall = (BootModule :ModuleScript, BootMemory :SharedTable) -> TypeActorManager

type TypeExecutorServiceMethods = {}

export type TypeExecutorService = TypeExecutorServiceMethods & TypeExecutorServiceCall

local FILLER = {} return FILLER