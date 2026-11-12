------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--// NAME: TaskClass

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)

local ObjectService = FLHQ("ObjectService")

type SelfType = {
	_Path :{}
}

local function CreateNode(Callback)
	local Node = {}
	Node.Callback = Callback
	Node.OnFail = {}
	Node.OnSuccess = {}
	
	return Node
end

local function GetReturnTable(self :SelfType, NewNode)
	return {
		OnFail = function(NextCallback)
			return self:_OnFailInternal(NextCallback, NewNode)
		end,

		OnSuccess = function(NextCallback)
			return self:_OnSuccessInternal(NextCallback, NewNode)
		end,
		
		Do = function()
			self:Do()
		end,
	}
end

local TaskClass = {}

function TaskClass.New(Callback)

	local self :SelfType = {}

	self["<RL>_Path"] = CreateNode(Callback)

	return ObjectService(script, self)
end

local function FireNodeCallbacks(DoInternal, Callbacks)
	for _, NewNode in pairs(Callbacks) do
		DoInternal(NewNode)
	end
end

local function DoInternal(Node)
	
	local Success, Return = pcall(Node.Callback)
	
	if Success then FireNodeCallbacks(DoInternal, Node.OnSuccess) return end
	if not Success then warn("Task Errored!") warn(Return) end
	
	FireNodeCallbacks(DoInternal, Node.OnFail)
end

TaskClass["<I>Do"] = function(self :SelfType)
	DoInternal(self._Path)
end

TaskClass["<IL>_OnFailInternal"] = function(self :SelfType, Callback, Node)

	local NewNode = CreateNode(Callback)
	table.insert(Node.OnFail, NewNode)

	return GetReturnTable(self, NewNode)
end

TaskClass["<I>OnFail"] = function(self :SelfType, Callback)
	return self:_OnFailInternal(Callback, self._Path)
end

TaskClass["<IL>_OnSuccessInternal"] = function(self :SelfType, Callback, Node)

	local NewNode = CreateNode(Callback)
	table.insert(Node.OnSuccess, NewNode)

	return GetReturnTable(self, NewNode)
end

TaskClass["<I>OnSuccess"] = function(self :SelfType, Callback)
	return self:_OnSuccessInternal(Callback, self._Path)
end

return TaskClass
