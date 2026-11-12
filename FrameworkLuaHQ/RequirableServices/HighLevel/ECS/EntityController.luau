------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: EntityController

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicateStorage = game:GetService("ReplicatedStorage")

local FLHQ = require(ReplicateStorage.FrameworkLuaHQ)
local InternalService = FLHQ("InternalService")
local ObjectService = FLHQ("ObjectService")

type SelfType = {
	_ECS :any,
	_Archetypes :{},
	_EntityPathData :{},
	
	_OnAddEvent :{},
	_OnRemoveEvent :{},
	_OnArchetypeEvent: {},
}

local function GetMaxBit32Iterations(ArcheTypeIdBuffer, MatchBufferSize)

	local BufferSize = buffer.len(ArcheTypeIdBuffer)
	local MaxBit32Iterations = BufferSize /4
	if MaxBit32Iterations > MatchBufferSize then MaxBit32Iterations = MatchBufferSize /4 end
	
	return MaxBit32Iterations -1
end

local function GetComparisonBit32(ArcheTypeMatchBuffer, ArcheTypeIdBuffer, Iteration)
	local MatchBit32 = buffer.readu32(ArcheTypeMatchBuffer, Iteration)
	local CheckBit32 = buffer.readu32(ArcheTypeIdBuffer, Iteration)

	return MatchBit32, CheckBit32
end

local function ConstructArchetypeIdBuffer(LargestComponentBitIndex :number, ComponentBitIndexes :{number})

	local IdBufferDeltaSize = LargestComponentBitIndex%32
	local ArchetypeIdBufferSize =(LargestComponentBitIndex + (32 - IdBufferDeltaSize)) /8

	local ArchetypeIdBuffer = buffer.create(ArchetypeIdBufferSize)
	buffer.fill(ArchetypeIdBuffer, 0, 0)

	for _,BitIndex in ipairs(ComponentBitIndexes) do
		buffer.writebits(ArchetypeIdBuffer, BitIndex, 1, 1)
	end

	return ArchetypeIdBuffer
end

local EntityController = {}

function EntityController.New(ECS)
	
	local self = {}

	self["<RL>_ECS"] = ECS

	self["<RL>_Archetypes"] = {}
	self["<RL>_EntityPathData"] = {}
	
	self["<RL>_OnAddEvent"] = {}
	self["<RL>_OnRemoveEvent"] = {}
	self["<RL>_OnArchetypeEvent"] = {}
	
	return ObjectService(script, self)
end


EntityController["<I>OnAdd"] = function(self :SelfType, Callback)
	table.insert(self._OnAddEvent, {Callback = Callback, Async = false})
end

EntityController["<I>OnRemove"] = function(self :SelfType, Callback)
	table.insert(self._OnRemoveEvent, {Callback = Callback, Async = false})
end

EntityController["<I>OnArchetype"] = function(self :SelfType, Callback)
	table.insert(self._OnArchetypeEvent, {Callback = Callback, Async = false})
end

EntityController["<IL>_GetComponentData"] = function(self :SelfType, ComponentNames :{string})
	
	local ComponentStorage = self._ECS.ComponentStorage

	local ComponentBitIndexes = {}
	local LargestComponentBitIndex = 0
	for _,ComponentName in pairs(ComponentNames) do
		
		local _, ComponentBitIndex = ComponentStorage:Use(ComponentName)
		table.insert(ComponentBitIndexes, ComponentBitIndex)

		if ComponentBitIndex < LargestComponentBitIndex then continue end
		LargestComponentBitIndex = ComponentBitIndex
	end
	
	return LargestComponentBitIndex, ComponentBitIndexes
end

EntityController["<IL>_GetOnlyArchetypeWithBuffer"] = function(self :SelfType, ArcheTypeMatchBuffer :buffer)
	local Archetypes = self._Archetypes

	local MatchBufferSize = buffer.len(ArcheTypeMatchBuffer)

	local SelectedArchetype = nil
	for _, Archetype in pairs(Archetypes) do

		local ArcheTypeIdBuffer = Archetype.ArchetypeIdBuffer

		local Selected = true
		for Iteration=0, GetMaxBit32Iterations(ArcheTypeIdBuffer, MatchBufferSize) do

			local MatchBit32, CheckBit32 = GetComparisonBit32(ArcheTypeMatchBuffer, ArcheTypeIdBuffer, Iteration)
			if bit32.bxor(MatchBit32, CheckBit32) == 0 then continue end --// If all bits same then

			Selected = false

			break
		end

		if Selected then SelectedArchetype = Archetype break end
	end

	return SelectedArchetype
