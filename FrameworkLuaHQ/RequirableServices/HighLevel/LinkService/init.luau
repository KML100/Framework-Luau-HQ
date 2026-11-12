------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: LinkService
-- VERSION: 1.1
-- AUTHOR: KML100

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MemoryStoreService = game:GetService("MemoryStoreService")
local MessagingService = game:GetService("MessagingService")

local FLHQ = require(ReplicatedStorage.FrameworkLuaHQ)

local InternalService = FLHQ("InternalService")
local TaskService = FLHQ("TaskService")

local RESEND_WAIT_TIME = 0.33

local PubSubCallbacks = {}
local SubConnections = {}

local LinkService = {}

function LinkService:Subscribe(ChannelId :string, Callback)
	
	local ChannelCallbacks = PubSubCallbacks[ChannelId]
	if not ChannelCallbacks then
		
		ChannelCallbacks = {}
		PubSubCallbacks[ChannelId] = ChannelCallbacks 
		
		SubConnections[ChannelId] = MessagingService:SubscribeAsync(ChannelId, function(Message)
			InternalService:FireCallbacks(ChannelCallbacks, Message.Data, Message.Sent)  --// Roblox's own two variables
		end)
	end
	
	local CallbackId = InternalService:NewUUID()
	ChannelCallbacks[CallbackId] = {Callback = Callback, Async = true}

	return {
		Disconnect = function()
			ChannelCallbacks[CallbackId] = nil
			
			if next(ChannelCallbacks) then return end
			
			SubConnections[ChannelId]:Disconnect()
			SubConnections[ChannelId] = nil
		end,
	}
end

function LinkService:Publish(ChannelId :string, ...:any)
	
	local Data = table.pack(...)
	TaskService(function()
		MessagingService:PublishAsync(ChannelId, table.unpack(Data))
	end):OnFail(function()
		task.wait(RESEND_WAIT_TIME)
		MessagingService:PublishAsync(ChannelId, table.unpack(Data))
	end):OnFail(function()
		warn("Publish Failed!")
	end):Do()

	local ChannelCallbacks = PubSubCallbacks[ChannelId]
	if not ChannelCallbacks then return end
	
	InternalService:FireCallbacks(ChannelCallbacks, ...)
end

return LinkService

