------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// DESCRIPTION //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- NAME: InstanceActions

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--// CODE //--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local InstanceActions = {
	TweenPosition = function(Element, Time :number, Yield :boolean, To :UDim2, From :UDim2?)
		if From then Element.Position = From end
		
		local OwnTweenInfo = TweenInfo.new(Time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local Tween = TweenService:Create(Element, OwnTweenInfo, {Position = To})
		
		Tween:Play()

		if Yield then Tween.Completed:Wait() end
	end,
	
	TweenSize = function(Element, Time :number, Yield :boolean, To :UDim2, From :UDim2?)
		if From then Element.Size = From end

		local OwnTweenInfo = TweenInfo.new(Time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local Tween = TweenService:Create(Element, OwnTweenInfo, {Size = To})
		
		Tween:Play()
		
		if Yield then Tween.Completed:Wait() end
	end,
	
	TweenTransparency = function(Element, Time, Yield, To, From)
		if From then Element.Transparency = From end

		local OwnTweenInfo = TweenInfo.new(Time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local Tween = TweenService:Create(Element, OwnTweenInfo, {Transparency = To})

		Tween:Play()

		if Yield then Tween.Completed:Wait() end
	end,
	
	OnInput = function(Element, InputType, InputCallbacks)
		
		local MouseOn = false
		local ConnectionEnter = Element.MouseEnter:Connect(function() MouseOn = true end)
		local ConnectionLeave = Element.MouseLeave:Connect(function() MouseOn = false end)
		
		local ConnectionInput = UserInputService[InputType]:Connect(function(Input, GameProcessed)
			if GameProcessed then return end
			
			local InputCallback = InputCallbacks[Input.UserInputType] or InputCallbacks[Input.KeyCode]
			if not InputCallback then return end
			
			InputCallback(Input)
		end)
		
		return {
			Disconnect = function()
				ConnectionEnter:Disconnect()
				ConnectionLeave:Disconnect()
				ConnectionInput:Disconnect()
			end,
		}
	end,
}

return InstanceActions
