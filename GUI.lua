-- ═══════════════════════════════════════════════════════════════
-- NEXUS HUB v3.0 — Enhanced Universal Script GUI
-- Dipercantik & Disempurnakan tanpa merusak fungsionalitas
-- ═══════════════════════════════════════════════════════════════

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
    PrimaryColor = Color3.fromRGB(12, 12, 22),
    SecondaryColor = Color3.fromRGB(18, 18, 32),
    AccentColor = Color3.fromRGB(88, 101, 242),
    AccentGlow = Color3.fromRGB(120, 130, 255),
    AccentSoft = Color3.fromRGB(60, 70, 180),
    TextColor = Color3.fromRGB(235, 235, 250),
    SubTextColor = Color3.fromRGB(140, 140, 170),
    MutedText = Color3.fromRGB(90, 90, 120),
    ToggleOn = Color3.fromRGB(67, 181, 129),
    ToggleOff = Color3.fromRGB(70, 70, 95),
    DangerColor = Color3.fromRGB(237, 66, 69),
    WarningColor = Color3.fromRGB(250, 168, 26),
    CardColor = Color3.fromRGB(25, 25, 42),
    CardHover = Color3.fromRGB(32, 32, 52),
    BorderColor = Color3.fromRGB(45, 45, 70),
    SliderTrack = Color3.fromRGB(40, 40, 62),
    GlowPurple = Color3.fromRGB(160, 100, 255),
    GlowCyan = Color3.fromRGB(80, 200, 255),

    DefaultWalkSpeed = 16,
    DefaultFlySpeed = 50,
    DefaultGravity = 196.2,
    DefaultJumpPower = 50,
    DefaultFOV = 70,

    CornerRadius = UDim.new(0, 10),
    CornerRadiusLarge = UDim.new(0, 14),
    CornerRadiusSmall = UDim.new(0, 6),
    Font = Enum.Font.GothamBold,
    FontSemiBold = Enum.Font.GothamSemibold,
    FontRegular = Enum.Font.GothamMedium,
}

