------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--// NAME: InterfaceService
-- VERSION: 2.0
-- AUTHOR: KML100

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)
local ObjectService = FLHQ("ObjectService")

local InstanceActions = require(script.InstanceActions)

local UI_EXEMPT_PREFIXS = "UI"
local UNIQUE_ITEM_NIL = "N/A"

type SelfType = {
	_ScreenGUI :ScreenGui,
	_Elements :{},
	_UniqueElements :{},
}

local function CreateInstanceContainer(InstanceName :string?, OldInstance :Instance?)

	local MetaTable = {}

	local NewInstance = OldInstance or Instance.new(InstanceName)
	MetaTable.Instance = NewInstance

	MetaTable.__index = function(_, Index)

		local InstanceAction = InstanceActions[Index]
		if InstanceAction then 
			return function(_, ...)
				return InstanceAction(NewInstance, ...)
			end
		end
		
		local InstanceIndex = NewInstance[Index]
		if not (type(InstanceIndex) == "function") then return InstanceIndex end

		return function(_, ...)
			return InstanceIndex(NewInstance, ...)
		end
	end

	MetaTable.__newindex = function(_, Index, Value)
		NewInstance[Index] = Value
	end

	local ProxyTable = {}
	return setmetatable(ProxyTable, MetaTable)
end

local function InsertToElements(self :SelfType, Key, Element)
	
	table.insert(self._Elements, Element)
	
	if self._UniqueElements[Key] then self._UniqueElements[Key] = UNIQUE_ITEM_NIL return end
	self._UniqueElements[Key] = Element
end

local InterfaceService = {}

function InterfaceService.New(ScreenParent)

	local self :SelfType = {}

	self["<RL>_ScreenGUI"] = "__ALLOC__"
	self["<RL>_Elements"] = {}
	self["<Rl>_UniqueElements"]={}
	
	return ObjectService(script, self, ScreenParent)
end

InterfaceService["<M>Initialize"] = function(self :SelfType, ScreenParent)
	local ScreenGUI = Instance.new("ScreenGui", ScreenParent)
	
	ScreenGUI.IgnoreGuiInset = true
	
	self._ScreenGUI = ScreenGUI
end

InterfaceService["<I>CreateElement"] = function(self :SelfType, InstanceName :string, ElementName :string, Parent :Instance?)
	local NewElement = CreateInstanceContainer(InstanceName)
	NewElement.Name = ElementName
	
	if Parent then NewElement.Parent = Parent else NewElement.Parent = self._ScreenGUI end

	InsertToElements(self, ElementName, NewElement)

	return NewElement
end

InterfaceService["<I>LoadExisting"] = function(self :SelfType, OldInstance :Instance, IncludeDescendants :boolean)

	InsertToElements(self, OldInstance.Name,  CreateInstanceContainer(nil, OldInstance))
	
	if not IncludeDescendants then return end
	
	for _, Descendant in pairs(OldInstance:GetDescendants()) do
		self:LoadExisting(Descendant, false)
	end
end

InterfaceService["<I>CloneFrom"] = function(self :SelfType, FromInstance :Instance, Parent :Instance?)
	local Clone = FromInstance:Clone()
	if Parent then Clone.Parent = Parent else Clone.Parent = self._ScreenGUI end
	
	self:LoadExisting(Clone, true)
end

InterfaceService["<I>SearchForUnique"] = function(self :SelfType, ElementName :string)
	local UniqueElement = self._UniqueElements[ElementName]
	if not UniqueElement then error("Couldnt Find Unique Element! "..tostring(ElementName)) end
	
	return UniqueElement
end

InterfaceService["<I>GetScreenGUI"] = function(self :SelfType)
	return self._ScreenGUI
end

InterfaceService["<I>Destroy"] = function(self :SelfType)
	
	for _, Element in pairs(self._Elements) do
		Element:Destroy()
	end
	
	self._ScreenGUI:Destroy()
end

return InterfaceService
