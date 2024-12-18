local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/KlorPe000/KlorPeLib/main/source'))()

local Window = OrionLib:MakeWindow({
    Name = "KlorPeHub", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "KlorPeTest"
})

local PlayerTab = Window:MakeTab({
    Name = "Гравець",
    Icon = "rbxassetid://17404114716",
    PremiumOnly = false
})

local walkSpeed = 16
local jumpHeight = 7
local fieldOfView = 70  -- Начальное значение FOV

-- Переменные для включения и выключения изменений
local walkSpeedEnabled = false
local jumpHeightEnabled = false
local fovEnabled = false

-- Дефолтные значения из игры
local defaultWalkSpeed = 16
local defaultJumpHeight = 7
local defaultFieldOfView = 70

-- Функция для сброса значений на дефолтные
local function resetHumanoid(humanoid)
    humanoid.WalkSpeed = defaultWalkSpeed
    humanoid.JumpHeight = defaultJumpHeight
end

local function resetFOV()
    game.Workspace.CurrentCamera.FieldOfView = defaultFieldOfView
end

-- Функция для блокировки изменений
local function monitorHumanoid(humanoid)
    humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if walkSpeedEnabled and humanoid.WalkSpeed ~= walkSpeed then
            humanoid.WalkSpeed = walkSpeed
        else
            script.Parent.PlayerTab:SetSliderValue("Швидкість руху", humanoid.WalkSpeed)
        end
    end)

    humanoid:GetPropertyChangedSignal("JumpHeight"):Connect(function()
        if jumpHeightEnabled and humanoid.JumpHeight ~= jumpHeight then
            humanoid.JumpHeight = jumpHeight
        else
            script.Parent.PlayerTab:SetSliderValue("Висота стрибка", humanoid.JumpHeight)
        end
    end)

    if walkSpeedEnabled then
        humanoid.WalkSpeed = walkSpeed
    else
        humanoid.WalkSpeed = defaultWalkSpeed
    end

    if jumpHeightEnabled then
        humanoid.JumpHeight = jumpHeight
    else
        humanoid.JumpHeight = defaultJumpHeight
    end
end

local function monitorFOV()
    game.Workspace.CurrentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
        if fovEnabled and game.Workspace.CurrentCamera.FieldOfView ~= fieldOfView then
            game.Workspace.CurrentCamera.FieldOfView = fieldOfView
        else
            script.Parent.PlayerTab:SetSliderValue("Поле зору", game.Workspace.CurrentCamera.FieldOfView)
        end
    end)

    if fovEnabled then
        game.Workspace.CurrentCamera.FieldOfView = fieldOfView
    else
        resetFOV()
    end
end

local function setupCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    if humanoid then
        monitorHumanoid(humanoid)
    end
end

game.Players.LocalPlayer.CharacterAdded:Connect(setupCharacter)

if game.Players.LocalPlayer.Character then
    setupCharacter(game.Players.LocalPlayer.Character)
end

monitorFOV()

local Section = PlayerTab:AddSection({
    Name = "Швідкість"
})

PlayerTab:AddSlider({
    Name = "Швидкість руху",
    Min = 16,
    Max = 500,
    Default = 16,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Сила",
    Callback = function(Value)
        walkSpeed = Value
        if walkSpeedEnabled then
            local character = game.Players.LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = walkSpeed
                end
            end
        end
    end
})

PlayerTab:AddToggle({
    Name = "Вкл/Викл швидкість рух",
    Default = false,
    Callback = function(State)
        walkSpeedEnabled = State
        local character = game.Players.LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                if walkSpeedEnabled then
                    humanoid.WalkSpeed = walkSpeed
                else
                    resetHumanoid(humanoid)
                end
            end
        end
    end
})

local Section = PlayerTab:AddSection({
    Name = "Стрибки"
})

PlayerTab:AddSlider({
    Name = "Висота стрибка",
    Min = 7,
    Max = 100,
    Default = 7,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Сила",
    Callback = function(Value)
        jumpHeight = Value
        if jumpHeightEnabled then
            local character = game.Players.LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.JumpHeight = jumpHeight
                end
            end
        end
    end
})

PlayerTab:AddToggle({
    Name = "Вкл/Викл висота стрибка",
    Default = false,
    Callback = function(State)
        jumpHeightEnabled = State
        local character = game.Players.LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                if jumpHeightEnabled then
                    humanoid.JumpHeight = jumpHeight
                else
                    resetHumanoid(humanoid)
                end
            end
        end
    end
})

local Section = PlayerTab:AddSection({
    Name = "Поле зору"
})

PlayerTab:AddSlider({
    Name = "Поле зору",
    Min = 70,
    Max = 120,
    Default = 70,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Сила",
    Callback = function(Value)
        fieldOfView = Value
        if fovEnabled then
            game.Workspace.CurrentCamera.FieldOfView = fieldOfView
        end
    end
})

