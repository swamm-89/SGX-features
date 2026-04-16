-- ================== FOLLOW PLAYER SCRIPT ==================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Logic Variables
local FollowEnabled = false
local FaceTarget = false
local TargetPlayer = nil
local FollowDistance = 5
local FollowSpeed = 10
local Minimized = false

-- Character Handler
local Character, HRP
local function UpdateCharacter(newChar)
    Character = newChar
    HRP = Character:WaitForChild("HumanoidRootPart", 5)
end

if LocalPlayer.Character then UpdateCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(UpdateCharacter)

-- Theme
local Theme = {
    Background = Color3.fromRGB(12, 12, 14),
    Header = Color3.fromRGB(18, 18, 22),
    Surface = Color3.fromRGB(24, 24, 28),
    Accent = Color3.fromRGB(180, 0, 255),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(170, 170, 170),
    ToggleOff = Color3.fromRGB(40, 40, 45),
    CloseBtn = Color3.fromRGB(255, 60, 60),
    MinBtn = Color3.fromRGB(255, 255, 255)
}

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FollowPlayer"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

-- Intro Animation
local IntroBg = Instance.new("Frame")
IntroBg.Size = UDim2.new(1, 0, 1, 0)
IntroBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
IntroBg.BackgroundTransparency = 0
IntroBg.ZIndex = 100
IntroBg.Parent = ScreenGui

local IntroText = Instance.new("TextLabel")
IntroText.Text = "FOLLOW PLAYER 🫂"
IntroText.Font = Enum.Font.GothamBlack
IntroText.TextSize = 20
IntroText.TextColor3 = Theme.Accent
IntroText.BackgroundTransparency = 1
IntroText.Position = UDim2.new(0.5, 0, 0.5, 0)
IntroText.AnchorPoint = Vector2.new(0.5, 0.5)
IntroText.TextTransparency = 1
IntroText.ZIndex = 101
IntroText.Parent = IntroBg

local IntroGlow = Instance.new("UIStroke", IntroText)
IntroGlow.Color = Theme.Accent
IntroGlow.Thickness = 0
IntroGlow.Transparency = 1

-- Play Intro
TweenService:Create(IntroText, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0, TextSize = 65}):Play()
TweenService:Create(IntroGlow, TweenInfo.new(1), {Thickness = 3, Transparency = 0}):Play()

task.wait(1.5)
TweenService:Create(IntroText, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {TextTransparency = 1, TextSize = 100}):Play()
TweenService:Create(IntroGlow, TweenInfo.new(0.5), {Transparency = 1, Thickness = 0}):Play()
TweenService:Create(IntroBg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()

task.wait(0.5)
IntroBg:Destroy()

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 360)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -180)
MainFrame.BackgroundTransparency = 1
MainFrame.Parent = ScreenGui

local BgFrame = Instance.new("Frame")
BgFrame.Size = UDim2.new(1, 0, 1, 0)
BgFrame.BackgroundColor3 = Theme.Background
BgFrame.ClipsDescendants = true
BgFrame.Parent = MainFrame
Instance.new("UICorner", BgFrame).CornerRadius = UDim.new(0, 12)

local OutlineFrame = Instance.new("Frame")
OutlineFrame.Size = UDim2.new(1, 0, 1, 0)
OutlineFrame.BackgroundTransparency = 1
OutlineFrame.Parent = MainFrame
Instance.new("UICorner", OutlineFrame).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", OutlineFrame)
MainStroke.Thickness = 2
MainStroke.Color = Theme.Accent
MainStroke.Transparency = 0.1

-- Particle Background
local ParticleContainer = Instance.new("Frame")
ParticleContainer.Size = UDim2.new(1, 0, 1, 0)
ParticleContainer.BackgroundTransparency = 1
ParticleContainer.Parent = BgFrame

