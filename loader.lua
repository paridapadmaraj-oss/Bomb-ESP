--[[
    Bomb ESP for Escape Tsunami (Brainrots)
    Mobile-Friendly: On-screen toggle button
    Detects: Pink, Blue, Deep Blue bombs
    Mode By @padmaraj1234
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Settings
local ESPEnabled = true

-- Bomb colors to detect (pink, blue, deep blue)
local BombColorsToDetect = {
    Color3.fromRGB(255, 192, 203), -- Pink
    Color3.fromRGB(0, 0, 255),     -- Blue
    Color3.fromRGB(0, 0, 139)      -- Deep Blue
}

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BombESP"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main status frame (top-left)
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

-- Mode By @padmaraj1234 text
local CreditLabel = Instance.new("TextLabel")
CreditLabel.Size = UDim2.new(1, 0, 0, 20)
CreditLabel.Position = UDim2.new(0, 0, 0, 67)
CreditLabel.BackgroundTransparency = 1
CreditLabel.Text = "Mode By @padmaraj1234"
CreditLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CreditLabel.TextSize = 11
CreditLabel.Font = Enum.Font.Gotham
CreditLabel.Parent = StatusFrame

-- Bomb counter (top-right)
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

-- Toggle button (touch-friendly)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 120, 0, 45)
ToggleButton.Position = UDim2.new(0, 10, 1, -55)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.BackgroundTransparency = 0.3
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "ESP OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
ToggleButton.TextSize = 18
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ScreenGui

-- Function to update UI based on ESP state
local function UpdateUI()
    if ESPEnabled then
        TitleLabel.Text = "CANDY ESP [ON]"
        TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        ToggleButton.Text = "ESP ON"
        ToggleButton.TextColor3 = Color3.fromRGB(100, 255, 100)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    else
        TitleLabel.Text = "CANDY ESP [OFF]"
        TitleLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.Text = "ESP OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    end
end

-- Toggle function
local function ToggleESP()
    ESPEnabled = not ESPEnabled
    UpdateUI()
end

-- Button click/tap
ToggleButton.MouseButton1Click:Connect(ToggleESP)

-- For mobile touch (fallback)
ToggleButton.TouchTap:Connect(ToggleESP)

-- Color matching function
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

-- Find bombs in workspace
local function FindBombs()
    local bombs = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            if v.Name:lower():find("bomb") or v.Name:lower():find("mine") or v.Name:lower():find("explosive") then
                table.insert(bombs, v)
            elseif v.BrickColor and IsBombColor(v.BrickColor.Color) then
                table.insert(bombs, v)
            elseif v.Color and IsBombColor(v.Color) then
                table.insert(bombs, v)
            end
        end
    end
    return bombs
end

-- ESP management
local espObjects = {}

local function ClearESP()
    for _, obj in ipairs(espObjects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    espObjects = {}
end

local function UpdateESP()
    ClearESP()
    if not ESPEnabled then
        BombCounter.Text = "BOMBS: 0"
        return
    end

    local bombs = FindBombs()
    BombCounter.Text = "BOMBS: " .. #bombs

    for _, bomb in ipairs(bombs) do
        -- Highlight
        local highlight = Instance.new("Highlight")
        highlight.Parent = bomb
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0.3
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        table.insert(espObjects, highlight)

        -- Billboard text
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

-- Update loop (every 0.5 sec)
spawn(function()
    while true do
        UpdateESP()
        wait(0.5)
    end
end)

-- Initial setup
UpdateUI()
print("✅ Bomb ESP Loaded for Escape Tsunami (Mobile)")
print("👤 Mode By @padmaraj1234")
print("🔘 Tap the button on screen to toggle ON/OFF")
