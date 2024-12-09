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

local Section = PlayerTab:AddSection({
    Name = "Рух"
})

local walkSpeed = 16
local jumpHeight = 7
local fieldOfView = 70  -- Начальное значение FOV

-- Функция для блокировки изменений
local function monitorHumanoid(humanoid)
    -- Блокируем изменение WalkSpeed
    humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if humanoid.WalkSpeed ~= walkSpeed then
            humanoid.WalkSpeed = walkSpeed
        end
    end)

    -- Блокируем изменение JumpHeight
    humanoid:GetPropertyChangedSignal("JumpHeight"):Connect(function()
        if humanoid.JumpHeight ~= jumpHeight then
            humanoid.JumpHeight = jumpHeight
        end
    end)

    -- Устанавливаем начальные значения
    humanoid.WalkSpeed = walkSpeed
    humanoid.JumpHeight = jumpHeight
end

-- Функция для блокировки изменений FOV
local function monitorFOV()
    game.Workspace.CurrentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
        if game.Workspace.CurrentCamera.FieldOfView ~= fieldOfView then
            game.Workspace.CurrentCamera.FieldOfView = fieldOfView
        end
    end)

    -- Устанавливаем начальное значение FOV
    game.Workspace.CurrentCamera.FieldOfView = fieldOfView
end

local function setupCharacter(character)
    local humanoid = character:WaitForChild("Humanoid") -- Ждем появления Humanoid
    if humanoid then
        humanoid.WalkSpeed = walkSpeed -- Устанавливаем скорость
        humanoid.JumpHeight = jumpHeight -- Устанавливаем высоту прыжка
        monitorHumanoid(humanoid) -- Подключаем блокировку изменений
    end
end

-- Отслеживаем, когда персонаж игрока появляется
game.Players.LocalPlayer.CharacterAdded:Connect(setupCharacter)

-- Для уже существующего персонажа
if game.Players.LocalPlayer.Character then
    setupCharacter(game.Players.LocalPlayer.Character)
end

-- Запускаем защиту FOV
monitorFOV()

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
        local character = game.Players.LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = walkSpeed
            end
        end
    end
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
        local character = game.Players.LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.JumpHeight = jumpHeight
            end
        end
    end
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
        game.Workspace.CurrentCamera.FieldOfView = fieldOfView
    end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping")
    end
end)

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

local UniversalTab = Window:MakeTab({
    Name = "Універсальне", 
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

local UniversalSection = UniversalTab:AddSection({
    Name = "Вх"
})

-- Функция для активации ESP
local function activateESP()
    local plr = game.Players.LocalPlayer
    local camera = game.Workspace.CurrentCamera

    function getTeamColor(player)
        if player.Team then
            return player.Team.TeamColor.Color -- Цвет команды
        else
            return Color3.fromRGB(255, 255, 255) -- Белый цвет по умолчанию
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

        function ESP()
            local connection
            connection = game:GetService("RunService").RenderStepped:Connect(function()
                if v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Name ~= plr.Name and v.Character.Humanoid.Health > 0 then
                    -- Обновляем цвет для игрока
                    local teamColor = getTeamColor(v)
                    Top.Color = teamColor
                    Bottom.Color = teamColor
                    Left.Color = teamColor
                    Right.Color = teamColor

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

                        Top.Visible = true
                        Left.Visible = true
                        Bottom.Visible = true
                        Right.Visible = true
                    else
                        Top.Visible = false
                        Left.Visible = false
                        Bottom.Visible = false
                        Right.Visible = false
                    end
                else
                    Top.Visible = false
                    Left.Visible = false
                    Bottom.Visible = false
                    Right.Visible = false
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

UniversalTab:AddButton({
    Name = "Увімкнути вх",
    Callback = function()
        activateESP()
        print("ESP активирован!")
    end
})
