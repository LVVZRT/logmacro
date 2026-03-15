return function(Config)

-- PLAYER WHITELIST (PUT ROBLOX IDS HERE)
local PlayerWhitelist = {
    523539850,
    1,
    2
}

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ALERT SOUND
local AlertSound = Instance.new("Sound")
AlertSound.SoundId = "rbxassetid://102770722936174"
AlertSound.Volume = 1
AlertSound.Parent = game:GetService("SoundService")

-- CHECK IF PLAYER IS WHITELISTED
local function isWhitelisted(plr)

    for _,id in pairs(PlayerWhitelist) do
        if plr.UserId == id then
            return true
        end
    end

    return false

end

-- APPLY FLY TO NON WHITELISTED PLAYERS
local function applyFly(plr)

    if plr == player then return end

    local function apply(character)

        if isWhitelisted(plr) then return end

        local root = character:WaitForChild("HumanoidRootPart")

        AlertSound:Play()

        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(999999,999999,999999)
        bv.Velocity = Vector3.new(0,150,0)
        bv.Parent = root

        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(999999,999999,999999)
        bg.CFrame = root.CFrame
        bg.Parent = root

    end

    if plr.Character then
        apply(plr.Character)
    end

    plr.CharacterAdded:Connect(apply)

end

-- FIRST THING SCRIPT DOES
for _,plr in pairs(Players:GetPlayers()) do
    applyFly(plr)
end

Players.PlayerAdded:Connect(function(plr)
    applyFly(plr)
end)

-- ORIGINAL SCRIPT BELOW

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

showMessage("autoLog Enabled")

end