local State = {
    FlyEnabled = false,
    InfiniteJumpEnabled = false,
    NoclipEnabled = false,
    ESPEnabled = false,
    WalkSpeed = Config.DefaultWalkSpeed,
    FlySpeed = Config.DefaultFlySpeed,
    Gravity = Config.DefaultGravity,
    JumpPower = Config.DefaultJumpPower,
    FOV = Config.DefaultFOV,
    GuiOpen = true,
    CurrentTab = "Home",
    BodyVelocity = nil,
    BodyGyro = nil,
    FlyConnection = nil,
    NoclipConnection = nil,
    ESPObjects = {},
    Uptime = 0,
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
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
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

local function GetAccountAge()
    local days = LocalPlayer.AccountAge
    if days >= 365 then
        return string.format("%d year(s), %d day(s)", math.floor(days / 365), days % 365)
    else
        return string.format("%d day(s)", days)
    end
end

local function FormatUptime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d", mins, secs)
end

local function Ripple(button)
    local ripple = Instance.new("Frame")
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.75
    ripple.BorderSizePixel = 0
    ripple.ZIndex = button.ZIndex + 1
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.Parent = button
    CreateCorner(ripple, UDim.new(1, 0))
    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
    Tween(ripple, {Size = UDim2.new(0, maxSize, 0, maxSize), BackgroundTransparency = 1}, 0.6, Enum.EasingStyle.Quad)
    task.delay(0.65, function()
        if ripple and ripple.Parent then ripple:Destroy() end
    end)
end

-- ═══════════════════════════════════════════════════════
-- SCREEN GUI SETUP
-- ═══════════════════════════════════════════════════════

if LocalPlayer.PlayerGui:FindFirstChild("NexusHub") then
    LocalPlayer.PlayerGui:FindFirstChild("NexusHub"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexusHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer.PlayerGui

-- ═══════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM (NEW)
-- ═══════════════════════════════════════════════════════
local NotificationContainer = Instance.new("Frame")
NotificationContainer.Name = "Notifications"
NotificationContainer.Size = UDim2.new(0, 260, 1, -20)
NotificationContainer.Position = UDim2.new(1, -270, 0, 10)
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.ZIndex = 200
NotificationContainer.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.Parent = NotificationContainer

local function ShowNotification(title, message, duration, notifType)
    local notifColor = Config.AccentColor
    local notifIcon = "ℹ️"
    if notifType == "success" then notifColor = Config.ToggleOn; notifIcon = "✅"
    elseif notifType == "warning" then notifColor = Config.WarningColor; notifIcon = "⚠️"
    elseif notifType == "error" then notifColor = Config.DangerColor; notifIcon = "❌" end

    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(1, 0, 0, 60)
    Notif.BackgroundColor3 = Config.CardColor
    Notif.BorderSizePixel = 0
    Notif.ClipsDescendants = true
    Notif.ZIndex = 201
    Notif.Parent = NotificationContainer
    CreateCorner(Notif, Config.CornerRadius)
    CreateStroke(Notif, notifColor, 1, 0.4)

    local AccBar = Instance.new("Frame")
    AccBar.Size = UDim2.new(0, 4, 0.7, 0)
    AccBar.Position = UDim2.new(0, 4, 0.15, 0)
    AccBar.BackgroundColor3 = notifColor
    AccBar.BorderSizePixel = 0
    AccBar.ZIndex = 202
    AccBar.Parent = Notif
    CreateCorner(AccBar, UDim.new(0, 2))

    local NIcon = Instance.new("TextLabel")
    NIcon.Size = UDim2.new(0, 20, 0, 20)
    NIcon.Position = UDim2.new(0, 16, 0, 10)
    NIcon.BackgroundTransparency = 1
    NIcon.Text = notifIcon
    NIcon.TextSize = 14
    NIcon.ZIndex = 202
    NIcon.Parent = Notif

    local NTitle = Instance.new("TextLabel")
    NTitle.Size = UDim2.new(1, -45, 0, 16)
    NTitle.Position = UDim2.new(0, 40, 0, 10)
    NTitle.BackgroundTransparency = 1
    NTitle.Text = title
    NTitle.TextColor3 = Config.TextColor
    NTitle.TextSize = 12
    NTitle.Font = Config.FontSemiBold
    NTitle.TextXAlignment = Enum.TextXAlignment.Left
    NTitle.TextTruncate = Enum.TextTruncate.AtEnd
    NTitle.ZIndex = 202
    NTitle.Parent = Notif

    local NMsg = Instance.new("TextLabel")
    NMsg.Size = UDim2.new(1, -45, 0, 14)
    NMsg.Position = UDim2.new(0, 40, 0, 28)
    NMsg.BackgroundTransparency = 1
    NMsg.Text = message
    NMsg.TextColor3 = Config.SubTextColor
    NMsg.TextSize = 10
    NMsg.Font = Config.FontRegular
    NMsg.TextXAlignment = Enum.TextXAlignment.Left
    NMsg.TextTruncate = Enum.TextTruncate.AtEnd
    NMsg.ZIndex = 202
    NMsg.Parent = Notif

    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(1, 0, 0, 3)
    ProgressBar.Position = UDim2.new(0, 0, 1, -3)
    ProgressBar.BackgroundColor3 = notifColor
    ProgressBar.BackgroundTransparency = 0.3
    ProgressBar.BorderSizePixel = 0
    ProgressBar.ZIndex = 202
    ProgressBar.Parent = Notif

    Notif.Position = UDim2.new(1, 0, 0, 0)
    Tween(Notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Back)
    Tween(ProgressBar, {Size = UDim2.new(0, 0, 0, 3)}, duration or 3, Enum.EasingStyle.Linear)

    task.delay(duration or 3, function()
        if Notif and Notif.Parent then
            Tween(Notif, {Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 1}, 0.4)
            task.delay(0.45, function()
                if Notif and Notif.Parent then Notif:Destroy() end
            end)
        end
    end)
end

-- ═══════════════════════════════════════════════════════
-- LOADING SCREEN (Enhanced)
-- ═══════════════════════════════════════════════════════

local function CreateLoadingScreen()
    local LoadingFrame = Instance.new("Frame")
    LoadingFrame.Name = "LoadingScreen"
    LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
    LoadingFrame.BackgroundColor3 = Color3.fromRGB(6, 6, 14)
    LoadingFrame.BorderSizePixel = 0
    LoadingFrame.ZIndex = 100
    LoadingFrame.Parent = ScreenGui

    -- Floating particles
    for i = 1, 15 do
        local p = Instance.new("Frame")
        p.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
        p.Position = UDim2.new(math.random() * 0.95, 0, math.random() * 0.95, 0)
        p.BackgroundColor3 = Config.AccentColor
        p.BackgroundTransparency = math.random(70, 92) / 100
        p.BorderSizePixel = 0
        p.ZIndex = 101
        p.Parent = LoadingFrame
        CreateCorner(p, UDim.new(1, 0))
        spawn(function()
            while p and p.Parent do
                Tween(p, {
                    Position = UDim2.new(math.clamp(p.Position.X.Scale + (math.random() - 0.5) * 0.1, 0, 0.95), 0, math.random() * 0.9, 0),
                    BackgroundTransparency = math.random(60, 92) / 100
                }, math.random(30, 50) / 10, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                wait(math.random(30, 50) / 10)
            end
        end)
    end

    local Center = Instance.new("Frame")
    Center.Size = UDim2.new(0, 400, 0, 320)
    Center.Position = UDim2.new(0.5, -200, 0.5, -160)
    Center.BackgroundTransparency = 1
    Center.ZIndex = 102
    Center.Parent = LoadingFrame

    -- Logo outer glow
    local LogoOuter = Instance.new("Frame")
    LogoOuter.Size = UDim2.new(0, 94, 0, 94)
    LogoOuter.Position = UDim2.new(0.5, -47, 0, 12)
    LogoOuter.BackgroundColor3 = Config.AccentColor
    LogoOuter.BackgroundTransparency = 0.8
    LogoOuter.BorderSizePixel = 0
    LogoOuter.ZIndex = 102
    LogoOuter.Parent = Center
    CreateCorner(LogoOuter, UDim.new(0, 20))

    local LogoFrame = Instance.new("Frame")
    LogoFrame.Size = UDim2.new(0, 78, 0, 78)
    LogoFrame.Position = UDim2.new(0.5, -39, 0.5, -39)
    LogoFrame.BackgroundColor3 = Config.AccentColor
    LogoFrame.BorderSizePixel = 0
    LogoFrame.ZIndex = 103
    LogoFrame.Parent = LogoOuter
    CreateCorner(LogoFrame, UDim.new(0, 16))
    CreateGradient(LogoFrame, Config.AccentColor, Config.GlowPurple, 135)

    local LogoText = Instance.new("TextLabel")
    LogoText.Size = UDim2.new(1, 0, 1, 0)
    LogoText.BackgroundTransparency = 1
    LogoText.Text = "N"
    LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoText.TextSize = 40
    LogoText.Font = Config.Font
    LogoText.ZIndex = 104
    LogoText.Parent = LogoFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 120)
    Title.BackgroundTransparency = 1
    Title.Text = "NEXUS HUB"
    Title.TextColor3 = Config.TextColor
    Title.TextSize = 32
    Title.Font = Config.Font
    Title.ZIndex = 103
    Title.Parent = Center

    -- Typing subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, 0, 0, 22)
    Subtitle.Position = UDim2.new(0, 0, 0, 160)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = ""
    Subtitle.TextColor3 = Config.SubTextColor
    Subtitle.TextSize = 13
    Subtitle.Font = Config.FontRegular
    Subtitle.ZIndex = 103
    Subtitle.Parent = Center

    spawn(function()
        local fullText = "Universal Script Hub v3.0 — Enhanced Edition"
        for ci = 1, #fullText do
            Subtitle.Text = fullText:sub(1, ci)
            wait(0.022)
        end
    end)

    local LoadBarBg = Instance.new("Frame")
    LoadBarBg.Size = UDim2.new(0, 300, 0, 6)
    LoadBarBg.Position = UDim2.new(0.5, -150, 0, 215)
    LoadBarBg.BackgroundColor3 = Config.SliderTrack
    LoadBarBg.BorderSizePixel = 0
    LoadBarBg.ZIndex = 103
    LoadBarBg.Parent = Center
    CreateCorner(LoadBarBg, UDim.new(0, 3))

    local LoadBarFill = Instance.new("Frame")
    LoadBarFill.Size = UDim2.new(0, 0, 1, 0)
    LoadBarFill.BackgroundColor3 = Config.AccentColor
    LoadBarFill.BorderSizePixel = 0
    LoadBarFill.ZIndex = 104
    LoadBarFill.Parent = LoadBarBg
    CreateCorner(LoadBarFill, UDim.new(0, 3))
    CreateGradient(LoadBarFill, Config.AccentColor, Config.GlowCyan, 0)

    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(1, 0, 0, 18)
    StatusText.Position = UDim2.new(0, 0, 0, 235)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "Initializing..."
    StatusText.TextColor3 = Config.SubTextColor
    StatusText.TextSize = 11
    StatusText.Font = Config.FontRegular
    StatusText.ZIndex = 103
    StatusText.Parent = Center

    local PercentText = Instance.new("TextLabel")
    PercentText.Size = UDim2.new(1, 0, 0, 20)
    PercentText.Position = UDim2.new(0, 0, 0, 255)
    PercentText.BackgroundTransparency = 1
    PercentText.Text = "0%"
    PercentText.TextColor3 = Config.AccentGlow
    PercentText.TextSize = 15
    PercentText.Font = Config.Font
    PercentText.ZIndex = 103
    PercentText.Parent = Center

    local FeatureList = Instance.new("TextLabel")
    FeatureList.Size = UDim2.new(1, 0, 0, 18)
    FeatureList.Position = UDim2.new(0, 0, 0, 285)
    FeatureList.BackgroundTransparency = 1
    FeatureList.Text = "✈️ Fly  •  🏃 Speed  •  ⬆️ Jump  •  🌍 Gravity  •  👻 Noclip  •  👁️ ESP"
    FeatureList.TextColor3 = Config.MutedText
    FeatureList.TextSize = 10
    FeatureList.Font = Config.FontRegular
    FeatureList.ZIndex = 103
    FeatureList.Parent = Center

    local Credits = Instance.new("TextLabel")
    Credits.Size = UDim2.new(1, 0, 0, 18)
    Credits.Position = UDim2.new(0, 0, 1, -35)
    Credits.BackgroundTransparency = 1
    Credits.Text = "Made with ❤ | Nexus Hub v3.0"
    Credits.TextColor3 = Color3.fromRGB(55, 55, 85)
    Credits.TextSize = 10
    Credits.Font = Config.FontRegular
    Credits.ZIndex = 103
    Credits.Parent = LoadingFrame

    -- Logo pulse
    spawn(function()
        while LogoOuter and LogoOuter.Parent do
            Tween(LogoOuter, {BackgroundTransparency = 0.5, Rotation = 3}, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            wait(1)
            Tween(LogoOuter, {BackgroundTransparency = 0.8, Rotation = -3}, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            wait(1)
        end
    end)

    local loadSteps = {
        {text = "Initializing core modules...", pct = 12},
        {text = "Loading player data...", pct = 24},
        {text = "Setting up fly system...", pct = 36},
        {text = "Configuring walk speed...", pct = 48},
        {text = "Preparing infinite jump...", pct = 58},
        {text = "Loading noclip engine...", pct = 68},
        {text = "Setting up ESP system...", pct = 78},
        {text = "Loading gravity control...", pct = 86},
        {text = "Building user interface...", pct = 94},
        {text = "Ready!", pct = 100},
    }

    for _, step in ipairs(loadSteps) do
        StatusText.Text = step.text
        PercentText.Text = step.pct .. "%"
        Tween(LoadBarFill, {Size = UDim2.new(step.pct / 100, 0, 1, 0)}, 0.3)
        wait(math.random(18, 35) / 100)
    end

    wait(0.4)

    Tween(LoadingFrame, {BackgroundTransparency = 1}, 0.6)
    for _, child in pairs(LoadingFrame:GetDescendants()) do
        if child:IsA("TextLabel") then
            Tween(child, {TextTransparency = 1}, 0.5)
        elseif child:IsA("Frame") then
            Tween(child, {BackgroundTransparency = 1}, 0.5)
        end
    end
    wait(0.65)
    LoadingFrame:Destroy()
end

-- ═══════════════════════════════════════════════════════
-- MAIN GUI
-- ═══════════════════════════════════════════════════════

local function CreateMainGui()
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 390)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -195)
    MainFrame.BackgroundColor3 = Config.PrimaryColor
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    CreateCorner(MainFrame, Config.CornerRadiusLarge)
    CreateStroke(MainFrame, Config.BorderColor, 1, 0.2)

    -- Subtle top glow
    local TopGlow = Instance.new("Frame")
    TopGlow.Size = UDim2.new(1, 0, 0, 60)
    TopGlow.BackgroundColor3 = Config.AccentColor
    TopGlow.BackgroundTransparency = 0.95
    TopGlow.BorderSizePixel = 0
    TopGlow.ZIndex = 0
    TopGlow.Parent = MainFrame
    CreateGradient(TopGlow, Config.AccentColor, Config.PrimaryColor, 90)

    -- ═══════════════════════════════════════════════════
    -- TITLE BAR
    -- ═══════════════════════════════════════════════════
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 46)
    TitleBar.BackgroundColor3 = Config.SecondaryColor
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 5
    TitleBar.Parent = MainFrame
    CreateCorner(TitleBar, Config.CornerRadiusLarge)

    local TitleBarFix = Instance.new("Frame")
    TitleBarFix.Size = UDim2.new(1, 0, 0, 14)
    TitleBarFix.Position = UDim2.new(0, 0, 1, -14)
    TitleBarFix.BackgroundColor3 = Config.SecondaryColor
    TitleBarFix.BorderSizePixel = 0
    TitleBarFix.ZIndex = 5
    TitleBarFix.Parent = TitleBar

    -- Animated accent line
    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(1, 0, 0, 2)
    AccentLine.Position = UDim2.new(0, 0, 1, -2)
    AccentLine.BackgroundColor3 = Config.AccentColor
    AccentLine.BackgroundTransparency = 0.3
    AccentLine.BorderSizePixel = 0
    AccentLine.ZIndex = 6
    AccentLine.Parent = TitleBar
    local accentGrad = CreateGradient(AccentLine, Config.AccentColor, Config.GlowPurple, 0)

    spawn(function()
        local rot = 0
        while AccentLine and AccentLine.Parent do
            rot = (rot + 1) % 360
            accentGrad.Rotation = rot
            wait(0.03)
        end
    end)

    -- Logo
    local LogoSmall = Instance.new("Frame")
    LogoSmall.Size = UDim2.new(0, 28, 0, 28)
    LogoSmall.Position = UDim2.new(0, 12, 0.5, -14)
    LogoSmall.BackgroundColor3 = Config.AccentColor
    LogoSmall.BorderSizePixel = 0
    LogoSmall.ZIndex = 7
    LogoSmall.Parent = TitleBar
    CreateCorner(LogoSmall, UDim.new(0, 7))
    CreateGradient(LogoSmall, Config.AccentColor, Config.GlowPurple, 135)

    local LogoSmallText = Instance.new("TextLabel")
    LogoSmallText.Size = UDim2.new(1, 0, 1, 0)
    LogoSmallText.BackgroundTransparency = 1
    LogoSmallText.Text = "N"
    LogoSmallText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoSmallText.TextSize = 16
    LogoSmallText.Font = Config.Font
    LogoSmallText.ZIndex = 8
    LogoSmallText.Parent = LogoSmall

    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(0, 120, 1, 0)
    TitleText.Position = UDim2.new(0, 48, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "NEXUS HUB"
    TitleText.TextColor3 = Config.TextColor
    TitleText.TextSize = 15
    TitleText.Font = Config.Font
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.ZIndex = 7
    TitleText.Parent = TitleBar

    -- Version badge
    local VersionBadge = Instance.new("Frame")
    VersionBadge.Size = UDim2.new(0, 42, 0, 18)
    VersionBadge.Position = UDim2.new(0, 155, 0.5, -9)
    VersionBadge.BackgroundColor3 = Config.AccentColor
    VersionBadge.BackgroundTransparency = 0.75
    VersionBadge.BorderSizePixel = 0
    VersionBadge.ZIndex = 7
    VersionBadge.Parent = TitleBar
    CreateCorner(VersionBadge, UDim.new(0, 4))

    local VersionText = Instance.new("TextLabel")
    VersionText.Size = UDim2.new(1, 0, 1, 0)
    VersionText.BackgroundTransparency = 1
    VersionText.Text = "v3.0"
    VersionText.TextColor3 = Config.AccentGlow
    VersionText.TextSize = 10
    VersionText.Font = Config.FontSemiBold
    VersionText.ZIndex = 8
    VersionText.Parent = VersionBadge

    -- Uptime
    local UptimeLabel = Instance.new("TextLabel")
    UptimeLabel.Size = UDim2.new(0, 70, 1, 0)
    UptimeLabel.Position = UDim2.new(1, -170, 0, 0)
    UptimeLabel.BackgroundTransparency = 1
    UptimeLabel.Text = "⏱ 00:00"
    UptimeLabel.TextColor3 = Config.MutedText
    UptimeLabel.TextSize = 10
    UptimeLabel.Font = Config.FontRegular
    UptimeLabel.TextXAlignment = Enum.TextXAlignment.Right
    UptimeLabel.ZIndex = 7
    UptimeLabel.Parent = TitleBar

    spawn(function()
        while UptimeLabel and UptimeLabel.Parent do
            State.Uptime = State.Uptime + 1
            UptimeLabel.Text = "⏱ " .. FormatUptime(State.Uptime)
            wait(1)
        end
    end)

    -- macOS-style window buttons
    local function CreateWindowBtn(color, xOff)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 14, 0, 14)
        btn.Position = UDim2.new(1, xOff, 0.5, -7)
        btn.BackgroundColor3 = color
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.ZIndex = 8
        btn.Parent = TitleBar
        CreateCorner(btn, UDim.new(1, 0))
        btn.MouseEnter:Connect(function()
            Tween(btn, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, xOff - 1, 0.5, -8)}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, xOff, 0.5, -7)}, 0.15)
        end)
        return btn
    end

    local CloseBtn = CreateWindowBtn(Config.DangerColor, -18)
    local MinBtn = CreateWindowBtn(Config.WarningColor, -38)
    local PinBtn = CreateWindowBtn(Config.ToggleOn, -58)

    -- Dragging
    local dragging, dragInput, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
    -- SIDEBAR
    -- ═══════════════════════════════════════════════════
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 56, 1, -48)
    Sidebar.Position = UDim2.new(0, 0, 0, 48)
    Sidebar.BackgroundColor3 = Config.SecondaryColor
    Sidebar.BorderSizePixel = 0
    Sidebar.ZIndex = 3
    Sidebar.Parent = MainFrame

    local SidebarFix = Instance.new("Frame")
    SidebarFix.Size = UDim2.new(0, 14, 1, 0)
    SidebarFix.Position = UDim2.new(1, -14, 0, 0)
    SidebarFix.BackgroundColor3 = Config.SecondaryColor
    SidebarFix.BorderSizePixel = 0
    SidebarFix.ZIndex = 3
    SidebarFix.Parent = Sidebar

    local SidebarBtmFix = Instance.new("Frame")
    SidebarBtmFix.Size = UDim2.new(1, 0, 0, 14)
    SidebarBtmFix.Position = UDim2.new(0, 0, 1, -14)
    SidebarBtmFix.BackgroundColor3 = Config.SecondaryColor
    SidebarBtmFix.BorderSizePixel = 0
    SidebarBtmFix.ZIndex = 3
    SidebarBtmFix.Parent = Sidebar
    CreateCorner(SidebarBtmFix, Config.CornerRadiusLarge)

    local SidebarDiv = Instance.new("Frame")
    SidebarDiv.Size = UDim2.new(0, 1, 1, 0)
    SidebarDiv.Position = UDim2.new(1, 0, 0, 0)
    SidebarDiv.BackgroundColor3 = Config.BorderColor
    SidebarDiv.BackgroundTransparency = 0.4
    SidebarDiv.BorderSizePixel = 0
    SidebarDiv.ZIndex = 4
    SidebarDiv.Parent = Sidebar

    local Tabs = {
        {Name = "Home", Icon = "🏠"},
        {Name = "Player", Icon = "👤"},
        {Name = "Movement", Icon = "🏃"},
        {Name = "Visuals", Icon = "👁️"},
        {Name = "World", Icon = "🌍"},
        {Name = "Settings", Icon = "⚙"},
    }

    local TabButtons = {}
    local TabPages = {}

    -- Active indicator
    local ActiveIndicator = Instance.new("Frame")
    ActiveIndicator.Size = UDim2.new(0, 3, 0, 22)
    ActiveIndicator.Position = UDim2.new(0, 0, 0, 19)
    ActiveIndicator.BackgroundColor3 = Config.AccentColor
    ActiveIndicator.BorderSizePixel = 0
    ActiveIndicator.ZIndex = 5
    ActiveIndicator.Parent = Sidebar
    CreateCorner(ActiveIndicator, UDim.new(0, 2))

    for i, tab in ipairs(Tabs) do
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = tab.Name .. "Tab"
        TabBtn.Size = UDim2.new(1, -8, 0, 42)
        TabBtn.Position = UDim2.new(0, 4, 0, 6 + (i - 1) * 48)
        TabBtn.BackgroundColor3 = Config.AccentColor
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = tab.Icon
        TabBtn.TextSize = 19
        TabBtn.Font = Config.FontRegular
        TabBtn.TextColor3 = Config.SubTextColor
        TabBtn.BorderSizePixel = 0
        TabBtn.ZIndex = 4
        TabBtn.ClipsDescendants = true
        TabBtn.Parent = Sidebar
        CreateCorner(TabBtn, UDim.new(0, 8))

        -- Tooltip
        local Tooltip = Instance.new("TextLabel")
        Tooltip.Size = UDim2.new(0, 75, 0, 26)
        Tooltip.Position = UDim2.new(1, 6, 0.5, -13)
        Tooltip.BackgroundColor3 = Config.CardColor
        Tooltip.Text = tab.Name
        Tooltip.TextColor3 = Config.TextColor
        Tooltip.TextSize = 11
        Tooltip.Font = Config.FontSemiBold
        Tooltip.BorderSizePixel = 0
        Tooltip.ZIndex = 50
        Tooltip.Visible = false
        Tooltip.Parent = TabBtn
        CreateCorner(Tooltip, Config.CornerRadiusSmall)
        CreateStroke(Tooltip, Config.BorderColor, 1, 0.4)

        TabBtn.MouseEnter:Connect(function()
            if State.CurrentTab ~= tab.Name then
                Tween(TabBtn, {BackgroundTransparency = 0.85, TextColor3 = Config.TextColor}, 0.2)
            end
            Tooltip.Visible = true
        end)
        TabBtn.MouseLeave:Connect(function()
            if State.CurrentTab ~= tab.Name then
                Tween(TabBtn, {BackgroundTransparency = 1, TextColor3 = Config.SubTextColor}, 0.2)
            end
            Tooltip.Visible = false
        end)

        TabButtons[tab.Name] = {btn = TabBtn, index = i}
    end

    -- ═══════════════════════════════════════════════════
    -- CONTENT AREA
    -- ═══════════════════════════════════════════════════
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -58, 1, -48)
    ContentArea.Position = UDim2.new(0, 58, 0, 48)
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel = 0
    ContentArea.ClipsDescendants = true
    ContentArea.ZIndex = 2
    ContentArea.Parent = MainFrame

    -- ═══════════════════════════════════════════════════
    -- HELPERS
    -- ═══════════════════════════════════════════════════

    local function CreateSectionHeader(parent, text, icon, yPos)
        local h = Instance.new("TextLabel")
        h.Size = UDim2.new(1, -24, 0, 20)
        h.Position = UDim2.new(0, 14, 0, yPos)
        h.BackgroundTransparency = 1
        h.Text = (icon or "") .. "  " .. text
        h.TextColor3 = Config.SubTextColor
        h.TextSize = 11
        h.Font = Config.Font
        h.TextXAlignment = Enum.TextXAlignment.Left
        h.Parent = parent
        return h
    end

    local function CreateToggle(parent, label, desc, yPos, default, callback)
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, -24, 0, 60)
        Container.Position = UDim2.new(0, 12, 0, yPos)
        Container.BackgroundColor3 = Config.CardColor
        Container.BorderSizePixel = 0
        Container.ClipsDescendants = true
        Container.Parent = parent
        CreateCorner(Container, Config.CornerRadius)
        CreateStroke(Container, Config.BorderColor, 1, 0.6)

        local LeftAcc = Instance.new("Frame")
        LeftAcc.Size = UDim2.new(0, 3, 0.6, 0)
        LeftAcc.Position = UDim2.new(0, 0, 0.2, 0)
        LeftAcc.BackgroundColor3 = default and Config.ToggleOn or Config.AccentSoft
        LeftAcc.BackgroundTransparency = 0.4
        LeftAcc.BorderSizePixel = 0
        LeftAcc.Parent = Container
        CreateCorner(LeftAcc, UDim.new(0, 2))

        local LabelT = Instance.new("TextLabel")
        LabelT.Size = UDim2.new(1, -80, 0, 20)
        LabelT.Position = UDim2.new(0, 16, 0, 10)
        LabelT.BackgroundTransparency = 1
        LabelT.Text = label
        LabelT.TextColor3 = Config.TextColor
        LabelT.TextSize = 13
        LabelT.Font = Config.FontSemiBold
        LabelT.TextXAlignment = Enum.TextXAlignment.Left
        LabelT.Parent = Container

        local DescT = Instance.new("TextLabel")
        DescT.Size = UDim2.new(1, -80, 0, 14)
        DescT.Position = UDim2.new(0, 16, 0, 32)
        DescT.BackgroundTransparency = 1
        DescT.Text = desc
        DescT.TextColor3 = Config.SubTextColor
        DescT.TextSize = 10
        DescT.Font = Config.FontRegular
        DescT.TextXAlignment = Enum.TextXAlignment.Left
        DescT.Parent = Container

        local ToggleBg = Instance.new("Frame")
        ToggleBg.Size = UDim2.new(0, 44, 0, 24)
        ToggleBg.Position = UDim2.new(1, -58, 0.5, -12)
        ToggleBg.BackgroundColor3 = default and Config.ToggleOn or Config.ToggleOff
        ToggleBg.BorderSizePixel = 0
        ToggleBg.Parent = Container
        CreateCorner(ToggleBg, UDim.new(0, 12))

        local Circle = Instance.new("Frame")
        Circle.Size = UDim2.new(0, 18, 0, 18)
        Circle.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Circle.BorderSizePixel = 0
        Circle.Parent = ToggleBg
        CreateCorner(Circle, UDim.new(1, 0))

        local toggled = default

        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 1, 0)
        Btn.BackgroundTransparency = 1
        Btn.Text = ""
        Btn.ZIndex = 3
        Btn.Parent = Container

        Btn.MouseButton1Click:Connect(function()
            toggled = not toggled
            Tween(ToggleBg, {BackgroundColor3 = toggled and Config.ToggleOn or Config.ToggleOff}, 0.25)
            Tween(Circle, {Position = toggled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}, 0.25, Enum.EasingStyle.Back)
            Tween(LeftAcc, {BackgroundColor3 = toggled and Config.ToggleOn or Config.AccentSoft}, 0.25)
            Ripple(Container)
            callback(toggled)
        end)

        Btn.MouseEnter:Connect(function() Tween(Container, {BackgroundColor3 = Config.CardHover}, 0.2) end)
        Btn.MouseLeave:Connect(function() Tween(Container, {BackgroundColor3 = Config.CardColor}, 0.2) end)

        return Container
    end

    local function CreateSlider(parent, label, yPos, minVal, maxVal, defaultVal, suffix, callback)
        suffix = suffix or ""
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, -24, 0, 75)
        Container.Position = UDim2.new(0, 12, 0, yPos)
        Container.BackgroundColor3 = Config.CardColor
        Container.BorderSizePixel = 0
        Container.Parent = parent
        CreateCorner(Container, Config.CornerRadius)
        CreateStroke(Container, Config.BorderColor, 1, 0.6)

        local LabelT = Instance.new("TextLabel")
        LabelT.Size = UDim2.new(0.6, 0, 0, 20)
        LabelT.Position = UDim2.new(0, 16, 0, 10)
        LabelT.BackgroundTransparency = 1
        LabelT.Text = label
        LabelT.TextColor3 = Config.TextColor
        LabelT.TextSize = 13
        LabelT.Font = Config.FontSemiBold
        LabelT.TextXAlignment = Enum.TextXAlignment.Left
        LabelT.Parent = Container

        local ValBadge = Instance.new("Frame")
        ValBadge.Size = UDim2.new(0, 60, 0, 20)
        ValBadge.Position = UDim2.new(1, -76, 0, 10)
        ValBadge.BackgroundColor3 = Config.AccentColor
        ValBadge.BackgroundTransparency = 0.8
        ValBadge.BorderSizePixel = 0
        ValBadge.Parent = Container
        CreateCorner(ValBadge, UDim.new(0, 4))

        local ValLabel = Instance.new("TextLabel")
        ValLabel.Size = UDim2.new(1, 0, 1, 0)
        ValLabel.BackgroundTransparency = 1
        ValLabel.Text = tostring(math.floor(defaultVal)) .. suffix
        ValLabel.TextColor3 = Config.AccentGlow
        ValLabel.TextSize = 11
        ValLabel.Font = Config.Font
        ValLabel.Parent = ValBadge

        local Track = Instance.new("Frame")
        Track.Size = UDim2.new(1, -32, 0, 6)
        Track.Position = UDim2.new(0, 16, 0, 48)
        Track.BackgroundColor3 = Config.SliderTrack
        Track.BorderSizePixel = 0
        Track.Parent = Container
        CreateCorner(Track, UDim.new(0, 3))

        local fillPct = (defaultVal - minVal) / (maxVal - minVal)
        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new(fillPct, 0, 1, 0)
        Fill.BackgroundColor3 = Config.AccentColor
        Fill.BorderSizePixel = 0
        Fill.Parent = Track
        CreateCorner(Fill, UDim.new(0, 3))
        CreateGradient(Fill, Config.AccentColor, Config.GlowCyan, 0)

        local Knob = Instance.new("Frame")
        Knob.Size = UDim2.new(0, 16, 0, 16)
        Knob.Position = UDim2.new(fillPct, -8, 0.5, -8)
        Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Knob.BorderSizePixel = 0
        Knob.ZIndex = 5
        Knob.Parent = Track
        CreateCorner(Knob, UDim.new(1, 0))

        local KnobDot = Instance.new("Frame")
        KnobDot.Size = UDim2.new(0, 6, 0, 6)
        KnobDot.Position = UDim2.new(0.5, -3, 0.5, -3)
        KnobDot.BackgroundColor3 = Config.AccentColor
        KnobDot.BorderSizePixel = 0
        KnobDot.ZIndex = 6
        KnobDot.Parent = Knob
        CreateCorner(KnobDot, UDim.new(1, 0))

        local sliding = false
        local SliderBtn = Instance.new("TextButton")
        SliderBtn.Size = UDim2.new(1, 0, 0, 32)
        SliderBtn.Position = UDim2.new(0, 0, 0, 34)
        SliderBtn.BackgroundTransparency = 1
        SliderBtn.Text = ""
        SliderBtn.ZIndex = 3
        SliderBtn.Parent = Container

        local function UpdateSlider(inputX)
            local tPos = Track.AbsolutePosition.X
            local tSize = Track.AbsoluteSize.X
            local rel = math.clamp((inputX - tPos) / tSize, 0, 1)
            local value = math.floor(minVal + (maxVal - minVal) * rel)
            Fill.Size = UDim2.new(rel, 0, 1, 0)
            Knob.Position = UDim2.new(rel, -8, 0.5, -8)
            ValLabel.Text = tostring(value) .. suffix
            callback(value)
        end

        SliderBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = true
                UpdateSlider(input.Position.X)
            end
        end)
        SliderBtn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                UpdateSlider(input.Position.X)
            end
        end)

        SliderBtn.MouseEnter:Connect(function() Tween(Container, {BackgroundColor3 = Config.CardHover}, 0.2) end)
        SliderBtn.MouseLeave:Connect(function() Tween(Container, {BackgroundColor3 = Config.CardColor}, 0.2) end)

        return Container
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
    HomePage.CanvasSize = UDim2.new(0, 0, 0, 430)
    HomePage.Parent = ContentArea

    -- Welcome card
    local WelcomeCard = Instance.new("Frame")
    WelcomeCard.Size = UDim2.new(1, -24, 0, 105)
    WelcomeCard.Position = UDim2.new(0, 12, 0, 10)
    WelcomeCard.BackgroundColor3 = Config.AccentColor
    WelcomeCard.BackgroundTransparency = 0.4
    WelcomeCard.BorderSizePixel = 0
    WelcomeCard.ClipsDescendants = true
    WelcomeCard.Parent = HomePage
    CreateCorner(WelcomeCard, Config.CornerRadius)
    CreateGradient(WelcomeCard, Config.AccentColor, Config.GlowPurple, 30)

    -- Decorative circles
    local Deco1 = Instance.new("Frame")
    Deco1.Size = UDim2.new(0, 100, 0, 100)
    Deco1.Position = UDim2.new(1, -50, 0, -25)
    Deco1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Deco1.BackgroundTransparency = 0.93
    Deco1.BorderSizePixel = 0
    Deco1.Parent = WelcomeCard
    CreateCorner(Deco1, UDim.new(1, 0))

    local Deco2 = Instance.new("Frame")
    Deco2.Size = UDim2.new(0, 70, 0, 70)
    Deco2.Position = UDim2.new(1, -95, 0, 50)
    Deco2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Deco2.BackgroundTransparency = 0.96
    Deco2.BorderSizePixel = 0
    Deco2.Parent = WelcomeCard
    CreateCorner(Deco2, UDim.new(1, 0))

    local WTitle = Instance.new("TextLabel")
    WTitle.Size = UDim2.new(0.7, 0, 0, 28)
    WTitle.Position = UDim2.new(0, 16, 0, 14)
    WTitle.BackgroundTransparency = 1
    WTitle.Text = "Welcome back, " .. LocalPlayer.DisplayName .. "! 👋"
    WTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    WTitle.TextSize = 18
    WTitle.Font = Config.Font
    WTitle.TextXAlignment = Enum.TextXAlignment.Left
    WTitle.ZIndex = 2
    WTitle.Parent = WelcomeCard

    local WDesc = Instance.new("TextLabel")
    WDesc.Size = UDim2.new(0.72, 0, 0, 40)
    WDesc.Position = UDim2.new(0, 16, 0, 48)
    WDesc.BackgroundTransparency = 1
    WDesc.Text = "Nexus Hub v3.0 is ready. Navigate features using the sidebar.\nPress RightControl to toggle GUI visibility."
    WDesc.TextColor3 = Color3.fromRGB(210, 210, 235)
    WDesc.TextSize = 11
    WDesc.Font = Config.FontRegular
    WDesc.TextXAlignment = Enum.TextXAlignment.Left
    WDesc.TextWrapped = true
    WDesc.ZIndex = 2
    WDesc.Parent = WelcomeCard

    -- Stat cards
    local function CreateStatCard(parent, title, value, icon, xPos, yPos, color)
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(0.5, -18, 0, 68)
        Card.Position = UDim2.new(xPos, 12, 0, yPos)
        Card.BackgroundColor3 = Config.CardColor
        Card.BorderSizePixel = 0
        Card.Parent = parent
        CreateCorner(Card, Config.CornerRadius)
        CreateStroke(Card, Config.BorderColor, 1, 0.6)

        local IconBg = Instance.new("Frame")
        IconBg.Size = UDim2.new(0, 34, 0, 34)
        IconBg.Position = UDim2.new(0, 10, 0.5, -17)
        IconBg.BackgroundColor3 = color or Config.AccentColor
        IconBg.BackgroundTransparency = 0.85
        IconBg.BorderSizePixel = 0
        IconBg.Parent = Card
        CreateCorner(IconBg, UDim.new(0, 8))

        local IconL = Instance.new("TextLabel")
        IconL.Size = UDim2.new(1, 0, 1, 0)
        IconL.BackgroundTransparency = 1
        IconL.Text = icon
        IconL.TextSize = 17
        IconL.Parent = IconBg

        local STitle = Instance.new("TextLabel")
        STitle.Size = UDim2.new(1, -54, 0, 14)
        STitle.Position = UDim2.new(0, 50, 0, 14)
        STitle.BackgroundTransparency = 1
        STitle.Text = title
        STitle.TextColor3 = Config.SubTextColor
        STitle.TextSize = 10
        STitle.Font = Config.FontRegular
        STitle.TextXAlignment = Enum.TextXAlignment.Left
        STitle.Parent = Card

        local SValue = Instance.new("TextLabel")
        SValue.Size = UDim2.new(1, -54, 0, 22)
        SValue.Position = UDim2.new(0, 50, 0, 30)
        SValue.BackgroundTransparency = 1
        SValue.Text = value
        SValue.TextColor3 = color or Config.TextColor
        SValue.TextSize = 16
        SValue.Font = Config.Font
        SValue.TextXAlignment = Enum.TextXAlignment.Left
        SValue.Parent = Card

        return Card, SValue
    end

    local _, flyStatVal = CreateStatCard(HomePage, "Fly", "OFF", "✈️", 0, 125, Config.DangerColor)
    local _, jumpStatVal = CreateStatCard(HomePage, "Inf. Jump", "OFF", "⬆️", 0.5, 125, Config.DangerColor)
    local _, speedStatVal = CreateStatCard(HomePage, "WalkSpeed", tostring(Config.DefaultWalkSpeed), "🏃", 0, 200, Config.AccentGlow)
    local _, gravStatVal = CreateStatCard(HomePage, "Gravity", tostring(Config.DefaultGravity), "🌍", 0.5, 200, Config.AccentGlow)

    -- Quick actions
    CreateSectionHeader(HomePage, "QUICK ACTIONS", "⚡", 280)

    local function CreateQuickAction(parent, text, icon, xPos, yPos, color, onClick)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(0.333, -14, 0, 48)
        Btn.Position = UDim2.new(xPos, 12, 0, yPos)
        Btn.BackgroundColor3 = Config.CardColor
        Btn.BorderSizePixel = 0
        Btn.Text = ""
        Btn.ClipsDescendants = true
        Btn.Parent = parent
        CreateCorner(Btn, Config.CornerRadius)
        CreateStroke(Btn, Config.BorderColor, 1, 0.6)

        local BIcon = Instance.new("TextLabel")
        BIcon.Size = UDim2.new(1, 0, 0, 20)
        BIcon.Position = UDim2.new(0, 0, 0, 5)
        BIcon.BackgroundTransparency = 1
        BIcon.Text = icon
        BIcon.TextSize = 15
        BIcon.Parent = Btn

        local BText = Instance.new("TextLabel")
        BText.Size = UDim2.new(1, 0, 0, 14)
        BText.Position = UDim2.new(0, 0, 0, 27)
        BText.BackgroundTransparency = 1
        BText.Text = text
        BText.TextColor3 = Config.SubTextColor
        BText.TextSize = 10
        BText.Font = Config.FontSemiBold
        BText.Parent = Btn

        Btn.MouseEnter:Connect(function()
            Tween(Btn, {BackgroundColor3 = Config.CardHover}, 0.2)
            Tween(BText, {TextColor3 = color or Config.TextColor}, 0.2)
        end)
        Btn.MouseLeave:Connect(function()
            Tween(Btn, {BackgroundColor3 = Config.CardColor}, 0.2)
            Tween(BText, {TextColor3 = Config.SubTextColor}, 0.2)
        end)
        Btn.MouseButton1Click:Connect(function()
            Ripple(Btn)
            if onClick then onClick() end
        end)
    end

    CreateQuickAction(HomePage, "Rejoin", "🔄", 0, 304, Config.AccentGlow, function()
        ShowNotification("Rejoin", "Teleporting to server...", 2, "info")
        pcall(function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId) end)
    end)

    CreateQuickAction(HomePage, "Reset", "💀", 0.333, 304, Config.DangerColor, function()
        local c = LocalPlayer.Character
        if c then
            local h = c:FindFirstChild("Humanoid")
            if h then h.Health = 0; ShowNotification("Reset", "Character reset!", 2, "warning") end
        end
    end)

    CreateQuickAction(HomePage, "Copy ID", "📋", 0.666, 304, Config.ToggleOn, function()
        pcall(function()
            setclipboard(tostring(LocalPlayer.UserId))
            ShowNotification("Copied", "User ID copied!", 2, "success")
        end)
    end)

    local TipText = Instance.new("TextLabel")
    TipText.Size = UDim2.new(1, -24, 0, 40)
    TipText.Position = UDim2.new(0, 12, 0, 368)
    TipText.BackgroundTransparency = 1
    TipText.Text = "💡 Tip: Use Movement for Fly, Speed & Jump. Visuals for ESP. World for Gravity."
    TipText.TextColor3 = Config.MutedText
    TipText.TextSize = 10
    TipText.Font = Config.FontRegular
    TipText.TextXAlignment = Enum.TextXAlignment.Left
    TipText.TextWrapped = true
    TipText.Parent = HomePage

    TabPages["Home"] = HomePage

    -- ═══════════════════════════════════════════════════
    -- PAGE: PLAYER
    -- ═══════════════════════════════════════════════════
    local PlayerPage = Instance.new("ScrollingFrame")
    PlayerPage.Name = "PlayerPage"
    PlayerPage.Size = UDim2.new(1, 0, 1, 0)
    PlayerPage.BackgroundTransparency = 1
    PlayerPage.BorderSizePixel = 0
    PlayerPage.ScrollBarThickness = 3
    PlayerPage.ScrollBarImageColor3 = Config.AccentColor
    PlayerPage.CanvasSize = UDim2.new(0, 0, 0, 620)
    PlayerPage.Visible = false
    PlayerPage.Parent = ContentArea

    -- Avatar card
    local AvatarCard = Instance.new("Frame")
    AvatarCard.Size = UDim2.new(1, -24, 0, 110)
    AvatarCard.Position = UDim2.new(0, 12, 0, 10)
    AvatarCard.BackgroundColor3 = Config.CardColor
    AvatarCard.BorderSizePixel = 0
    AvatarCard.ClipsDescendants = true
    AvatarCard.Parent = PlayerPage
    CreateCorner(AvatarCard, Config.CornerRadius)
    CreateStroke(AvatarCard, Config.BorderColor, 1, 0.5)

    local AvatarBanner = Instance.new("Frame")
    AvatarBanner.Size = UDim2.new(1, 0, 0, 38)
    AvatarBanner.BackgroundColor3 = Config.AccentColor
    AvatarBanner.BackgroundTransparency = 0.6
    AvatarBanner.BorderSizePixel = 0
    AvatarBanner.Parent = AvatarCard
    CreateGradient(AvatarBanner, Config.AccentColor, Config.GlowPurple, 0)

    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Size = UDim2.new(0, 65, 0, 65)
    AvatarImage.Position = UDim2.new(0, 16, 0, 26)
    AvatarImage.BackgroundColor3 = Config.SliderTrack
    AvatarImage.BorderSizePixel = 0
    AvatarImage.ZIndex = 3
    AvatarImage.Parent = AvatarCard
    CreateCorner(AvatarImage, UDim.new(1, 0))
    CreateStroke(AvatarImage, Config.AccentColor, 2, 0.3)

    pcall(function()
        local content = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        AvatarImage.Image = content
    end)

    local PName = Instance.new("TextLabel")
    PName.Size = UDim2.new(1, -110, 0, 22)
    PName.Position = UDim2.new(0, 92, 0, 36)
    PName.BackgroundTransparency = 1
    PName.Text = LocalPlayer.Name
    PName.TextColor3 = Config.TextColor
    PName.TextSize = 17
    PName.Font = Config.Font
    PName.TextXAlignment = Enum.TextXAlignment.Left
    PName.ZIndex = 3
    PName.Parent = AvatarCard

    local DName = Instance.new("TextLabel")
    DName.Size = UDim2.new(1, -110, 0, 16)
    DName.Position = UDim2.new(0, 92, 0, 58)
    DName.BackgroundTransparency = 1
    DName.Text = "@" .. LocalPlayer.DisplayName
    DName.TextColor3 = Config.SubTextColor
    DName.TextSize = 12
    DName.Font = Config.FontRegular
    DName.TextXAlignment = Enum.TextXAlignment.Left
    DName.ZIndex = 3
    DName.Parent = AvatarCard

    local OnlineBadge = Instance.new("Frame")
    OnlineBadge.Size = UDim2.new(0, 68, 0, 20)
    OnlineBadge.Position = UDim2.new(0, 92, 0, 78)
    OnlineBadge.BackgroundColor3 = Config.ToggleOn
    OnlineBadge.BackgroundTransparency = 0.8
    OnlineBadge.BorderSizePixel = 0
    OnlineBadge.ZIndex = 3
    OnlineBadge.Parent = AvatarCard
    CreateCorner(OnlineBadge, UDim.new(0, 4))

    local OnlineT = Instance.new("TextLabel")
    OnlineT.Size = UDim2.new(1, 0, 1, 0)
    OnlineT.BackgroundTransparency = 1
    OnlineT.Text = "● Online"
    OnlineT.TextColor3 = Config.ToggleOn
    OnlineT.TextSize = 10
    OnlineT.Font = Config.FontSemiBold
    OnlineT.ZIndex = 3
    OnlineT.Parent = OnlineBadge

    local function CreateInfoRow(parent, label, value, yPos, icon)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, -24, 0, 44)
        Row.Position = UDim2.new(0, 12, 0, yPos)
        Row.BackgroundColor3 = Config.CardColor
        Row.BorderSizePixel = 0
        Row.Parent = parent
        CreateCorner(Row, Config.CornerRadius)
        CreateStroke(Row, Config.BorderColor, 1, 0.7)

        local IL = Instance.new("TextLabel")
        IL.Size = UDim2.new(0, 28, 1, 0)
        IL.Position = UDim2.new(0, 10, 0, 0)
        IL.BackgroundTransparency = 1
        IL.Text = icon or "📋"
        IL.TextSize = 14
        IL.Parent = Row

        local LL = Instance.new("TextLabel")
        LL.Size = UDim2.new(0.4, 0, 1, 0)
        LL.Position = UDim2.new(0, 40, 0, 0)
        LL.BackgroundTransparency = 1
        LL.Text = label
        LL.TextColor3 = Config.SubTextColor
        LL.TextSize = 12
        LL.Font = Config.FontRegular
        LL.TextXAlignment = Enum.TextXAlignment.Left
        LL.Parent = Row

        local VL = Instance.new("TextLabel")
        VL.Size = UDim2.new(0.5, -16, 1, 0)
        VL.Position = UDim2.new(0.5, 0, 0, 0)
        VL.BackgroundTransparency = 1
        VL.Text = value
        VL.TextColor3 = Config.TextColor
        VL.TextSize = 12
        VL.Font = Config.FontSemiBold
        VL.TextXAlignment = Enum.TextXAlignment.Right
        VL.Parent = Row
    end

    CreateSectionHeader(PlayerPage, "ACCOUNT INFORMATION", "📊", 130)
    CreateInfoRow(PlayerPage, "Username", LocalPlayer.Name, 154, "👤")
    CreateInfoRow(PlayerPage, "Display Name", LocalPlayer.DisplayName, 204, "🏷️")
    CreateInfoRow(PlayerPage, "User ID", tostring(LocalPlayer.UserId), 254, "🔑")
    CreateInfoRow(PlayerPage, "Account Age", GetAccountAge(), 304, "📅")
    CreateInfoRow(PlayerPage, "Team", LocalPlayer.Team and LocalPlayer.Team.Name or "None", 354, "🏁")

    local membershipText = "Standard"
    pcall(function()
        if LocalPlayer.MembershipType == Enum.MembershipType.Premium then membershipText = "⭐ Premium" end
    end)
    CreateInfoRow(PlayerPage, "Membership", membershipText, 404, "💎")

    CreateSectionHeader(PlayerPage, "GAME INFORMATION", "🎮", 458)
    local placeIdStr = "N/A"
    pcall(function() placeIdStr = tostring(game.PlaceId) end)
    CreateInfoRow(PlayerPage, "Place ID", placeIdStr, 482, "🎮")

    local jobIdStr = "N/A"
    pcall(function() jobIdStr = string.sub(tostring(game.JobId), 1, 12) .. "..." end)
    CreateInfoRow(PlayerPage, "Server ID", jobIdStr, 532, "🖥️")
    CreateInfoRow(PlayerPage, "Players", tostring(#Players:GetPlayers()) .. "/" .. tostring(Players.MaxPlayers), 582, "👥")

    TabPages["Player"] = PlayerPage

    -- ═══════════════════════════════════════════════════
    -- PAGE: MOVEMENT
    -- ═══════════════════════════════════════════════════
    local MovementPage = Instance.new("ScrollingFrame")
    MovementPage.Name = "MovementPage"
    MovementPage.Size = UDim2.new(1, 0, 1, 0)
    MovementPage.BackgroundTransparency = 1
    MovementPage.BorderSizePixel = 0
    MovementPage.ScrollBarThickness = 3
    MovementPage.ScrollBarImageColor3 = Config.AccentColor
    MovementPage.CanvasSize = UDim2.new(0, 0, 0, 590)
    MovementPage.Visible = false
    MovementPage.Parent = ContentArea

    CreateSectionHeader(MovementPage, "FLY SYSTEM", "✈️", 8)

    CreateToggle(MovementPage, "Enable Fly", "WASD to move, Space/Shift for up/down.", 30, false, function(enabled)
        State.FlyEnabled = enabled
        flyStatVal.Text = enabled and "ON" or "OFF"
        flyStatVal.TextColor3 = enabled and Config.ToggleOn or Config.DangerColor

        local character = LocalPlayer.Character
        if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local hum = character:FindFirstChild("Humanoid")
        if not hrp or not hum then return end

        if enabled then
            State.BodyVelocity = Instance.new("BodyVelocity")
            State.BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            State.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            State.BodyVelocity.Parent = hrp

            State.BodyGyro = Instance.new("BodyGyro")
            State.BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            State.BodyGyro.D = 200
            State.BodyGyro.P = 10000
            State.BodyGyro.Parent = hrp

            hum.PlatformStand = true

            State.FlyConnection = RunService.RenderStepped:Connect(function()
                if not State.FlyEnabled then return end
                local cam = Workspace.CurrentCamera
                local dir = Vector3.new(0, 0, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
                if dir.Magnitude > 0 then dir = dir.Unit end
                State.BodyVelocity.Velocity = dir * State.FlySpeed
                State.BodyGyro.CFrame = cam.CFrame
            end)
            ShowNotification("Fly", "Fly mode enabled!", 2, "success")
        else
            hum.PlatformStand = false
            if State.BodyVelocity then State.BodyVelocity:Destroy(); State.BodyVelocity = nil end
            if State.BodyGyro then State.BodyGyro:Destroy(); State.BodyGyro = nil end
            if State.FlyConnection then State.FlyConnection:Disconnect(); State.FlyConnection = nil end
            ShowNotification("Fly", "Fly mode disabled.", 2, "info")
        end
    end)

    CreateSlider(MovementPage, "Fly Speed", 98, 10, 500, Config.DefaultFlySpeed, "", function(v) State.FlySpeed = v end)

    CreateSectionHeader(MovementPage, "WALK SPEED", "🏃", 185)
    CreateSlider(MovementPage, "Walk Speed", 207, 0, 500, Config.DefaultWalkSpeed, "", function(v)
        State.WalkSpeed = v
        speedStatVal.Text = tostring(v)
        local c = LocalPlayer.Character
        if c then local h = c:FindFirstChild("Humanoid"); if h then h.WalkSpeed = v end end
    end)

    CreateSectionHeader(MovementPage, "JUMP POWER", "🦘", 294)
    CreateSlider(MovementPage, "Jump Power", 316, 0, 500, Config.DefaultJumpPower, "", function(v)
        State.JumpPower = v
        local c = LocalPlayer.Character
        if c then local h = c:FindFirstChild("Humanoid"); if h then h.JumpPower = v; h.UseJumpPower = true end end
    end)

    CreateSectionHeader(MovementPage, "INFINITE JUMP", "⬆️", 403)
    CreateToggle(MovementPage, "Enable Infinite Jump", "Jump unlimited times in mid-air.", 425, false, function(enabled)
        State.InfiniteJumpEnabled = enabled
        jumpStatVal.Text = enabled and "ON" or "OFF"
        jumpStatVal.TextColor3 = enabled and Config.ToggleOn or Config.DangerColor
        ShowNotification("Infinite Jump", enabled and "Enabled!" or "Disabled.", 2, enabled and "success" or "info")
    end)

    CreateSectionHeader(MovementPage, "NOCLIP", "👻", 497)
    CreateToggle(MovementPage, "Enable Noclip", "Walk through walls and objects.", 519, false, function(enabled)
        State.NoclipEnabled = enabled
        if enabled then
            State.NoclipConnection = RunService.Stepped:Connect(function()
                if State.NoclipEnabled then
                    local c = LocalPlayer.Character
                    if c then
                        for _, p in pairs(c:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end
                end
            end)
            ShowNotification("Noclip", "Noclip enabled!", 2, "success")
        else
            if State.NoclipConnection then State.NoclipConnection:Disconnect(); State.NoclipConnection = nil end
            local c = LocalPlayer.Character
            if c then for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end
            ShowNotification("Noclip", "Noclip disabled.", 2, "info")
        end
    end)

    UserInputService.JumpRequest:Connect(function()
        if State.InfiniteJumpEnabled then
            local c = LocalPlayer.Character
            if c then local h = c:FindFirstChild("Humanoid"); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
        end
    end)

    TabPages["Movement"] = MovementPage

    -- ═══════════════════════════════════════════════════
    -- PAGE: VISUALS (NEW)
    -- ═══════════════════════════════════════════════════
    local VisualsPage = Instance.new("ScrollingFrame")
    VisualsPage.Name = "VisualsPage"
    VisualsPage.Size = UDim2.new(1, 0, 1, 0)
    VisualsPage.BackgroundTransparency = 1
    VisualsPage.BorderSizePixel = 0
    VisualsPage.ScrollBarThickness = 3
    VisualsPage.ScrollBarImageColor3 = Config.AccentColor
    VisualsPage.CanvasSize = UDim2.new(0, 0, 0, 280)
    VisualsPage.Visible = false
    VisualsPage.Parent = ContentArea

    CreateSectionHeader(VisualsPage, "PLAYER ESP", "👁️", 8)

    local ESPInfo = Instance.new("Frame")
    ESPInfo.Size = UDim2.new(1, -24, 0, 45)
    ESPInfo.Position = UDim2.new(0, 12, 0, 30)
    ESPInfo.BackgroundColor3 = Config.AccentColor
    ESPInfo.BackgroundTransparency = 0.85
    ESPInfo.BorderSizePixel = 0
    ESPInfo.Parent = VisualsPage
    CreateCorner(ESPInfo, Config.CornerRadius)

    local ESPInfoT = Instance.new("TextLabel")
    ESPInfoT.Size = UDim2.new(1, -16, 1, -8)
    ESPInfoT.Position = UDim2.new(0, 8, 0, 4)
    ESPInfoT.BackgroundTransparency = 1
    ESPInfoT.Text = "💡 ESP highlights other players with visible outlines and name tags through walls."
    ESPInfoT.TextColor3 = Color3.fromRGB(170, 180, 255)
    ESPInfoT.TextSize = 10
    ESPInfoT.Font = Config.FontRegular
    ESPInfoT.TextXAlignment = Enum.TextXAlignment.Left
    ESPInfoT.TextWrapped = true
    ESPInfoT.Parent = ESPInfo

    local function ClearESP()
        for _, obj in pairs(State.ESPObjects) do
            if obj and obj.Parent then obj:Destroy() end
        end
        State.ESPObjects = {}
    end

    local function CreateESP()
        ClearESP()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "NexusESP"
                    bb.Size = UDim2.new(0, 110, 0, 36)
                    bb.StudsOffset = Vector3.new(0, 3, 0)
                    bb.AlwaysOnTop = true
                    bb.Adornee = head
                    bb.Parent = head

                    local nl = Instance.new("TextLabel")
                    nl.Size = UDim2.new(1, 0, 0.6, 0)
                    nl.BackgroundTransparency = 1
                    nl.Text = player.DisplayName
                    nl.TextColor3 = Config.AccentGlow
                    nl.TextSize = 13
                    nl.Font = Config.FontSemiBold
                    nl.TextStrokeTransparency = 0.5
                    nl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    nl.Parent = bb

                    local dl = Instance.new("TextLabel")
                    dl.Name = "Dist"
                    dl.Size = UDim2.new(1, 0, 0.4, 0)
                    dl.Position = UDim2.new(0, 0, 0.6, 0)
                    dl.BackgroundTransparency = 1
                    dl.Text = "0m"
                    dl.TextColor3 = Config.SubTextColor
                    dl.TextSize = 10
                    dl.Font = Config.FontRegular
                    dl.TextStrokeTransparency = 0.5
                    dl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    dl.Parent = bb

                    local hl = Instance.new("Highlight")
                    hl.Name = "NexusHL"
                    hl.FillColor = Config.AccentColor
                    hl.FillTransparency = 0.7
                    hl.OutlineColor = Config.AccentGlow
                    hl.OutlineTransparency = 0.2
                    hl.Parent = player.Character

                    table.insert(State.ESPObjects, bb)
                    table.insert(State.ESPObjects, hl)
                end
            end
        end
    end

    CreateToggle(VisualsPage, "Enable ESP", "See player names & outlines through walls.", 82, false, function(enabled)
        State.ESPEnabled = enabled
        if enabled then
            CreateESP()
            spawn(function()
                while State.ESPEnabled do
                    local myC = LocalPlayer.Character
                    local myR = myC and myC:FindFirstChild("HumanoidRootPart")
                    if myR then
                        for _, pl in pairs(Players:GetPlayers()) do
                            if pl ~= LocalPlayer and pl.Character then
                                local hd = pl.Character:FindFirstChild("Head")
                                if hd then
                                    local bb = hd:FindFirstChild("NexusESP")
                                    if bb then
                                        local d = bb:FindFirstChild("Dist")
                                        if d then d.Text = math.floor((myR.Position - hd.Position).Magnitude) .. "m" end
                                    end
                                end
                            end
                        end
                    end
                    wait(0.5)
                end
            end)
            ShowNotification("ESP", "ESP enabled!", 2, "success")
        else
            ClearESP()
            ShowNotification("ESP", "ESP disabled.", 2, "info")
        end
    end)

    CreateSectionHeader(VisualsPage, "FIELD OF VIEW", "🔭", 155)
    CreateSlider(VisualsPage, "Camera FOV", 178, 30, 120, Config.DefaultFOV, "°", function(v)
        State.FOV = v
        pcall(function() Workspace.CurrentCamera.FieldOfView = v end)
    end)

    TabPages["Visuals"] = VisualsPage

    -- ═══════════════════════════════════════════════════
    -- PAGE: WORLD
    -- ═══════════════════════════════════════════════════
    local WorldPage = Instance.new("ScrollingFrame")
    WorldPage.Name = "WorldPage"
    WorldPage.Size = UDim2.new(1, 0, 1, 0)
    WorldPage.BackgroundTransparency = 1
    WorldPage.BorderSizePixel = 0
    WorldPage.ScrollBarThickness = 3
    WorldPage.ScrollBarImageColor3 = Config.AccentColor
    WorldPage.CanvasSize = UDim2.new(0, 0, 0, 340)
    WorldPage.Visible = false
    WorldPage.Parent = ContentArea

    CreateSectionHeader(WorldPage, "GRAVITY CONTROL", "🌍", 8)

    local GravInfo = Instance.new("Frame")
    GravInfo.Size = UDim2.new(1, -24, 0, 42)
    GravInfo.Position = UDim2.new(0, 12, 0, 30)
    GravInfo.BackgroundColor3 = Config.AccentColor
    GravInfo.BackgroundTransparency = 0.85
    GravInfo.BorderSizePixel = 0
    GravInfo.Parent = WorldPage
    CreateCorner(GravInfo, Config.CornerRadius)

    local GravInfoT = Instance.new("TextLabel")
    GravInfoT.Size = UDim2.new(1, -16, 1, -8)
    GravInfoT.Position = UDim2.new(0, 8, 0, 4)
    GravInfoT.BackgroundTransparency = 1
    GravInfoT.Text = "💡 Default: 196.2. Lower = Moon-like. Higher = Heavy gravity."
    GravInfoT.TextColor3 = Color3.fromRGB(170, 180, 255)
    GravInfoT.TextSize = 10
    GravInfoT.Font = Config.FontRegular
    GravInfoT.TextXAlignment = Enum.TextXAlignment.Left
    GravInfoT.TextWrapped = true
    GravInfoT.Parent = GravInfo

    CreateSlider(WorldPage, "Gravity", 82, 0, 800, Config.DefaultGravity, "", function(v)
        State.Gravity = v
        gravStatVal.Text = tostring(v)
        Workspace.Gravity = v
    end)

    CreateSectionHeader(WorldPage, "PRESETS", "🎯", 170)

    local presets = {
        {Name = "🌙 Moon", Value = 30, Color = Color3.fromRGB(180, 180, 220)},
        {Name = "🌍 Earth", Value = 196.2, Color = Color3.fromRGB(100, 180, 100)},
        {Name = "🪐 Jupiter", Value = 500, Color = Color3.fromRGB(220, 150, 80)},
        {Name = "🕳️ Zero-G", Value = 0, Color = Color3.fromRGB(150, 100, 255)},
        {Name = "🔴 Mars", Value = 72, Color = Color3.fromRGB(220, 80, 60)},
        {Name = "⚫ Heavy", Value = 750, Color = Color3.fromRGB(180, 180, 180)},
    }

    for i, preset in ipairs(presets) do
        local col = ((i - 1) % 3)
        local row = math.floor((i - 1) / 3)
        local PBtn = Instance.new("TextButton")
        PBtn.Size = UDim2.new(0.333, -14, 0, 42)
        PBtn.Position = UDim2.new(col * 0.333, 12, 0, 194 + row * 50)
        PBtn.BackgroundColor3 = Config.CardColor
        PBtn.BorderSizePixel = 0
        PBtn.Text = preset.Name
        PBtn.TextColor3 = preset.Color
        PBtn.TextSize = 11
        PBtn.Font = Config.FontSemiBold
        PBtn.ClipsDescendants = true
        PBtn.Parent = WorldPage
        CreateCorner(PBtn, Config.CornerRadius)
        CreateStroke(PBtn, Config.BorderColor, 1, 0.6)

        PBtn.MouseEnter:Connect(function() Tween(PBtn, {BackgroundColor3 = Config.CardHover}, 0.2) end)
        PBtn.MouseLeave:Connect(function() Tween(PBtn, {BackgroundColor3 = Config.CardColor}, 0.2) end)
        PBtn.MouseButton1Click:Connect(function()
            Ripple(PBtn)
            Workspace.Gravity = preset.Value
            State.Gravity = preset.Value
            gravStatVal.Text = tostring(preset.Value)
            ShowNotification("Gravity", "Set to " .. preset.Name, 2, "success")
            Tween(PBtn, {BackgroundColor3 = preset.Color, BackgroundTransparency = 0.5}, 0.15)
            wait(0.2)
            Tween(PBtn, {BackgroundColor3 = Config.CardColor, BackgroundTransparency = 0}, 0.3)
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
    SettingsPage.CanvasSize = UDim2.new(0, 0, 0, 360)
    SettingsPage.Visible = false
    SettingsPage.Parent = ContentArea

    CreateSectionHeader(SettingsPage, "SETTINGS", "⚙", 8)

    -- Reset
    local ResetCard = Instance.new("Frame")
    ResetCard.Size = UDim2.new(1, -24, 0, 58)
    ResetCard.Position = UDim2.new(0, 12, 0, 32)
    ResetCard.BackgroundColor3 = Config.CardColor
    ResetCard.BorderSizePixel = 0
    ResetCard.Parent = SettingsPage
    CreateCorner(ResetCard, Config.CornerRadius)
    CreateStroke(ResetCard, Config.BorderColor, 1, 0.6)

    local RL = Instance.new("TextLabel")
    RL.Size = UDim2.new(0.6, 0, 0, 20)
    RL.Position = UDim2.new(0, 16, 0, 8)
    RL.BackgroundTransparency = 1
    RL.Text = "Reset All Settings"
    RL.TextColor3 = Config.TextColor
    RL.TextSize = 13
    RL.Font = Config.FontSemiBold
    RL.TextXAlignment = Enum.TextXAlignment.Left
    RL.Parent = ResetCard

    local RD = Instance.new("TextLabel")
    RD.Size = UDim2.new(0.6, 0, 0, 14)
    RD.Position = UDim2.new(0, 16, 0, 30)
    RD.BackgroundTransparency = 1
    RD.Text = "Reset everything to default values"
    RD.TextColor3 = Config.SubTextColor
    RD.TextSize = 10
    RD.Font = Config.FontRegular
    RD.TextXAlignment = Enum.TextXAlignment.Left
    RD.Parent = ResetCard

    local ResetBtn = Instance.new("TextButton")
    ResetBtn.Size = UDim2.new(0, 80, 0, 32)
    ResetBtn.Position = UDim2.new(1, -95, 0.5, -16)
    ResetBtn.BackgroundColor3 = Config.DangerColor
    ResetBtn.Text = "Reset"
    ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ResetBtn.TextSize = 12
    ResetBtn.Font = Config.FontSemiBold
    ResetBtn.BorderSizePixel = 0
    ResetBtn.ClipsDescendants = true
    ResetBtn.Parent = ResetCard
    CreateCorner(ResetBtn, UDim.new(0, 7))

    ResetBtn.MouseEnter:Connect(function() Tween(ResetBtn, {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}, 0.2) end)
    ResetBtn.MouseLeave:Connect(function() Tween(ResetBtn, {BackgroundColor3 = Config.DangerColor}, 0.2) end)

    ResetBtn.MouseButton1Click:Connect(function()
        Ripple(ResetBtn)
        State.FlyEnabled = false
        State.InfiniteJumpEnabled = false
        State.NoclipEnabled = false
        State.ESPEnabled = false
        State.WalkSpeed = Config.DefaultWalkSpeed
        State.FlySpeed = Config.DefaultFlySpeed
        State.Gravity = Config.DefaultGravity
        State.JumpPower = Config.DefaultJumpPower
        State.FOV = Config.DefaultFOV

        Workspace.Gravity = Config.DefaultGravity
        pcall(function() Workspace.CurrentCamera.FieldOfView = Config.DefaultFOV end)
        ClearESP()
        if State.NoclipConnection then State.NoclipConnection:Disconnect(); State.NoclipConnection = nil end

        local c = LocalPlayer.Character
        if c then
            local h = c:FindFirstChild("Humanoid")
            if h then h.WalkSpeed = Config.DefaultWalkSpeed; h.JumpPower = Config.DefaultJumpPower; h.PlatformStand = false end
        end

        if State.BodyVelocity then State.BodyVelocity:Destroy(); State.BodyVelocity = nil end
        if State.BodyGyro then State.BodyGyro:Destroy(); State.BodyGyro = nil end
        if State.FlyConnection then State.FlyConnection:Disconnect(); State.FlyConnection = nil end

        flyStatVal.Text = "OFF"; flyStatVal.TextColor3 = Config.DangerColor
        jumpStatVal.Text = "OFF"; jumpStatVal.TextColor3 = Config.DangerColor
        speedStatVal.Text = tostring(Config.DefaultWalkSpeed)
        gravStatVal.Text = tostring(Config.DefaultGravity)

        Tween(ResetBtn, {BackgroundColor3 = Config.ToggleOn}, 0.15)
        ResetBtn.Text = "✓ Done!"
        ShowNotification("Reset", "All settings reset!", 2, "success")
        wait(1)
        Tween(ResetBtn, {BackgroundColor3 = Config.DangerColor}, 0.3)
        ResetBtn.Text = "Reset"
    end)

    -- Destroy
    local DestroyCard = Instance.new("Frame")
    DestroyCard.Size = UDim2.new(1, -24, 0, 58)
    DestroyCard.Position = UDim2.new(0, 12, 0, 100)
    DestroyCard.BackgroundColor3 = Config.CardColor
    DestroyCard.BorderSizePixel = 0
    DestroyCard.Parent = SettingsPage
    CreateCorner(DestroyCard, Config.CornerRadius)
    CreateStroke(DestroyCard, Config.BorderColor, 1, 0.6)

    local DL = Instance.new("TextLabel")
    DL.Size = UDim2.new(0.6, 0, 0, 20)
    DL.Position = UDim2.new(0, 16, 0, 8)
    DL.BackgroundTransparency = 1
    DL.Text = "Destroy GUI"
    DL.TextColor3 = Config.TextColor
    DL.TextSize = 13
    DL.Font = Config.FontSemiBold
    DL.TextXAlignment = Enum.TextXAlignment.Left
    DL.Parent = DestroyCard

    local DD = Instance.new("TextLabel")
    DD.Size = UDim2.new(0.6, 0, 0, 14)
    DD.Position = UDim2.new(0, 16, 0, 30)
    DD.BackgroundTransparency = 1
    DD.Text = "Completely remove the GUI"
    DD.TextColor3 = Config.SubTextColor
    DD.TextSize = 10
    DD.Font = Config.FontRegular
    DD.TextXAlignment = Enum.TextXAlignment.Left
    DD.Parent = DestroyCard

    local DestroyBtn = Instance.new("TextButton")
    DestroyBtn.Size = UDim2.new(0, 80, 0, 32)
    DestroyBtn.Position = UDim2.new(1, -95, 0.5, -16)
    DestroyBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
    DestroyBtn.Text = "Destroy"
    DestroyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DestroyBtn.TextSize = 12
    DestroyBtn.Font = Config.FontSemiBold
    DestroyBtn.BorderSizePixel = 0
    DestroyBtn.ClipsDescendants = true
    DestroyBtn.Parent = DestroyCard
    CreateCorner(DestroyBtn, UDim.new(0, 7))

    DestroyBtn.MouseEnter:Connect(function() Tween(DestroyBtn, {BackgroundColor3 = Config.DangerColor}, 0.2) end)
    DestroyBtn.MouseLeave:Connect(function() Tween(DestroyBtn, {BackgroundColor3 = Color3.fromRGB(100, 30, 30)}, 0.2) end)

    DestroyBtn.MouseButton1Click:Connect(function()
        ClearESP()
        if State.BodyVelocity then State.BodyVelocity:Destroy() end
        if State.BodyGyro then State.BodyGyro:Destroy() end
        if State.FlyConnection then State.FlyConnection:Disconnect() end
        if State.NoclipConnection then State.NoclipConnection:Disconnect() end
        Workspace.Gravity = Config.DefaultGravity
        pcall(function() Workspace.CurrentCamera.FieldOfView = Config.DefaultFOV end)
        local c = LocalPlayer.Character
        if c then local h = c:FindFirstChild("Humanoid"); if h then h.WalkSpeed = Config.DefaultWalkSpeed; h.PlatformStand = false end end
        ScreenGui:Destroy()
    end)

    -- Credits
    local CreditsCard = Instance.new("Frame")
    CreditsCard.Size = UDim2.new(1, -24, 0, 85)
    CreditsCard.Position = UDim2.new(0, 12, 0, 170)
    CreditsCard.BackgroundColor3 = Config.CardColor
    CreditsCard.BorderSizePixel = 0
    CreditsCard.Parent = SettingsPage
    CreateCorner(CreditsCard, Config.CornerRadius)
    CreateStroke(CreditsCard, Config.BorderColor, 1, 0.6)

    local CT = Instance.new("TextLabel")
    CT.Size = UDim2.new(1, -16, 0, 20)
    CT.Position = UDim2.new(0, 14, 0, 8)
    CT.BackgroundTransparency = 1
    CT.Text = "📜 Credits & Info"
    CT.TextColor3 = Config.TextColor
    CT.TextSize = 13
    CT.Font = Config.FontSemiBold
    CT.TextXAlignment = Enum.TextXAlignment.Left
    CT.Parent = CreditsCard

    local CText = Instance.new("TextLabel")
    CText.Size = UDim2.new(1, -16, 0, 48)
    CText.Position = UDim2.new(0, 14, 0, 30)
    CText.BackgroundTransparency = 1
    CText.Text = "Nexus Hub v3.0 Enhanced — Universal Script GUI\nFeatures: Fly, Speed, Jump, Noclip, ESP, Gravity, FOV\nDeveloped with ❤ | All features in one file."
    CText.TextColor3 = Config.SubTextColor
    CText.TextSize = 10
    CText.Font = Config.FontRegular
    CText.TextXAlignment = Enum.TextXAlignment.Left
    CText.TextWrapped = true
    CText.Parent = CreditsCard

    -- Keybinds
    local KCard = Instance.new("Frame")
    KCard.Size = UDim2.new(1, -24, 0, 65)
    KCard.Position = UDim2.new(0, 12, 0, 265)
    KCard.BackgroundColor3 = Config.CardColor
    KCard.BorderSizePixel = 0
    KCard.Parent = SettingsPage
    CreateCorner(KCard, Config.CornerRadius)
    CreateStroke(KCard, Config.BorderColor, 1, 0.6)

    local KT = Instance.new("TextLabel")
    KT.Size = UDim2.new(1, -16, 0, 20)
    KT.Position = UDim2.new(0, 14, 0, 6)
    KT.BackgroundTransparency = 1
    KT.Text = "⌨️ Keybinds"
    KT.TextColor3 = Config.TextColor
    KT.TextSize = 13
    KT.Font = Config.FontSemiBold
    KT.TextXAlignment = Enum.TextXAlignment.Left
    KT.Parent = KCard

    local KText = Instance.new("TextLabel")
    KText.Size = UDim2.new(1, -16, 0, 30)
    KText.Position = UDim2.new(0, 14, 0, 28)
    KText.BackgroundTransparency = 1
    KText.Text = "RightCtrl — Toggle GUI  |  WASD — Fly Movement\nSpace — Fly Up / Jump  |  LShift — Fly Down"
    KText.TextColor3 = Config.SubTextColor
    KText.TextSize = 10
    KText.Font = Config.FontRegular
    KText.TextXAlignment = Enum.TextXAlignment.Left
    KText.TextWrapped = true
    KText.Parent = KCard

    TabPages["Settings"] = SettingsPage

    -- ═══════════════════════════════════════════════════
    -- TAB SWITCHING
    -- ═══════════════════════════════════════════════════
    local function SwitchTab(tabName)
        State.CurrentTab = tabName

        for name, data in pairs(TabButtons) do
            if name == tabName then
                Tween(data.btn, {BackgroundTransparency = 0.75, TextColor3 = Config.TextColor}, 0.25)
            else
                Tween(data.btn, {BackgroundTransparency = 1, TextColor3 = Config.SubTextColor}, 0.25)
            end
        end

        -- Move active indicator
        local targetData = TabButtons[tabName]
        if targetData then
            local targetY = 6 + (targetData.index - 1) * 48 + 10
            Tween(ActiveIndicator, {Position = UDim2.new(0, 0, 0, targetY)}, 0.3, Enum.EasingStyle.Back)
        end

        for name, page in pairs(TabPages) do
            if name == tabName then
                page.Visible = true
                page.Position = UDim2.new(0.03, 0, 0, 0)
                Tween(page, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
            else
                page.Visible = false
            end
        end
    end

    for name, data in pairs(TabButtons) do
        data.btn.MouseButton1Click:Connect(function()
            SwitchTab(name)
        end)
    end

    SwitchTab("Home")

    -- ═══════════════════════════════════════════════════
    -- CLOSE / MINIMIZE
    -- ═══════════════════════════════════════════════════
    CloseBtn.MouseButton1Click:Connect(function()
        ClearESP()
        if State.BodyVelocity then State.BodyVelocity:Destroy() end
        if State.BodyGyro then State.BodyGyro:Destroy() end
        if State.FlyConnection then State.FlyConnection:Disconnect() end
        if State.NoclipConnection then State.NoclipConnection:Disconnect() end
        Workspace.Gravity = Config.DefaultGravity
        pcall(function() Workspace.CurrentCamera.FieldOfView = Config.DefaultFOV end)
        local c = LocalPlayer.Character
        if c then local h = c:FindFirstChild("Humanoid"); if h then h.WalkSpeed = Config.DefaultWalkSpeed; h.PlatformStand = false end end
        ScreenGui:Destroy()
    end)

    MinBtn.MouseButton1Click:Connect(function()
        State.GuiOpen = false
        Tween(MainFrame, {Size = UDim2.new(0, 550, 0, 0)}, 0.3)
        wait(0.35)
        MainFrame.Visible = false
    end)

    -- ═══════════════════════════════════════════════════
    -- TOGGLE GUI (RightControl)
    -- ═══════════════════════════════════════════════════
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            if State.GuiOpen then
                State.GuiOpen = false
                Tween(MainFrame, {Size = UDim2.new(0, 550, 0, 0)}, 0.3)
                wait(0.35)
                MainFrame.Visible = false
            else
                State.GuiOpen = true
                MainFrame.Visible = true
                MainFrame.Size = UDim2.new(0, 550, 0, 0)
                Tween(MainFrame, {Size = UDim2.new(0, 550, 0, 390)}, 0.3, Enum.EasingStyle.Back)
            end
        end
    end)

    -- ═══════════════════════════════════════════════════
    -- RE-APPLY ON RESPAWN
    -- ═══════════════════════════════════════════════════
    LocalPlayer.CharacterAdded:Connect(function(character)
        wait(1)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.WalkSpeed = State.WalkSpeed
            humanoid.JumpPower = State.JumpPower
            humanoid.UseJumpPower = true
        end
        if State.FlyEnabled then
            State.FlyEnabled = false
            flyStatVal.Text = "OFF"
            flyStatVal.TextColor3 = Config.DangerColor
            ShowNotification("Fly", "Fly disabled on respawn. Re-enable manually.", 3, "warning")
        end
        if State.ESPEnabled then
            wait(0.5)
            CreateESP()
        end
    end)

    -- Open animation
    MainFrame.Size = UDim2.new(0, 550, 0, 0)
    MainFrame.Visible = true
    Tween(MainFrame, {Size = UDim2.new(0, 550, 0, 390)}, 0.4, Enum.EasingStyle.Back)
end

-- ═══════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════
CreateLoadingScreen()
wait(0.3)
CreateMainGui()

-- Welcome notification
task.delay(1, function()
    ShowNotification("Nexus Hub", "GUI loaded! Press RightCtrl to toggle.", 4, "success")
end)

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Nexus Hub v3.0",
        Text = "GUI loaded! Press RightCtrl to toggle.",
        Duration = 5,
    })
end)

print("[Nexus Hub] ✅ v3.0 Enhanced loaded successfully!")
print("[Nexus Hub] Press RightControl to toggle GUI visibility.")
