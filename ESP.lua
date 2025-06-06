-- ⚔️ نظام ESP المتطور مع تفعيل يدوي
-- يوضع السكربت في LocalScript داخل StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- إعدادات قابلة للتخصيص
local ESP_SETTINGS = {
    BoxColor = Color3.fromRGB(0, 255, 0),
    BehindWallColor = Color3.fromRGB(255, 0, 0),
    TracerColor = Color3.fromRGB(255, 255, 255),
    TextColor = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    BoxThickness = 1,
    TracerThickness = 1,
    MaxDistance = 1000,
    ShowName = true,
    ShowDistance = true,
    ShowHealth = true,
    ShowTracer = true,
    TeamCheck = false,
    TeamColor = Color3.fromRGB(0, 0, 255)
}

-- جدول لتخزين عناصر ESP لكل لاعب
local ESPObjects = {}
local espEnabled = false -- تم تغيير القيمة الافتراضية إلى false

-- إنشاء واجهة المستخدم
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESPControlGUI"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 200)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "نظام ESP المتقدم"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TitleBar

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = TitleBar

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, 0, 1, -30)
ContentFrame.Position = UDim2.new(0, 0, 0, 30)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0.8, 0, 0, 40)
ToggleButton.Position = UDim2.new(0.1, 0, 0.1, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(120, 0, 0) -- لون أحمر للإشارة إلى غير مفعل
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "تفعيل ESP" -- النص الابتدائي "تفعيل"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.Parent = ContentFrame

local SettingsFrame = Instance.new("Frame")
SettingsFrame.Name = "SettingsFrame"
SettingsFrame.Size = UDim2.new(1, 0, 0, 100)
SettingsFrame.Position = UDim2.new(0, 0, 0, 50)
SettingsFrame.BackgroundTransparency = 1
SettingsFrame.Parent = ContentFrame

local TeamCheck = Instance.new("TextButton")
TeamCheck.Name = "TeamCheck"
TeamCheck.Size = UDim2.new(0.8, 0, 0, 30)
TeamCheck.Position = UDim2.new(0.1, 0, 0, 0)
TeamCheck.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
TeamCheck.BorderSizePixel = 0
TeamCheck.Text = "تمييز الفريق: معطل"
TeamCheck.TextColor3 = Color3.fromRGB(255, 255, 255)
TeamCheck.Font = Enum.Font.Gotham
TeamCheck.TextSize = 12
TeamCheck.Parent = SettingsFrame

local ShowTracer = Instance.new("TextButton")
ShowTracer.Name = "ShowTracer"
ShowTracer.Size = UDim2.new(0.8, 0, 0, 30)
ShowTracer.Position = UDim2.new(0.1, 0, 0, 35)
ShowTracer.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ShowTracer.BorderSizePixel = 0
ShowTracer.Text = "الخط التوجيهي: مفعل"
ShowTracer.TextColor3 = Color3.fromRGB(255, 255, 255)
ShowTracer.Font = Enum.Font.Gotham
ShowTracer.TextSize = 12
ShowTracer.Parent = SettingsFrame

local MaxDistanceLabel = Instance.new("TextLabel")
MaxDistanceLabel.Name = "MaxDistanceLabel"
MaxDistanceLabel.Size = UDim2.new(0.8, 0, 0, 20)
MaxDistanceLabel.Position = UDim2.new(0.1, 0, 0, 70)
MaxDistanceLabel.BackgroundTransparency = 1
MaxDistanceLabel.Text = "المسافة القصوى: "..ESP_SETTINGS.MaxDistance
MaxDistanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
MaxDistanceLabel.Font = Enum.Font.Gotham
MaxDistanceLabel.TextSize = 12
MaxDistanceLabel.TextXAlignment = Enum.TextXAlignment.Left
MaxDistanceLabel.Parent = SettingsFrame

local MaxDistanceSlider = Instance.new("TextButton")
MaxDistanceSlider.Name = "MaxDistanceSlider"
MaxDistanceSlider.Size = UDim2.new(0.8, 0, 0, 10)
MaxDistanceSlider.Position = UDim2.new(0.1, 0, 0, 90)
MaxDistanceSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MaxDistanceSlider.BorderSizePixel = 0
MaxDistanceSlider.Text = ""
MaxDistanceSlider.Parent = SettingsFrame

local MaxDistanceFill = Instance.new("Frame")
MaxDistanceFill.Name = "MaxDistanceFill"
MaxDistanceFill.Size = UDim2.new(1, 0, 1, 0)
MaxDistanceFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
MaxDistanceFill.BorderSizePixel = 0
MaxDistanceFill.Parent = MaxDistanceSlider

-- دالة لإنشاء عناصر ESP (بدون تفعيلها تلقائياً)
local function CreateESP(player)
    if ESPObjects[player] then
        for _, drawing in pairs(ESPObjects[player]) do
            drawing:Remove()
        end
    end

    local box = Drawing.new("Square")
    box.Thickness = ESP_SETTINGS.BoxThickness
    box.Color = ESP_SETTINGS.BoxColor
    box.Filled = false
    box.Visible = false -- تم تغييرها إلى false بدلاً من true

    local tracer = Drawing.new("Line")
    tracer.Thickness = ESP_SETTINGS.TracerThickness
    tracer.Color = ESP_SETTINGS.TracerColor
    tracer.Visible = false -- تم تغييرها إلى false بدلاً من ESP_SETTINGS.ShowTracer

    local nameText = Drawing.new("Text")
    nameText.Text = player.Name
    nameText.Size = ESP_SETTINGS.TextSize
    nameText.Color = ESP_SETTINGS.TextColor
    nameText.Outline = true
    nameText.Visible = false -- تم تغييرها إلى false بدلاً من ESP_SETTINGS.ShowName

    local distanceText = Drawing.new("Text")
    distanceText.Size = ESP_SETTINGS.TextSize
    distanceText.Color = ESP_SETTINGS.TextColor
    distanceText.Outline = true
    distanceText.Visible = false -- تم تغييرها إلى false بدلاً من ESP_SETTINGS.ShowDistance

    local healthText = Drawing.new("Text")
    healthText.Size = ESP_SETTINGS.TextSize
    healthText.Color = ESP_SETTINGS.TextColor
    healthText.Outline = true
    healthText.Visible = false -- تم تغييرها إلى false بدلاً من ESP_SETTINGS.ShowHealth

    ESPObjects[player] = {
        Box = box,
        Tracer = tracer,
        NameText = nameText,
        DistanceText = distanceText,
        HealthText = healthText
    }

    local function update()
        if not espEnabled then return end -- لا تقم بالتحديث إذا كان ESP معطلاً
        
        if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            for _, drawing in pairs(ESPObjects[player]) do
                drawing.Visible = false
            end
            return
        end

        local hrp = player.Character.HumanoidRootPart
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        
        if onScreen then
            local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
            
            if distance > ESP_SETTINGS.MaxDistance then
                for _, drawing in pairs(ESPObjects[player]) do
                    drawing.Visible = false
                end
                return
            end

            local ray = RaycastParams.new()
            ray.FilterDescendantsInstances = {LocalPlayer.Character, player.Character}
            ray.FilterType = Enum.RaycastFilterType.Blacklist

            local result = workspace:Raycast(Camera.CFrame.Position, (hrp.Position - Camera.CFrame.Position).Unit * distance, ray)
            local isBehindWall = result and result.Instance and not player.Character:IsAncestorOf(result.Instance)

            local boxColor = ESP_SETTINGS.BoxColor
            if ESP_SETTINGS.TeamCheck and player.Team == LocalPlayer.Team then
                boxColor = ESP_SETTINGS.TeamColor
            elseif isBehindWall then
                boxColor = ESP_SETTINGS.BehindWallColor
            end

            ESPObjects[player].Box.Color = boxColor
            ESPObjects[player].Tracer.Color = boxColor

            local size = Vector2.new(40 / (distance / 10), 60 / (distance / 10))
            ESPObjects[player].Box.Size = size
            ESPObjects[player].Box.Position = Vector2.new(pos.X - size.X / 2, pos.Y - size.Y / 2)
            ESPObjects[player].Box.Visible = true

            ESPObjects[player].Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            ESPObjects[player].Tracer.To = Vector2.new(pos.X, pos.Y)
            ESPObjects[player].Tracer.Visible = ESP_SETTINGS.ShowTracer

            if ESP_SETTINGS.ShowName then
                ESPObjects[player].NameText.Position = Vector2.new(pos.X, pos.Y - size.Y / 2 - 20)
                ESPObjects[player].NameText.Visible = true
            else
                ESPObjects[player].NameText.Visible = false
            end

            if ESP_SETTINGS.ShowDistance then
                ESPObjects[player].DistanceText.Text = string.format("[%dm]", math.floor(distance))
                ESPObjects[player].DistanceText.Position = Vector2.new(pos.X, pos.Y + size.Y / 2 + 5)
                ESPObjects[player].DistanceText.Visible = true
            else
                ESPObjects[player].DistanceText.Visible = false
            end

            if ESP_SETTINGS.ShowHealth and humanoid then
                ESPObjects[player].HealthText.Text = string.format("%d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
                ESPObjects[player].HealthText.Position = Vector2.new(pos.X, pos.Y + size.Y / 2 + 25)
                ESPObjects[player].HealthText.Visible = true
                
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                if healthPercent < 0.3 then
                    ESPObjects[player].HealthText.Color = Color3.fromRGB(255, 0, 0)
                elseif healthPercent < 0.6 then
                    ESPObjects[player].HealthText.Color = Color3.fromRGB(255, 255, 0)
                else
                    ESPObjects[player].HealthText.Color = Color3.fromRGB(0, 255, 0)
                end
            else
                ESPObjects[player].HealthText.Visible = false
            end
        else
            for _, drawing in pairs(ESPObjects[player]) do
                drawing.Visible = false
            end
        end
    end

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not player or not player.Parent then
            connection:Disconnect()
            if ESPObjects[player] then
                for _, drawing in pairs(ESPObjects[player]) do
                    drawing:Remove()
                end
                ESPObjects[player] = nil
            end
            return
        end
        update()
    end)
end

-- تفعيل/تعطيل ESP للجميع
local function ToggleESP(enable)
    espEnabled = enable
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and ESPObjects[player] then
            for _, drawing in pairs(ESPObjects[player]) do
                drawing.Visible = enable
            end
        end
    end
end

-- تطبيق ESP على جميع اللاعبين (بدون تفعيل)
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

-- عند دخول لاعب جديد
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            wait(1)
            CreateESP(player)
        end)
    end
