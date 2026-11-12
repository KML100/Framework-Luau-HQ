------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--// NAME: AtomClass

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)

local ConfigService = FLHQ("ConfigService") ConfigService:Load("AtomService")
local InternalService = FLHQ("InternalService")
local ObjectService = FLHQ("ObjectService")

type SelfType = {
	_AtomTable :{},
	_ProxyTable :{},
	
	_IndexCallbacks :{},
	_NewIndexCallbacks :{},
}

local AtomClass = {}

function AtomClass.New(ExistingTable)
	
	local self :SelfType = {}
	
	self["<RL>_AtomTable"] = "__ALLOC__"
	self["<RL>_ProxyTable"] = "__ALLOC__"
	
	self["<RL>_IndexCallbacks"] = {}
	self["<RL>_NewIndexCallbacks"] = {}
	
	return ObjectService(script, self, ExistingTable)
end

AtomClass["<M>Initialize"] = function(self :SelfType, ExistingTable)
	
	local ProxyTable = {}
	self._ProxyTable = ProxyTable
	self._AtomTable = ExistingTable
	
	setmetatable(ProxyTable,{
		__index = function(_, Index)

			InternalService:FireCallbacks(self._IndexCallbacks, Index)

			return ExistingTable[Index]
		end,

		__newindex = function(_, Index, Value)

			ExistingTable[Index] = Value

			InternalService:FireCallbacks(self._NewIndexCallbacks, Index, Value)
		end,
		
		__metatable = ConfigService.ATOM_METATABLE_ACCESS
	})
end

AtomClass["<I>OnIndex"] = function(self :SelfType, Callback, Async :boolean)
	
	local Id = InternalService:NewUUID()
	self._IndexCallbacks[Id] = {Callback = Callback, Async = Async}

	return {
		Disconnect = function()
			self._IndexCallbacks[Id] = nil	
		end,
	}
end

AtomClass["<I>OnNewIndex"] = function(self :SelfType, Callback, Async :boolean)
	
	local Id = InternalService:NewUUID()
	self._NewIndexCallbacks[Id] = {Callback = Callback, Async = Async}

	return {
		Disconnect = function()
			self._NewIndexCallbacks[Id] = nil	
		end,
	}
end

AtomClass["<I>GetAtom"] = function(self :SelfType)
	return self._AtomTable
end

AtomClass["<I>GetProxy"] = function(self :SelfType)
	return self._ProxyTable
end

return AtomClass