PlayerTab:AddToggle({
    Name = "Вкл/Викл поле зору",
    Default = false,
    Callback = function(State)
        fovEnabled = State
        if fovEnabled then
            game.Workspace.CurrentCamera.FieldOfView = fieldOfView
        else
            resetFOV()
        end
    end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping")
    end
end)

local Section = PlayerTab:AddSection({
    Name = "Інше"
})

PlayerTab:AddToggle({
    Name = "Бескінечні стрибки",
    Default = false,
    Callback = function(State)
        InfiniteJumpEnabled = State
    end
})

local Noclip = nil
local Clip = nil
local originalCollisions = {}

local function saveCollisions()
    for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
        if v:IsA('BasePart') then
            originalCollisions[v] = v.CanCollide
        end
    end
end

function noclip()
    Clip = false
    saveCollisions()  
    local function Nocl()
        if Clip == false and game.Players.LocalPlayer.Character ~= nil then
            for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if v:IsA('BasePart') and v.CanCollide and v.Name ~= floatName then
                    v.CanCollide = false
                end
            end
        end
        wait(0.21) 
    end
    Noclip = game:GetService('RunService').Stepped:Connect(Nocl)
end

function clip()
    if game.Players.LocalPlayer.Character.Humanoid:GetState() == Enum.HumanoidStateType.Physics then
        repeat
            wait(0.1)
        until game.Players.LocalPlayer.Character.Humanoid:GetState() == Enum.HumanoidStateType.Seated or
               game.Players.LocalPlayer.Character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall == false
    end

    if Noclip then Noclip:Disconnect() end
    Clip = true
    
    for part, collision in pairs(originalCollisions) do
        if part and part:IsA('BasePart') then
            part.CanCollide = collision
        end
    end
end

PlayerTab:AddToggle({
    Name = "Без зіткнень",
    Default = false,
    Callback = function(State)
        if State then
            noclip()
        else
            clip()
        end
    end
})

local function activateFLY()

    local main = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    local up = Instance.new("TextButton")
    local down = Instance.new("TextButton")
    local onof = Instance.new("TextButton")
    local TextLabel = Instance.new("TextLabel")
    local plus = Instance.new("TextButton")
    local speed = Instance.new("TextLabel")
    local mine = Instance.new("TextButton")
    local closebutton = Instance.new("TextButton")
    local mini = Instance.new("TextButton")
    local mini2 = Instance.new("TextButton")
    
    local main = Instance.new("ScreenGui")
    main.Name = "main"
    main.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    main.ResetOnSpawn = false
    
    local Frame = Instance.new("Frame")
    Frame.Parent = main
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Frame.BorderColor3 = Color3.fromRGB(150, 150, 150)
    Frame.Position = UDim2.new(0.100320168, -0, 0.379746825, 0)
    Frame.Size = UDim2.new(0, 189, 0, 56)
    
    local up = Instance.new("TextButton")
    up.Name = "up"
    up.Parent = Frame
    up.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    up.BorderColor3 = Color3.fromRGB(150, 150, 150)
    up.Size = UDim2.new(0, 44, 0, 28)
    up.Font = Enum.Font.SourceSans
    up.Text = "Більше"
    up.TextColor3 = Color3.fromRGB(240, 240, 240)
    up.TextSize = 14.000
    
    local down = Instance.new("TextButton")
    down.Name = "down"
    down.Parent = Frame
    down.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    down.BorderColor3 = Color3.fromRGB(150, 150, 150)
    down.Position = UDim2.new(0, 0, 0.491228074, 1)
    down.Size = UDim2.new(0, 44, 0, 28)
    down.Font = Enum.Font.SourceSans
    down.Text = "Менше"
    down.TextColor3 = Color3.fromRGB(240, 240, 240)
    down.TextSize = 14.000
    
    local onof = Instance.new("TextButton")
    onof.Name = "onof"
    onof.Parent = Frame
    onof.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    onof.BorderColor3 = Color3.fromRGB(150, 150, 150)
    onof.Position = UDim2.new(0.702823281, 0, 0.491228074, 1)
    onof.Size = UDim2.new(0, 56, 0, 28)
    onof.Font = Enum.Font.SourceSans
    onof.Text = "Політ"
    onof.TextColor3 = Color3.fromRGB(240, 240, 240)
    onof.TextSize = 14.000
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = Frame
    TextLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TextLabel.BorderColor3 = Color3.fromRGB(150, 150, 150)
    TextLabel.Position = UDim2.new(0.469327301, 0, -0.001, 0)  -- Изменена позиция, чтобы текст был сверху
    TextLabel.Size = UDim2.new(0, 100, 0, 27)
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.Text = "Fly KlorPe"
    TextLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    TextLabel.TextScaled = true
    TextLabel.TextSize = 14.000
    TextLabel.TextWrapped = true
    
    local plus = Instance.new("TextButton")
    plus.Name = "plus"
    plus.Parent = Frame
    plus.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    plus.BorderColor3 = Color3.fromRGB(150, 150, 150)
    plus.Position = UDim2.new(0.231578946, 0, 0, 0)
    plus.Size = UDim2.new(0, 44, 0, 28)
    plus.Font = Enum.Font.SourceSans
    plus.Text = "+"
    plus.TextColor3 = Color3.fromRGB(240, 240, 240)
    plus.TextScaled = true
    plus.TextSize = 14.000
    plus.TextWrapped = true
    
    local speed = Instance.new("TextLabel")
    speed.Name = "speed"
    speed.Parent = Frame
    speed.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    speed.BorderColor3 = Color3.fromRGB(150, 150, 150)
    speed.Position = UDim2.new(0.468421042, 0, 0.491228074, 1)
    speed.Size = UDim2.new(0, 44, 0, 28)
    speed.Font = Enum.Font.SourceSans
    speed.Text = "1"
    speed.TextColor3 = Color3.fromRGB(240, 240, 240)
    speed.TextScaled = true
    speed.TextSize = 14.000
    speed.TextWrapped = true
    
    local mine = Instance.new("TextButton")
    mine.Name = "mine"
    mine.Parent = Frame
    mine.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mine.BorderColor3 = Color3.fromRGB(150, 150, 150)
    mine.Position = UDim2.new(0.231578946, 0, 0.491228074, 1)
    mine.Size = UDim2.new(0, 44, 0, 28)
    mine.Font = Enum.Font.SourceSans
    mine.Text = "-"
    mine.TextColor3 = Color3.fromRGB(240, 240, 240)
    mine.TextScaled = true
    mine.TextSize = 14.000
    mine.TextWrapped = true
    
    local closebutton = Instance.new("TextButton")
    closebutton.Name = "Close"
    closebutton.Parent = Frame
    closebutton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    closebutton.BorderColor3 = Color3.fromRGB(150, 150, 150)
    closebutton.Font = Enum.Font.SourceSans
    closebutton.Size = UDim2.new(0, 44, 0, 28)
    closebutton.Text = "X"
    closebutton.TextSize = 30
    closebutton.Position = UDim2.new(0, 0, -1, 27)
    
    local mini = Instance.new("TextButton")
    mini.Name = "minimize"
    mini.Parent = Frame
    mini.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mini.BorderColor3 = Color3.fromRGB(150, 150, 150)
    mini.Font = Enum.Font.SourceSans
    mini.Size = UDim2.new(0, 44, 0, 28)
    mini.Text = "-"
    mini.TextSize = 40
    mini.Position = UDim2.new(0, 44, -1, 27)
    
    local mini2 = Instance.new("TextButton")
    mini2.Name = "minimize2"
    mini2.Parent = Frame
    mini2.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mini2.BorderColor3 = Color3.fromRGB(150, 150, 150)
    mini2.Font = Enum.Font.SourceSans
    mini2.Size = UDim2.new(0, 44, 0, 28)
    mini2.Text = "+"
    mini2.TextSize = 40
    mini2.Position = UDim2.new(0, 44, -1, 57)
    mini2.Visible = false
    
    speeds = 1
    
    local speaker = game:GetService("Players").LocalPlayer
    
    local chr = game.Players.LocalPlayer.Character
    local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
    
    nowe = false
    
    game:GetService("StarterGui"):SetCore("SendNotification", { 
        Title = "Fly KlorPe";
        Text = "By KlorPe";
        Icon = "rbxthumb://type=Asset&id=5107182114&w=150&h=150"})
    Duration = 5;
    
    Frame.Active = true -- main = gui
    Frame.Draggable = true
    
    onof.MouseButton1Down:connect(function()
    
        if nowe == true then
            nowe = false
    
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,true)
            speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        else 
            nowe = true
    
    
    
            for i = 1, speeds do
                spawn(function()
    
                    local hb = game:GetService("RunService").Heartbeat	
    
    
                    tpwalking = true
                    local chr = game.Players.LocalPlayer.Character
                    local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                    while tpwalking and hb:Wait() and chr and hum and hum.Parent do
                        if hum.MoveDirection.Magnitude > 0 then
                            chr:TranslateBy(hum.MoveDirection)
                        end
                    end
    
                end)
            end
            game.Players.LocalPlayer.Character.Animate.Disabled = true
            local Char = game.Players.LocalPlayer.Character
            local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
    
            for i,v in next, Hum:GetPlayingAnimationTracks() do
                v:AdjustSpeed(0)
            end
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,false)
            speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
        end
    
    
    
    
        if game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
    
    
    
            local plr = game.Players.LocalPlayer
            local torso = plr.Character.Torso
            local flying = true
            local deb = true
            local ctrl = {f = 0, b = 0, l = 0, r = 0}
            local lastctrl = {f = 0, b = 0, l = 0, r = 0}
            local maxspeed = 50
            local speed = 0
    
    
            local bg = Instance.new("BodyGyro", torso)
            bg.P = 9e4
            bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.cframe = torso.CFrame
            local bv = Instance.new("BodyVelocity", torso)
            bv.velocity = Vector3.new(0,0.1,0)
            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
            if nowe == true then
                plr.Character.Humanoid.PlatformStand = true
            end
            while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
                game:GetService("RunService").RenderStepped:Wait()
    
                if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                    speed = speed+.5+(speed/maxspeed)
                    if speed > maxspeed then
                        speed = maxspeed
                    end
                elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
                    speed = speed-1
                    if speed < 0 then
                        speed = 0
                    end
                end
                if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                    bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
                    lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
                elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
                    bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
                else
                    bv.velocity = Vector3.new(0,0,0)
                end
                --	game.Players.LocalPlayer.Character.Animate.Disabled = true
                bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
            end
            ctrl = {f = 0, b = 0, l = 0, r = 0}
            lastctrl = {f = 0, b = 0, l = 0, r = 0}
            speed = 0
            bg:Destroy()
            bv:Destroy()
            plr.Character.Humanoid.PlatformStand = false
            game.Players.LocalPlayer.Character.Animate.Disabled = false
            tpwalking = false
    
    
    
    
        else
            local plr = game.Players.LocalPlayer
            local UpperTorso = plr.Character.UpperTorso
            local flying = true
            local deb = true
            local ctrl = {f = 0, b = 0, l = 0, r = 0}
            local lastctrl = {f = 0, b = 0, l = 0, r = 0}
            local maxspeed = 50
            local speed = 0
    
    
            local bg = Instance.new("BodyGyro", UpperTorso)
            bg.P = 9e4
            bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.cframe = UpperTorso.CFrame
            local bv = Instance.new("BodyVelocity", UpperTorso)
            bv.velocity = Vector3.new(0,0.1,0)
            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
            if nowe == true then
                plr.Character.Humanoid.PlatformStand = true
            end
            while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
                wait()
    
                if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                    speed = speed+.5+(speed/maxspeed)
                    if speed > maxspeed then
                        speed = maxspeed
                    end
                elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
                    speed = speed-1
                    if speed < 0 then
                        speed = 0
                    end
                end
                if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                    bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
                    lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
                elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
                    bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
                else
                    bv.velocity = Vector3.new(0,0,0)
                end
    
                bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
            end
            ctrl = {f = 0, b = 0, l = 0, r = 0}
            lastctrl = {f = 0, b = 0, l = 0, r = 0}
            speed = 0
            bg:Destroy()
            bv:Destroy()
            plr.Character.Humanoid.PlatformStand = false
            game.Players.LocalPlayer.Character.Animate.Disabled = false
            tpwalking = false
    
    
    
        end
    
    
    
    
    
    end)
    
    local tis
    
    up.MouseButton1Down:connect(function()
        tis = up.MouseEnter:connect(function()
            while tis do
                wait()
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0)
            end
        end)
    end)
    
    up.MouseLeave:connect(function()
        if tis then
            tis:Disconnect()
            tis = nil
        end
    end)
    
    local dis
    
    down.MouseButton1Down:connect(function()
        dis = down.MouseEnter:connect(function()
            while dis do
                wait()
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,-1,0)
            end
        end)
    end)
    
    down.MouseLeave:connect(function()
        if dis then
            dis:Disconnect()
            dis = nil
        end
    end)
    
    
    game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(char)
        wait(0.7)
        game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
        game.Players.LocalPlayer.Character.Animate.Disabled = false
    
    end)
    
    
    plus.MouseButton1Down:connect(function()
        speeds = speeds + 1
        speed.Text = speeds
        if nowe == true then
    
    
            tpwalking = false
            for i = 1, speeds do
                spawn(function()
    
                    local hb = game:GetService("RunService").Heartbeat	
    
    
                    tpwalking = true
                    local chr = game.Players.LocalPlayer.Character
                    local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                    while tpwalking and hb:Wait() and chr and hum and hum.Parent do
                        if hum.MoveDirection.Magnitude > 0 then
                            chr:TranslateBy(hum.MoveDirection)
                        end
                    end
    
                end)
            end
        end
    end)
    mine.MouseButton1Down:connect(function()
        if speeds == 1 then
            speed.Text = 'Не може бути менше 1'
            wait(1)
            speed.Text = speeds
        else
            speeds = speeds - 1
            speed.Text = speeds
            if nowe == true then
                tpwalking = false
                for i = 1, speeds do
                    spawn(function()
    
                        local hb = game:GetService("RunService").Heartbeat	
    
    
                        tpwalking = true
                        local chr = game.Players.LocalPlayer.Character
                        local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                        while tpwalking and hb:Wait() and chr and hum and hum.Parent do
                            if hum.MoveDirection.Magnitude > 0 then
                                chr:TranslateBy(hum.MoveDirection)
                            end
                        end
    
                    end)
                end
            end
        end
    end)
    
    closebutton.MouseButton1Click:Connect(function()
        main:Destroy()
    end)
    
    mini.MouseButton1Click:Connect(function()
        up.Visible = false
        down.Visible = false
        onof.Visible = false
        plus.Visible = false
        speed.Visible = false
        mine.Visible = false
        mini.Visible = false
        mini2.Visible = true
        main.Frame.BackgroundTransparency = 1
        closebutton.Position =  UDim2.new(0, 0, -1, 57)
    end)
    
    mini2.MouseButton1Click:Connect(function()
        up.Visible = true
        down.Visible = true
        onof.Visible = true
        plus.Visible = true
        speed.Visible = true
        mine.Visible = true
        mini.Visible = true
        mini2.Visible = false
        main.Frame.BackgroundTransparency = 0 
        closebutton.Position =  UDim2.new(0, 0, -1, 27)
    end)