end

EntityController["<I>Add"] = function(self :SelfType, ComponentNames :{string})
	
	local ComponentStorage = self._ECS.ComponentStorage

	local NewEntity = SharedTable.new()
	for _,ComponentName in pairs(ComponentNames) do
		local ComponentValue = ComponentStorage:Use(ComponentName)
		
		NewEntity[ComponentName] = ComponentValue
	end
	
	local ArchetypeIdBuffer = ConstructArchetypeIdBuffer(self:_GetComponentData(ComponentNames))
	local Archetype = self:_GetOnlyArchetypeWithBuffer(ArchetypeIdBuffer)	
	if not Archetype then 
		
		local ArchetypeId = InternalService:NewUUID()
		
		Archetype = {
			ArchetypeIdBuffer = ArchetypeIdBuffer,
			ArchetypeId = ArchetypeId,
			Entities = {},
		}
	
		self._Archetypes[ArchetypeId] = Archetype

		InternalService:FireCallbacks(self._OnArchetypeEvent, ArchetypeId)
	end
	
	local ArchetypeEntities = Archetype.Entities
	local EntityIndex = #ArchetypeEntities +1
	
	local EntityId = InternalService:NewUUID()
	ArchetypeEntities[EntityIndex] = NewEntity
	
	self._EntityPathData[EntityId] = { 
		ArchetypeId = Archetype.ArchetypeId,
		EntityIndex = EntityIndex,
	}

	InternalService:FireCallbacks(self._OnAddEvent, Archetype.ArchetypeId, EntityId, NewEntity)

	return EntityId
end

EntityController["<I>Remove"] = function(self :SelfType, EntityId :string)
	
	local PathData = self._EntityPathData
	local EntityPathData = PathData[EntityId] 
	
	local EntityArchetype = self._Archetypes[EntityPathData.ArchetypeId]
	local ArchetypeEntities = EntityArchetype.Entities
	local EntityIndex = EntityPathData.EntityIndex
	
	local EntityArchetypeCount = #ArchetypeEntities
	local ArchetypeLastEntity = ArchetypeEntities[EntityArchetypeCount]
	
	InternalService:FireCallbacks(self._OnRemoveEvent, EntityPathData.ArchetypeId, EntityId)
	
	ArchetypeEntities[EntityIndex] = ArchetypeLastEntity
	ArchetypeEntities[EntityArchetypeCount] = nil
	PathData[EntityId] = nil
end

EntityController["<IL>_GetAllArchetypeEntiesWithBuffer"] = function(self :SelfType, ArcheTypeMatchBuffer :buffer)
	local Archetypes = self._Archetypes

	local MatchBufferSize = buffer.len(ArcheTypeMatchBuffer)

	local MatchedArcheTypes = {}
	for ArchetypeId, Archetype in pairs(Archetypes) do

		local ArcheTypeIdBuffer = Archetype.ArchetypeIdBuffer
		for Iteration=0, GetMaxBit32Iterations(ArcheTypeIdBuffer, MatchBufferSize) do

			local MatchBit32, CheckBit32 = GetComparisonBit32(ArcheTypeMatchBuffer, ArcheTypeIdBuffer, Iteration)
			if bit32.bor(MatchBit32, CheckBit32) == 0 then continue end --// If not any bits same

			MatchedArcheTypes[ArchetypeId] = Archetype.Entities 

			break
		end
	end

	return MatchedArcheTypes
end

EntityController["<I>QueryWith"] = function(self :SelfType, ComponentNames :{string})
	
	local ArchetypeIdBuffer = ConstructArchetypeIdBuffer(self:_GetComponentData(ComponentNames))

	local Archetypes = self:_GetAllArchetypeEntiesWithBuffer(ArchetypeIdBuffer)	

	return Archetypes
end

return EntityController
