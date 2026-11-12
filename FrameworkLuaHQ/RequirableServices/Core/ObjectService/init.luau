------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: ObjectService
-- VERSION: 5.1
-- AUTHOR: KML100

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local MetaDataCompiler = require(script.MetaDataCompiler)
local MetaMethodInjector = require(script.MetaMethodInjector)

local NO_MODULE_ERROR = "// FLHQ ERROR! No Module Was Provided To ObjectService! "

local function CompileTable(Table, ModuleData)
	for Key, Entry in pairs(Table) do
		
		local TokenTable, StrippedKey = MetaDataCompiler:LexicalAnalysis(Key)
		local AST = MetaDataCompiler:SyntaxAnalysis(TokenTable)
		local KeyData = MetaDataCompiler:Compile(AST)
		
		if KeyData.L then ModuleData.Locked[Key] = true end
		if KeyData.R then ModuleData.ReadOnly[Key] = true end
		if KeyData.I then ModuleData.Internal[Key] = true end
		if KeyData.M then 
			ModuleData.MetaMethods[KeyData.MetaMethod] = KeyData.MetaMethod 
		end
		
		ModuleData.KeyTranslation[StrippedKey] = Key
	end
end

local function New(_, ModuleScript :ModuleScript, self :any, ...)
	
	if not ModuleScript:IsA("ModuleScript") then error(NO_MODULE_ERROR) end
	local Module = require(ModuleScript)

	local MetaMethods = {}
	local ModuleData = {
		Locked = {},
		ReadOnly = {},
		Internal = {},
		MetaMethods = MetaMethods,
		KeyTranslation = {},
	}
	
	CompileTable(Module, ModuleData)
	CompileTable(self, ModuleData)

	local MetaTable = {}
	local PublicProxy = {}
	
	setmetatable(PublicProxy, MetaTable)
	
	local InjectionData = {
	
		ModuleScript = ModuleScript,
		Module = Module,
		ModuleData = ModuleData,
		
		Proxy = PublicProxy,
		MetaTable = MetaTable,
		self = self,
		
		InitializationData = table.pack(...),
	}

	local MetaMethodNames = {}
	MetaMethodNames[(MetaMethods.Index and "IndexedIndex") or "Index"] = true
	MetaMethodNames[(MetaMethods.NewIndex and "IndexedNewIndex") or "NewIndex"] = true
	MetaMethodNames[(MetaMethods.Call and "IndexedCall") or "Call"] = true
	MetaMethodNames["TableName"] = true
	
	if MetaMethods.Initialize then MetaMethodNames["Initialize"] = true end
	
	MetaMethodInjector:InjectAll(MetaMethodNames, InjectionData)

	return PublicProxy
end

local ObjectService = setmetatable({}, {__call = New})

return ObjectService