end

PlayerTab:AddButton({
    Name = "Політ",
    Callback = function()
        activateFLY()
    end
})

local UniversalTab = Window:MakeTab({
    Name = "Аім", 
    Icon = "rbxassetid://17404114716", 
    PremiumOnly = false
})

local UniversalSection = UniversalTab:AddSection({
    Name = "Аім"
})

local AimbotScript = loadstring([[
    local game, workspace = game, workspace
local getrawmetatable, getmetatable, setmetatable, pcall, getgenv, next, tick, select = getrawmetatable, getmetatable, setmetatable, pcall, getgenv, next, tick, select
local Vector2new, Vector3new, Vector3zero, CFramenew, Color3fromRGB, Color3fromHSV, Drawingnew, TweenInfonew = Vector2.new, Vector3.new, Vector3.zero, CFrame.new, Color3.fromRGB, Color3.fromHSV, Drawing.new, TweenInfo.new
local getupvalue, mousemoverel, tablefind, tableremove, stringlower, stringsub, mathclamp = debug.getupvalue, mousemoverel or (Input and Input.MouseMove), table.find, table.remove, string.lower, string.sub, math.clamp

local GameMetatable = getrawmetatable and getrawmetatable(game) or {__index = function(self, Index)
	return self[Index]
end, __newindex = function(self, Index, Value)
	self[Index] = Value
end}

local __index = GameMetatable.__index
local __newindex = GameMetatable.__newindex
local GetService = select(2, pcall(__index, game, "GetService")) or game.GetService

--// Services

local RunService = GetService(game, "RunService")
local UserInputService = GetService(game, "UserInputService")
local TweenService = GetService(game, "TweenService")
local Players = GetService(game, "Players")

--// Degrade "__index" and "__newindex" functions if the executor doesn't support "getrawmetatable" properly.

local ReciprocalRelativeSensitivity = false

if getrawmetatable and select(2, pcall(__index, Players, "LocalPlayer")) then
	ReciprocalRelativeSensitivity = true

	__index, __newindex = function(Object, Key)
		return Object[Key]
	end, function(Object, Key, Value)
		Object[Key] = Value
	end
end

--// Service Methods

local LocalPlayer = __index(Players, "LocalPlayer")
local Camera = __index(workspace, "CurrentCamera")

local FindFirstChild, FindFirstChildOfClass = __index(game, "FindFirstChild"), __index(game, "FindFirstChildOfClass")
local GetDescendants = __index(game, "GetDescendants")
local WorldToViewportPoint = __index(Camera, "WorldToViewportPoint")
local GetPartsObscuringTarget = __index(Camera, "GetPartsObscuringTarget")
local GetMouseLocation = __index(UserInputService, "GetMouseLocation")
local GetPlayers = __index(Players, "GetPlayers")

--// Variables

local RequiredDistance, Typing, Running, ServiceConnections, Animation, OriginalSensitivity = 2000, false, false, {}
local Connect, Disconnect, GetRenderProperty, SetRenderProperty = __index(game, "DescendantAdded").Connect

local Degrade = false

do
	xpcall(function()
		local TemporaryDrawing = Drawingnew("Line")
		GetRenderProperty = getupvalue(getmetatable(TemporaryDrawing).__index, 4)
		SetRenderProperty = getupvalue(getmetatable(TemporaryDrawing).__newindex, 4)
		TemporaryDrawing.Remove(TemporaryDrawing)
	end, function()
		Degrade, GetRenderProperty, SetRenderProperty = true, function(Object, Key)
			return Object[Key]
		end, function(Object, Key, Value)
			Object[Key] = Value
		end
	end)

	local TemporaryConnection = Connect(__index(game, "DescendantAdded"), function() end)
	Disconnect = TemporaryConnection.Disconnect
	Disconnect(TemporaryConnection)
end

--// Checking for multiple processes

if ExunysDeveloperAimbot and ExunysDeveloperAimbot.Exit then
	ExunysDeveloperAimbot:Exit()
end

--// Environment

getgenv().ExunysDeveloperAimbot = {
	DeveloperSettings = {
		UpdateMode = "RenderStepped",
		TeamCheckOption = "TeamColor",
		RainbowSpeed = 1 -- Bigger = Slower
	},

	Settings = {
		Enabled = true,

		TeamCheck = false,
		AliveCheck = true,
		WallCheck = false,

		OffsetToMoveDirection = false,
		OffsetIncrement = 15,

		Sensitivity = 0, -- Animation length (in seconds) before fully locking onto target
		Sensitivity2 = 3.5, -- mousemoverel Sensitivity

		LockMode = 1, -- 1 = CFrame; 2 = mousemoverel
		LockPart = "Head", -- Body part to lock on

		TriggerKey = Enum.UserInputType.MouseButton2,
		Toggle = false
	},

	FOVSettings = {
		Enabled = true,
		Visible = true,

		Radius = 280,
		NumSides = 60,

		Thickness = 1,
		Transparency = 1,
		Filled = false,

		RainbowColor = false,
		RainbowOutlineColor = false,
		Color = Color3fromRGB(255, 255, 255),
		OutlineColor = Color3fromRGB(0, 0, 0),
		LockedColor = Color3fromRGB(255, 150, 150)
	},

	Blacklisted = {},
	FOVCircle = Drawingnew("Circle"),
	FOVCircleOutline = Drawingnew("Circle")
}

local Environment = getgenv().ExunysDeveloperAimbot

SetRenderProperty(Environment.FOVCircle, "Visible", false)
SetRenderProperty(Environment.FOVCircleOutline, "Visible", false)

--// Core Functions

local FixUsername = function(String)
	local Result

	for _, Value in next, GetPlayers(Players) do
		local Name = __index(Value, "Name")

		if stringsub(stringlower(Name), 1, #String) == stringlower(String) then
			Result = Name
		end
	end

	return Result
end

local GetRainbowColor = function()
	local RainbowSpeed = Environment.DeveloperSettings.RainbowSpeed

	return Color3fromHSV(tick() % RainbowSpeed / RainbowSpeed, 1, 1)
end

local ConvertVector = function(Vector)
	return Vector2new(Vector.X, Vector.Y)
end

local CancelLock = function()
	Environment.Locked = nil

	local FOVCircle = Degrade and Environment.FOVCircle or Environment.FOVCircle.__OBJECT

	SetRenderProperty(FOVCircle, "Color", Environment.FOVSettings.Color)
	__newindex(UserInputService, "MouseDeltaSensitivity", OriginalSensitivity)

	if Animation then
		Animation:Cancel()
	end
end

local GetClosestPlayer = function()
	local Settings = Environment.Settings
	local LockPart = Settings.LockPart

	if not Environment.Locked then
		RequiredDistance = Environment.FOVSettings.Enabled and Environment.FOVSettings.Radius or 2000

		for _, Value in next, GetPlayers(Players) do
			local Character = __index(Value, "Character")
			local Humanoid = Character and FindFirstChildOfClass(Character, "Humanoid")

			if Value ~= LocalPlayer and not tablefind(Environment.Blacklisted, __index(Value, "Name")) and Character and FindFirstChild(Character, LockPart) and Humanoid then
				local PartPosition, TeamCheckOption = __index(Character[LockPart], "Position"), Environment.DeveloperSettings.TeamCheckOption

				if Settings.TeamCheck and __index(Value, TeamCheckOption) == __index(LocalPlayer, TeamCheckOption) then
					continue
				end

				if Settings.AliveCheck and __index(Humanoid, "Health") <= 0 then
					continue
				end

				if Settings.WallCheck then
					local BlacklistTable = GetDescendants(__index(LocalPlayer, "Character"))

					for _, Value in next, GetDescendants(Character) do
						BlacklistTable[#BlacklistTable + 1] = Value
					end

					if #GetPartsObscuringTarget(Camera, {PartPosition}, BlacklistTable) > 0 then
						continue
					end
				end

				local Vector, OnScreen, Distance = WorldToViewportPoint(Camera, PartPosition)
				Vector = ConvertVector(Vector)
				Distance = (GetMouseLocation(UserInputService) - Vector).Magnitude

				if Distance < RequiredDistance and OnScreen then
					RequiredDistance, Environment.Locked = Distance, Value
				end
			end
		end
	elseif (GetMouseLocation(UserInputService) - ConvertVector(WorldToViewportPoint(Camera, __index(__index(__index(Environment.Locked, "Character"), LockPart), "Position")))).Magnitude > RequiredDistance then
		CancelLock()
	end
end

local Load = function()
	OriginalSensitivity = __index(UserInputService, "MouseDeltaSensitivity")

	local Settings, FOVCircle, FOVCircleOutline, FOVSettings, Offset = Environment.Settings, Environment.FOVCircle, Environment.FOVCircleOutline, Environment.FOVSettings

	if not Degrade then
		FOVCircle, FOVCircleOutline = FOVCircle.__OBJECT, FOVCircleOutline.__OBJECT
	end

	SetRenderProperty(FOVCircle, "ZIndex", 2)
	SetRenderProperty(FOVCircleOutline, "ZIndex", 1)

	ServiceConnections.RenderSteppedConnection = Connect(__index(RunService, Environment.DeveloperSettings.UpdateMode), function()
		local OffsetToMoveDirection, LockPart = Settings.OffsetToMoveDirection, Settings.LockPart

		if FOVSettings.Enabled and Settings.Enabled then
			for Index, Value in next, FOVSettings do
				if Index == "Color" then
					continue
				end

				if pcall(GetRenderProperty, FOVCircle, Index) then
					SetRenderProperty(FOVCircle, Index, Value)
					SetRenderProperty(FOVCircleOutline, Index, Value)
				end
			end

			SetRenderProperty(FOVCircle, "Color", (Environment.Locked and FOVSettings.LockedColor) or FOVSettings.RainbowColor and GetRainbowColor() or FOVSettings.Color)
			SetRenderProperty(FOVCircleOutline, "Color", FOVSettings.RainbowOutlineColor and GetRainbowColor() or FOVSettings.OutlineColor)

			SetRenderProperty(FOVCircleOutline, "Thickness", FOVSettings.Thickness + 1)
			SetRenderProperty(FOVCircle, "Position", GetMouseLocation(UserInputService))
			SetRenderProperty(FOVCircleOutline, "Position", GetMouseLocation(UserInputService))
		else
			SetRenderProperty(FOVCircle, "Visible", false)
			SetRenderProperty(FOVCircleOutline, "Visible", false)
		end

		if Running and Settings.Enabled then
			GetClosestPlayer()

			Offset = OffsetToMoveDirection and __index(FindFirstChildOfClass(__index(Environment.Locked, "Character"), "Humanoid"), "MoveDirection") * (mathclamp(Settings.OffsetIncrement, 1, 30) / 10) or Vector3zero

			if Environment.Locked then
				local LockedPosition_Vector3 = __index(__index(Environment.Locked, "Character")[LockPart], "Position")
				local LockedPosition = WorldToViewportPoint(Camera, LockedPosition_Vector3 + Offset)
 
				local RelativeSensitivity = ReciprocalRelativeSensitivity and (1 / Settings.Sensitivity2) or Settings.Sensitivity2

				if Environment.Settings.LockMode == 2 then
					mousemoverel((LockedPosition.X - GetMouseLocation(UserInputService).X) * RelativeSensitivity, (LockedPosition.Y - GetMouseLocation(UserInputService).Y) * RelativeSensitivity)
				else
					if Settings.Sensitivity > 0 then
						Animation = TweenService:Create(Camera, TweenInfonew(Environment.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFramenew(Camera.CFrame.Position, LockedPosition_Vector3)})
						Animation:Play()
					else
						__newindex(Camera, "CFrame", CFramenew(Camera.CFrame.Position, LockedPosition_Vector3 + Offset))
					end

					__newindex(UserInputService, "MouseDeltaSensitivity", 0)
				end

				SetRenderProperty(FOVCircle, "Color", FOVSettings.LockedColor)
			end
		end
	end)

	ServiceConnections.InputBeganConnection = Connect(__index(UserInputService, "InputBegan"), function(Input)
		local TriggerKey, Toggle = Settings.TriggerKey, Settings.Toggle

		if Typing then
			return
		end

		if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == TriggerKey or Input.UserInputType == TriggerKey then
			if Toggle then
				Running = not Running
 
				if not Running then
					CancelLock()
				end
			else
				Running = true
			end
		end
	end)

	ServiceConnections.InputEndedConnection = Connect(__index(UserInputService, "InputEnded"), function(Input)
		local TriggerKey, Toggle = Settings.TriggerKey, Settings.Toggle
 
		if Toggle or Typing then
			return
		end
 
		if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == TriggerKey or Input.UserInputType == TriggerKey then
			Running = false
			CancelLock()
		end
	end)
end

--// Typing Check

ServiceConnections.TypingStartedConnection = Connect(__index(UserInputService, "TextBoxFocused"), function()
	Typing = true
end)

ServiceConnections.TypingEndedConnection = Connect(__index(UserInputService, "TextBoxFocusReleased"), function()
	Typing = false
end)

--// Functions

function Environment.Exit(self) -- METHOD | ExunysDeveloperAimbot:Exit(<void>)
	assert(self, "EXUNYS_AIMBOT-V3.Exit: Missing parameter #1 \"self\" <table>.")
 
	for Index, _ in next, ServiceConnections do
		Disconnect(ServiceConnections[Index])
	end
 
	Load = nil; ConvertVector = nil; CancelLock = nil; GetClosestPlayer = nil; GetRainbowColor = nil; FixUsername = nil
 
	self.FOVCircle:Remove()
	self.FOVCircleOutline:Remove()
	getgenv().ExunysDeveloperAimbot = nil
end

function Environment.Restart() -- ExunysDeveloperAimbot.Restart(<void>)
	for Index, _ in next, ServiceConnections do
		Disconnect(ServiceConnections[Index])
	end
 
	Load()
end

function Environment.Blacklist(self, Username) -- METHOD | ExunysDeveloperAimbot:Blacklist(<string> Player Name)
	assert(self, "EXUNYS_AIMBOT-V3.Blacklist: Missing parameter #1 \"self\" <table>.")
	assert(Username, "EXUNYS_AIMBOT-V3.Blacklist: Missing parameter #2 \"Username\" <string>.")
 
	Username = FixUsername(Username)
 
	assert(self, "EXUNYS_AIMBOT-V3.Blacklist: User "..Username.." couldn't be found.")
 
	self.Blacklisted[#self.Blacklisted + 1] = Username
end

function Environment.Whitelist(self, Username) -- METHOD | ExunysDeveloperAimbot:Whitelist(<string> Player Name)
	assert(self, "EXUNYS_AIMBOT-V3.Whitelist: Missing parameter #1 \"self\" <table>.")
	assert(Username, "EXUNYS_AIMBOT-V3.Whitelist: Missing parameter #2 \"Username\" <string>.")
 
	Username = FixUsername(Username)
 
	assert(Username, "EXUNYS_AIMBOT-V3.Whitelist: User "..Username.." couldn't be found.")
 
	local Index = tablefind(self.Blacklisted, Username)
 
	assert(Index, "EXUNYS_AIMBOT-V3.Whitelist: User "..Username.." is not blacklisted.")
 
	tableremove(self.Blacklisted, Index)
end

function Environment.GetClosestPlayer() -- ExunysDeveloperAimbot.GetClosestPlayer(<void>)
	GetClosestPlayer()
	local Value = Environment.Locked
	CancelLock()
	
	return Value
end

Environment.Load = Load -- ExunysDeveloperAimbot.Load()

setmetatable(Environment, {__call = Load})

return Environment
]])()

UniversalTab:AddButton({
    Name = "Увімкнути аімбот",
    Callback = function()
        AimbotScript:Load()
    end
})

local AimTab = Window:MakeTab({
    Name = "Вх",
    Icon = "rbxassetid://17404114716",
    PremiumOnly = false
})

local ESPEnabled = false
local TracersEnabled = false
local HighlightEnabled = false
local UseTeamColor = false
local UseTeamColorForTracers = false
local UseTeamColorForHighlight = false

local updateInterval = 0.001
local lastUpdateTime = 0

local function activateESP()
    local plr = game.Players.LocalPlayer
    local camera = game.Workspace.CurrentCamera

    function getTeamColor(player)
        if UseTeamColor and player.Team then
            return player.Team.TeamColor.Color
        else
            return Color3.fromRGB(255, 255, 255)
        end
    end

    function getTracerColor(player)
        if UseTeamColorForTracers and player.Team then
            return player.Team.TeamColor.Color
        else
            return Color3.fromRGB(255, 255, 255)
        end
    end

    for i, v in pairs(game.Players:GetPlayers()) do
        local Top = Drawing.new("Line")
        Top.Visible = false
        Top.Color = getTeamColor(v)
        Top.Thickness = 2
        Top.Transparency = 1

        local Bottom = Drawing.new("Line")
        Bottom.Visible = false
        Bottom.Color = getTeamColor(v)
        Bottom.Thickness = 2
        Bottom.Transparency = 1

        local Left = Drawing.new("Line")
        Left.Visible = false
        Left.Color = getTeamColor(v)
        Left.Thickness = 2
        Left.Transparency = 1

        local Right = Drawing.new("Line")
        Right.Visible = false
        Right.Color = getTeamColor(v)
        Right.Thickness = 2
        Right.Transparency = 1

        local Tracer = Drawing.new("Line")
        Tracer.Visible = false
        Tracer.Color = getTracerColor(v)
        Tracer.Thickness = 2
        Tracer.Transparency = 1

        function ESP()
            local connection
            connection = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
                lastUpdateTime = lastUpdateTime + deltaTime
                if lastUpdateTime < updateInterval then
                    return
                end
                lastUpdateTime = 0

                if not ESPEnabled and not TracersEnabled then
                    Top.Visible = false
                    Left.Visible = false
                    Bottom.Visible = false
                    Right.Visible = false
                    Tracer.Visible = false
                    connection:Disconnect()
                    return
                end

                if v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Name ~= plr.Name and v.Character.Humanoid.Health > 0 then
                    local teamColor = getTeamColor(v)
                    local tracerColor = getTracerColor(v)
                    Top.Color = teamColor
                    Bottom.Color = teamColor
                    Left.Color = teamColor
                    Right.Color = teamColor
                    Tracer.Color = tracerColor

                    local ScreenPos, OnScreen = camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                    if OnScreen then
                        local Scale = v.Character.Head.Size.Y / 2
                        local Size = Vector3.new(2, 3, 0) * (Scale * 2)
                        local TL = camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, Size.Y, 0)).p)
                        local TR = camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, Size.Y, 0)).p)
                        local BL = camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, -Size.Y, 0)).p)
                        local BR = camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, -Size.Y, 0)).p)

                        Top.From = Vector2.new(TL.X, TL.Y)
                        Top.To = Vector2.new(TR.X, TR.Y)
                        Left.From = Vector2.new(TL.X, TL.Y)
                        Left.To = Vector2.new(BL.X, BL.Y)
                        Right.From = Vector2.new(TR.X, TR.Y)
                        Right.To = Vector2.new(BR.X, BR.Y)
                        Bottom.From = Vector2.new(BL.X, BL.Y)
                        Bottom.To = Vector2.new(BR.X, BR.Y)

                        if TracersEnabled then
                            Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                            Tracer.To = Vector2.new(ScreenPos.X, ScreenPos.Y)
                            Tracer.Visible = true
                        else
                            Tracer.Visible = false
                        end

                        Top.Visible = ESPEnabled
                        Left.Visible = ESPEnabled
                        Bottom.Visible = ESPEnabled
                        Right.Visible = ESPEnabled
                    else
                        Top.Visible = false
                        Left.Visible = false
                        Bottom.Visible = false
                        Right.Visible = false
                        Tracer.Visible = false
                    end
                else
                    Top.Visible = false
                    Left.Visible = false
                    Bottom.Visible = false
                    Right.Visible = false
                    Tracer.Visible = false
                    if not game.Players:FindFirstChild(v.Name) then
                        connection:Disconnect()
                    end
                end
            end)
        end
        coroutine.wrap(ESP)()
    end

    game.Players.PlayerAdded:Connect(function(newplr)
        initializeESP(newplr)
    end)
