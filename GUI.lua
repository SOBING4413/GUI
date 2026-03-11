
-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ═══════════════════════════════════════════════════════
-- CONFIGURATION
-- ═══════════════════════════════════════════════════════
local Config = {
    -- Colors (Modern Dark Theme)
    PrimaryColor = Color3.fromRGB(15, 15, 25),
    SecondaryColor = Color3.fromRGB(22, 22, 38),
    AccentColor = Color3.fromRGB(88, 101, 242),      -- Discord-like blue/purple
    AccentGlow = Color3.fromRGB(120, 130, 255),
    TextColor = Color3.fromRGB(230, 230, 245),
    SubTextColor = Color3.fromRGB(150, 150, 175),
    ToggleOn = Color3.fromRGB(67, 181, 129),          -- Green
    ToggleOff = Color3.fromRGB(80, 80, 100),
    DangerColor = Color3.fromRGB(237, 66, 69),
    CardColor = Color3.fromRGB(30, 30, 50),
    BorderColor = Color3.fromRGB(50, 50, 75),
    SliderTrack = Color3.fromRGB(45, 45, 70),

    -- Settings
    DefaultWalkSpeed = 16,
    DefaultFlySpeed = 50,
    DefaultGravity = 196.2,
    
    -- UI
    CornerRadius = UDim.new(0, 8),
    CornerRadiusLarge = UDim.new(0, 12),
    Font = Enum.Font.GothamBold,
    FontSemiBold = Enum.Font.GothamSemibold,
    FontRegular = Enum.Font.GothamMedium,
}

-- State
local State = {
    FlyEnabled = false,
    InfiniteJumpEnabled = false,
    WalkSpeed = Config.DefaultWalkSpeed,
    FlySpeed = Config.DefaultFlySpeed,
    Gravity = Config.DefaultGravity,
    GuiOpen = true,
    CurrentTab = "Home",
    BodyVelocity = nil,
    BodyGyro = nil,
    FlyConnection = nil,
    JumpConnection = nil,
}

-- ═══════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════

local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or Config.CornerRadius
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Config.BorderColor
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0.5
    stroke.Parent = parent
    return stroke
end

local function CreatePadding(parent, top, bottom, left, right)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, top or 8)
    padding.PaddingBottom = UDim.new(0, bottom or 8)
    padding.PaddingLeft = UDim.new(0, left or 8)
    padding.PaddingRight = UDim.new(0, right or 8)
    padding.Parent = parent
    return padding
end