end)

-- تنظيف عند مغادرة اللاعب
Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, drawing in pairs(ESPObjects[player]) do
            drawing:Remove()
        end
        ESPObjects[player] = nil
    end
end)

-- أحداث واجهة المستخدم
local minimized = false

ToggleButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        ToggleButton.Text = "تعطيل ESP"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
        ToggleESP(true)
    else
        ToggleButton.Text = "تفعيل ESP"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        ToggleESP(false)
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        ContentFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 250, 0, 30)
        MinimizeButton.Text = "+"
    else
        ContentFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 250, 0, 200)
        MinimizeButton.Text = "_"
    end
end)

TeamCheck.MouseButton1Click:Connect(function()
    ESP_SETTINGS.TeamCheck = not ESP_SETTINGS.TeamCheck
    if ESP_SETTINGS.TeamCheck then
        TeamCheck.Text = "تمييز الفريق: مفعل"
        TeamCheck.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
    else
        TeamCheck.Text = "تمييز الفريق: معطل"
        TeamCheck.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end
end)

ShowTracer.MouseButton1Click:Connect(function()
    ESP_SETTINGS.ShowTracer = not ESP_SETTINGS.ShowTracer
    if ESP_SETTINGS.ShowTracer then
        ShowTracer.Text = "الخط التوجيهي: مفعل"
        ShowTracer.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
    else
        ShowTracer.Text = "الخط التوجيهي: معطل"
        ShowTracer.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end
end)

local function updateMaxDistance(value)
    ESP_SETTINGS.MaxDistance = math.floor(value)
    MaxDistanceLabel.Text = "المسافة القصوى: "..ESP_SETTINGS.MaxDistance
    MaxDistanceFill.Size = UDim2.new(value / 1000, 0, 1, 0)
end

MaxDistanceSlider.MouseButton1Down:Connect(function()
    local connection
    connection = RunService.RenderStepped:Connect(function()
        local mousePos = UserInputService:GetMouseLocation().X
        local sliderPos = MaxDistanceSlider.AbsolutePosition.X
        local sliderSize = MaxDistanceSlider.AbsoluteSize.X
        
        local relativePos = math.clamp(mousePos - sliderPos, 0, sliderSize)
        local value = math.floor((relativePos / sliderSize) * 1000)
        
        updateMaxDistance(value)
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            connection:Disconnect()
        end
    end)
end)

-- إعادة إنشاء ESP عند تغيير الشخصية
LocalPlayer.CharacterAdded:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            CreateESP(player)
        end
    end
end)

-- التهيئة الأولية
updateMaxDistance(ESP_SETTINGS.MaxDistance)