end

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local HighlightEnabled = true -- Переменная для управления включением/выключением функции
local UseTeamColorForHighlight = true -- Использовать ли командные цвета для Highlight

local function applyHighlight(player)
    if player == localPlayer then return end -- Пропускаем локального игрока

    local function createHighlightForCharacter(character)
        -- Проверяем, включен ли Highlight
        if not HighlightEnabled or not character then return end
        
        -- Создаем Highlight и настраиваем
        local highlight = Instance.new("Highlight")
        highlight.Archivable = true
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Enabled = true

        -- Устанавливаем цвет на основе команды или стандартный
        if UseTeamColorForHighlight and player.Team then
            highlight.FillColor = player.Team.TeamColor.Color
        else
            highlight.FillColor = Color3.fromRGB(255, 0, 4)
        end

        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = character

        -- Удаляем Highlight при удалении персонажа
        player.CharacterRemoving:Connect(function()
            if highlight then
                highlight:Destroy()
            end
        end)

        -- Изменение цвета при смене команды
        player:GetPropertyChangedSignal("Team"):Connect(function()
            if UseTeamColorForHighlight and player.Team then
                highlight.FillColor = player.Team.TeamColor.Color
            else
                highlight.FillColor = Color3.fromRGB(255, 0, 4)
            end
        end)
    end

    -- Если у игрока уже есть персонаж
    if player.Character then
        createHighlightForCharacter(player.Character)
    end

    -- Подключаемся к событию появления персонажа
    player.CharacterAdded:Connect(createHighlightForCharacter)
