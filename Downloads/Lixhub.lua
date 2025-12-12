local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ===================================
-- Tableau des Paramètres (Settings)
-- C'est ici que toutes les options sont stockées.
-- ===================================
local Settings = {
    AimbotEnabled = false,
    AimbotKey = Enum.UserInputType.MouseButton2, -- Clic droit pour viser
    AimStrength = 0.15, -- Puissance de l'aimbot (0.1 = lent, 1 = instantané)
    VisibleCheck = true, -- Vérifie si la cible est visible (pas derrière un mur)

    -- Options ESP (Extra Sensory Perception)
    EspBox = false, -- Boîte autour des joueurs
    EspName = false, -- Nom des joueurs
    EspDistance = false, -- Distance des joueurs
    EspHighlight = false, -- Surligne les joueurs
    AnimalEsp = false, -- ESP pour les animaux
    LegendaryAnimalEsp = false, -- ESP pour les animaux légendaires
    OreEsp = false, -- ESP pour les minerais

    BoxColor = Color3.fromRGB(255, 0, 0), -- Couleur des boîtes ESP

    -- Autres options
    Fullbright = false, -- Rend le jeu entièrement lumineux
    HorseStamina = false, -- Stamina infinie pour le cheval
    HitboxExtendAnimal = false, -- Agrandit la hitbox des animaux

    -- Interface
    MenuKey = Enum.KeyCode.Insert, -- Touche pour ouvrir/fermer le menu
    FovSize = 150, -- Taille du FOV (Field of View) pour l'aimbot
    Transparency = 0.5, -- Transparence du menu
}

-- ===================================
-- Cache des objets (pour optimiser les performances)
-- ===================================
local PlayerCache = {}
local AnimalCache = {}
local LegendaryAnimalCache = {}
local OreCache = {}
local HitboxCache = {}

-- ===================================
-- Interface Graphique (GUI)
-- ===================================
-- Crée le ScreenGui principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LixhubGUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

-- Crée la fenêtre principale du menu
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -375, 0.5, -240)
MainFrame.Size = UDim2.new(0, 750, 0, 500)
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true

-- Arrondit les coins de la fenêtre
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 6)
MainCorner.Parent = MainFrame

-- Crée la barre latérale
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 180, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Sidebar.Parent = MainFrame
local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 6)
SidebarCorner.Parent = Sidebar

-- Titre du menu
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -20, 0, 50)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "Lixhub"
Title.TextColor3 = Color3.fromRGB(255, 85, 0)
Title.TextSize = 28
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Sidebar

-- Conteneur pour les boutons de navigation
local NavigationLayout = Instance.new("UIListLayout")
NavigationLayout.Padding = UDim.new(0, 5)
NavigationLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavigationLayout.Parent = Sidebar

-- Conteneur pour les pages de contenu
local PagesContainer = Instance.new("Frame")
PagesContainer.Name = "PagesContainer"
PagesContainer.Size = UDim2.new(1, -190, 1, -20)
PagesContainer.Position = UDim2.new(0, 190, 0, 10)
PagesContainer.BackgroundTransparency = 1
PagesContainer.Parent = MainFrame

-- Tableau pour stocker les pages et les boutons
local Pages = {}
local NavigationButtons = {}

-- Fonction pour créer une page de contenu
local function createPage(pageName)
    local page = Instance.new("ScrollingFrame")
    page.Name = pageName
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 8
    page.Parent = PagesContainer

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Padding = UDim.new(0, 8)
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Parent = page

    return page
end

-- Fonction pour créer un bouton de navigation
local function createNavigationButton(text, icon, layoutOrder)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.Gotham
    button.Text = "  " .. icon .. "  " .. text
    button.TextColor3 = Color3.fromRGB(200, 200, 200)
    button.TextSize = 16
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.LayoutOrder = layoutOrder
    button.Parent = Sidebar

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = button

    return button
end

-- Fonction pour basculer entre les pages
local function switchToPage(pageToShow)
    for _, page in pairs(Pages) do
        page.Visible = false
    end
    for _, button in pairs(NavigationButtons) do
        button.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
    pageToShow.Visible = true
end

-- Création des pages et des boutons
do
    -- Page Combat
    local combatPage = createPage("Combat")
    local combatButton = createNavigationButton("Combat", "⚔️", 1)
    combatButton.MouseButton1Click:Connect(function() switchToPage(combatPage) end)
    Pages["Combat"] = combatPage
    NavigationButtons["Combat"] = combatButton

    -- Page Visuals
    local visualsPage = createPage("Visuals")
    local visualsButton = createNavigationButton("Visuels", "👁️", 2)
    visualsButton.MouseButton1Click:Connect(function() switchToPage(visualsPage) end)
    Pages["Visuals"] = visualsPage
    NavigationButtons["Visuals"] = visualsButton

    -- Page World
    local worldPage = createPage("World")
    local worldButton = createNavigationButton("Monde", "🌍", 3)
    worldButton.MouseButton1Click:Connect(function() switchToPage(worldPage) end)
    Pages["World"] = world