task.spawn(function()
    while task.wait(0.12) do
        if not ScreenGui.Parent then break end
        local sprinkle = Instance.new("Frame")
        local size = math.random(3, 6)
        sprinkle.Size = UDim2.new(0, size, 0, size)
        sprinkle.Position = UDim2.new(math.random(0, 100)/100, 0, 1.1, 0)
        sprinkle.BackgroundColor3 = Theme.Accent
        sprinkle.BackgroundTransparency = math.random(20, 60)/100
        sprinkle.Rotation = math.random(0, 180)
        Instance.new("UICorner", sprinkle).CornerRadius = UDim.new(1, 0)
        sprinkle.Parent = ParticleContainer

        local duration = math.random(4, 7)
        local endX = sprinkle.Position.X.Scale + (math.random(-20, 20)/100)

        local tween = TweenService:Create(sprinkle, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            Position = UDim2.new(endX, 0, -0.2, 0),
            BackgroundTransparency = 1,
            Rotation = sprinkle.Rotation + math.random(90, 180)
        })
        tween:Play()
        tween.Completed:Connect(function() sprinkle:Destroy() end)
    end
end)

-- Pop In Animation
MainFrame.Size = UDim2.new(0, 240, 0, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 240, 0, 360)}):Play()

-- Drag Logic
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Theme.Header
Header.Parent = BgFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -70, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Text = "FOLLOW PLAYER"
TitleLabel.TextColor3 = Theme.Accent
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.BackgroundTransparency = 1
TitleLabel.Parent = Header

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Theme.CloseBtn
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = Header

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 240, 0, 0)}):Play()
    task.wait(0.3)
    ScreenGui:Destroy()
end)

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -65, 0, 5)
MinBtn.Text = "—"
MinBtn.TextColor3 = Theme.MinBtn
MinBtn.BackgroundTransparency = 1
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.Parent = Header

MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if Minimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 240, 0, 40)}):Play()
        Content.Visible = false
        MinBtn.Text = "＋"
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 240, 0, 360)}):Play()
        Content.Visible = true
        MinBtn.Text = "—"
    end
end)

-- Content Area
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, 0, 1, -40)
Content.Position = UDim2.new(0, 0, 0, 40)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 2
Content.ScrollBarImageColor3 = Theme.Accent
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.Parent = BgFrame

local UIList = Instance.new("UIListLayout", Content)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8)

local UIPadding = Instance.new("UIPadding", Content)
UIPadding.PaddingTop = UDim.new(0, 10)
UIPadding.PaddingBottom = UDim.new(0, 10)
UIPadding.PaddingLeft = UDim.new(0, 15)
UIPadding.PaddingRight = UDim.new(0, 15)

-- Section Creator
local function CreateSection(text)
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, 0, 0, 15)
    L.BackgroundTransparency = 1
    L.Text = text
    L.TextColor3 = Theme.SubText
    L.Font = Enum.Font.GothamBold
    L.TextSize = 10
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = Content
end

-- Target Selection
CreateSection("TARGET")

local PlayerScroll = Instance.new("ScrollingFrame")
PlayerScroll.Size = UDim2.new(1, 0, 0, 95)
PlayerScroll.BackgroundTransparency = 1
PlayerScroll.ScrollBarThickness = 2
PlayerScroll.ScrollBarImageColor3 = Theme.Accent
PlayerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerScroll.Parent = Content

local PListLayout = Instance.new("UIListLayout", PlayerScroll)
PListLayout.Padding = UDim.new(0, 4)

local CurrentTargetLabel = Instance.new("TextLabel")
CurrentTargetLabel.Size = UDim2.new(1, 0, 0, 15)
CurrentTargetLabel.BackgroundTransparency = 1
CurrentTargetLabel.Text = " TARGET: NONE"
CurrentTargetLabel.TextColor3 = Theme.Text
CurrentTargetLabel.Font = Enum.Font.GothamSemibold
CurrentTargetLabel.TextSize = 11
CurrentTargetLabel.TextXAlignment = Enum.TextXAlignment.Left
CurrentTargetLabel.Parent = Content

local function RefreshPlayers()
    for _, v in pairs(PlayerScroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, -6, 0, 28)
            Btn.Position = UDim2.new(0, 3, 0, 0)
            Btn.BackgroundColor3 = Theme.Surface
            Btn.Text = "  " .. p.Name
            Btn.TextColor3 = Theme.Text
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 12
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.Parent = PlayerScroll
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

            Btn.MouseButton1Click:Connect(function()
                TargetPlayer = p
                CurrentTargetLabel.Text = " TARGET: " .. string.upper(p.Name)
                CurrentTargetLabel.TextColor3 = Theme.Accent

                for _, b in pairs(PlayerScroll:GetChildren()) do
                    if b:IsA("TextButton") then
                        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Surface, TextColor3 = Theme.Text}):Play()
                    end
                end
                TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            end)
        end
    end
