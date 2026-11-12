------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: InternalService
-- VERSION: N/A
-- AUTHOR: KML100

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local HttpService = game:GetService("HttpService")

local ThreadPool = {}
local ThreadPoolSize = 0

local InternalService = {}

local function PooledThreadExecution(Thread, Callback, ...)
	if not Thread then return end
	
	Callback(...)
	
	ThreadPoolSize += 1
	table.insert(ThreadPool, Thread)
end

local function NewThread()
	
	local Thread = coroutine.create(function()
		while true do
			PooledThreadExecution(coroutine.yield())
		end
	end)

	InternalService:SafeCoroutineResume(Thread)
	
	return Thread
end

local function RecursiveDeepClone(Table, Visitted)
	if Visitted[Table] then return Visitted[Table] end

	local ClonedTable = {}
	Visitted[Table] = ClonedTable

	for Key, Entry in pairs(Table) do
		if type(Entry) ~= "table" then ClonedTable[Key] = Entry continue end
		ClonedTable[Key] = RecursiveDeepClone(Entry, Visitted)
	end

	return ClonedTable
end

function InternalService:SafeCoroutineResume(Coroutine, ...)
	if not (coroutine.status(Coroutine) == "suspended") then return false, nil end

	local Success, Return = coroutine.resume(Coroutine, ...)
	if not Success then error(Return) end

	return Success, Return
end

function InternalService:TaskPooledThread(Callback, ...)

	local Thread = ThreadPool[ThreadPoolSize]
	if not Thread then Thread = NewThread() ThreadPoolSize = 1 end
	
	local Success = InternalService:SafeCoroutineResume(Thread, Thread, Callback, ...)
	if not Success then 
		ThreadPool[ThreadPoolSize] = nil
		InternalService:TaskPooledThread(Callback, ...)
	end
	
	ThreadPool[ThreadPoolSize] = nil
	ThreadPoolSize -= 1
end

function InternalService:FireCallbacks(CallbackTable, ...)
	for _, CallbackData in pairs(CallbackTable) do

		local Callback = CallbackData.Callback
		if not CallbackData.Async then Callback(...) continue end

		InternalService:TaskPooledThread(Callback, ...)		
	end	
end

function InternalService:GetThreadPoolData()
	return ThreadPool, ThreadPoolSize
end

function InternalService:DeepCloneTable(TableToClone)
	return RecursiveDeepClone(TableToClone, {})
end

function InternalService:EncodeTable(...)
	return HttpService:JSONEncode(table.pack(...))
end

function InternalService:DecodeTable(Table)
	return table.unpack(HttpService:JSONDecode(Table))
end

function InternalService:NewUUID()
	return HttpService:GenerateGUID(false)
end

return InternalService
