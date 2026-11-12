------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: MetaMethodInjector

--// NOTE: Contains Service Owned Magic Strings And Duplicate Code When Compared To Other Modules. This Is Due To Guidelines. (Core -> Low -> High)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)

--// Magic Strings
local ALLOC_STRING = "__ALLOC__"
local GUARD_STRING = "__GUARD__"
local DEBUG_STRING = "__DEBUG__"

local LOCKED_INDEX_ERROR = "// FLHQ ERROR! Tried To Access A Locked Index Non-Internally At Run Time! "
local READ_INDEX_ERROR = "// FLHQ ERROR! Tried To Access A Read-Only Index And Overwrite At Run Time! "

local LOCKED_META_TABLE_ENDFIX = "_LOCKED_BY_OBJECT_SERVICE"

local function DeepCloneTable(TableToClone) --// Copy-Paste Code From InternalService

	local ClonedTable = {}
	for Key, Entry in pairs(TableToClone) do
		if not (type(Entry) == "table") then ClonedTable[Key] = Entry continue end

		ClonedTable[Key] = DeepCloneTable(Entry)
	end

	return ClonedTable
end

local function GetIndex(KeyTranslation, Key)
	return KeyTranslation[Key] or Key
end

local function GetData(self, Module, RealIndex)
	local RawIndex = rawget(self, RealIndex)
	if not (RawIndex == nil) then return RawIndex end
	return Module[RealIndex]
end

local function SetData(self, RealIndex, Value)
	rawset(self, RealIndex ,Value)
end

local function TryMetaMethod(MetaTable, HasMetaMethod, ActualMetaMethodName, Callback)
	if not HasMetaMethod then return end

	MetaTable[ActualMetaMethodName] = Callback
end

local MetaMethodInjector = {}

function MetaMethodInjector:InjectAll(MethodNames, InjectionData)
	
	local ModuleScript = InjectionData.ModuleScript
	local Module = InjectionData.Module
	local ModuleData = InjectionData.ModuleData

	local Locked = ModuleData.Locked
	local ReadOnly = ModuleData.ReadOnly
	local Internal = ModuleData.Internal
	local KeyTranslation = ModuleData.KeyTranslation

	local Proxy = InjectionData.Proxy
	local MetaTable = InjectionData.MetaTable
	local self = InjectionData.self
	
	--// Access control function
	local function CallFunctionAs(Function, Internal, ...)
		if not Internal then
			return Function(Proxy, ...)
		else
			return Function(self, ...)
		end
	end

	--// Self metatable for proper encapsulation
	setmetatable(self, {
		__index = function(SelfSelf, Index)
				
			local RealIndex = GetIndex(KeyTranslation, Index)
			local Data = GetData(SelfSelf, Module, RealIndex)
			
			if Data == ALLOC_STRING then return nil end
			if not (type(Data) == "function") then return Data end

			local ReturnFunction = function(_, ...)
				return CallFunctionAs(Data, true, ...)
			end

			return ReturnFunction
		end,
		
		__newindex = function(SelfSelf, Index, Value)
			
			local RealIndex = GetIndex(KeyTranslation, Index)
			local Data = GetData(SelfSelf, Module, RealIndex) 

			if Data == ALLOC_STRING then SetData(SelfSelf, RealIndex, Value) return end
			if ReadOnly[RealIndex] then error(READ_INDEX_ERROR..tostring(Index)) end

			SetData(SelfSelf, RealIndex, Value)
		end,
	})

	--// Act like the normal indexing and incorporate access control to it
	TryMetaMethod(MetaTable, MethodNames.Index, "__index", function(_, Index)

		local RealIndex = GetIndex(KeyTranslation, Index)
		if Locked[RealIndex] then error(LOCKED_INDEX_ERROR..tostring(Index)) end
		
		local Data = GetData(self, Module, RealIndex)
		if Data == ALLOC_STRING then return nil end
		if not (type(Data) == "function") then return Data end

		local ReturnFunction = function(_, ...)
			return CallFunctionAs(Data, Internal[RealIndex], ...)
		end

		return ReturnFunction
	end)
	
	--// EXPERIMENTAL
	--// Only index functions and let data index fall through to the exception. Functions will still have access control
	TryMetaMethod(MetaTable, MethodNames.IndexedIndex, "__index", function(_, Index)

		local RealIndex = GetIndex(KeyTranslation, Index)
		local Data = GetData(self, Module, RealIndex) 
		
		if not (type(Data) == "function") then 
			
			local MetaMethodIndex = GetIndex(KeyTranslation, "Index")
			local MetaMethod = GetData(self, Module, MetaMethodIndex) 
			
			return CallFunctionAs(MetaMethod, true, Index) 
		end

		if Locked[RealIndex] then error(LOCKED_INDEX_ERROR..tostring(Index)) end
		return function(_, ...)
			return CallFunctionAs(Data, Internal[RealIndex], ...)
		end
	end)
	
	TryMetaMethod(MetaTable, MethodNames.NewIndex, "__newindex", function(_, Index, Value)
		
		local RealIndex = GetIndex(KeyTranslation, Index)
		local Data = GetData(self, Module, RealIndex) 
		
		if Data == ALLOC_STRING then SetData(self, RealIndex, Value) return end
		if Locked[RealIndex] then error(LOCKED_INDEX_ERROR..tostring(Index)) end
		if ReadOnly[RealIndex] then error(READ_INDEX_ERROR..tostring(Index)) end
		
		SetData(self, RealIndex, Value)
	end)
	
	--// EXPERIMENTAL
	TryMetaMethod(MetaTable, MethodNames.IndexedNewIndex, "__newindex", function(_, Index, Value)
		
		local RealIndex = GetIndex(KeyTranslation, "NewIndex")
		local Callback = GetData(self, Module, RealIndex) 

		return CallFunctionAs(Callback, true, RealIndex, Value)
	end)
	
	TryMetaMethod(MetaTable, MethodNames.Call, "__call", function(_, ...)
		
		local Index = (select(1, ...))
		if Index == GUARD_STRING then return true end
		if Index == DEBUG_STRING then return DeepCloneTable(self) end
		
		return
	end)
	
	--// EXPERIMENTAL
	TryMetaMethod(MetaTable, MethodNames.IndexedCall, "__call", function(_, ...)
		
		local Index = (select(1, ...))
		if Index == GUARD_STRING then return true end
		if Index == DEBUG_STRING then return DeepCloneTable(self) end

		local RealIndex = GetIndex(KeyTranslation, "Call")
		local Callback = GetData(self, Module, RealIndex) 

		return CallFunctionAs(Callback, true, ...)
	end)

	--// Basic QOL additions for every object
	if MethodNames.TableName then
		MetaTable.__metatable = ModuleScript.Name..LOCKED_META_TABLE_ENDFIX
	end

	if MethodNames.Initialize then
		
		local RealIndex = GetIndex(KeyTranslation, "Initialize")
		local Callback = GetData(self, Module, RealIndex) 
	
		CallFunctionAs(Callback, true, table.unpack(InjectionData.InitializationData))
	end
end

return MetaMethodInjector