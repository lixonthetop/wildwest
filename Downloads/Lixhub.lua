-- Lixhub for Roblox Wild West
-- Version: 1.1 Beta
-- Auteur: Lix

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

-- Player
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Configuration des options (ce sont ces variables qui contrôlent les features)
local Settings = {
    Aimbot = false,
    AimbotKey = Enum.KeyCode.Q,
    EspPlayers = false,
    EspAnimals = false,
    EspOres = false,
    Fullbright = false,
    InfiniteStamina = false,
    MenuKey = Enum.KeyCode.RightControl -- Touche pour ouvrir/fermer le menu
}

local CurrentTarget = nil
local EspObjects = {}

-- === INTERFACE GRAPHIQUE (GUI) ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LixhubGUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -200)
MainFrame.Size = UDim2.new(0, 420, 0, 450)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true -- Permet de déplacer la fenêtre

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1.000
Title.Position = UDim2.new(0, 0, 0, 10)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Font = Enum.Font.GothamBold
Title.Text = "Lixhub - Wild West"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22.000

-- Fonction pour créer un bouton toggle (ON/OFF)
local function createToggle(text, yPos, settingName)
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Parent = MainFrame
    ToggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Position = UDim2.new(0, 20, 0, yPos)
    ToggleButton.Size = UDim2.new(0, 380, 0, 40)
    ToggleButton.Font = Enum.Font.Gotham
    ToggleButton.Text = text
    ToggleButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToggleButton.TextSize = 16.000
    ToggleButton.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Padding pour le texte
    local TextPadding = Instance.new("UIPadding")
    TextPadding.PaddingLeft = UDim.new(0, 15)
    TextPadding.Parent = ToggleButton

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = ToggleButton

    -- Indicateur ON/OFF
    local Indicator = Instance.new("Frame")
    Indicator.Name = "Indicator"
    Indicator.Parent = ToggleButton
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    Indicator.BorderSizePixel = 0
    Indicator.Position = UDim2.new(1, -50, 0.5, -10)
    Indicator.Size = UDim2.new(0, 30, 0, 20)
    
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(0, 10)
    IndicatorCorner.Parent = Indicator

    -- Fonction pour mettre à jour l'état du bouton
    local function updateButton()
        if Settings[settingName] then
            TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 255, 50)}):Play()
        else
            TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}):Play()
        end
    end

    -- Logique du clic
    ToggleButton.MouseButton1Click:Connect(function()
        Settings[settingName] = not Settings[settingName]
        updateButton()
    end)

    updateButton() -- Mettre à jour l'état initial
end

-- Création de tous les boutons dans le menu
createToggle("Aimbot (Appuyer sur Q pour viser)", 60, "Aimbot")
createToggle("ESP Joueurs", 110, "EspPlayers")
createToggle("ESP Animaux", 160, "EspAnimals")
createToggle("ESP Minerais", 210, "EspOres")
createToggle("Fullbright", 260, "Fullbright")
createToggle("Stamina Infinie (Cheval)", 310, "InfiniteStamina")


-- === LOGIQUE DES FONCTIONNALITÉS ===

-- Fonction pour obtenir le HumanoidRootPart
local function getRootPart(character)
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
end

-- Fonction pour vérifier la visibilité (si la cible n'est pas derrière un mur)
local function isVisible(target)
    local origin = Camera.CFrame.Position
    local direction = (target.Position - origin).Unit
    local ray = Ray.new(origin, direction * (target.Position - origin).Magnitude)
    local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    return hit == nil or hit:IsDescendantOf(target.Parent)
end

-- Boucle principale qui s'exécute à chaque image
RunService.Heartbeat:Connect(function()
    -- Nettoyer les anciens objets ESP
    for _, obj in pairs(EspObjects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    EspObjects = {}

    -- --- AIMBOT ---
    if Settings.Aimbot and UserInputService:IsKeyDown(Settings.AimbotKey) then
        local closestPlayer = nil
        local shortestDistance = math.huge

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and getRootPart(player.Character) and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
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

    -- --- ESP JOUEURS ---
    if Settings.EspPlayers then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and getRootPart(player.Character) and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local rootPart = getRootPart(player.Character)
                local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                
                if onScreen then
                    local box = Drawing.new("Square")
                    box.Size = Vector2.new(2000 / pos.Z, 2500 / pos.Z)
                    box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y / 2)
                    box.Color = Color3.fromRGB(255, 0, 0)
                    box.Thickness = 2
                    box.Transparency = 1
                    box.Visible = true
                    table.insert(EspObjects, box)
                end
            end
        end
    end

    -- --- ESP ANIMAUX ---
    if Settings.EspAnimals then
        for _, animal in pairs(Workspace.WORKSPACE_Interactables.Animals:GetChildren()) do
            if animal:FindFirstChild("HumanoidRootPart") then
                local rootPart
