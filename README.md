It is a framework, an innovative one at that, however undocumented, with many edge cases and very minimal error handling besides the most basic case. If you wish to use it, go for it but if I may suggest you one thing, check out OS short for ObjectService first, it is the back bone of the framework.

OS is a Object Oriented Object Factory, a mouthful, I know. So, you know the basic setmetable things you do to use OOP in Luau? I hope you do.

What if... what if we just do this instead.

(In this we assume FLHQ is in ReplicatedStorage and this a ModuleScript, change to code format preview to have a better look at that example code below)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FLHQ = require(ReplicatedStorage.FrameworkLuauHQ)

local ObjectService = FLHQ("ObjectService")

local MyTable = {}

local function New(...)

  local self = {}

  return ObjectService(script, self)
end

return MyTable

AND WOWE! We have achieved OOP but with many lines less of boilerplate. Anyways, there is much more to discover however I am too lazy to tell you all of that. Some key notes include, True Parallel Execution, Parallel Entity Component System, Encapsulation in OS with key flags and over ten other services. Have fun! 
