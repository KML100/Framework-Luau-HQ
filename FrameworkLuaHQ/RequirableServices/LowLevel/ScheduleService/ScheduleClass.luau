------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--// NAME: ScheduleClass

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)

local ConfigService = FLHQ("ConfigService") ConfigService:Load("ScheduleService")
local ObjectService = FLHQ("ObjectService")

type SelfType = {
	_State :string,
	
	_ConnectionDatas :{},
	_LowestPriority :number,
}

local ScheduleClass = {}

function ScheduleClass.New(State :string)
	
	local self :SelfType = {}

	self["<RL>_State"] = State
	
	self["<RL>_ConnectionDatas"] = {}
	self["<L>_LowestPriority"] = 0
	
	return ObjectService(script, self)
end

ScheduleClass["<M>Initialize"] = function(self :SelfType)

	local ConnectionDatas = self._ConnectionDatas

	RunService[self._State]:Connect(function(...)
		for Index=1, self._LowestPriority do
			
			local ConnectionData = ConnectionDatas[Index]
			if not ConnectionData then continue end
			if ConnectionData.Disconnected then continue end

			local Success, Return = pcall(ConnectionData.Callback, ...)
			if Success then continue end
			
			warn(Return)
		end
	end)	
end

ScheduleClass["<M>Call"] = function(self :SelfType, Callback, Priority :number, MustConnect :boolean)
	
	local ConnectionDatas = self._ConnectionDatas
	local ConnectionDataCount = #ConnectionDatas
	
	if ConnectionDatas[Priority] and not MustConnect then ConfigService:Halt(ConfigService.PRIORITY_TAKEN, Priority) end
	
	local ConnectionIndex = ((not ConnectionDatas[Priority]) and Priority) or (ConnectionDataCount +1)
	if ConnectionIndex > self._LowestPriority then self._LowestPriority = ConnectionIndex end
	
	local ConnectionData = {
		Callback = Callback,
		Disconnected = false,
	}
	
	ConnectionDatas[ConnectionIndex] = ConnectionData

	local DisconnectTable = {
		Disconnect = function()
			if ConnectionData.Disconnected then return end
			
			ConnectionData.Disconnected = true
			ConnectionDatas[ConnectionIndex] = nil
		end,
	}
	
	return DisconnectTable
end


return ScheduleClass
