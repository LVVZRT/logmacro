return function(Config)

-- PLAYER WHITELIST (PUT ROBLOX IDS HERE)
local PlayerWhitelist = {
    12345678,
    87654321,
    11223344
}

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- SOUND (PLAYS WHEN NON-WHITELISTED PLAYER DETECTED)
local AlertSound = Instance.new("Sound")
AlertSound.SoundId = "rbxassetid://102770722936174"
AlertSound.Volume = 1
AlertSound.Parent = game:GetService("SoundService")

-- Executed Check
local existing = game.CoreGui:FindFirstChild("LogMacroUI")
if existing then
    existing:Destroy()
end

-- UI

local ScreenGui = Instance.new("ScreenGui")
local TextLabel = Instance.new("TextLabel")

ScreenGui.Name = "LogMacroUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

TextLabel.Parent = ScreenGui
TextLabel.Size = UDim2.new(0,220,0,40)

TextLabel.AnchorPoint = Vector2.new(1,0)
TextLabel.Position = UDim2.new(1,-20,0,20)

TextLabel.TextColor3 = Color3.new(1,1,1)
TextLabel.BackgroundColor3 = Color3.new(0,0,0)
TextLabel.BackgroundTransparency = 0.3
TextLabel.TextScaled = true
TextLabel.Font = Enum.Font.SourceSansBold
TextLabel.Visible = false

local messageID = 0

local function showMessage(text)

    messageID += 1
    local currentID = messageID

    TextLabel.Text = text
    TextLabel.Visible = true

    task.delay(1,function()

        if currentID == messageID then
            TextLabel.Visible = false
        end

    end)

end


local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local lastHealth = humanoid.Health
local macroEnabled = true

local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input,gp)

    if gp then return end

    if input.KeyCode == Config.PanicKey then
        game:Shutdown()
    end

    if input.KeyCode == Config.ToggleKey then

        macroEnabled = not macroEnabled

        if macroEnabled then
            showMessage("autoLog Enabled")
        else
            showMessage("autoLog Disabled")
        end

    end

end)


local function isPlayerWhitelisted()

    for _,plr in pairs(Players:GetPlayers()) do

        for _,id in pairs(PlayerWhitelist) do

            if plr.UserId == id then
                return true
            end

        end

    end

    return false

end


local function isWhitelistedPlayer(plr)

    for _,id in pairs(PlayerWhitelist) do
        if plr.UserId == id then
            return true
        end
    end

    return false

end


local function applyMovement(plr)

    if plr == player then return end

    local character = plr.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if not isWhitelistedPlayer(plr) then
        humanoid.WalkSpeed = 100
        humanoid.JumpPower = 100

        -- PLAY ALERT SOUND
        AlertSound:Play()
    end

end


humanoid.HealthChanged:Connect(function(newHealth)

    if not macroEnabled then
        lastHealth = newHealth
        return
    end

    if isPlayerWhitelisted() then
        lastHealth = newHealth
        return
    end

    if newHealth < lastHealth then
        game:Shutdown()
    end

    lastHealth = newHealth

end)


for _,plr in pairs(Players:GetPlayers()) do

    applyMovement(plr)

    plr.CharacterAdded:Connect(function()
        task.wait(1)
        applyMovement(plr)
    end)

end


Players.PlayerAdded:Connect(function(plr)

    plr.CharacterAdded:Connect(function()
        task.wait(1)
        applyMovement(plr)
    end)

end)


showMessage("autoLog Enabled")

end
