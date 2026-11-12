------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: ECS
-- VERSION: 3.0
-- AUTHOR: KML100

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)

local EntityController = require(script.EntityController)
local ComponentStorage = require(script.ComponentStorage)
local SerialSystemScheduler = require(script.SerialSystemScheduler)
local ParallelSystemScheduler = require(script.ParallelSystemScheduler)

type SelfType = {	
	EntityController :any,
	ComponentStorage :any,
	SerialSystemScheduler :any,
	ParallelSystemScheduler :any,
}

local ECS = {}

function ECS.World() :(SelfType)

	local self :SelfType = {}
	
	self["<R>EntityController"] = "__ALLOC__"
	self["<R>ComponentStorage"] = "__ALLOC__"
	self["<R>SerialSystemScheduler"] = "__ALLOC__"
	self["<R>ParallelSystemScheduler"] = "__ALLOC__"
	
	return FLHQ("ObjectService")(script, self)
end

ECS["<M>Initialize"] = function(self :SelfType)
	
	self.EntityController =  EntityController.New(self)
	self.ComponentStorage = ComponentStorage.New(self)
	self.SerialSystemScheduler = SerialSystemScheduler.New(self)
	self.ParallelSystemScheduler = ParallelSystemScheduler.New(self)
end

ECS["<I>AddEntity"] = function(self :SelfType, EntityComponents :{string})
	return self.EntityController:Add(EntityComponents)
end

ECS["<I>RemoveEntity"] = function(self :SelfType, EntityId :string)
	return self.EntityController:Remove(EntityId)
end

ECS["<I>AddComponent"] = function(self :SelfType, ComponentName :string, ComponentValue :any)
	return self.ComponentStorage:Add(ComponentName, ComponentValue)
end

ECS["<I>RemoveComponent"] = function(self :SelfType, ComponentName :string)
	return self.ComponentStorage:Remove(ComponentName)
end

ECS["<I>AddSystem"] = function(self :SelfType, System :ModuleScript, SystemConfig)
	if SystemConfig.Parallel then
		return self.ParallelSystemScheduler:Add(System, SystemConfig)
	else
		return self.SerialSystemScheduler:Add(System, SystemConfig)
	end
end

ECS["<I>RemoveSystem"] = function(self :SelfType, SystemId :string)
	self.SerialSystemScheduler:Remove(SystemId)
	self.ParallelSystemScheduler:Remove(SystemId)
end

ECS["<I>ApplyEffect "] = function(self :SelfType, Callback :()->(), ComponentNames :{string})
	self.SerialSystemScheduler:ApplyEffect(Callback, ComponentNames)
end

ECS["<I>Destroy"] = function(self :SelfType)
	self.SerialSystemScheduler:Destroy()
	self.ParallelSystemScheduler:Destroy()
end


return ECS
