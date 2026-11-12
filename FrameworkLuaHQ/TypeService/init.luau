--!strict

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: TypeService
-- AUTHOR: KML100

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ObjectServiceType = require(script.ObjectServiceType)

local SignalServiceType = require(script.SignalServiceType)
local CollectServiceType = require(script.CollectServiceType)
local ScheduleServiceType = require(script.ScheduleServiceType)
local ExecutorServiceType = require(script.ExecutorServiceType)
local AtomServiceType = require(script.AtomServiceType)
local EnumServiceType = require(script.EnumServiceType)

local ECSType = require(script.ECSType)
local InterfaceServiceType = require(script.InterfaceServiceType)
local LinkServiceType = require(script.LinkServiceType)
local NetworkServiceType = require(script.NetworkServiceType)
local DataServiceType = require(script.DataServiceType)

--## FrameworkLuaHQ (FLHQ)

type TypeCallableFLHQ = 
((LibraryName: "ObjectService") -> ObjectServiceType.TypeObjectService)

& ((LibraryName: "AtomService") -> AtomServiceType.TypeAtomService)
& ((LibraryName: "CollectService") -> CollectServiceType.TypeCollectService)
& ((LibraryName: "EnumService") -> EnumServiceType.TypeEnumService)
& ((LibraryName: "ExecutorService") -> ExecutorServiceType.TypeExecutorService) 
& ((LibraryName: "ScheduleService") -> ScheduleServiceType.TypeScheduleService) 
& ((LibraryName: "SignalService") -> SignalServiceType.TypeSignalService) 


& ((LibraryName: "ECS") -> ECSType.TypeECS)
& ((LibraryName: "InterfaceService") -> InterfaceServiceType.TypeInterfaceService)
& ((LibraryName: "LinkService") -> LinkServiceType.TypeLinkService)
& ((LibraryName: "NetworkService") -> NetworkServiceType.TypeNetworkService)
& ((LibraryName: "DataService") -> DataServiceType.TypeDataService)

--[[

]]

export type TypeFLHQ = TypeCallableFLHQ

local TypeService = {}

return TypeService
