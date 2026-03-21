--[[
    Bomb ESP for Escape Tsunami (Brainrots)
    Toggle: Press [T] to turn ON/OFF
    Detects: Pink, Blue, Deep Blue bombs
    Mode By @padmaraj1234
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Settings
local ESPEnabled = true
local BombColor = Color3.fromRGB(255, 0, 0) -- Red outline

-- Bomb colors to detect (pink, blue, deep blue)
local BombColorsToDetect = {
    Color3.fromRGB(255, 192, 203), -- Pink
    Color3.fromRGB(0, 0, 255),     -- Blue
    Color3.fromRGB(0, 0, 139)      -- Deep Blue
}

-- Create GUI for ESP status
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BombESP"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main status frame (like your reference image)
local StatusFrame = Instance.new("Frame")
StatusFrame.Size = UDim2.new(0, 280, 0, 90)
StatusFrame.Position = UDim2.new(0, 10, 0, 10)
StatusFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
StatusFrame.BackgroundTransparency = 0.4
StatusFrame.BorderSizePixel = 0
StatusFrame.Parent = ScreenGui

-- CANDY ESP [ON] text
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.Position = UDim2.new(0, 0, 0, 5)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "CANDY ESP [ON]"
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
TitleLabel.TextSize = 20
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = StatusFrame

-- Status Enabled text
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 0, 0, 42)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status Enabled /"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = StatusFrame

-- Mode By @padmaraj1234 text (UPDATED)
local CreditLabel = Instance.new("TextLabel")
CreditLabel.Size = UDim2.new(1, 0, 0, 20)
CreditLabel.Position = UDim2.new(0, 0, 0, 67)
CreditLabel.BackgroundTransparency = 1
CreditLabel.Text = "Mode By @padmaraj1234"
CreditLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CreditLabel.TextSize = 11
CreditLabel.Font = Enum.Font.Gotham
CreditLabel.Parent = StatusFrame

-- Toggle hint
local ToggleHint = Instance.new("TextLabel")
ToggleHint.Size = UDim2.new(0, 200, 0, 20)
ToggleHint.Position = UDim2.new(0, 10, 1, -35)
ToggleHint.BackgroundTransparency = 1
ToggleHint.Text = "Press [T] to toggle ON/OFF"
ToggleHint.TextColor3 = Color3.fromRGB(100, 255, 100)
ToggleHint.TextSize = 12
ToggleHint.Font = Enum.Font.Gotham
ToggleHint.Parent = ScreenGui

-- Bomb counter
local BombCounter = Instance.new("TextLabel")
BombCounter.Size = UDim2.new(0, 120, 0, 30)
BombCounter.Position = UDim2.new(1, -130, 0, 15)
BombCounter.BackgroundTransparency = 1
BombCounter.Text = "BOMBS: 0"
BombCounter.TextColor3 = Color3.fromRGB(255, 255, 0)
BombCounter.TextSize = 16
BombCounter.Font = Enum.Font.GothamBold
BombCounter.TextXAlignment = Enum.TextXAlignment.Right
BombCounter.Parent = ScreenGui

-- Update status text function
local function UpdateStatus()
    if ESPEnabled then
        TitleLabel.Text = "CANDY ESP [ON]"
        TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        ToggleHint.Text = "Press [T] to toggle OFF"
        ToggleHint.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        TitleLabel.Text = "CANDY ESP [OFF]"
        TitleLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        ToggleHint.Text = "Press [T] to toggle ON"
        ToggleHint.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

-- Toggle on 'T' key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.T then
        ESPEnabled = not ESPEnabled
        UpdateStatus()
    end
end)

-- Function to check if color matches bomb colors
local function IsBombColor(color)
    for _, bombColor in ipairs(BombColorsToDetect) do
        local rDiff = (color.R - bombColor.R) ^ 2
        local gDiff = (color.G - bombColor.G) ^ 2
        local bDiff = (color.B - bombColor.B) ^ 2
        if rDiff + gDiff + bDiff < 0.05 then
            return true
        end
    end
    return false
end

-- Find all bombs in the game
local function FindBombs()
    local bombs = {}
    local checkParts = workspace:GetDescendants()
    
    for _, v in ipairs(checkParts) do
        if v:IsA("BasePart") then
            -- Check by name
            if v.Name:lower():find("bomb") or v.Name:lower():find("mine") or v.Name:lower():find("explosive") then
                table.insert(bombs, v)
            -- Check by color
            elseif v.BrickColor and IsBombColor(v.BrickColor.Color) then
                table.insert(bombs, v)
            elseif v.Color and IsBombColor(v.Color) then
                table.insert(bombs, v)
            end
        end
    end
    return bombs
end

-- Store ESP objects
local espObjects = {}
local currentBombCount = 0

-- Clear all ESP highlights
local function ClearESP()
    for _, obj in ipairs(espObjects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    espObjects = {}
end

-- Update ESP highlights
local function UpdateESP()
    ClearESP()
    
    if not ESPEnabled then
        BombCounter.Text = "BOMBS: 0"
        return
    end
    
    local bombs = FindBombs()
    currentBombCount = #bombs
    BombCounter.Text = "BOMBS: " .. currentBombCount
    
    for _, bomb in ipairs(bombs) do
        -- Create highlight effect
        local highlight = Instance.new("Highlight")
        highlight.Parent = bomb
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0.3
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        table.insert(espObjects, highlight)
        
        -- Add BillboardGui with text
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 80, 0, 25)
        billboard.Adornee = bomb
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.Parent = bomb
        
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = "💣 BOMB"
        text.TextColor3 = Color3.fromRGB(255, 0, 0)
        text.TextStrokeTransparency = 0
        text.TextSize = 14
        text.Font = Enum.Font.GothamBold
        text.Parent = billboard
        
        table.insert(espObjects, billboard)
    end
end

-- Update ESP every 0.5 seconds (good balance of performance and accuracy)
spawn(function()
    while true do
        UpdateESP()
        wait(0.5)
    end
end)

-- Initial status update
UpdateStatus()
print("✅ Bomb ESP Loaded for Escape Tsunami!")
print("💣 Press [T] to toggle ESP ON/OFF")
print("👤 Mode By @padmaraj1234")
