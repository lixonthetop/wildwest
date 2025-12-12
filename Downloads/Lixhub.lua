local LixHub = {}
LixHub.__index = LixHub

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variables
local ESP_Objects = {}
local Aimbot_Toggled = false
local Aimbot_Target = nil
local Aimbot_Key = Enum.KeyCode.Q -- Touche pour verrouiller/déverrouiller la cible
local Locked_Target = nil

-- Fonction pour créer l'interface graphique
function LixHub:CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LixHubGUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    MainFrame.Size = UDim2.new(0, 500, 0, 400)
    MainFrame.Visible = false
    MainFrame.Active = true
    MainFrame.Draggable = true

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Title.BorderSizePixel = 0
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Lix Hub"
    Title.TextColor3 = Color3.fromRGB(100, 200, 255)
    Title.TextSize = 20.000

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = MainFrame
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(1, -50, 0, 5)
    CloseButton.Size = UDim2.new(0, 40, 0, 30)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 18.000

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 5)
    CloseCorner.Parent = CloseButton

    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Name = "ScrollingFrame"
    ScrollingFrame.Parent = MainFrame
    ScrollingFrame.Active = true
    ScrollingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.Position = UDim2.new(0, 10, 0, 50)
    ScrollingFrame.Size = UDim2.new(1, -20, 1, -60)
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollingFrame.ScrollBarThickness = 8
    
    local ScrollingCorner = Instance.new("UICorner")
    ScrollingCorner.CornerRadius = UDim.new(0, 5)
    ScrollingCorner.Parent = ScrollingFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = ScrollingFrame
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 10)

    self.GUI = ScreenGui
    self.MainFrame = MainFrame
    self.ScrollingFrame = ScrollingFrame
    self.UIListLayout = UIListLayout

    self:CreateToggle("Infinite Health", function(state)
        if state then
            self:StartInfiniteHealth()
        else
            self:StopInfiniteHealth()
        end
    end)

    self:CreateToggle("ESP", function(state)
        if state then
            self:StartESP()
        else
            self:StopESP()
        end
    end)

    self:CreateToggle("Aimbot (Q to Lock)", function(state)
        Aimbot_Toggled = state
        if not state then
            Locked_Target = nil
        end
    end)

    self:CreateToggle("No Clip", function(state)
        if state then
            self:StartNoClip()
        else
            self:StopNoClip()
        end
    end)

    self:CreateToggle("Speed Boost", function(state)
        if state then
            self:StartSpeedBoost()
        else
            self:StopSpeedBoost()
        end
    end)

    self:CreateToggle("High Jump", function(state)
        if state then
            self:StartHighJump()
        else
            self:StopHighJump()
        end
    end)
    
    -- Mettre à jour la taille du Canvas après avoir ajouté tous les éléments
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)

    -- Animation d'ouverture
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 0, 0, 400)
    local tween = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 500, 0, 400)})
    tween:Play()
end

function LixHub:CreateToggle(name, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = name
    ToggleFrame.Parent = self.ScrollingFrame
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Size = UDim2.new(1, -10, 0, 40)

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 5)
    ToggleCorner.Parent = ToggleFrame

    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Name = "ToggleLabel"
    ToggleLabel.Parent = ToggleFrame
    ToggleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.BackgroundTransparency = 1.000
    ToggleLabel.BorderSizePixel = 0
    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
    ToggleLabel.Size = UDim2.new(1, -70, 1, 0)
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextSize = 16.000
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = ToggleFrame
    ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Position = UDim2.new(1, -60, 0.5, -15)
    ToggleButton.Size = UDim2.new(0,