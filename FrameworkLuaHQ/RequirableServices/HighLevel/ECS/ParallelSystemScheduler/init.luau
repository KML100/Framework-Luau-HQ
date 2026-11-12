------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: ParallelSystemScheduler

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicateStorage = game:GetService("ReplicatedStorage")

local FLHQ = require(ReplicateStorage.FrameworkLuaHQ)
local InternalService = FLHQ("InternalService")
local ObjectService = FLHQ("ObjectService")
local ExecutorService = FLHQ("ExecutorService")

local ParallelSystemClass = require(script.ParallelSystemClass)

type SelfType = {
	
	_ECS :any,
	
	_Systems :{},
}

local ParallelSystemScheduler = {}

function ParallelSystemScheduler.New(ECS)
	
	local self = {}
	
	self["<RL>_ECS"] = ECS
	
	self["<RL>_Systems"] = {}
	
	return ObjectService(script, self, ECS)	
end

ParallelSystemScheduler["<M>Initialize"] = function(self :SelfType, ECS)
	
	local EntityController = ECS.EntityController
	
	local Systems = self._Systems
	
	EntityController:OnRemove(function(ArchetypeId, EntityId)
		for _, System in pairs(Systems) do
			if not System:GetUsedArchetypes()[ArchetypeId] then continue end

			System:RemoveEntity(EntityId)
		end
	end)
	
	EntityController:OnAdd(function(ArchetypeId, EntityId, Entity)
		for _, System in pairs(Systems) do
			if not System:GetUsedArchetypes()[ArchetypeId] then continue end
			
			System:AddEntity(EntityId, Entity)
		end
	end)
	
	EntityController:OnArchetype(function(ArchetypeId)
		for _, System in pairs(Systems) do
			System:TryArchetypeIdAdd(ArchetypeId)
		end
	end)
end

ParallelSystemScheduler["<I>Add"] = function(self :SelfType, SystemModule :ModuleScript, SystemConfig)
	
	local SystemId = InternalService:NewUUID()
	self._Systems[SystemId] = ParallelSystemClass.New(self._ECS, SystemModule, SystemConfig)
	
	return SystemId
end

ParallelSystemScheduler["<I>Remove"] = function(self :SelfType, SystemId :string)
	
	local System = self._Systems[SystemId]
	if not System then return end

	System:Destroy()
	
	self._Systems[SystemId] = nil
end

ParallelSystemScheduler["<I>Destroy"] = function(self :SelfType, SystemId :string)
	for _, System in pairs(self._Systems) do
		System:Destroy()
	end
end

return ParallelSystemScheduler
