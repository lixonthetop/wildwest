-- ===================================
-- PARTIE 1 : SERVICES ET VARIABLES INITIALES
-- ===================================

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

-- Player
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Feature state (Variables globales pour activer/désactiver)
local silentAimActive = false
local espActive = false
local espList = {}
-- ===================================
-- PARTIE 2 : CRÉATION DE L'INTERFACE GRAPHIQUE (GUI)
-- ===================================

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Lixhub"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
-- Protection contre la suppression par Roblox
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
MainFrame.Size = UDim2.new(0, 600, 0, 500)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.Position = UDim2.new(0, 0, 0, 0)

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopBar

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(0, 100, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "Lixhub"
Title.TextColor3 = Color3.fromRGB(255, 85, 0)
Title.TextSize = 20.000
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TopBar
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -45, 0.5, -12)
CloseButton.Size = UDim2.new(0, 35, 0, 25)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14.000

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- Tab Buttons Container
local TabButtons = Instance.new("Frame")
TabButtons.Name = "TabButtons"
TabButtons.Parent = MainFrame
TabButtons.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TabButtons.BorderSizePixel = 0
TabButtons.Position = UDim2.new(0, 0, 0, 40)
TabButtons.Size = UDim2.new(0, 150, 1, -40)

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 12)
TabCorner.Parent = TabButtons

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Padding = UDim.new(0, 5)
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Parent = TabButtons

-- Pages Container
local Pages = Instance.new("Frame")
Pages.Name = "Pages"
Pages.Parent = MainFrame
Pages.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Pages.BorderSizePixel = 0
Pages.Position = UDim2.new(0, 160, 0, 50)
Pages.Size = UDim2.new(1, -170, 1, -60)

local PagesCorner = Instance.new("UICorner")
PagesCorner.CornerRadius = UDim.new(0, 8)
PagesCorner.Parent = Pages
-- ===================================
-- PARTIE 3 : FONCTIONS DE CRÉATION D'ÉLÉMENTS GUI
-- ===================================

-- Page Creation
local function createPage(pageName)
    local page = Instance.new("ScrollingFrame")
    page.Name = pageName
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 8
    page.Parent = Pages

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Padding = UDim.new(0, 10)
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Parent = page

    pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 20)
    end)

    return page
end

-- Tab Button Creation
local function createTabButton(text, page, layoutOrder)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 35)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.TextColor3 = Color3.fromRGB(200, 200, 200)
    button.TextSize = 16.000
    button.LayoutOrder = layoutOrder
    button.Parent = TabButtons

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button

    button.MouseButton1Click:Connect(function()
        -- Hide all pages and reset button colors
        for _, p in pairs(Pages:GetChildren()) do
            if p:IsA("ScrollingFrame") then
                p.Visible = false
            end
        end
        for _, b in pairs(TabButtons:GetChildren()) do
            if b:IsA("TextButton") then
                b.TextColor3 = Color3.fromRGB(200, 200, 200)
                b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            end
        end
        -- Show selected page and highlight button
        page.Visible = true
        button.TextColor3 = Color3.fromRGB(255, 85, 0)
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end)

    return button
end

-- Toggle Creation
local function createToggle(text, yPos, stateVariable, page)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = "ToggleFrame"
    ToggleFrame.Parent = page
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Position = UDim2.new(0, 10, 0, yPos)
    ToggleFrame.Size = UDim2.new(1, -20, 0, 30)
    ToggleFrame.LayoutOrder = yPos

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleFrame

    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Name = "ToggleLabel"
    ToggleLabel.Parent = ToggleFrame
    ToggleLabel.BackgroundTransparency = 1.000
    ToggleLabel.Position = UDim2.new(0, 40, 0, 0)
    ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.Text = text
    ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToggleLabel.TextSize = 14.000
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = ToggleFrame
    ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Position = UDim2.new(0, 10, 0.5, -8)
    ToggleButton.Size = UDim2.new(0, 25, 0, 16)
    ToggleButton.Font = Enum.Font.SourceSans
    ToggleButton.Text = ""
    ToggleButton.TextSize = 14.000

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = ToggleButton

    -- Logic
    -- On initialise la variable de l'état du toggle à partir de la variable globale
    local toggled = stateVariable[1]
    ToggleButton.BackgroundColor3 = toggled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)

    ToggleButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        stateVariable[1] = toggled -- Met à jour la variable globale
        TweenService:Create(ToggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
            BackgroundColor3 = toggled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
        }):Play()
    end)