local function CreateGradient(parent, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(color1, color2)
    gradient.Rotation = rotation or 90
    gradient.Parent = parent
    return gradient
end

local function Tween(object, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quint,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function FormatNumber(num)
    local formatted = tostring(math.floor(num))
    local k = #formatted
    if k > 3 then
        formatted = formatted:sub(1, k-3) .. "," .. formatted:sub(k-2)
    end
    return formatted
end

local function GetAccountAge()
    local days = LocalPlayer.AccountAge
    if days >= 365 then
        local years = math.floor(days / 365)
        local remainDays = days % 365
        return string.format("%d year(s), %d day(s)", years, remainDays)
    else
        return string.format("%d day(s)", days)
    end
end

-- ═══════════════════════════════════════════════════════
-- SCREEN GUI SETUP
-- ═══════════════════════════════════════════════════════

-- Destroy old GUI if exists
if LocalPlayer.PlayerGui:FindFirstChild("NexusHub") then
    LocalPlayer.PlayerGui:FindFirstChild("NexusHub"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexusHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer.PlayerGui

-- ═══════════════════════════════════════════════════════
-- LOADING / INTRO SCREEN
-- ═══════════════════════════════════════════════════════

local function CreateLoadingScreen()
    local LoadingFrame = Instance.new("Frame")
    LoadingFrame.Name = "LoadingScreen"
    LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
    LoadingFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 18)
    LoadingFrame.BorderSizePixel = 0
    LoadingFrame.ZIndex = 100
    LoadingFrame.Parent = ScreenGui

    -- Background gradient overlay
    local bgGradient = Instance.new("Frame")
    bgGradient.Size = UDim2.new(1, 0, 1, 0)
    bgGradient.BackgroundColor3 = Config.AccentColor
    bgGradient.BackgroundTransparency = 0.92
    bgGradient.BorderSizePixel = 0
    bgGradient.ZIndex = 101
    bgGradient.Parent = LoadingFrame

    -- Center container
    local CenterContainer = Instance.new("Frame")
    CenterContainer.Size = UDim2.new(0, 400, 0, 300)
    CenterContainer.Position = UDim2.new(0.5, -200, 0.5, -150)
    CenterContainer.BackgroundTransparency = 1
    CenterContainer.ZIndex = 102
    CenterContainer.Parent = LoadingFrame

    -- Logo icon (hexagon shape simulated)
    local LogoFrame = Instance.new("Frame")
    LogoFrame.Size = UDim2.new(0, 80, 0, 80)
    LogoFrame.Position = UDim2.new(0.5, -40, 0, 20)
    LogoFrame.BackgroundColor3 = Config.AccentColor
    LogoFrame.BorderSizePixel = 0
    LogoFrame.ZIndex = 103
    LogoFrame.Parent = CenterContainer
    CreateCorner(LogoFrame, UDim.new(0, 16))

    local LogoGlow = Instance.new("ImageLabel")
    LogoGlow.Size = UDim2.new(1, 40, 1, 40)
    LogoGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    LogoGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    LogoGlow.BackgroundTransparency = 1
    LogoGlow.ImageColor3 = Config.AccentColor
    LogoGlow.ImageTransparency = 0.7
    LogoGlow.ZIndex = 102
    LogoGlow.Parent = LogoFrame

    local LogoText = Instance.new("TextLabel")
    LogoText.Size = UDim2.new(1, 0, 1, 0)
    LogoText.BackgroundTransparency = 1
    LogoText.Text = "N"
    LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoText.TextSize = 40
    LogoText.Font = Config.Font
    LogoText.ZIndex = 104
    LogoText.Parent = LogoFrame

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 115)
    Title.BackgroundTransparency = 1
    Title.Text = "NEXUS HUB"
    Title.TextColor3 = Config.TextColor
    Title.TextSize = 32
    Title.Font = Config.Font
    Title.ZIndex = 103
    Title.Parent = CenterContainer

    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, 0, 0, 25)
    Subtitle.Position = UDim2.new(0, 0, 0, 155)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Universal Script Hub v2.0"
    Subtitle.TextColor3 = Config.SubTextColor
    Subtitle.TextSize = 14
    Subtitle.Font = Config.FontRegular
    Subtitle.ZIndex = 103
    Subtitle.Parent = CenterContainer

    -- Loading bar background
    local LoadBarBg = Instance.new("Frame")
    LoadBarBg.Size = UDim2.new(0, 300, 0, 4)
    LoadBarBg.Position = UDim2.new(0.5, -150, 0, 210)
    LoadBarBg.BackgroundColor3 = Config.SliderTrack
    LoadBarBg.BorderSizePixel = 0
    LoadBarBg.ZIndex = 103
    LoadBarBg.Parent = CenterContainer
    CreateCorner(LoadBarBg, UDim.new(0, 2))

    -- Loading bar fill
    local LoadBarFill = Instance.new("Frame")
    LoadBarFill.Size = UDim2.new(0, 0, 1, 0)
    LoadBarFill.BackgroundColor3 = Config.AccentColor
    LoadBarFill.BorderSizePixel = 0
    LoadBarFill.ZIndex = 104
    LoadBarFill.Parent = LoadBarBg
    CreateCorner(LoadBarFill, UDim.new(0, 2))
    CreateGradient(LoadBarFill, Config.AccentColor, Config.AccentGlow, 0)

    -- Status text
    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(1, 0, 0, 20)
    StatusText.Position = UDim2.new(0, 0, 0, 225)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "Initializing..."
    StatusText.TextColor3 = Config.SubTextColor
    StatusText.TextSize = 12
    StatusText.Font = Config.FontRegular
    StatusText.ZIndex = 103
    StatusText.Parent = CenterContainer

    -- Percentage text
    local PercentText = Instance.new("TextLabel")
    PercentText.Size = UDim2.new(1, 0, 0, 20)
    PercentText.Position = UDim2.new(0, 0, 0, 245)
    PercentText.BackgroundTransparency = 1
    PercentText.Text = "0%"
    PercentText.TextColor3 = Config.AccentGlow
    PercentText.TextSize = 14
    PercentText.Font = Config.FontSemiBold
    PercentText.ZIndex = 103
    PercentText.Parent = CenterContainer

    -- Credits at bottom
    local Credits = Instance.new("TextLabel")
    Credits.Size = UDim2.new(1, 0, 0, 20)
    Credits.Position = UDim2.new(0, 0, 1, -40)
    Credits.BackgroundTransparency = 1
    Credits.Text = "Made with ❤ | Nexus Hub"
    Credits.TextColor3 = Color3.fromRGB(80, 80, 110)
    Credits.TextSize = 11
    Credits.Font = Config.FontRegular
    Credits.ZIndex = 103
    Credits.Parent = LoadingFrame

    -- Animate loading
    local loadSteps = {
        {text = "Initializing modules...", pct = 15},
        {text = "Loading player data...", pct = 30},
        {text = "Setting up fly system...", pct = 45},
        {text = "Configuring walk speed...", pct = 60},
        {text = "Preparing infinite jump...", pct = 75},
        {text = "Loading gravity control...", pct = 85},
        {text = "Building user interface...", pct = 95},
        {text = "Ready!", pct = 100},
    }

    -- Logo pulse animation
    spawn(function()
        while LoadingFrame.Parent do
            Tween(LogoFrame, {BackgroundTransparency = 0.2}, 0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            wait(0.8)
            Tween(LogoFrame, {BackgroundTransparency = 0}, 0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            wait(0.8)
        end
    end)

    for i, step in ipairs(loadSteps) do
        StatusText.Text = step.text
        PercentText.Text = step.pct .. "%"
        Tween(LoadBarFill, {Size = UDim2.new(step.pct / 100, 0, 1, 0)}, 0.3)
        wait(math.random(20, 40) / 100)
    end

    wait(0.5)

    -- Fade out
    Tween(LoadingFrame, {BackgroundTransparency = 1}, 0.6)
    for _, child in pairs(LoadingFrame:GetDescendants()) do
        if child:IsA("TextLabel") then
            Tween(child, {TextTransparency = 1}, 0.5)
        elseif child:IsA("Frame") then
            Tween(child, {BackgroundTransparency = 1}, 0.5)
        elseif child:IsA("ImageLabel") then
            Tween(child, {ImageTransparency = 1}, 0.5)
        end
    end

    wait(0.7)
    LoadingFrame:Destroy()
end

-- ═══════════════════════════════════════════════════════
-- MAIN GUI
-- ═══════════════════════════════════════════════════════

local function CreateMainGui()
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 520, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
    MainFrame.BackgroundColor3 = Config.PrimaryColor
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    CreateCorner(MainFrame, Config.CornerRadiusLarge)
    CreateStroke(MainFrame, Config.BorderColor, 1, 0.3)

    -- Drop shadow (simulated)
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.6
    Shadow.ZIndex = -1
    Shadow.Parent = MainFrame

    -- ═══════════════════════════════════════════════════
    -- TITLE BAR
    -- ═══════════════════════════════════════════════════
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 45)
    TitleBar.BackgroundColor3 = Config.SecondaryColor
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    CreateCorner(TitleBar, Config.CornerRadiusLarge)

    -- Fix bottom corners of title bar
    local TitleBarFix = Instance.new("Frame")
    TitleBarFix.Size = UDim2.new(1, 0, 0, 15)
    TitleBarFix.Position = UDim2.new(0, 0, 1, -15)
    TitleBarFix.BackgroundColor3 = Config.SecondaryColor
    TitleBarFix.BorderSizePixel = 0
    TitleBarFix.Parent = TitleBar

    -- Title bar accent line
    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(1, 0, 0, 2)
    AccentLine.Position = UDim2.new(0, 0, 1, -2)
    AccentLine.BackgroundColor3 = Config.AccentColor
    AccentLine.BackgroundTransparency = 0.5
    AccentLine.BorderSizePixel = 0
    AccentLine.Parent = TitleBar
    CreateGradient(AccentLine, Config.AccentColor, Color3.fromRGB(200, 100, 255), 0)

    -- Logo small
    local LogoSmall = Instance.new("Frame")
    LogoSmall.Size = UDim2.new(0, 28, 0, 28)
    LogoSmall.Position = UDim2.new(0, 12, 0.5, -14)
    LogoSmall.BackgroundColor3 = Config.AccentColor
    LogoSmall.BorderSizePixel = 0
    LogoSmall.Parent = TitleBar
    CreateCorner(LogoSmall, UDim.new(0, 6))

    local LogoSmallText = Instance.new("TextLabel")
    LogoSmallText.Size = UDim2.new(1, 0, 1, 0)
    LogoSmallText.BackgroundTransparency = 1
    LogoSmallText.Text = "N"
    LogoSmallText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoSmallText.TextSize = 16
    LogoSmallText.Font = Config.Font
    LogoSmallText.Parent = LogoSmall

    -- Title text
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(0, 200, 1, 0)
    TitleText.Position = UDim2.new(0, 48, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "NEXUS HUB"
    TitleText.TextColor3 = Config.TextColor
    TitleText.TextSize = 16
    TitleText.Font = Config.Font
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar

    -- Version badge
    local VersionBadge = Instance.new("TextLabel")
    VersionBadge.Size = UDim2.new(0, 40, 0, 18)
    VersionBadge.Position = UDim2.new(0, 155, 0.5, -9)
    VersionBadge.BackgroundColor3 = Config.AccentColor
    VersionBadge.BackgroundTransparency = 0.7
    VersionBadge.Text = "v2.0"
    VersionBadge.TextColor3 = Config.AccentGlow
    VersionBadge.TextSize = 10
    VersionBadge.Font = Config.FontSemiBold
    VersionBadge.Parent = TitleBar
    CreateCorner(VersionBadge, UDim.new(0, 4))

    -- Close button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
    CloseBtn.BackgroundColor3 = Config.DangerColor
    CloseBtn.BackgroundTransparency = 0.8
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Config.DangerColor
    CloseBtn.TextSize = 14
    CloseBtn.Font = Config.Font
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TitleBar
    CreateCorner(CloseBtn, UDim.new(0, 6))

    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, {BackgroundTransparency = 0.3}, 0.2)
        Tween(CloseBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, {BackgroundTransparency = 0.8}, 0.2)
        Tween(CloseBtn, {TextColor3 = Config.DangerColor}, 0.2)
    end)

    -- Minimize button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -75, 0.5, -15)
    MinBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    MinBtn.BackgroundTransparency = 0.8
    MinBtn.Text = "—"
    MinBtn.TextColor3 = Color3.fromRGB(255, 200, 50)
    MinBtn.TextSize = 14
    MinBtn.Font = Config.Font
    MinBtn.BorderSizePixel = 0
    MinBtn.Parent = TitleBar
    CreateCorner(MinBtn, UDim.new(0, 6))

    MinBtn.MouseEnter:Connect(function()
        Tween(MinBtn, {BackgroundTransparency = 0.3}, 0.2)
    end)
    MinBtn.MouseLeave:Connect(function()
        Tween(MinBtn, {BackgroundTransparency = 0.8}, 0.2)
    end)

    -- Dragging
    local dragging, dragInput, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- ═══════════════════════════════════════════════════
    -- SIDEBAR (Tab Navigation)
    -- ═══════════════════════════════════════════════════
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 55, 1, -47)
    Sidebar.Position = UDim2.new(0, 0, 0, 47)
    Sidebar.BackgroundColor3 = Config.SecondaryColor
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    -- Fix corners
    local SidebarCornerFix = Instance.new("Frame")
    SidebarCornerFix.Size = UDim2.new(0, 15, 1, 0)
    SidebarCornerFix.Position = UDim2.new(1, -15, 0, 0)
    SidebarCornerFix.BackgroundColor3 = Config.SecondaryColor
    SidebarCornerFix.BorderSizePixel = 0
    SidebarCornerFix.Parent = Sidebar

    local SidebarBottomFix = Instance.new("Frame")
    SidebarBottomFix.Size = UDim2.new(1, 0, 0, 12)
    SidebarBottomFix.Position = UDim2.new(0, 0, 1, -12)
    SidebarBottomFix.BackgroundColor3 = Config.SecondaryColor
    SidebarBottomFix.BorderSizePixel = 0
    SidebarBottomFix.Parent = Sidebar
    CreateCorner(SidebarBottomFix, Config.CornerRadiusLarge)

    -- Sidebar divider
    local SidebarDivider = Instance.new("Frame")
    SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
    SidebarDivider.Position = UDim2.new(1, 0, 0, 0)
    SidebarDivider.BackgroundColor3 = Config.BorderColor
    SidebarDivider.BackgroundTransparency = 0.5
    SidebarDivider.BorderSizePixel = 0
    SidebarDivider.Parent = Sidebar

    -- Tab buttons data
    local Tabs = {
        {Name = "Home", Icon = "🏠", Order = 1},
        {Name = "Player", Icon = "👤", Order = 2},
        {Name = "Movement", Icon = "🏃", Order = 3},
        {Name = "World", Icon = "🌍", Order = 4},
        {Name = "Settings", Icon = "⚙", Order = 5},
    }

    local TabButtons = {}
    local TabPages = {}

    for i, tab in ipairs(Tabs) do
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = tab.Name .. "Tab"
        TabBtn.Size = UDim2.new(1, -10, 0, 42)
        TabBtn.Position = UDim2.new(0, 5, 0, 10 + (i - 1) * 50)
        TabBtn.BackgroundColor3 = Config.AccentColor
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = tab.Icon
        TabBtn.TextSize = 20
        TabBtn.Font = Config.FontRegular
        TabBtn.TextColor3 = Config.SubTextColor
        TabBtn.BorderSizePixel = 0
        TabBtn.Parent = Sidebar
        CreateCorner(TabBtn, UDim.new(0, 8))

        -- Hover effects
        TabBtn.MouseEnter:Connect(function()
            if State.CurrentTab ~= tab.Name then
                Tween(TabBtn, {BackgroundTransparency = 0.85}, 0.2)
                Tween(TabBtn, {TextColor3 = Config.TextColor}, 0.2)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if State.CurrentTab ~= tab.Name then
                Tween(TabBtn, {BackgroundTransparency = 1}, 0.2)
                Tween(TabBtn, {TextColor3 = Config.SubTextColor}, 0.2)
            end
        end)

        TabButtons[tab.Name] = TabBtn
    end

    -- ═══════════════════════════════════════════════════
    -- CONTENT AREA
    -- ═══════════════════════════════════════════════════
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -57, 1, -47)
    ContentArea.Position = UDim2.new(0, 57, 0, 47)
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel = 0
    ContentArea.ClipsDescendants = true
    ContentArea.Parent = MainFrame

    -- ═══════════════════════════════════════════════════
    -- HELPER: Create Toggle Switch
    -- ═══════════════════════════════════════════════════
    local function CreateToggle(parent, label, description, yPos, defaultState, callback)
        local ToggleContainer = Instance.new("Frame")
        ToggleContainer.Size = UDim2.new(1, -24, 0, 60)
        ToggleContainer.Position = UDim2.new(0, 12, 0, yPos)
        ToggleContainer.BackgroundColor3 = Config.CardColor
        ToggleContainer.BorderSizePixel = 0
        ToggleContainer.Parent = parent
        CreateCorner(ToggleContainer, Config.CornerRadius)
        CreateStroke(ToggleContainer, Config.BorderColor, 1, 0.6)

        local LabelText = Instance.new("TextLabel")
        LabelText.Size = UDim2.new(1, -80, 0, 22)
        LabelText.Position = UDim2.new(0, 14, 0, 10)
        LabelText.BackgroundTransparency = 1
        LabelText.Text = label
        LabelText.TextColor3 = Config.TextColor
        LabelText.TextSize = 14
        LabelText.Font = Config.FontSemiBold
        LabelText.TextXAlignment = Enum.TextXAlignment.Left
        LabelText.Parent = ToggleContainer

        local DescText = Instance.new("TextLabel")
        DescText.Size = UDim2.new(1, -80, 0, 16)
        DescText.Position = UDim2.new(0, 14, 0, 32)
        DescText.BackgroundTransparency = 1
        DescText.Text = description
        DescText.TextColor3 = Config.SubTextColor
        DescText.TextSize = 11
        DescText.Font = Config.FontRegular
        DescText.TextXAlignment = Enum.TextXAlignment.Left
        DescText.Parent = ToggleContainer

        -- Toggle switch
        local ToggleBg = Instance.new("Frame")
        ToggleBg.Size = UDim2.new(0, 44, 0, 24)
        ToggleBg.Position = UDim2.new(1, -58, 0.5, -12)
        ToggleBg.BackgroundColor3 = defaultState and Config.ToggleOn or Config.ToggleOff
        ToggleBg.BorderSizePixel = 0
        ToggleBg.Parent = ToggleContainer
        CreateCorner(ToggleBg, UDim.new(0, 12))

        local ToggleCircle = Instance.new("Frame")
        ToggleCircle.Size = UDim2.new(0, 18, 0, 18)
        ToggleCircle.Position = defaultState and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleCircle.BorderSizePixel = 0
        ToggleCircle.Parent = ToggleBg
        CreateCorner(ToggleCircle, UDim.new(0, 9))

        local toggled = defaultState

        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
        ToggleBtn.BackgroundTransparency = 1
        ToggleBtn.Text = ""
        ToggleBtn.Parent = ToggleContainer

        ToggleBtn.MouseButton1Click:Connect(function()
            toggled = not toggled
            if toggled then
                Tween(ToggleBg, {BackgroundColor3 = Config.ToggleOn}, 0.25)
                Tween(ToggleCircle, {Position = UDim2.new(1, -21, 0.5, -9)}, 0.25)
            else
                Tween(ToggleBg, {BackgroundColor3 = Config.ToggleOff}, 0.25)
                Tween(ToggleCircle, {Position = UDim2.new(0, 3, 0.5, -9)}, 0.25)
            end
            callback(toggled)
        end)

        -- Hover
        ToggleBtn.MouseEnter:Connect(function()
            Tween(ToggleContainer, {BackgroundColor3 = Color3.fromRGB(35, 35, 58)}, 0.2)
        end)
        ToggleBtn.MouseLeave:Connect(function()
            Tween(ToggleContainer, {BackgroundColor3 = Config.CardColor}, 0.2)
        end)

        return ToggleContainer
    end

    -- ═══════════════════════════════════════════════════
    -- HELPER: Create Slider
    -- ═══════════════════════════════════════════════════
    local function CreateSlider(parent, label, yPos, minVal, maxVal, defaultVal, callback)
        local SliderContainer = Instance.new("Frame")
        SliderContainer.Size = UDim2.new(1, -24, 0, 75)
        SliderContainer.Position = UDim2.new(0, 12, 0, yPos)
        SliderContainer.BackgroundColor3 = Config.CardColor
        SliderContainer.BorderSizePixel = 0
        SliderContainer.Parent = parent
        CreateCorner(SliderContainer, Config.CornerRadius)
        CreateStroke(SliderContainer, Config.BorderColor, 1, 0.6)

        local LabelText = Instance.new("TextLabel")
        LabelText.Size = UDim2.new(0.6, 0, 0, 22)
        LabelText.Position = UDim2.new(0, 14, 0, 10)
        LabelText.BackgroundTransparency = 1
        LabelText.Text = label
        LabelText.TextColor3 = Config.TextColor
        LabelText.TextSize = 14
        LabelText.Font = Config.FontSemiBold
        LabelText.TextXAlignment = Enum.TextXAlignment.Left
        LabelText.Parent = SliderContainer

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Size = UDim2.new(0.35, 0, 0, 22)
        ValueLabel.Position = UDim2.new(0.6, 0, 0, 10)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = tostring(math.floor(defaultVal))
        ValueLabel.TextColor3 = Config.AccentGlow
        ValueLabel.TextSize = 14
        ValueLabel.Font = Config.Font
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Parent = SliderContainer

        -- Slider track
        local SliderTrack = Instance.new("Frame")
        SliderTrack.Size = UDim2.new(1, -28, 0, 6)
        SliderTrack.Position = UDim2.new(0, 14, 0, 48)
        SliderTrack.BackgroundColor3 = Config.SliderTrack
        SliderTrack.BorderSizePixel = 0
        SliderTrack.Parent = SliderContainer
        CreateCorner(SliderTrack, UDim.new(0, 3))

        -- Slider fill
        local fillPct = (defaultVal - minVal) / (maxVal - minVal)
        local SliderFill = Instance.new("Frame")
        SliderFill.Size = UDim2.new(fillPct, 0, 1, 0)
        SliderFill.BackgroundColor3 = Config.AccentColor
        SliderFill.BorderSizePixel = 0
        SliderFill.Parent = SliderTrack
        CreateCorner(SliderFill, UDim.new(0, 3))
        CreateGradient(SliderFill, Config.AccentColor, Config.AccentGlow, 0)

        -- Slider knob
        local SliderKnob = Instance.new("Frame")
        SliderKnob.Size = UDim2.new(0, 16, 0, 16)
        SliderKnob.Position = UDim2.new(fillPct, -8, 0.5, -8)
        SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderKnob.BorderSizePixel = 0
        SliderKnob.ZIndex = 5
        SliderKnob.Parent = SliderTrack
        CreateCorner(SliderKnob, UDim.new(0, 8))

        -- Knob glow
        local KnobGlow = Instance.new("Frame")
        KnobGlow.Size = UDim2.new(0, 24, 0, 24)
        KnobGlow.Position = UDim2.new(0.5, -12, 0.5, -12)
        KnobGlow.AnchorPoint = Vector2.new(0, 0)
        KnobGlow.BackgroundColor3 = Config.AccentColor
        KnobGlow.BackgroundTransparency = 0.7
        KnobGlow.BorderSizePixel = 0
        KnobGlow.ZIndex = 4
        KnobGlow.Visible = false
        KnobGlow.Parent = SliderKnob
        CreateCorner(KnobGlow, UDim.new(0, 12))

        -- Slider interaction
        local sliding = false

        local SliderBtn = Instance.new("TextButton")
        SliderBtn.Size = UDim2.new(1, 0, 0, 30)
        SliderBtn.Position = UDim2.new(0, 0, 0, 35)
        SliderBtn.BackgroundTransparency = 1
        SliderBtn.Text = ""
        SliderBtn.Parent = SliderContainer

        local function UpdateSlider(inputX)
            local trackAbsPos = SliderTrack.AbsolutePosition.X
            local trackAbsSize = SliderTrack.AbsoluteSize.X
            local relX = math.clamp((inputX - trackAbsPos) / trackAbsSize, 0, 1)
            local value = math.floor(minVal + (maxVal - minVal) * relX)

            SliderFill.Size = UDim2.new(relX, 0, 1, 0)
            SliderKnob.Position = UDim2.new(relX, -8, 0.5, -8)
            ValueLabel.Text = tostring(value)
            callback(value)
        end

        SliderBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = true
                KnobGlow.Visible = true
                UpdateSlider(input.Position.X)
            end
        end)

        SliderBtn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = false
                KnobGlow.Visible = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                UpdateSlider(input.Position.X)
            end
        end)

        -- Hover
        SliderBtn.MouseEnter:Connect(function()
            Tween(SliderContainer, {BackgroundColor3 = Color3.fromRGB(35, 35, 58)}, 0.2)
        end)
        SliderBtn.MouseLeave:Connect(function()
            Tween(SliderContainer, {BackgroundColor3 = Config.CardColor}, 0.2)
        end)

        return SliderContainer
    end

    -- ═══════════════════════════════════════════════════
    -- PAGE: HOME
    -- ═══════════════════════════════════════════════════
    local HomePage = Instance.new("ScrollingFrame")
    HomePage.Name = "HomePage"
    HomePage.Size = UDim2.new(1, 0, 1, 0)
    HomePage.BackgroundTransparency = 1
    HomePage.BorderSizePixel = 0
    HomePage.ScrollBarThickness = 3
    HomePage.ScrollBarImageColor3 = Config.AccentColor
    HomePage.CanvasSize = UDim2.new(0, 0, 0, 400)
    HomePage.Parent = ContentArea

    -- Welcome card
    local WelcomeCard = Instance.new("Frame")
    WelcomeCard.Size = UDim2.new(1, -24, 0, 100)
    WelcomeCard.Position = UDim2.new(0, 12, 0, 10)
    WelcomeCard.BackgroundColor3 = Config.AccentColor
    WelcomeCard.BackgroundTransparency = 0.6
    WelcomeCard.BorderSizePixel = 0
    WelcomeCard.Parent = HomePage
    CreateCorner(WelcomeCard, Config.CornerRadius)
    CreateGradient(WelcomeCard, Config.AccentColor, Color3.fromRGB(140, 80, 220), 45)

    local WelcomeTitle = Instance.new("TextLabel")
    WelcomeTitle.Size = UDim2.new(1, -20, 0, 30)
    WelcomeTitle.Position = UDim2.new(0, 16, 0, 15)
    WelcomeTitle.BackgroundTransparency = 1
    WelcomeTitle.Text = "Welcome, " .. LocalPlayer.Name .. "! 👋"
    WelcomeTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    WelcomeTitle.TextSize = 18
    WelcomeTitle.Font = Config.Font
    WelcomeTitle.TextXAlignment = Enum.TextXAlignment.Left
    WelcomeTitle.Parent = WelcomeCard

    local WelcomeDesc = Instance.new("TextLabel")
    WelcomeDesc.Size = UDim2.new(1, -20, 0, 40)
    WelcomeDesc.Position = UDim2.new(0, 16, 0, 48)
    WelcomeDesc.BackgroundTransparency = 1
    WelcomeDesc.Text = "Nexus Hub is ready. Use the sidebar to navigate between features.\nPress RightControl to toggle GUI visibility."
    WelcomeDesc.TextColor3 = Color3.fromRGB(220, 220, 240)
    WelcomeDesc.TextSize = 12
    WelcomeDesc.Font = Config.FontRegular
    WelcomeDesc.TextXAlignment = Enum.TextXAlignment.Left
    WelcomeDesc.TextWrapped = true
    WelcomeDesc.Parent = WelcomeCard

    -- Quick stats
    local function CreateStatCard(parent, title, value, icon, xPos, yPos, color)
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(0.5, -18, 0, 70)
        Card.Position = UDim2.new(xPos, 12, 0, yPos)
        Card.BackgroundColor3 = Config.CardColor
        Card.BorderSizePixel = 0
        Card.Parent = parent
        CreateCorner(Card, Config.CornerRadius)
        CreateStroke(Card, Config.BorderColor, 1, 0.6)

        local IconLabel = Instance.new("TextLabel")
        IconLabel.Size = UDim2.new(0, 30, 0, 30)
        IconLabel.Position = UDim2.new(0, 12, 0, 12)
        IconLabel.BackgroundTransparency = 1
        IconLabel.Text = icon
        IconLabel.TextSize = 22
        IconLabel.Font = Config.FontRegular
        IconLabel.Parent = Card

        local StatTitle = Instance.new("TextLabel")
        StatTitle.Size = UDim2.new(1, -55, 0, 16)
        StatTitle.Position = UDim2.new(0, 46, 0, 12)
        StatTitle.BackgroundTransparency = 1
        StatTitle.Text = title
        StatTitle.TextColor3 = Config.SubTextColor
        StatTitle.TextSize = 11
        StatTitle.Font = Config.FontRegular
        StatTitle.TextXAlignment = Enum.TextXAlignment.Left
        StatTitle.Parent = Card

        local StatValue = Instance.new("TextLabel")
        StatValue.Size = UDim2.new(1, -55, 0, 22)
        StatValue.Position = UDim2.new(0, 46, 0, 32)
        StatValue.BackgroundTransparency = 1
        StatValue.Text = value
        StatValue.TextColor3 = color or Config.TextColor
        StatValue.TextSize = 16
        StatValue.Font = Config.Font
        StatValue.TextXAlignment = Enum.TextXAlignment.Left
        StatValue.Parent = Card

        return Card, StatValue
    end

    local _, flyStatVal = CreateStatCard(HomePage, "Fly", "OFF", "✈️", 0, 120, Config.DangerColor)
    local _, jumpStatVal = CreateStatCard(HomePage, "Inf. Jump", "OFF", "⬆️", 0.5, 120, Config.DangerColor)
    local _, speedStatVal = CreateStatCard(HomePage, "WalkSpeed", tostring(Config.DefaultWalkSpeed), "🏃", 0, 200, Config.AccentGlow)
    local _, gravStatVal = CreateStatCard(HomePage, "Gravity", tostring(Config.DefaultGravity), "🌍", 0.5, 200, Config.AccentGlow)

    -- Info text
    local InfoText = Instance.new("TextLabel")
    InfoText.Size = UDim2.new(1, -24, 0, 60)
    InfoText.Position = UDim2.new(0, 12, 0, 285)
    InfoText.BackgroundTransparency = 1
    InfoText.Text = "💡 Tip: All features can be configured in their respective tabs.\nUse Movement tab for Fly, Speed & Jump. Use World tab for Gravity."
    InfoText.TextColor3 = Config.SubTextColor
    InfoText.TextSize = 11
    InfoText.Font = Config.FontRegular
    InfoText.TextXAlignment = Enum.TextXAlignment.Left
    InfoText.TextWrapped = true
    InfoText.Parent = HomePage

    TabPages["Home"] = HomePage

    -- ═══════════════════════════════════════════════════
    -- PAGE: PLAYER INFO
    -- ═══════════════════════════════════════════════════
    local PlayerPage = Instance.new("ScrollingFrame")
    PlayerPage.Name = "PlayerPage"
    PlayerPage.Size = UDim2.new(1, 0, 1, 0)
    PlayerPage.BackgroundTransparency = 1
    PlayerPage.BorderSizePixel = 0
    PlayerPage.ScrollBarThickness = 3
    PlayerPage.ScrollBarImageColor3 = Config.AccentColor
    PlayerPage.CanvasSize = UDim2.new(0, 0, 0, 520)
    PlayerPage.Visible = false
    PlayerPage.Parent = ContentArea

    -- Player avatar card
    local AvatarCard = Instance.new("Frame")
    AvatarCard.Size = UDim2.new(1, -24, 0, 110)
    AvatarCard.Position = UDim2.new(0, 12, 0, 10)
    AvatarCard.BackgroundColor3 = Config.CardColor
    AvatarCard.BorderSizePixel = 0
    AvatarCard.Parent = PlayerPage
    CreateCorner(AvatarCard, Config.CornerRadius)
    CreateStroke(AvatarCard, Config.BorderColor, 1, 0.6)

    -- Avatar thumbnail
    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Size = UDim2.new(0, 75, 0, 75)
    AvatarImage.Position = UDim2.new(0, 18, 0.5, -37)
    AvatarImage.BackgroundColor3 = Config.SliderTrack
    AvatarImage.BorderSizePixel = 0
    AvatarImage.Parent = AvatarCard
    CreateCorner(AvatarImage, UDim.new(0, 38))
    CreateStroke(AvatarImage, Config.AccentColor, 2, 0.3)

    -- Try to load avatar
    pcall(function()
        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size150x150
        local content, isReady = Players:GetUserThumbnailAsync(LocalPlayer.UserId, thumbType, thumbSize)
        AvatarImage.Image = content
    end)

    local PlayerNameLabel = Instance.new("TextLabel")
    PlayerNameLabel.Size = UDim2.new(1, -120, 0, 24)
    PlayerNameLabel.Position = UDim2.new(0, 108, 0, 20)
    PlayerNameLabel.BackgroundTransparency = 1
    PlayerNameLabel.Text = LocalPlayer.Name
    PlayerNameLabel.TextColor3 = Config.TextColor
    PlayerNameLabel.TextSize = 18
    PlayerNameLabel.Font = Config.Font
    PlayerNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    PlayerNameLabel.Parent = AvatarCard

    local DisplayNameLabel = Instance.new("TextLabel")
    DisplayNameLabel.Size = UDim2.new(1, -120, 0, 18)
    DisplayNameLabel.Position = UDim2.new(0, 108, 0, 46)
    DisplayNameLabel.BackgroundTransparency = 1
    DisplayNameLabel.Text = "@" .. LocalPlayer.DisplayName
    DisplayNameLabel.TextColor3 = Config.SubTextColor
    DisplayNameLabel.TextSize = 13
    DisplayNameLabel.Font = Config.FontRegular
    DisplayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    DisplayNameLabel.Parent = AvatarCard

    -- Online badge
    local OnlineBadge = Instance.new("Frame")
    OnlineBadge.Size = UDim2.new(0, 70, 0, 20)
    OnlineBadge.Position = UDim2.new(0, 108, 0, 72)
    OnlineBadge.BackgroundColor3 = Config.ToggleOn
    OnlineBadge.BackgroundTransparency = 0.7
    OnlineBadge.BorderSizePixel = 0
    OnlineBadge.Parent = AvatarCard
    CreateCorner(OnlineBadge, UDim.new(0, 4))

    local OnlineText = Instance.new("TextLabel")
    OnlineText.Size = UDim2.new(1, 0, 1, 0)
    OnlineText.BackgroundTransparency = 1
    OnlineText.Text = "● Online"
    OnlineText.TextColor3 = Config.ToggleOn
    OnlineText.TextSize = 11
    OnlineText.Font = Config.FontSemiBold
    OnlineText.Parent = OnlineBadge

    -- Player info cards
    local function CreateInfoRow(parent, label, value, yPos, icon)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, -24, 0, 48)
        Row.Position = UDim2.new(0, 12, 0, yPos)
        Row.BackgroundColor3 = Config.CardColor
        Row.BorderSizePixel = 0
        Row.Parent = parent
        CreateCorner(Row, Config.CornerRadius)
        CreateStroke(Row, Config.BorderColor, 1, 0.7)

        local IconLabel = Instance.new("TextLabel")
        IconLabel.Size = UDim2.new(0, 30, 1, 0)
        IconLabel.Position = UDim2.new(0, 12, 0, 0)
        IconLabel.BackgroundTransparency = 1
        IconLabel.Text = icon or "📋"
        IconLabel.TextSize = 16
        IconLabel.Font = Config.FontRegular
        IconLabel.Parent = Row

        local LabelText = Instance.new("TextLabel")
        LabelText.Size = UDim2.new(0.4, 0, 1, 0)
        LabelText.Position = UDim2.new(0, 44, 0, 0)
        LabelText.BackgroundTransparency = 1
        LabelText.Text = label
        LabelText.TextColor3 = Config.SubTextColor
        LabelText.TextSize = 13
        LabelText.Font = Config.FontRegular
        LabelText.TextXAlignment = Enum.TextXAlignment.Left
        LabelText.Parent = Row

        local ValueText = Instance.new("TextLabel")
        ValueText.Size = UDim2.new(0.5, -20, 1, 0)
        ValueText.Position = UDim2.new(0.5, 0, 0, 0)
        ValueText.BackgroundTransparency = 1
        ValueText.Text = value
        ValueText.TextColor3 = Config.TextColor
        ValueText.TextSize = 13
        ValueText.Font = Config.FontSemiBold
        ValueText.TextXAlignment = Enum.TextXAlignment.Right
        ValueText.Parent = Row

        return Row
    end

    -- Section header
    local InfoHeader = Instance.new("TextLabel")
    InfoHeader.Size = UDim2.new(1, -24, 0, 25)
    InfoHeader.Position = UDim2.new(0, 12, 0, 130)
    InfoHeader.BackgroundTransparency = 1
    InfoHeader.Text = "ACCOUNT INFORMATION"
    InfoHeader.TextColor3 = Config.SubTextColor
    InfoHeader.TextSize = 11
    InfoHeader.Font = Config.Font
    InfoHeader.TextXAlignment = Enum.TextXAlignment.Left
    InfoHeader.Parent = PlayerPage

    CreateInfoRow(PlayerPage, "Username", LocalPlayer.Name, 158, "👤")
    CreateInfoRow(PlayerPage, "Display Name", LocalPlayer.DisplayName, 212, "🏷️")
    CreateInfoRow(PlayerPage, "User ID", tostring(LocalPlayer.UserId), 266, "🔑")
    CreateInfoRow(PlayerPage, "Account Age", GetAccountAge(), 320, "📅")
    CreateInfoRow(PlayerPage, "Team", LocalPlayer.Team and LocalPlayer.Team.Name or "None", 374, "🏁")

    -- Membership
    local membershipText = "Standard"
    pcall(function()
        if LocalPlayer.MembershipType == Enum.MembershipType.Premium then
            membershipText = "⭐ Premium"
        end
    end)
    CreateInfoRow(PlayerPage, "Membership", membershipText, 428, "💎")

    -- Game info
    local GameHeader = Instance.new("TextLabel")
    GameHeader.Size = UDim2.new(1, -24, 0, 25)
    GameHeader.Position = UDim2.new(0, 12, 0, 486)
    GameHeader.BackgroundTransparency = 1
    GameHeader.Text = "GAME INFORMATION"
    GameHeader.TextColor3 = Config.SubTextColor
    GameHeader.TextSize = 11
    GameHeader.Font = Config.Font
    GameHeader.TextXAlignment = Enum.TextXAlignment.Left
    GameHeader.Parent = PlayerPage

    -- Extend canvas for game info
    PlayerPage.CanvasSize = UDim2.new(0, 0, 0, 620)

    local placeIdStr = "N/A"
    pcall(function() placeIdStr = tostring(game.PlaceId) end)
    CreateInfoRow(PlayerPage, "Place ID", placeIdStr, 514, "🎮")

    local jobIdStr = "N/A"
    pcall(function() jobIdStr = string.sub(tostring(game.JobId), 1, 12) .. "..." end)
    CreateInfoRow(PlayerPage, "Server ID", jobIdStr, 568, "🖥️")

    TabPages["Player"] = PlayerPage

    -- ═══════════════════════════════════════════════════
    -- PAGE: MOVEMENT (Fly, WalkSpeed, Infinite Jump)
    -- ═══════════════════════════════════════════════════
    local MovementPage = Instance.new("ScrollingFrame")
    MovementPage.Name = "MovementPage"
    MovementPage.Size = UDim2.new(1, 0, 1, 0)
    MovementPage.BackgroundTransparency = 1
    MovementPage.BorderSizePixel = 0
    MovementPage.ScrollBarThickness = 3
    MovementPage.ScrollBarImageColor3 = Config.AccentColor
    MovementPage.CanvasSize = UDim2.new(0, 0, 0, 400)
    MovementPage.Visible = false
    MovementPage.Parent = ContentArea

    -- Section: Fly
    local FlyHeader = Instance.new("TextLabel")
    FlyHeader.Size = UDim2.new(1, -24, 0, 22)
    FlyHeader.Position = UDim2.new(0, 14, 0, 8)
    FlyHeader.BackgroundTransparency = 1
    FlyHeader.Text = "✈️  FLY SYSTEM"
    FlyHeader.TextColor3 = Config.SubTextColor
    FlyHeader.TextSize = 11
    FlyHeader.Font = Config.Font
    FlyHeader.TextXAlignment = Enum.TextXAlignment.Left
    FlyHeader.Parent = MovementPage

    -- Fly Toggle
    CreateToggle(MovementPage, "Enable Fly", "Press E to fly. Use WASD to move, Space/Shift for up/down.", 32, false, function(enabled)
        State.FlyEnabled = enabled
        flyStatVal.Text = enabled and "ON" or "OFF"
        flyStatVal.TextColor3 = enabled and Config.ToggleOn or Config.DangerColor

        local character = LocalPlayer.Character
        if not character then return end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoidRootPart or not humanoid then return end

        if enabled then
            -- Create fly objects
            State.BodyVelocity = Instance.new("BodyVelocity")
            State.BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            State.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            State.BodyVelocity.Parent = humanoidRootPart

            State.BodyGyro = Instance.new("BodyGyro")
            State.BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            State.BodyGyro.D = 200
            State.BodyGyro.P = 10000
            State.BodyGyro.Parent = humanoidRootPart

            humanoid.PlatformStand = true

            State.FlyConnection = RunService.RenderStepped:Connect(function()
                if not State.FlyEnabled then return end
                local camera = Workspace.CurrentCamera
                local moveDirection = Vector3.new(0, 0, 0)

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0)
                end

                if moveDirection.Magnitude > 0 then
                    moveDirection = moveDirection.Unit
                end

                State.BodyVelocity.Velocity = moveDirection * State.FlySpeed
                State.BodyGyro.CFrame = camera.CFrame
            end)
        else
            -- Disable fly
            humanoid.PlatformStand = false
            if State.BodyVelocity then
                State.BodyVelocity:Destroy()
                State.BodyVelocity = nil
            end
            if State.BodyGyro then
                State.BodyGyro:Destroy()
                State.BodyGyro = nil
            end
            if State.FlyConnection then
                State.FlyConnection:Disconnect()
                State.FlyConnection = nil
            end
        end
    end)

    -- Fly Speed Slider
    CreateSlider(MovementPage, "Fly Speed", 100, 10, 500, Config.DefaultFlySpeed, function(value)
        State.FlySpeed = value
    end)

    -- Section: Walk Speed
    local SpeedHeader = Instance.new("TextLabel")
    SpeedHeader.Size = UDim2.new(1, -24, 0, 22)
    SpeedHeader.Position = UDim2.new(0, 14, 0, 188)
    SpeedHeader.BackgroundTransparency = 1
    SpeedHeader.Text = "🏃  WALK SPEED"
    SpeedHeader.TextColor3 = Config.SubTextColor
    SpeedHeader.TextSize = 11
    SpeedHeader.Font = Config.Font
    SpeedHeader.TextXAlignment = Enum.TextXAlignment.Left
    SpeedHeader.Parent = MovementPage

    CreateSlider(MovementPage, "Walk Speed", 212, 0, 500, Config.DefaultWalkSpeed, function(value)
        State.WalkSpeed = value
        speedStatVal.Text = tostring(value)
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    end)

    -- Section: Infinite Jump
    local JumpHeader = Instance.new("TextLabel")
    JumpHeader.Size = UDim2.new(1, -24, 0, 22)
    JumpHeader.Position = UDim2.new(0, 14, 0, 300)
    JumpHeader.BackgroundTransparency = 1
    JumpHeader.Text = "⬆️  INFINITE JUMP"
    JumpHeader.TextColor3 = Config.SubTextColor
    JumpHeader.TextSize = 11
    JumpHeader.Font = Config.Font
    JumpHeader.TextXAlignment = Enum.TextXAlignment.Left
    JumpHeader.Parent = MovementPage

    CreateToggle(MovementPage, "Enable Infinite Jump", "Jump unlimited times in mid-air by pressing Space.", 324, false, function(enabled)
        State.InfiniteJumpEnabled = enabled
        jumpStatVal.Text = enabled and "ON" or "OFF"
        jumpStatVal.TextColor3 = enabled and Config.ToggleOn or Config.DangerColor
    end)

    -- Infinite Jump handler
    UserInputService.JumpRequest:Connect(function()
        if State.InfiniteJumpEnabled then
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end)

    TabPages["Movement"] = MovementPage

    -- ═══════════════════════════════════════════════════
    -- PAGE: WORLD (Gravity Control)
    -- ═══════════════════════════════════════════════════
    local WorldPage = Instance.new("ScrollingFrame")
    WorldPage.Name = "WorldPage"
    WorldPage.Size = UDim2.new(1, 0, 1, 0)
    WorldPage.BackgroundTransparency = 1
    WorldPage.BorderSizePixel = 0
    WorldPage.ScrollBarThickness = 3
    WorldPage.ScrollBarImageColor3 = Config.AccentColor
    WorldPage.CanvasSize = UDim2.new(0, 0, 0, 300)
    WorldPage.Visible = false
    WorldPage.Parent = ContentArea

    local GravHeader = Instance.new("TextLabel")
    GravHeader.Size = UDim2.new(1, -24, 0, 22)
    GravHeader.Position = UDim2.new(0, 14, 0, 8)
    GravHeader.BackgroundTransparency = 1
    GravHeader.Text = "🌍  GRAVITY CONTROL"
    GravHeader.TextColor3 = Config.SubTextColor
    GravHeader.TextSize = 11
    GravHeader.Font = Config.Font
    GravHeader.TextXAlignment = Enum.TextXAlignment.Left
    GravHeader.Parent = WorldPage

    -- Gravity description card
    local GravDescCard = Instance.new("Frame")
    GravDescCard.Size = UDim2.new(1, -24, 0, 55)
    GravDescCard.Position = UDim2.new(0, 12, 0, 32)
    GravDescCard.BackgroundColor3 = Config.AccentColor
    GravDescCard.BackgroundTransparency = 0.8
    GravDescCard.BorderSizePixel = 0
    GravDescCard.Parent = WorldPage
    CreateCorner(GravDescCard, Config.CornerRadius)

    local GravDescText = Instance.new("TextLabel")
    GravDescText.Size = UDim2.new(1, -20, 1, -10)
    GravDescText.Position = UDim2.new(0, 10, 0, 5)
    GravDescText.BackgroundTransparency = 1
    GravDescText.Text = "💡 Adjust the workspace gravity. Default is 196.2.\nLower values = Moon-like gravity. Higher values = Heavy gravity."
    GravDescText.TextColor3 = Color3.fromRGB(180, 190, 255)
    GravDescText.TextSize = 11
    GravDescText.Font = Config.FontRegular
    GravDescText.TextXAlignment = Enum.TextXAlignment.Left
    GravDescText.TextWrapped = true
    GravDescText.Parent = GravDescCard

    -- Gravity Slider
    CreateSlider(WorldPage, "Gravity", 100, 0, 800, Config.DefaultGravity, function(value)
        State.Gravity = value
        gravStatVal.Text = tostring(value)
        Workspace.Gravity = value
    end)

    -- Preset buttons
    local PresetsHeader = Instance.new("TextLabel")
    PresetsHeader.Size = UDim2.new(1, -24, 0, 22)
    PresetsHeader.Position = UDim2.new(0, 14, 0, 190)
    PresetsHeader.BackgroundTransparency = 1
    PresetsHeader.Text = "PRESETS"
    PresetsHeader.TextColor3 = Config.SubTextColor
    PresetsHeader.TextSize = 11
    PresetsHeader.Font = Config.Font
    PresetsHeader.TextXAlignment = Enum.TextXAlignment.Left
    PresetsHeader.Parent = WorldPage

    local presets = {
        {Name = "🌙 Moon", Value = 30, Color = Color3.fromRGB(180, 180, 220)},
        {Name = "🌍 Earth", Value = 196.2, Color = Color3.fromRGB(100, 180, 100)},
        {Name = "🪐 Jupiter", Value = 500, Color = Color3.fromRGB(220, 150, 80)},
        {Name = "🕳️ Zero-G", Value = 0, Color = Color3.fromRGB(150, 100, 255)},
    }

    for i, preset in ipairs(presets) do
        local PresetBtn = Instance.new("TextButton")
        PresetBtn.Size = UDim2.new(0.5, -18, 0, 40)
        PresetBtn.Position = UDim2.new(((i - 1) % 2) * 0.5, 12, 0, 215 + math.floor((i - 1) / 2) * 48)
        PresetBtn.BackgroundColor3 = Config.CardColor
        PresetBtn.BorderSizePixel = 0
        PresetBtn.Text = preset.Name
        PresetBtn.TextColor3 = preset.Color
        PresetBtn.TextSize = 13
        PresetBtn.Font = Config.FontSemiBold
        PresetBtn.Parent = WorldPage
        CreateCorner(PresetBtn, Config.CornerRadius)
        CreateStroke(PresetBtn, Config.BorderColor, 1, 0.6)

        PresetBtn.MouseEnter:Connect(function()
            Tween(PresetBtn, {BackgroundColor3 = Color3.fromRGB(40, 40, 65)}, 0.2)
        end)
        PresetBtn.MouseLeave:Connect(function()
            Tween(PresetBtn, {BackgroundColor3 = Config.CardColor}, 0.2)
        end)

        PresetBtn.MouseButton1Click:Connect(function()
            Workspace.Gravity = preset.Value
            State.Gravity = preset.Value
            gravStatVal.Text = tostring(preset.Value)
            -- Flash effect
            Tween(PresetBtn, {BackgroundColor3 = preset.Color}, 0.15)
            wait(0.15)
            Tween(PresetBtn, {BackgroundColor3 = Config.CardColor}, 0.3)
        end)
    end

    TabPages["World"] = WorldPage

    -- ═══════════════════════════════════════════════════
    -- PAGE: SETTINGS
    -- ═══════════════════════════════════════════════════
    local SettingsPage = Instance.new("ScrollingFrame")
    SettingsPage.Name = "SettingsPage"
    SettingsPage.Size = UDim2.new(1, 0, 1, 0)
    SettingsPage.BackgroundTransparency = 1
    SettingsPage.BorderSizePixel = 0
    SettingsPage.ScrollBarThickness = 3
    SettingsPage.ScrollBarImageColor3 = Config.AccentColor
    SettingsPage.CanvasSize = UDim2.new(0, 0, 0, 320)
    SettingsPage.Visible = false
    SettingsPage.Parent = ContentArea

    local SettingsHeader = Instance.new("TextLabel")
    SettingsHeader.Size = UDim2.new(1, -24, 0, 22)
    SettingsHeader.Position = UDim2.new(0, 14, 0, 8)
    SettingsHeader.BackgroundTransparency = 1
    SettingsHeader.Text = "⚙  SETTINGS"
    SettingsHeader.TextColor3 = Config.SubTextColor
    SettingsHeader.TextSize = 11
    SettingsHeader.Font = Config.Font
    SettingsHeader.TextXAlignment = Enum.TextXAlignment.Left
    SettingsHeader.Parent = SettingsPage

    -- Reset all button
    local ResetCard = Instance.new("Frame")
    ResetCard.Size = UDim2.new(1, -24, 0, 60)
    ResetCard.Position = UDim2.new(0, 12, 0, 35)
    ResetCard.BackgroundColor3 = Config.CardColor
    ResetCard.BorderSizePixel = 0
    ResetCard.Parent = SettingsPage
    CreateCorner(ResetCard, Config.CornerRadius)
    CreateStroke(ResetCard, Config.BorderColor, 1, 0.6)

    local ResetLabel = Instance.new("TextLabel")
    ResetLabel.Size = UDim2.new(0.6, 0, 0, 22)
    ResetLabel.Position = UDim2.new(0, 14, 0, 10)
    ResetLabel.BackgroundTransparency = 1
    ResetLabel.Text = "Reset All Settings"
    ResetLabel.TextColor3 = Config.TextColor
    ResetLabel.TextSize = 14
    ResetLabel.Font = Config.FontSemiBold
    ResetLabel.TextXAlignment = Enum.TextXAlignment.Left
    ResetLabel.Parent = ResetCard

    local ResetDesc = Instance.new("TextLabel")
    ResetDesc.Size = UDim2.new(0.6, 0, 0, 16)
    ResetDesc.Position = UDim2.new(0, 14, 0, 32)
    ResetDesc.BackgroundTransparency = 1
    ResetDesc.Text = "Reset everything to default values"
    ResetDesc.TextColor3 = Config.SubTextColor
    ResetDesc.TextSize = 11
    ResetDesc.Font = Config.FontRegular
    ResetDesc.TextXAlignment = Enum.TextXAlignment.Left
    ResetDesc.Parent = ResetCard

    local ResetBtn = Instance.new("TextButton")
    ResetBtn.Size = UDim2.new(0, 80, 0, 32)
    ResetBtn.Position = UDim2.new(1, -95, 0.5, -16)
    ResetBtn.BackgroundColor3 = Config.DangerColor
    ResetBtn.Text = "Reset"
    ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ResetBtn.TextSize = 13
    ResetBtn.Font = Config.FontSemiBold
    ResetBtn.BorderSizePixel = 0
    ResetBtn.Parent = ResetCard
    CreateCorner(ResetBtn, UDim.new(0, 6))

    ResetBtn.MouseEnter:Connect(function()
        Tween(ResetBtn, {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}, 0.2)
    end)
    ResetBtn.MouseLeave:Connect(function()
        Tween(ResetBtn, {BackgroundColor3 = Config.DangerColor}, 0.2)
    end)

    ResetBtn.MouseButton1Click:Connect(function()
        -- Reset everything
        State.FlyEnabled = false
        State.InfiniteJumpEnabled = false
        State.WalkSpeed = Config.DefaultWalkSpeed
        State.FlySpeed = Config.DefaultFlySpeed
        State.Gravity = Config.DefaultGravity

        Workspace.Gravity = Config.DefaultGravity

        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = Config.DefaultWalkSpeed
                humanoid.PlatformStand = false
            end
        end

        if State.BodyVelocity then State.BodyVelocity:Destroy(); State.BodyVelocity = nil end
        if State.BodyGyro then State.BodyGyro:Destroy(); State.BodyGyro = nil end
        if State.FlyConnection then State.FlyConnection:Disconnect(); State.FlyConnection = nil end

        flyStatVal.Text = "OFF"; flyStatVal.TextColor3 = Config.DangerColor
        jumpStatVal.Text = "OFF"; jumpStatVal.TextColor3 = Config.DangerColor
        speedStatVal.Text = tostring(Config.DefaultWalkSpeed)
        gravStatVal.Text = tostring(Config.DefaultGravity)

        -- Flash button
        Tween(ResetBtn, {BackgroundColor3 = Config.ToggleOn}, 0.15)
        ResetBtn.Text = "Done!"
        wait(0.8)
        Tween(ResetBtn, {BackgroundColor3 = Config.DangerColor}, 0.3)
        ResetBtn.Text = "Reset"
    end)

    -- Destroy GUI button
    local DestroyCard = Instance.new("Frame")
    DestroyCard.Size = UDim2.new(1, -24, 0, 60)
    DestroyCard.Position = UDim2.new(0, 12, 0, 105)
    DestroyCard.BackgroundColor3 = Config.CardColor
    DestroyCard.BorderSizePixel = 0
    DestroyCard.Parent = SettingsPage
    CreateCorner(DestroyCard, Config.CornerRadius)
    CreateStroke(DestroyCard, Config.BorderColor, 1, 0.6)

    local DestroyLabel = Instance.new("TextLabel")
    DestroyLabel.Size = UDim2.new(0.6, 0, 0, 22)
    DestroyLabel.Position = UDim2.new(0, 14, 0, 10)
    DestroyLabel.BackgroundTransparency = 1
    DestroyLabel.Text = "Destroy GUI"
    DestroyLabel.TextColor3 = Config.TextColor
    DestroyLabel.TextSize = 14
    DestroyLabel.Font = Config.FontSemiBold
    DestroyLabel.TextXAlignment = Enum.TextXAlignment.Left
    DestroyLabel.Parent = DestroyCard

    local DestroyDesc = Instance.new("TextLabel")
    DestroyDesc.Size = UDim2.new(0.6, 0, 0, 16)
    DestroyDesc.Position = UDim2.new(0, 14, 0, 32)
    DestroyDesc.BackgroundTransparency = 1
    DestroyDesc.Text = "Completely remove the GUI"
    DestroyDesc.TextColor3 = Config.SubTextColor
    DestroyDesc.TextSize = 11
    DestroyDesc.Font = Config.FontRegular
    DestroyDesc.TextXAlignment = Enum.TextXAlignment.Left
    DestroyDesc.Parent = DestroyCard

    local DestroyBtn = Instance.new("TextButton")
    DestroyBtn.Size = UDim2.new(0, 80, 0, 32)
    DestroyBtn.Position = UDim2.new(1, -95, 0.5, -16)
    DestroyBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
    DestroyBtn.Text = "Destroy"
    DestroyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DestroyBtn.TextSize = 13
    DestroyBtn.Font = Config.FontSemiBold
    DestroyBtn.BorderSizePixel = 0
    DestroyBtn.Parent = DestroyCard
    CreateCorner(DestroyBtn, UDim.new(0, 6))

    DestroyBtn.MouseButton1Click:Connect(function()
        -- Clean up
        if State.BodyVelocity then State.BodyVelocity:Destroy() end
        if State.BodyGyro then State.BodyGyro:Destroy() end
        if State.FlyConnection then State.FlyConnection:Disconnect() end
        Workspace.Gravity = Config.DefaultGravity
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = Config.DefaultWalkSpeed
                humanoid.PlatformStand = false
            end
        end
        ScreenGui:Destroy()
    end)

    -- Credits section
    local CreditsCard = Instance.new("Frame")
    CreditsCard.Size = UDim2.new(1, -24, 0, 80)
    CreditsCard.Position = UDim2.new(0, 12, 0, 180)
    CreditsCard.BackgroundColor3 = Config.CardColor
    CreditsCard.BorderSizePixel = 0
    CreditsCard.Parent = SettingsPage
    CreateCorner(CreditsCard, Config.CornerRadius)
    CreateStroke(CreditsCard, Config.BorderColor, 1, 0.6)

    local CreditsTitle = Instance.new("TextLabel")
    CreditsTitle.Size = UDim2.new(1, -20, 0, 22)
    CreditsTitle.Position = UDim2.new(0, 14, 0, 10)
    CreditsTitle.BackgroundTransparency = 1
    CreditsTitle.Text = "📜 Credits"
    CreditsTitle.TextColor3 = Config.TextColor
    CreditsTitle.TextSize = 14
    CreditsTitle.Font = Config.FontSemiBold
    CreditsTitle.TextXAlignment = Enum.TextXAlignment.Left
    CreditsTitle.Parent = CreditsCard

    local CreditsText = Instance.new("TextLabel")
    CreditsText.Size = UDim2.new(1, -20, 0, 40)
    CreditsText.Position = UDim2.new(0, 14, 0, 34)
    CreditsText.BackgroundTransparency = 1
    CreditsText.Text = "Nexus Hub v2.0 — Universal Script GUI\nDeveloped with ❤ | All features in one file."
    CreditsText.TextColor3 = Config.SubTextColor
    CreditsText.TextSize = 11
    CreditsText.Font = Config.FontRegular
    CreditsText.TextXAlignment = Enum.TextXAlignment.Left
    CreditsText.TextWrapped = true
    CreditsText.Parent = CreditsCard

    TabPages["Settings"] = SettingsPage

    -- ═══════════════════════════════════════════════════
    -- TAB SWITCHING LOGIC
    -- ═══════════════════════════════════════════════════
    local function SwitchTab(tabName)
        State.CurrentTab = tabName

        -- Update tab button visuals
        for name, btn in pairs(TabButtons) do
            if name == tabName then
                Tween(btn, {BackgroundTransparency = 0.7}, 0.25)
                Tween(btn, {TextColor3 = Config.TextColor}, 0.25)
            else
                Tween(btn, {BackgroundTransparency = 1}, 0.25)
                Tween(btn, {TextColor3 = Config.SubTextColor}, 0.25)
            end
        end

        -- Show/hide pages with fade
        for name, page in pairs(TabPages) do
            if name == tabName then
                page.Visible = true
                -- Fade in from right
                page.Position = UDim2.new(0.05, 0, 0, 0)
                Tween(page, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
            else
                page.Visible = false
            end
        end
    end

    -- Connect tab buttons
    for name, btn in pairs(TabButtons) do
        btn.MouseButton1Click:Connect(function()
            SwitchTab(name)
        end)
    end

    -- Initialize first tab
    SwitchTab("Home")

    -- ═══════════════════════════════════════════════════
    -- CLOSE / MINIMIZE HANDLERS
    -- ═══════════════════════════════════════════════════
    CloseBtn.MouseButton1Click:Connect(function()
        -- Clean up
        if State.BodyVelocity then State.BodyVelocity:Destroy() end
        if State.BodyGyro then State.BodyGyro:Destroy() end
        if State.FlyConnection then State.FlyConnection:Disconnect() end
        Workspace.Gravity = Config.DefaultGravity
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = Config.DefaultWalkSpeed
                humanoid.PlatformStand = false
            end
        end
        ScreenGui:Destroy()
    end)

    MinBtn.MouseButton1Click:Connect(function()
        State.GuiOpen = false
        Tween(MainFrame, {Size = UDim2.new(0, 520, 0, 0)}, 0.3)
        wait(0.35)
        MainFrame.Visible = false
    end)

    -- ═══════════════════════════════════════════════════
    -- TOGGLE GUI KEYBIND (RightControl)
    -- ═══════════════════════════════════════════════════
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            if State.GuiOpen then
                State.GuiOpen = false
                Tween(MainFrame, {Size = UDim2.new(0, 520, 0, 0)}, 0.3)
                wait(0.35)
                MainFrame.Visible = false
            else
                State.GuiOpen = true
                MainFrame.Visible = true
                MainFrame.Size = UDim2.new(0, 520, 0, 0)
                Tween(MainFrame, {Size = UDim2.new(0, 520, 0, 380)}, 0.3)
            end
        end
    end)

    -- ═══════════════════════════════════════════════════
    -- RE-APPLY SETTINGS ON RESPAWN
    -- ═══════════════════════════════════════════════════
    LocalPlayer.CharacterAdded:Connect(function(character)
        wait(1)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.WalkSpeed = State.WalkSpeed
        end

        -- Re-enable fly if it was active
        if State.FlyEnabled then
            State.FlyEnabled = false -- Reset so toggle can re-enable
            wait(0.5)
            -- User needs to re-enable fly after respawn
            flyStatVal.Text = "OFF"
            flyStatVal.TextColor3 = Config.DangerColor
        end
    end)

    -- Open animation
    MainFrame.Size = UDim2.new(0, 520, 0, 0)
    MainFrame.Visible = true
    Tween(MainFrame, {Size = UDim2.new(0, 520, 0, 380)}, 0.4, Enum.EasingStyle.Back)
end

-- ═══════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════
CreateLoadingScreen()
wait(0.3)
CreateMainGui()

-- Notification
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Nexus Hub",
        Text = "GUI loaded successfully! Press RightCtrl to toggle.",
        Duration = 5,
    })
end)

print("[Nexus Hub] ✅ Successfully loaded!")
print("[Nexus Hub] Press RightControl to toggle GUI visibility.")
