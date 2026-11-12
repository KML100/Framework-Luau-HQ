------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: ComponentStorage

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicateStorage = game:GetService("ReplicatedStorage")

local FLHQ = require(ReplicateStorage.FrameworkLuaHQ)
local ObjectService = FLHQ("ObjectService")

type SelfType = {
	_ActiveComponents :{},
	_RemovedQueuedComponents :{},
	
	_FreeComponentBitIndexes :{},
	_NextFreeComponentBitIndex :number,
}

local ComponentStorage = {}

function ComponentStorage.New(ECS)
	
	local self = {}

	self["<RL>_ActiveComponents"] = {}
	self["<RL>_RemovedQueuedComponents"] = {}
	
	self["<RL>_FreeComponentBitIndexes"] = {}
	self["<L>_NextFreeComponentBitIndex"] = 0

	return ObjectService(script, self, ECS)	
end

ComponentStorage["<M>Initialize"] = function(self :SelfType, ECS)
	
	local ActiveComponents =  self._ActiveComponents
	local RemovedQueuedComponents =  self._RemovedQueuedComponents
	
	ECS.EntityController:OnRemove(function()
		for ComponentName, _ in pairs(RemovedQueuedComponents) do
			
			if ActiveComponents[ComponentName].AmountInUse > 0 then continue end
			ActiveComponents[ComponentName] = nil
			RemovedQueuedComponents[ComponentName] = nil
		end
	end)
end

ComponentStorage["<I>Add"] = function(self :SelfType, ComponentName :string, ComponentValue :any)

	local FreeComponentBitIndexes = self._FreeComponentBitIndexes
	local NextFreeComponentBitIndex = self._NextFreeComponentBitIndex
	
	local ComponentBitIndex = FreeComponentBitIndexes[#FreeComponentBitIndexes] or NextFreeComponentBitIndex
	if ComponentBitIndex == NextFreeComponentBitIndex then self._NextFreeComponentBitIndex += 1 end
	
	local NewActiveComponent = {
		ComponentValue = ComponentValue,
		ComponentBitIndex = ComponentBitIndex,
		AmountInUse = 0,
	}
	
	self._ActiveComponents[ComponentName] = NewActiveComponent
end

ComponentStorage["<I>Remove"] = function(self :SelfType, ComponentName :string)
	if not self._ActiveComponents[ComponentName] then return end
	self._RemovedQueuedComponents[ComponentName] = true
end

ComponentStorage["<I>Use"] = function(self :SelfType, ComponentName :string)
	
	local Component = self._ActiveComponents[ComponentName]
	Component.AmountInUse += 1
	
	return Component.ComponentValue, Component.ComponentBitIndex
end

ComponentStorage["<I>UnUse"] = function(self :SelfType, ComponentName :string)

	local Component = self._ActiveComponents[ComponentName]
	Component.AmountInUse -= 1
end

return ComponentStorage
