------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: KeywordList

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local KeywordList = {
	
	All = {
		--// Meta Data Tags
		L = "L", --// Locked, Key Is Locked And Can Not Be Accessed From The Outside
		R = "R", --// Read-Only, Key Is Read-Only
		M = "M", --// Metamethod, Functions Is A MetaMethod
		I = "I", --// Internal, Function Can Access Locked Keys Of The Instance

		--// Meta Method Names
		Call = "Call",
		Index = "Index",
		NewIndex = "NewIndex",
		Initialize = "Initialize",

		--// Structure Definers
		ScopeStart = "<",
		ScopeEnd = ">",
	},
	
	ScopeStructure = {
		ScopeStart = "<",
		ScopeEnd = ">",
	},
	
	MetaDataTags = {
		L = "L",
		R = "R",
		M = "M",
		I = "I",
	},
	
	MetaMethodNames = {
		Call = "Call",
		Index = "Index",
		NewIndex = "NewIndex",
		Initialize = "Initialize",
	},
	
	
	
}

return KeywordList
