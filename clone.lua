--// LocalScript

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Variables
local running = false
local animTrack

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "InvisibleToggleGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0.25, 0, 0.1, 0) -- responsive
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 0
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.Parent = ScreenGui

-- Rounded corners + stroke
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(80, 80, 80)
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = Frame

-- Aspect ratio for Frame
local FrameAspect = Instance.new("UIAspectRatioConstraint")
FrameAspect.AspectRatio = 3
FrameAspect.Parent = Frame

-- Draggable logic
local dragging, dragStart, startPos
Frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = Frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.9, 0, 0.55, 0)
ToggleButton.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Red = OFF
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextScaled = true
ToggleButton.Text = "Invisible upon Cloning: OFF"
ToggleButton.Parent = Frame

-- Rounded corners for button
local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = ToggleButton

-- Text scaling constraint
local TextConstraint = Instance.new("UITextSizeConstraint")
TextConstraint.MaxTextSize = 24
TextConstraint.MinTextSize = 14
TextConstraint.Parent = ToggleButton

-- Credit label
local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, 0, 0.25, 0)
Credit.Position = UDim2.new(0, 0, 0.7, 0)
Credit.BackgroundTransparency = 1
Credit.Text = "Made by theother1211"
Credit.TextColor3 = Color3.fromRGB(180, 180, 180)
Credit.Font = Enum.Font.SourceSansItalic
Credit.TextScaled = true
Credit.Parent = Frame

local CreditConstraint = Instance.new("UITextSizeConstraint")
CreditConstraint.MaxTextSize = 18
CreditConstraint.MinTextSize = 12
CreditConstraint.Parent = Credit

-- Function to handle toggle
local function handleToggle(enabled)
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	
	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

	if enabled then
		running = true
		task.spawn(function()
			while running do
				local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
				local hrp = character:FindFirstChild("HumanoidRootPart")

				if torso and torso.Transparency ~= 0 then
					if not animTrack or not animTrack.IsPlaying then
						local animation = Instance.new("Animation")
						animation.AnimationId = "rbxassetid://75804462760596"
						animTrack = animator:LoadAnimation(animation)
						animTrack.Looped = true
						animTrack:Play()
						animTrack:AdjustSpeed(0)
					end
					if hrp then hrp.Transparency = 0.4 end
				else
					if animTrack and animTrack.IsPlaying then
						animTrack:Stop()
						animTrack = nil
					end
					if hrp then hrp.Transparency = 1 end
				end
				task.wait(0.5)
			end
		end)
	else
		running = false
		if animTrack and animTrack.IsPlaying then
			animTrack:Stop()
			animTrack = nil
		end
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.Transparency = 1 end
	end
end

-- Toggle button click
ToggleButton.MouseButton1Click:Connect(function()
	running = not running
	handleToggle(running)

	if running then
		ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Green = ON
		ToggleButton.Text = "Invisible upon Cloning: ON"
	else
		ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Red = OFF
		ToggleButton.Text = "Invisible upon Cloning: OFF"
	end
end)