end

-- Включение Highlight для всех игроков
local function activateHighlight()
    for _, player in pairs(Players:GetPlayers()) do
        applyHighlight(player)
    end

    -- Подключаемся к событию добавления нового игрока
    Players.PlayerAdded:Connect(function(player)
        applyHighlight(player)
    end)
end

-- Отключение Highlight
local function deactivateHighlight()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            for _, highlight in pairs(player.Character:GetChildren()) do
                if highlight:IsA("Highlight") then
                    highlight:Destroy()
                end
            end
        end
    end
end

local Section = AimTab:AddSection({
    Name = "Інтервал оновлення"
})

AimTab:AddSlider({
    Name = "Інтервал оновлення: боксів, трейсерів (Впливає на ФПС)",
    Min = 0.001,
    Max = 0.03,
    Default = 0.001,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.001,
    ValueName = "секунд",
    Callback = function(value)
        updateInterval = value
    end
})

local Section = AimTab:AddSection({
    Name = "Бокс"
})

AimTab:AddToggle({
    Name = "Бокс",
    Default = false,
    Callback = function(state)
        ESPEnabled = state
        if ESPEnabled then
            activateESP()
        end
    end
})

AimTab:AddToggle({
    Name = "Колір команди (Якщо є)",
    Default = false,
    Callback = function(state)
        UseTeamColor = state
    end
})

local Section = AimTab:AddSection({
    Name = "Трейсери"
})

AimTab:AddToggle({
    Name = "Трейсери",
    Default = false,
    Callback = function(state)
        TracersEnabled = state
        if TracersEnabled then
            activateESP()
        end
    end
})

AimTab:AddToggle({
    Name = "Колір команди (Якщо є)",
    Default = false,
    Callback = function(state)
        UseTeamColorForTracers = state
    end
})

local Section = AimTab:AddSection({
    Name = "Виділення (Інтервал оновлення не впливає)"
})

AimTab:AddToggle({
    Name = "Виділення",
    Default = false,
    Callback = function(state)
        HighlightEnabled = state
        if HighlightEnabled then
            activateHighlight()
        else
            deactivateHighlight()
        end
    end
})

AimTab:AddToggle({
    Name = "Колір команди (Якщо є)",
    Default = false,
    Callback = function(state)
        UseTeamColorForHighlight = state
        if HighlightEnabled then
            deactivateHighlight()
            activateHighlight()
        end
    end
})
