--// LocalScript: Combined Menu (Forsaken Invisibility + RagingPace + Auto Error 404)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")

-- ===============================
-- VARIABLES
-- ===============================
-- Forsaken Invisibility
local invisRunning = false
local animTrack

-- RagingPace
local savedRange = lp:FindFirstChild("RagingPaceRange")
if not savedRange then
    savedRange = Instance.new("NumberValue")
    savedRange.Name = "RagingPaceRange"
    savedRange.Value = 19
    savedRange.Parent = lp
end
local RANGE = savedRange.Value
local SPAM_DURATION = 3
local COOLDOWN_TIME = 5
local activeCooldowns = {}
local ragingEnabled = false
local animsToDetect = {
    ["116618003477002"]=true, ["119462383658044"]=true, ["131696603025265"]=true,
    ["121255898612475"]=true, ["133491532453922"]=true, ["103601716322988"]=true,
    ["86371356500204"]=true, ["72722244508749"]=true, ["87259391926321"]=true,
    ["96959123077498"]=true
}

-- Auto Error 404
local autoErrorEnabled = false
local detectionRange = 14
local soundHooks = {}
local soundTriggeredUntil = {}
local autoErrorTriggerSounds = {
    ["86710781315432"]=true, ["99820161736138"]=true, ["609342351"]=true, ["81976396729343"]=true,
    ["12222225"]=true, ["80521472651047"]=true, ["139012439429121"]=true, ["91194698358028"]=true,
    ["111910850942168"]=true, ["83851356262523"]=true
}

-- ===============================
-- CREATE SINGLE MENU GUI
-- ===============================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CombinedMenuGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 220)
Frame.Position = UDim2.new(0.5, -110, 0.5, -110)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 0
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.Parent = ScreenGui

-- Rounded corners + stroke
Instance.new("UICorner", Frame)
local UIStroke = Instance.new("UIStroke", Frame)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(80, 80, 80)

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
		Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
		                           startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- ===============================
-- UI ELEMENTS
-- ===============================
-- Credit
local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, 0, 0, 20)
Credit.Position = UDim2.new(0,0,0,5)
Credit.BackgroundTransparency = 1
Credit.Text = "Made by theother1211"
Credit.TextColor3 = Color3.fromRGB(180,180,180)
Credit.Font = Enum.Font.SourceSansItalic
Credit.TextSize = 14
Credit.Parent = Frame

-- Forsaken Invisibility
local InvisButton = Instance.new("TextButton")
InvisButton.Size = UDim2.new(1,-20,0,40)
InvisButton.Position = UDim2.new(0,10,0,30)
InvisButton.BackgroundColor3 = Color3.fromRGB(255,0,0)
InvisButton.TextColor3 = Color3.new(1,1,1)
InvisButton.Font = Enum.Font.SourceSansBold
InvisButton.TextSize = 16
InvisButton.Text = "Invisible upon Cloning: OFF"
InvisButton.Parent = Frame
Instance.new("UICorner", InvisButton)

-- RagingPace
local RagingButton = Instance.new("TextButton")
RagingButton.Size = UDim2.new(0.55,-10,0,30)
RagingButton.Position = UDim2.new(0,10,0,80)
RagingButton.BackgroundColor3 = Color3.fromRGB(200,0,0)
RagingButton.TextColor3 = Color3.new(1,1,1)
RagingButton.Font = Enum.Font.SourceSansBold
RagingButton.TextSize = 14
RagingButton.Text = "RagingPace: OFF"
RagingButton.Parent = Frame
Instance.new("UICorner", RagingButton)

local RangeBox = Instance.new("TextBox")
RangeBox.Size = UDim2.new(0.35,-10,0,30)
RangeBox.Position = UDim2.new(0.6,0,0,80)
RangeBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
RangeBox.TextColor3 = Color3.new(1,1,1)
RangeBox.Text = tostring(RANGE)
RangeBox.PlaceholderText = "Range"
RangeBox.Font = Enum.Font.SourceSans
RangeBox.TextSize = 14
RangeBox.ClearTextOnFocus = false
RangeBox.Parent = Frame
Instance.new("UICorner", RangeBox)

-- Auto Error 404
local ErrorButton = Instance.new("TextButton")
ErrorButton.Size = UDim2.new(1,-20,0,30)
ErrorButton.Position = UDim2.new(0,10,0,120)
ErrorButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
ErrorButton.TextColor3 = Color3.new(1,1,1)
ErrorButton.Font = Enum.Font.SourceSansBold
ErrorButton.TextSize = 14
ErrorButton.Text = "Auto Error 404: OFF"
ErrorButton.Parent = Frame
Instance.new("UICorner", ErrorButton)

local RangeErrorBox = Instance.new("TextBox")
RangeErrorBox.Size = UDim2.new(1,-20,0,25)
RangeErrorBox.Position = UDim2.new(0,10,0,155)
RangeErrorBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
RangeErrorBox.TextColor3 = Color3.new(1,1,1)
RangeErrorBox.Text = tostring(detectionRange)
RangeErrorBox.PlaceholderText = "Error Range"
RangeErrorBox.Font = Enum.Font.SourceSans
RangeErrorBox.TextSize = 14
RangeErrorBox.ClearTextOnFocus = false
RangeErrorBox.Parent = Frame
Instance.new("UICorner", RangeErrorBox)

Frame.Size = UDim2.new(0,220,0,190) -- adjust frame size