end
-- ===================================
-- PARTIE 4 : CRÉATION DES PAGES ET DES FONCTIONNALITÉS
-- ===================================

-- Page Combat
local combatPage = createPage("Combat")
createTabButton("Combat", combatPage, 1)
-- Toggle Silent Aim
createToggle("Silent Aim", 10, {silentAimActive}, combatPage)

-- Page Visuals
local visualsPage = createPage("Visuals")
createTabButton("Visuals", visualsPage, 2)
-- Toggle ESP
createToggle("ESP", 10, {espActive}, visualsPage)

-- Page Discord
local discordPage = createPage("Discord")
createTabButton("Discord", discordPage, 3)

local DiscordButton = Instance.new("TextButton")
DiscordButton.Parent = discordPage
DiscordButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
DiscordButton.BorderSizePixel = 0
DiscordButton.Position = UDim2.new(0, 10, 0, 10)
DiscordButton.Size = UDim2.new(1, -20, 0, 40)
DiscordButton.Font = Enum.Font.Gotham
DiscordButton.Text = "Copier le lien Discord"
DiscordButton.TextColor3 = Color3.fromRGB(200, 200, 200)
DiscordButton.TextSize = 16.000

local DiscordCorner = Instance.new("UICorner")
DiscordCorner.CornerRadius = UDim.new(0, 6)
DiscordCorner.Parent = DiscordButton

DiscordButton.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/votrediscord")
    DiscordButton.Text = "Lien copié !"
    task.wait(1)
    DiscordButton.Text = "Copier le lien Discord"
end)

-- ===================================
-- LOGIQUE DES FONCTIONS (Silent Aim & ESP)
-- ===================================

-- Nearest Head
local function getNearestHead()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    local closest = nil
    local shortest = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local dist = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortest then
                shortest = dist
                closest = player
            end
        end
    end
    if closest and closest.Character and closest.Character:FindFirstChild("Head") then
        return closest.Character.Head
    end
    return nil
end

-- Silent Aim
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- Ne fait rien si le jeu gère déjà l'input (ex: chat)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and silentAimActive then
        local target = getNearestHead()
        if target then
            -- Change la caméra pour viser la tête
            local originalCFrame = Camera.CFrame
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            -- Tire via le remote
            local event = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Attack")
            if event then
                event:FireServer()
            end
            -- Remet la caméra à sa place d'origine pour une transition fluide
            Camera.CFrame = originalCFrame
        end
    end
end)

-- Setup ESP
local function createESP(player)
    if player == LocalPlayer then return end
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = Color3.fromRGB(0, 255, 0)
    box.Transparency = 1
    box.Filled = false
    box.Visible = false
    espList[player] = { drawing = box }

    -- Clean up if player leaves
    player.AncestryChanged:Connect(function()
        if not player:IsDescendantOf(game) and espList[player] then
            espList[player].drawing:Remove()
            espList[player] = nil
        end
    end)
end

-- Add ESP to all players
for _, player in pairs(Players:GetPlayers()) do
    createESP(player)
end

-- Player joins
Players.PlayerAdded:Connect(function(player)
    createESP(player)
end)

-- Player leaves
Players.PlayerRemoving:Connect(function(player)
    if espList[player] then
        espList[player].drawing:Remove()
        espList[player] = nil
    end
end)

-- Main ESP Loop
RunService.Heartbeat:Connect(function() -- Heartbeat est plus performant que RenderStepped pour des dessins
    for player, data in pairs(espList) do
        local box = data.drawing
        if espActive and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local root = player.Character.HumanoidRootPart
            local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            if onScreen then
                local distance = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                local size = 3000 / distance -- Ajuste la taille de la boîte en fonction de la distance
                
                box.Size = Vector2.new(size, size * 1.8) -- Largeur et Hauteur
                box.Position = Vector2.new(rootPos.X - size / 2, rootPos.Y - size * 0.9)
                box.Visible = true
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end
end)
-- ===================================
-- PARTIE 5 : CONTRÔLES DE L'INTERFACE ET INITIALISATION
-- ===================================

-- Ouvrir/Fermer le menu avec la touche Insert
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Fermer avec le bouton X
CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Afficher la première page (Combat) au démarrage
-- On simule un clic sur le premier bouton d'onglet pour que la logique de changement de page s'applique
for _, button in pairs(TabButtons:GetChildren()) do
    if button:IsA("TextButton") and button.LayoutOrder == 1 then
        button.MouseButton1Click:Fire()
        break
    end
end

print("Lixhub GUI loaded with Silent Aim and ESP.")
