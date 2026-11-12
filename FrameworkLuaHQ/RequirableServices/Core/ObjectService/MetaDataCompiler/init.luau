------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: MetaDataCompiler

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local KeyWordList = require(script.KeywordList)

local SYNTAX = KeyWordList.All
local SCOPE_STRUCTURE = KeyWordList.ScopeStructure
local META_DATA_TAGS = KeyWordList.MetaDataTags
local META_METHOD_NAMES = KeyWordList.MetaMethodNames

local NO_METAMETHOD_ERROR = "// FLHQ ERROR! No Metamethod Found! "

local MetaDataCompiler = {}

local function TryMatch(LIST, Key :string, Index :number)
	
	for _, Token in pairs(LIST) do
		local TokenLength = string.len(Token)
		local TestToken = string.sub(Key, Index, Index + TokenLength -1)
		
		if not (Token == TestToken) then continue end
		
		return Token, TokenLength 
	end
end

local function TryStrip(StripData :{}, Token :string)
	
	if Token == SYNTAX.ScopeStart then StripData.CanStrip = true end	
	
	if not StripData.CanStrip then StripData.StrippedKey = StripData.StrippedKey..Token end
	
	if Token == SYNTAX.ScopeEnd then StripData.CanStrip = false end
end

function MetaDataCompiler:LexicalAnalysis(Key :string)
	
	local TokenTable = {}
	local StripData = {
		CanStrip = false,
		StrippedKey = "",
	}
	
	local KeyLength = string.len(Key)

	local CharacterSkipCount = 0	
	for Index=1, KeyLength do
		if CharacterSkipCount > 0 then CharacterSkipCount -= 1 continue end

		local Token, TokenLength = TryMatch(SCOPE_STRUCTURE, Key, Index)
		if not Token then Token, TokenLength = TryMatch(META_METHOD_NAMES, Key, Index) end
		if not Token then Token, TokenLength = TryMatch(META_DATA_TAGS, Key, Index) end
		
		local Character = string.sub(Key, Index, Index)
		TryStrip(StripData, Token or Character)
		
		if not Token then continue end

		CharacterSkipCount = TokenLength -1
		table.insert(TokenTable, Token)
	end

	return TokenTable, StripData.StrippedKey
end

local function AdvanceScope(Outside, Token)
	
	local Scope = {}
	Scope.Token = Token
	Scope.Outside = Outside
	Scope.Inside = {}

	return Scope
end

local function BacktrackScope(CurrentNode)
	return CurrentNode.Outside
end

local function PlaceToAST(CurrentNode, Key, Data)
	CurrentNode.Inside[Key] = Data
end

function MetaDataCompiler:SyntaxAnalysis(TokenTable :{})
	
	local AST = AdvanceScope(nil, nil)
	local CurrentNode = AST
	
	for _, Token in ipairs(TokenTable) do

		if Token == SYNTAX.ScopeStart then
			
			local NewScope = AdvanceScope(CurrentNode, Token)
			PlaceToAST(CurrentNode, "Scope", NewScope)
			CurrentNode = NewScope

			continue
		end
		
		if Token == SYNTAX.ScopeEnd then
			CurrentNode = BacktrackScope(CurrentNode)
			continue
		end

		if CurrentNode == AST then
			for _, SyntaxToken in pairs(META_METHOD_NAMES) do
				if not (SyntaxToken == Token) then continue end

				PlaceToAST(CurrentNode, SyntaxToken, SyntaxToken)
				
				break
			end

			continue
		end
		
		if not (CurrentNode == AST) then
			for _, SyntaxToken in pairs(META_DATA_TAGS) do
				if not (SyntaxToken == Token) then continue end

				PlaceToAST(CurrentNode, SyntaxToken, SyntaxToken)

				break
			end
		end
	end

	return AST
end

local function TransferData(Sender, Receiver)
	for Key, Entry in pairs(Sender) do
		Receiver[Key] = Entry
	end
end

local function CompileTags(Node)
	
	local Tags = {}
	for _, Token in pairs(Node) do
		
		if Token.Inside then TransferData(CompileTags(Token.Inside), Tags) end
		
		if META_DATA_TAGS[Token] then Tags[Token] = Token end	
	end
	
	return Tags
end

local function CompileMethod(AST)
	for _, Token in pairs(AST) do
		if META_METHOD_NAMES[Token] then return Token end
	end
	
	error(NO_METAMETHOD_ERROR)
end

function MetaDataCompiler:Compile(AST :{})
	
	local KeyData = {}
	
	local Tags = CompileTags(AST.Inside)
	TransferData(Tags, KeyData)
	
	if Tags.M then
		KeyData.MetaMethod = CompileMethod(AST.Inside)
	end
	
	return KeyData
end

return MetaDataCompiler
