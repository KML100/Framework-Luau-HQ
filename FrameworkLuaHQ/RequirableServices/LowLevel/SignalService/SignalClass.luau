------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--// NAME: SignalClass

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)

local InternalService = FLHQ("InternalService")
local ObjectService = FLHQ("ObjectService")

type SelfType = {
	_SignalConnections :{},
}

local function RemoveConnection(SignalConnections, ConnectionData)
	
	local NewestSignalIndex = #SignalConnections
	local NewestSignal = SignalConnections[NewestSignalIndex]
	
	local OldConnectionId = ConnectionData.ConnectionId
	
	NewestSignal.ConnectionId = OldConnectionId
	
	SignalConnections[OldConnectionId] = NewestSignal
	SignalConnections[NewestSignalIndex] = nil
end

local SignalClass = {}

function SignalClass.New()

	local self :SelfType = {}
	
	self["<RL>_SignalConnections"] = {}

	return ObjectService(script, self)
end

SignalClass["<I>Connect"] = function(self :SelfType, Callback :(any) -> (any))
	local SignalConnections = self._SignalConnections

	local ConnectionSettings = {}

	local ConnectionData = {
		ConnectionSettings = ConnectionSettings,
		ConnectionId = #SignalConnections +1,

		Callback = Callback,

		Disconnected = false,

		TimesFired = nil,
		FireLimit = nil,
	}

	ConnectionSettings.SetLimit = function(NewFireLimit :number)
		ConnectionData.FireLimit = NewFireLimit
		ConnectionData.TimesFired = 0

		return ConnectionSettings
	end

	ConnectionSettings.Disconnect = function()
		if ConnectionData.Disconnected then return end
		ConnectionData.Disconnected = true

		RemoveConnection(SignalConnections, ConnectionData)
	end

	SignalConnections[ConnectionData.ConnectionId] = ConnectionData

	return ConnectionSettings
end

SignalClass["<I>Fire"] = function(self :SelfType, ...)
	local SignalConnections = self._SignalConnections

	local PendingRemoval = {}
	for _, ConnectionData in ipairs(SignalConnections) do
		
		InternalService:TaskPooledThread(ConnectionData.Callback, ...)

		local FireLimit = ConnectionData.FireLimit
		if not FireLimit then continue end

		ConnectionData.TimesFired += 1
		if FireLimit > ConnectionData.TimesFired then continue end

		table.insert(PendingRemoval, ConnectionData)
	end
	
	for _, ConnectionData in ipairs(PendingRemoval) do
		ConnectionData.ConnectionSettings:Disconnect()
	end
end

SignalClass["<I>Yield"] = function(self :SelfType)
	
	local YieldedThread = coroutine.running()
	self:Connect(function()

		if not (coroutine.status(YieldedThread) == "suspended") then return end
		coroutine.resume(YieldedThread)

	end):SetLimit(1)

	coroutine.yield()
end

SignalClass["<I>SpinYield"] = function(self :SelfType)

	local Yielded = true
	self:Connect(function()
		Yielded = false
	end):SetLimit(1)

	while Yielded do
		task.wait()
	end
end

SignalClass["<I>DisconnectAll"] = function(self :SelfType)
	table.clear(self._SignalConnections)
end

return SignalClass