end

RefreshPlayers()
Players.PlayerAdded:Connect(RefreshPlayers)
Players.PlayerRemoving:Connect(RefreshPlayers)

-- Controls
CreateSection("CONTROLS")

local function CreateToggle(text, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 36)
    Frame.BackgroundColor3 = Theme.Surface
    Frame.Parent = Content
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 34, 0, 18)
    Indicator.Position = UDim2.new(1, -46, 0.5, -9)
    Indicator.BackgroundColor3 = Theme.ToggleOff
    Indicator.Parent = Frame
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 14, 0, 14)
    Knob.Position = UDim2.new(0, 2, 0.5, -7)
    Knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Knob.Parent = Indicator
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1,0,1,0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.Parent = Frame

    local isOn = false
    Btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        callback(isOn)
        if isOn then
            TweenService:Create(Indicator, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Accent}):Play()
            TweenService:Create(Knob, TweenInfo.new(0.3), {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        else
            TweenService:Create(Indicator, TweenInfo.new(0.3), {BackgroundColor3 = Theme.ToggleOff}):Play()
            TweenService:Create(Knob, TweenInfo.new(0.3), {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        end
    end)
end

CreateToggle("Enable Follow", function(s) FollowEnabled = s end)
CreateToggle("Face Target", function(s) FaceTarget = s end)

-- Distance Slider
CreateSection("DISTANCE")

local DistLabel = Instance.new("TextLabel")
DistLabel.Size = UDim2.new(1, 0, 0, 15)
DistLabel.BackgroundTransparency = 1
DistLabel.Text = "DISTANCE: " .. FollowDistance
DistLabel.TextColor3 = Theme.Accent
DistLabel.Font = Enum.Font.GothamBold
DistLabel.TextSize = 10
DistLabel.TextXAlignment = Enum.TextXAlignment.Left
DistLabel.Parent = Content

local SliderBg = Instance.new("Frame")
SliderBg.Size = UDim2.new(1, 0, 0, 6)
SliderBg.BackgroundColor3 = Theme.ToggleOff
SliderBg.Parent = Content
Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(FollowDistance/50, 0, 1, 0)
SliderFill.BackgroundColor3 = Theme.Accent
SliderFill.Parent = SliderBg
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

local SliderKnob = Instance.new("Frame")
SliderKnob.Size = UDim2.new(0, 14, 0, 14)
SliderKnob.Position = UDim2.new(1, -7, 0.5, -7)
SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderKnob.Parent = SliderFill
Instance.new("UICorner", SliderKnob).CornerRadius = UDim.new(1, 0)

local Trigger = Instance.new("TextButton")
Trigger.Size = UDim2.new(1, 0, 0, 30)
Trigger.Position = UDim2.new(0, 0, 0.5, -15)
Trigger.BackgroundTransparency = 1
Trigger.Text = ""
Trigger.Parent = SliderBg

local draggingSlider = false

local function UpdateSlider(input)
    local mPos = input.Position.X
    local bPos = SliderBg.AbsolutePosition.X
    local bSize = SliderBg.AbsoluteSize.X
    local p = math.clamp((mPos - bPos) / bSize, 0, 1)

    TweenService:Create(SliderFill, TweenInfo.new(0.05), {Size = UDim2.new(p, 0, 1, 0)}):Play()
    FollowDistance = math.floor(p * 50)
    DistLabel.Text = "DISTANCE: " .. FollowDistance
end

Trigger.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = true
        UpdateSlider(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        UpdateSlider(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = false
    end
end)

-- Main Follow Logic
RunService.RenderStepped:Connect(function(dt)
    if FollowEnabled and TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if Character and HRP then
            local tHRP = TargetPlayer.Character.HumanoidRootPart
            local goal = tHRP.CFrame * CFrame.new(0, 0, FollowDistance)
            if FaceTarget then
                goal = CFrame.new(HRP.Position, tHRP.Position) * CFrame.new(0, 0, FollowDistance)
            end
            HRP.CFrame = HRP.CFrame:Lerp(goal, math.clamp(FollowSpeed * dt, 0, 1))
        end
    end
end)
