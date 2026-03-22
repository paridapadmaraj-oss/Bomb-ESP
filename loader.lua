--[[
    Dual Minigame Clicker
    - Popcorn Burst: built‑in auto‑clicker (toggle on/off)
    - Candy Bomb: loads your external script (press to run)
    Mode By @padmaraj1234
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ===== CONFIGURATION =====
local POPCORN_CLICK_DELAY = 0.05          -- seconds between clicks
local POPCORN_TARGET_NAMES = {
    "Popcorn", "popcorn", "Kernel", "kernel", "Corn", "corn", "Pop", "pop"
}
local CANDY_BOMB_SCRIPT_URL = "https://cdn.sourceb.in/bins/NW3k1TbMr6/0"
-- =========================

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MinigameClicker"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Top status bar
local StatusFrame = Instance.new("Frame")
StatusFrame.Size = UDim2.new(0, 280, 0, 90)
StatusFrame.Position = UDim2.new(0, 10, 0, 10)
StatusFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
StatusFrame.BackgroundTransparency = 0.4
StatusFrame.BorderSizePixel = 0
StatusFrame.Parent = ScreenGui

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.Position = UDim2.new(0, 0, 0, 5)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "MINIGAME CLICKER"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
TitleLabel.TextSize = 20
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = StatusFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 0, 0, 42)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Select a minigame below"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = StatusFrame

local CreditLabel = Instance.new("TextLabel")
CreditLabel.Size = UDim2.new(1, 0, 0, 20)
CreditLabel.Position = UDim2.new(0, 0, 0, 67)
CreditLabel.BackgroundTransparency = 1
CreditLabel.Text = "Mode By @padmaraj1234"
CreditLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CreditLabel.TextSize = 11
CreditLabel.Font = Enum.Font.Gotham
CreditLabel.Parent = StatusFrame

-- ================= BUTTONS =================
local function MakeButton(text, yPos, clickCallback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 55)
    btn.Position = UDim2.new(0.5, -100, 1, yPos)   -- centered horizontally, y from bottom
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BackgroundTransparency = 0.3
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 18
    btn.Font = Enum.Font.GothamBold
    btn.Parent = ScreenGui
    btn.MouseButton1Click:Connect(clickCallback)
    btn.TouchTap:Connect(clickCallback)
    return btn
end

-- ================= POPCORN BURST CLICKER =================
local popcornEnabled = false
local popcornRunning = false
local popcornClickQueue = {}
local popcornCurrentlyClicking = false

local function ClearPopcornQueue()
    popcornClickQueue = {}
    popcornCurrentlyClicking = false
end

local function ClickPopcornObject(obj)
    local detector = obj:FindFirstChild("ClickDetector")
    if detector then
        detector:FireClick(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
        return true
    end
    -- Try common remote events
    local remotes = {
        ReplicatedStorage:FindFirstChild("ClickPopcorn"),
        ReplicatedStorage:FindFirstChild("PopKernel"),
        ReplicatedStorage:FindFirstChild("Click"),
        ReplicatedStorage:FindFirstChild("Tap")
    }
    for _, remote in ipairs(remotes) do
        if remote and remote:IsA("RemoteEvent") then
            remote:FireServer(obj)
            return true
        end
    end
    return false
end

local function FindPopcornObjects()
    local objects = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            for _, name in ipairs(POPCORN_TARGET_NAMES) do
                if obj.Name:find(name) then
                    table.insert(objects, obj)
                    break
                end
            end
        end
    end
    return objects
end

local function ProcessPopcornQueue()
    if not popcornEnabled or #popcornClickQueue == 0 then
        popcornCurrentlyClicking = false
        return
    end
    popcornCurrentlyClicking = true
    local obj = popcornClickQueue[1]
    table.remove(popcornClickQueue, 1)
    ClickPopcornObject(obj)
    task.wait(POPCORN_CLICK_DELAY)
    ProcessPopcornQueue()
end

local function PopcornLoop()
    while popcornRunning do
        if popcornEnabled then
            local objects = FindPopcornObjects()
            for _, obj in ipairs(objects) do
                local alreadyQueued = false
                for _, q in ipairs(popcornClickQueue) do
                    if q == obj then
                        alreadyQueued = true
                        break
                    end
                end
                if not alreadyQueued then
                    table.insert(popcornClickQueue, obj)
                end
            end
            if not popcornCurrentlyClicking and #popcornClickQueue > 0 then
                ProcessPopcornQueue()
            end
        end
        task.wait(0.2)
    end
end

local function StartPopcornClicker()
    if popcornRunning then return end
    popcornRunning = true
    spawn(PopcornLoop)
end

local function StopPopcornClicker()
    popcornRunning = false
    popcornEnabled = false
    ClearPopcornQueue()
end

local function TogglePopcorn()
    popcornEnabled = not popcornEnabled
    if popcornEnabled then
        if not popcornRunning then StartPopcornClicker() end
        StatusLabel.Text = "Popcorn Burst: ON"
        popcornButton.Text = "Popcorn Burst: ON"
        popcornButton.TextColor3 = Color3.fromRGB(100, 255, 100)
        popcornButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    else
        StatusLabel.Text = "Popcorn Burst: OFF"
        popcornButton.Text = "Popcorn Burst: OFF"
        popcornButton.TextColor3 = Color3.fromRGB(255, 100, 100)
        popcornButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    end
end

-- ================= CANDY BOMB SCRIPT =================
local candyBombLoaded = false

local function LoadCandyBomb()
    if candyBombLoaded then
        StatusLabel.Text = "Candy Bomb already loaded"
        return
    end
    local success, err = pcall(function()
        loadstring(game:HttpGet(CANDY_BOMB_SCRIPT_URL))()
    end)
    if success then
        candyBombLoaded = true
        StatusLabel.Text = "Candy Bomb script loaded"
        candyButton.Text = "Candy Bomb: LOADED"
        candyButton.TextColor3 = Color3.fromRGB(100, 255, 100)
        candyButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    else
        StatusLabel.Text = "Failed to load Candy Bomb: " .. tostring(err)
        warn("Candy Bomb load error: ", err)
    end
end

-- ================= CREATE BUTTONS =================
local popcornButton = MakeButton("Popcorn Burst: OFF", -65, TogglePopcorn)
local candyButton = MakeButton("Candy Bomb: LOAD", -130, LoadCandyBomb)

-- Initialise popcorn clicker (idle)
StartPopcornClicker()