-- ===============================
-- FUNCTIONS
-- ===============================
-- Forsaken Invisibility
local function handleInvisToggle(enabled)
	local character = lp.Character or lp.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
	if enabled then
		invisRunning = true
		task.spawn(function()
			while invisRunning do
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
		invisRunning = false
		if animTrack and animTrack.IsPlaying then
			animTrack:Stop()
			animTrack = nil
		end
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.Transparency = 1 end
	end
end

InvisButton.MouseButton1Click:Connect(function()
	invisRunning = not invisRunning
	handleInvisToggle(invisRunning)
	InvisButton.BackgroundColor3 = invisRunning and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
	InvisButton.Text = invisRunning and "Invisible upon Cloning: ON" or "Invisible upon Cloning: OFF"
end)

-- RagingPace
local function isAnimationMatching(anim)
	local id = tostring(anim.Animation and anim.Animation.AnimationId or "")
	local numId = id:match("%d+")
	return animsToDetect[numId] or false
end
local function fireRagingPace()
	local args = {"UseActorAbility","RagingPace"}
	ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end
RunService.Heartbeat:Connect(function()
	if not ragingEnabled then return end
	for _,player in ipairs(Players:GetPlayers()) do
		if player~=lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local targetHRP = player.Character.HumanoidRootPart
			local myChar = lp.Character
			if myChar and myChar:FindFirstChild("HumanoidRootPart") then
				local dist = (targetHRP.Position - myChar.HumanoidRootPart.Position).Magnitude
				if dist <= RANGE and (not activeCooldowns[player] or tick()-activeCooldowns[player]>=COOLDOWN_TIME) then
					local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
					if humanoid then
						for _,track in pairs(humanoid:GetPlayingAnimationTracks()) do
							if isAnimationMatching(track) then
								activeCooldowns[player] = tick()
								task.spawn(function()
									local startTime = tick()
									while tick()-startTime<SPAM_DURATION do
										fireRagingPace()
										task.wait(0.05)
									end
								end)
								break
							end
						end
					end
				end
			end
		end
	end
end)

RagingButton.MouseButton1Click:Connect(function()
	ragingEnabled = not ragingEnabled
	RagingButton.Text = ragingEnabled and "RagingPace: ON" or "RagingPace: OFF"
	RagingButton.BackgroundColor3 = ragingEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
end)

RangeBox.FocusLost:Connect(function(enter)
	if enter then
		local val = tonumber(RangeBox.Text)
		if val and val>0 then RANGE=val savedRange.Value=val else RangeBox.Text=tostring(RANGE) end
	end
end)
lp.CharacterAdded:Connect(function() task.wait(1) RANGE=savedRange.Value RangeBox.Text=tostring(RANGE) end)

-- Auto Error 404
local function extractNumericSoundId(sound)
	if not sound or not sound.SoundId then return nil end
	return tostring(sound.SoundId):match("%d+")
end
local function getSoundWorldPosition(sound)
	if sound.Parent and sound.Parent:IsA("BasePart") then return sound.Parent.Position end
	if sound.Parent and sound.Parent:IsA("Attachment") and sound.Parent.Parent:IsA("BasePart") then return sound.Parent.Parent.Position end
	local found = sound.Parent and sound.Parent:FindFirstChildWhichIsA("BasePart", true)
	if found then return found.Position end
	return nil
end
local function attemptError404ForSound(sound)
	if not autoErrorEnabled then return end
	if not sound or not sound:IsA("Sound") or not sound.IsPlaying then return end
	local id = extractNumericSoundId(sound)
	if not id or not autoErrorTriggerSounds[id] then return end
	local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end
	if soundTriggeredUntil[sound] and tick()<soundTriggeredUntil[sound] then return end
	local pos = getSoundWorldPosition(sound)
	local shouldTrigger = (not pos) or ((myRoot.Position - pos).Magnitude <= detectionRange)
	if shouldTrigger then
		warn("[AUTO ERROR 404] Triggered for Sound ID:", id)
		local args = {"UseActorAbility","404Error"}
		ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
		soundTriggeredUntil[sound] = tick()+1.2
	end
end
local function hookSound(sound)
	if soundHooks[sound] then return end
	local playedConn = sound.Played:Connect(function() attemptError404ForSound(sound) end)
	local propConn = sound:GetPropertyChangedSignal("IsPlaying"):Connect(function() if sound.IsPlaying then attemptError404ForSound(sound) end end)
	local destroyConn = sound.Destroying:Connect(function()
		playedConn:Disconnect()
		propConn:Disconnect()
		destroyConn:Disconnect()
		soundHooks[sound] = nil
		soundTriggeredUntil[sound] = nil
	end)
	soundHooks[sound] = true
	if sound.IsPlaying then attemptError404ForSound(sound) end
end
for _,s in ipairs(game:GetDescendants()) do if s:IsA("Sound") then hookSound(s) end end
game.DescendantAdded:Connect(function(d) if d:IsA("Sound") then hookSound(d) end end)

ErrorButton.MouseButton1Click:Connect(function()
	autoErrorEnabled = not autoErrorEnabled
	ErrorButton.Text = "Auto Error 404: "..(autoErrorEnabled and "ON" or "OFF")
end)
RangeErrorBox.FocusLost:Connect(function(enter)
	if enter then
		local val = tonumber(RangeErrorBox.Text)
		if val and val>0 then detectionRange=val RangeErrorBox.Text="Range = "..val else detectionRange=14 RangeErrorBox.Text="Range = 14" end
	end
end)
