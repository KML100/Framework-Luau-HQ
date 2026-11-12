------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: SerialSystemScheduler

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicateStorage = game:GetService("ReplicatedStorage")

local FLHQ = require(ReplicateStorage.FrameworkLuaHQ)

local InternalService = FLHQ("InternalService")
local ObjectService = FLHQ("ObjectService")

local ScheduleService = FLHQ("ScheduleService")

type SelfType = {
	
	_ECS :any,
	
	_Systems :{},
	_EffectCache :{},
	
	_UpdateConnection :any,
}

local SerialSystemScheduler = {}

function SerialSystemScheduler.New(ECS)

	local self = {}
	
	self["<RL>_ECS"] = ECS
	
	self["<RL>_Systems"] = {}
	self["<RL>_EffectCaches"] = {}
	
	self["<RL>_UpdateConnection"] = "__ALLOC__"
	
	return ObjectService(script, self)	
end

SerialSystemScheduler["<M>Initialize"] = function(self :SelfType)

	local EntityController = self._ECS.EntityController

	local Systems = self._Systems
	local EffectCaches = self._EffectCaches

	EntityController:OnRemove(function(ArchetypeId, EntityId)
		for _, System in pairs(Systems) do
			if not System.UsedArchetypeIds[ArchetypeId] then continue end
			System.Entities[EntityId] = nil
		end
		
		for _, EffectCache in pairs(EffectCaches) do 
			if not EffectCache.UsedArchetypeIds[ArchetypeId] then continue end
			EffectCache.Entities[EntityId] = nil
		end
	end)

	EntityController:OnAdd(function(ArchetypeId, EntityId, Entity)

		for _, System in pairs(Systems) do
			if not System.UsedArchetypeIds[ArchetypeId] then continue end
			System.Entities[EntityId] = Entity
		end
		
		for _, EffectCache in pairs(EffectCaches) do 
			if not EffectCache.UsedArchetypeIds[ArchetypeId] then continue end
			EffectCache.Entities[EntityId] = Entity
		end
	end)

	EntityController:OnArchetype(function(ArchetypeId)
			
		for _, System in pairs(Systems) do

			local UsedArchetypeIds = System.UsedArchetypeIds
			local Archetypes = EntityController:QueryWith(System.UsedComponents)
			for ArchetypeId, Archetype in pairs(Archetypes) do
				UsedArchetypeIds[ArchetypeId] = true
			end
		end
		
		for _, EffectCache in pairs(EffectCaches) do 

			local UsedArchetypeIds = EffectCache.UsedArchetypeIds
			local Archetypes = EntityController:QueryWith(EffectCache.UsedComponents)
			for ArchetypeId, Archetype in pairs(Archetypes) do
				UsedArchetypeIds[ArchetypeId] = true
			end
		end
	end)
	
	--// Main Update Connection
	self._UpdateConnection = ScheduleService("PrePhysics")(function(_, DeltaTime)
		for _, System in pairs(Systems) do
			System:UpdateFunction(System.SystemContainer, DeltaTime)
		end
	end, 10, true)
end

SerialSystemScheduler["<I>Add"] = function(self :SelfType, SystemModule :ModuleScript, SystemConfig)

	local EntityController = self._ECS.EntityController

	local UsedComponents = SystemConfig.SystemComponents

	local UsedArchetypeIds = {}
	local Entities = {}
	
	local Archetypes = EntityController:QueryWith(UsedComponents)
	for ArchetypeId, Archetype in pairs(Archetypes) do
		UsedArchetypeIds[ArchetypeId] = true

		for EntityId, Entity in pairs(Archetype) do
			Entities[EntityId] = Entity
		end
	end

	local RequiredSystemModule = require(SystemModule)
	
	local SystemContainer = {}
	SystemContainer.AllEntities = Entities
	SystemContainer.OwnEntities = Entities
	SystemContainer.SharedMemory = {}
	
	local System = {
		
		UpdateFunction = RequiredSystemModule.Update,
		SystemContainer = SystemContainer,
		
		Entities = Entities,
		
		UsedArchetypeIds = UsedArchetypeIds,
		UsedComponents = UsedComponents, 
	}
	
	local SystemId = InternalService:NewUUID()
	self._Systems[SystemId] = System
	
	return SystemId
end

SerialSystemScheduler["<I>ApplyEffect"] = function(self :SelfType, Callback, UsedComponents)

	local EntityController = self._ECS.EntityController

	table.sort(UsedComponents)

	local ComponentKey = ""
	for _, ComponentName in ipairs(UsedComponents) do
		ComponentKey = ComponentKey..ComponentName
	end

	local EffectCaches = self._EffectCaches
	local EffectCache = EffectCaches[ComponentKey]
	if EffectCache then Callback(EffectCache.Entities) end

	local Entities = {}
	local UsedArchetypeIds = {}

	local NewEffectCache = {
		Entities = Entities,
		UsedArchetypeIds = UsedArchetypeIds,
		UsedComponents = UsedComponents,
	}

	local Archetypes = EntityController:QueryWith(UsedComponents)
	for ArchetypeId, Archetype in pairs(Archetypes) do
		UsedArchetypeIds[ArchetypeId] = true

		for EntityId, Entity in pairs(Archetype) do
			Entities[EntityId] = Entity
		end
	end

	EffectCaches[ComponentKey] = NewEffectCache

	Callback(Entities)
end

SerialSystemScheduler["<I>Remove"] = function(self :SelfType, SystemId :string)
	self._Systems[SystemId] = nil
end

SerialSystemScheduler["<I>Destroy"] = function(self :SelfType, SystemId :string)
	self._UpdateConnection:Disconnect()
end


return SerialSystemScheduler
