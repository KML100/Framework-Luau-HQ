------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: ConfigService
-- VERSION: N/A
-- AUTHOR: KML100

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local Config = {}

local Seen = {}
for _, NameSpaceModule in pairs(script:GetChildren()) do
	for Name, String in pairs(require(NameSpaceModule)) do
		if Seen[Name] then Config:Halt("Duplicate In Name Space! Name: ", Name) end
		Seen[Name] = true
	end
end

function Config:Halt(...:string)
	
	if not select(2, ...) then 	error("// FLHQ ERROR! "..tostring(...)) end
	
	local ErrorString = ""
	for _, ArgString in ipairs({...}) do
		ErrorString = ErrorString..tostring(ArgString)
	end
	
	error("// FLHQ ERROR! "..ErrorString)
end

function Config:Load(NameSpaceName :string)
	
	local NameSpaceModule = script:FindFirstChild(NameSpaceName)
	local NameSpace = require(NameSpaceModule)
	
	for Name, String in pairs(NameSpace) do
		Config[Name] = String
	end
end

return Config
