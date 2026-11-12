------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--// NAME: ParallelSystemClass

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)

local InternalService = FLHQ("InternalService")
local ObjectService = FLHQ("ObjectService")
local ExecutorService = FLHQ("ExecutorService")

local ParallelInterpreterPath = script.ParallelInterpreter

local SYSTEM_MODULE_NAME = "SystemModule"

type SelfType = {
	
	_ECS :any,
	
	_SystemModule :ModuleScript,
	_SystemBatchSize :number,	
	_SystemComponents :{},
	
	_SystemAllEntities :SharedTable,
	_SystemSharedMemory :SharedTable,
	
	_UsedArchetypeIds :{},
	
	_EntityIdToActorData :{},
	
	_SystemActors :{},
	_PartialSystemActors :{},
}

local ParallelSystemClass = {}

function ParallelSystemClass.New(ECS, SystemModule, SystemConfig)
	
	local self :SelfType = {}
	
	self["<RL>_ECS"] = ECS
	
	self["<RL>_SystemModule"] = SystemModule
	self["<RL>_SystemBatchSize"] = SystemConfig.ParallelBatchSize
	self["<RL>_SystemComponents"] = SystemConfig.SystemComponents
	
	self["<RL>_SystemAllEntities"] = SharedTable.new()
	self["<RL>_SystemSharedMemory"] = SharedTable.new()
	
	self["<RL>_UsedArchetypeIds"] = {}
	
	self["<RL>_EntityIdToActorData"] = {}
	
	self["<RL>_SystemActors"] = {}
	self["<RL>_PartialSystemActors"] = {}
	
	return ObjectService(script, self)
end

ParallelSystemClass["<M>Initialize"] = function(self :SelfType)
	
	local EntityController = self._ECS.EntityController
	local UsedArchetypeIds = self._UsedArchetypeIds
	
	local Archetypes = EntityController:QueryWith(self._SystemComponents)
	for ArchetypeId, Archetype in pairs(Archetypes) do
		UsedArchetypeIds[ArchetypeId] = true
		
		for EntityId, Entity in pairs(Archetype) do
			self:AddEntity(EntityId, Entity)
		end
	end
end

ParallelSystemClass["<I>TryArchetypeIdAdd"] = function(self :SelfType, ArchetypeId :string)

	local EntityController = self._ECS.EntityController
	local UsedArchetypeIds = self._UsedArchetypeIds
	
	local Archetypes = EntityController:QueryWith(self._SystemComponents)
	for ArchetypeId, Archetype in pairs(Archetypes) do
		UsedArchetypeIds[ArchetypeId] = true
	end
end


ParallelSystemClass["<IL>_CreateActor"] = function(self :SelfType)

	local SystemAllEntities = self._SystemAllEntities
	local PartialSystemActors = self._PartialSystemActors 
	local SystemSharedMemory = self._SystemSharedMemory
	local SystemActors = self._SystemActors
	local SystemModule = self._SystemModule

	local Entities = SharedTable.new()
	local Memory = SharedTable.new()
	Memory.AllEntities = SystemAllEntities
	Memory.OwnEntities = Entities
	Memory.SharedMemory = SystemSharedMemory
	
	local NewActorInstance = ExecutorService(ParallelInterpreterPath, Memory)

	local NewSystemModule = SystemModule:Clone()
	NewSystemModule.Name = SYSTEM_MODULE_NAME
	NewSystemModule.Parent = NewActorInstance:GetModule()

	local PartialIndex = InternalService:NewUUID()
	local Index = InternalService:NewUUID()

	local NewActor = {
		Index = Index,
		PartialIndex = PartialIndex,
		
		ActorInstance = NewActorInstance,
		
		Memory = Memory,
		
		Entities = Entities,
		EntityCount = 0,
	}
	
	SystemActors[Index] = NewActor
	PartialSystemActors[PartialIndex] = NewActor
	
	return NewActor
end

ParallelSystemClass["<I>AddEntity"] = function(self :SelfType, EntityId :string, Entity :SharedTable)
	
	local SystemAllEntities = self._SystemAllEntities
	local PartialSystemActors = self._PartialSystemActors 
	local EntityIdToActorData = self._EntityIdToActorData
	local SystemBatchSize = self._SystemBatchSize

	SystemAllEntities[EntityId] = Entity

	local _, PartialActor = next(PartialSystemActors)
	if not PartialActor then PartialActor = self:_CreateActor() end

	EntityIdToActorData[EntityId] = PartialActor
	
	PartialActor.EntityCount += 1
	PartialActor.Entities[EntityId] = Entity

	if PartialActor.EntityCount < SystemBatchSize then return end
	
	PartialSystemActors[PartialActor.PartialIndex] = nil
	PartialActor.PartialIndex = nil

	return
end

ParallelSystemClass["<I>RemoveEntity"] = function(self :SelfType, EntityId :string)
	
	local SystemAllEntities = self._SystemAllEntities
	local PartialSystemActors = self._PartialSystemActors 
	local EntityIdToActorData = self._EntityIdToActorData
	local SystemActors = self._SystemActors

	local EntityActor = EntityIdToActorData[EntityId]
	EntityActor.EntityCount -= 1
	EntityActor.Entities[EntityId] = nil
	
	SystemAllEntities[EntityId] = nil
	
	if EntityActor.EntityCount > 0 then return end
	SystemActors[EntityActor.Index] = nil

	local PartialIndex = EntityActor.PartialIndex
	if PartialIndex then PartialSystemActors[PartialIndex] = nil end
	
	local ActorInstance = EntityActor.ActorInstance
	ActorInstance:TryCall(false, "Disconnect")
	ActorInstance:Decommission()
end


ParallelSystemClass["<I>GetUsedArchetypes"] = function(self :SelfType)
	return self._UsedArchetypeIds
end

ParallelSystemClass["<I>Destroy"] = function(self :SelfType)
	
	for _, ActorData in pairs(self._SystemActors) do

		local ActorInstance = ActorData.ActorInstance
		ActorInstance:TryCall(false, "Disconnect")
		ActorInstance:Decommission()
	end
end

return ParallelSystemClass
