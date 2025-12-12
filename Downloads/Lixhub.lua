-- Lixhub for Roblox Wild West
-- Version: 1.0
-- Auteur: Lix

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- Player
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Variables
local AimbotEnabled = false
local EspEnabled = false
local AnimalEspEnabled = false
local OreEspEnabled = false
local FullbrightEnabled = false
local InfiniteStaminaEnabled = false

local AimbotKey = Enum.KeyCode.Q
local MenuKey = Enum.KeyCode.RightControl

local CurrentTarget = nil
local EspObjects = {}

-- Fonction pour créer l'interface
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LixhubGUI"
ScreenGui.Parent = game:GetService("CoreGui") -- Pour que ça reste même si le script est rechargé
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Visible = false

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1.000
Title.Position = UDim2.new(0, 0, 0, 10)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "Lixhub - Wild West"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20.000

-- Fonction pour créer un bouton toggle
local function createToggle(text, yPos, configVar)
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Parent = MainFrame
    ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Position = UDim2.new(0, 20, 0, yPos)
    ToggleButton.Size = UDim2.new(0, 150, 0, 30)
    ToggleButton.Font = Enum.Font.Gotham
    ToggleButton.Text = text .. ": OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 14.000
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 5)
    UICorner.Parent = ToggleButton

    ToggleButton.MouseButton1Click:Connect(function()
        configVar.value = not configVar.value
        ToggleButton.Text = text .. ": " .. (configVar.value and "ON" or "OFF")
        ToggleButton.BackgroundColor3 = configVar.value and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
    end)
end

-- Création des boutons
createToggle("Aimbot (Q)", 60, { value = AimbotEnabled })
createToggle("ESP Players", 100, { value = EspEnabled })
createToggle("ESP Animals", 140, { value = AnimalEspEnabled })
createToggle("ESP Ores", 180, { value = OreEspEnabled })
createToggle("Fullbright", 220, { value = FullbrightEnabled })
createToggle("Infinite Stamina", 260, { value = InfiniteStaminaEnabled })

-- Mettre à jour les variables depuis les boutons
local function updateConfigVars()
    AimbotEnabled = MainFrame:FindFirstChild("Aimbot (Q): OFF") and MainFrame:FindFirstChild("Aimbot (Q): OFF").Text == "Aimbot (Q): ON" or false
    EspEnabled = MainFrame:FindFirstChild("ESP Players: OFF") and MainFrame:FindFirstChild("ESP Players: OFF").Text == "ESP Players: ON" or false
    AnimalEspEnabled = MainFrame:FindFirstChild("ESP Animals: OFF") and MainFrame:FindFirstChild("ESP Animals: OFF").Text == "ESP Animals: ON" or false
    OreEspEnabled = MainFrame:FindFirstChild("ESP Ores: OFF") and MainFrame:FindFirstChild("ESP Ores: OFF").Text == "ESP Ores: ON" or false
    FullbrightEnabled = MainFrame:FindFirstChild("Fullbright: OFF") and MainFrame:FindFirstChild("Fullbright: OFF").Text == "Fullbright: ON" or false
    InfiniteStaminaEnabled = MainFrame:FindFirstChild("Infinite Stamina: OFF") and MainFrame:FindFirstChild("Infinite Stamina: OFF").Text == "Infinite Stamina: ON" or false
end

-- Fonction pour obtenir le HumanoidRootPart
local function getRootPart(character)
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
end

-- Fonction pour vérifier la visibilité
local function isVisible(target)
    local origin = Camera.CFrame.Position
    local direction = (target.Position - origin).Unit
    local ray = Ray.new(origin, direction * (target.Position - origin).Magnitude)
    local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    return hit == nil or hit:IsDescendantOf(target.Parent)
end

-- Boucle principale
RunService.RenderStepped:Connect(function()
    updateConfigVars()

    -- Aimbot
    if AimbotEnabled and UserInputService:IsKeyDown(AimbotKey) then
        local closestPlayer = nil
        local shortestDistance = math.huge

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and getRootPart(player.Character) then
                local rootPart = getRootPart(player.Character)
                local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
                if distance < shortestDistance and isVisible(rootPart) then
                    shortestDistance = distance
                    closestPlayer = rootPart
                end
            end
        end

        if closestPlayer then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Position)
        end
    end

    -- Nettoyer les anciens ESP
    for _, obj in pairs(EspObjects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    EspObjects = {}

    -- ESP Joueurs
    if EspEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and getRootPart(player.Character) then
                local rootPart = getRootPart(player.Character)
                local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                
                if onScreen then
                    local box = Instance.new("Frame")
                    box.Size = UDim2.new(0, 4, 0, 4)
                    box.Position = UDim2.new(0, pos.X, 0, pos.Y)
                    box.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    box.BorderSizePixel = 0
                    box.Parent = ScreenGui
                    table.insert(EspObjects, box)
                end
            end
        end
    end
