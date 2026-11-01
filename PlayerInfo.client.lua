local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local npcFolder = Workspace:WaitForChild("NPCs")

local TINY5_DUO = Font.new("rbxasset://fonts/families/Tiny5.json")

-- Opciones de funciones
local settings = {
    panel = true,
    highlights = true,
    nameplates = true,
    npcCamera = true,
}

local function setEnabled(instance, enabled)
    if instance then
        if instance:IsA("Highlight") then
            instance.Enabled = enabled
        else
            instance.Enabled = enabled
        end
    end
end

-- Interfaz
local gui = Instance.new("ScreenGui")
gui.Name = "TargetInfoGui"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(280, 58)
panel.Position = UDim2.new(0.5, -140, 0.72, 0)
panel.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui

local border = Instance.new("UIStroke")
border.Color = Color3.fromRGB(55, 55, 60)
border.Thickness = 1
border.Parent = panel

local portrait = Instance.new("ImageLabel")
portrait.Position = UDim2.fromOffset(5, 5)
portrait.Size = UDim2.fromOffset(48, 48)
portrait.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
portrait.BorderSizePixel = 0
portrait.Parent = panel

local nameLabel = Instance.new("TextLabel")
nameLabel.Position = UDim2.fromOffset(58, 5)
nameLabel.Size = UDim2.new(1, -63, 0, 14)
nameLabel.BackgroundTransparency = 1
nameLabel.FontFace = TINY5_DUO
nameLabel.TextSize = 14
nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
nameLabel.Parent = panel

local healthBack = Instance.new("Frame")
healthBack.Position = UDim2.fromOffset(58, 21)
healthBack.Size = UDim2.new(1, -63, 0, 13)
healthBack.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
healthBack.BorderSizePixel = 0
healthBack.Parent = panel

local healthFill = Instance.new("Frame")
healthFill.Size = UDim2.fromScale(1, 1)
healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 70)
healthFill.BorderSizePixel = 0
healthFill.Parent = healthBack

local healthText = Instance.new("TextLabel")
healthText.Size = UDim2.fromScale(1, 1)
healthText.BackgroundTransparency = 1
healthText.FontFace = TINY5_DUO
healthText.TextSize = 13
healthText.TextColor3 = Color3.fromRGB(0, 255, 70)
healthText.TextStrokeTransparency = 0.4
healthText.Parent = healthBack

local details = Instance.new("TextLabel")
details.Position = UDim2.fromOffset(58, 37)
details.Size = UDim2.new(1, -63, 0, 16)
details.BackgroundTransparency = 1
details.FontFace = TINY5_DUO
details.TextSize = 13
details.TextColor3 = Color3.fromRGB(205, 205, 205)
details.TextXAlignment = Enum.TextXAlignment.Left
details.TextTruncate = Enum.TextTruncate.AtEnd
details.Parent = panel

-- Menú de opciones
local menu = Instance.new("Frame")
menu.Size = UDim2.fromOffset(220, 190)
menu.Position = UDim2.new(0, 20, 0.5, -95)
menu.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
menu.BorderSizePixel = 0
menu.Visible = false
menu.Parent = gui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 8)
menuCorner.Parent = menu

local menuTitle = Instance.new("TextLabel")
menuTitle.Size = UDim2.new(1, 0, 0, 32)
menuTitle.BackgroundTransparency = 1
menuTitle.Font = Enum.Font.GothamBold
menuTitle.Text = "Opciones"
menuTitle.TextColor3 = Color3.new(1, 1, 1)
menuTitle.TextSize = 18
menuTitle.Parent = menu

local function makeToggle(label, key, y)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 30)
    button.Position = UDim2.fromOffset(10, y)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.Gotham
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 14
    button.Parent = menu

    local function refresh()
        button.Text = string.format("%s: %s", label, settings[key] and "ON" or "OFF")
        button.BackgroundColor3 = settings[key]
            and Color3.fromRGB(30, 120, 65)
            or Color3.fromRGB(100, 45, 45)
    end

    button.Activated:Connect(function()
        settings[key] = not settings[key]
        refresh()
    end)

    refresh()
end

makeToggle("Panel", "panel", 40)
makeToggle("Resaltados", "highlights", 75)
makeToggle("Etiquetas", "nameplates", 110)
makeToggle("Cámara NPC (T)", "npcCamera", 145)

-- Teclas M para mostrar/ocultar menú, T para activar seguimiento mientras se mantiene
local holdingT = false
local savedCameraType
local savedCameraSubject

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.M then
        menu.Visible = not menu.Visible
    elseif input.KeyCode == Enum.KeyCode.T and settings.npcCamera then
        holdingT = true
    end
end)

local function restoreCamera()
    local camera = Workspace.CurrentCamera
    if camera and savedCameraType then
        camera.CameraType = savedCameraType
        camera.CameraSubject = savedCameraSubject
    end

    savedCameraType = nil
    savedCameraSubject = nil
end

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.T then
        holdingT = false
        restoreCamera()
    end
end)

local function create(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties) do
        object[property] = value
    end
    object.Parent = parent
    return object
end

-- Resaltados y etiquetas de jugadores
local highlights = {}
local nameplates = {}

local function addPlayerVisuals(player, character)
    if player == localPlayer or not character then return end

    if not highlights[player] then
        highlights[player] = create("Highlight", {
            Name = "RedWhiteHighlight",
            FillColor = Color3.fromRGB(255, 0, 0),
            OutlineColor = Color3.new(1, 1, 1),
            FillTransparency = 0.25,
            OutlineTransparency = 0,
            DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
            Enabled = settings.highlights,
            Adornee = character,
        }, gui)
    else
        highlights[player].Adornee = character
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
        or character:WaitForChild("Humanoid", 5)
    local head = character:FindFirstChild("Head")
        or character:WaitForChild("Head", 5)

    if not humanoid or not head then return end

    if nameplates[player] then
        nameplates[player]:Destroy()
    end

    local billboard = create("BillboardGui", {
        Name = "PlayerNameplate",
        Adornee = head,
        Size = UDim2.fromOffset(200, 42),
        StudsOffset = Vector3.new(0, 2.5, 0),
        AlwaysOnTop = true,
        Enabled = settings.nameplates,
    }, gui)

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0.5, 0),
        BackgroundTransparency = 1,
        FontFace = TINY5_DUO,
        TextSize = 16,
        TextColor3 = Color3.new(1, 1, 1),
        TextStrokeColor3 = Color3.fromRGB(20, 20, 20),
        TextStrokeTransparency = 0.25,
        Text = player.DisplayName,
    }, billboard)

    local hpLabel = create("TextLabel", {
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0.5, 0),
        BackgroundTransparency = 1,
        FontFace = TINY5_DUO,
        TextSize = 15,
        TextColor3 = Color3.fromRGB(0, 255, 70),
        TextStrokeColor3 = Color3.fromRGB(20, 20, 20),
        TextStrokeTransparency = 0.25,
        Text = string.format("%d HP", math.ceil(humanoid.Health)),
    }, billboard)

    humanoid.HealthChanged:Connect(function(health)
        if hpLabel.Parent then
            hpLabel.Text = string.format("%d HP", math.ceil(health))
        end
    end)
end

local function connectPlayer(player)
    if player == localPlayer then return end

    if player.Character then
        addPlayerVisuals(player, player.Character)
    end

    player.CharacterAdded:Connect(function(character)
        addPlayerVisuals(player, character)
    end)
end

local function removePlayer(player)
    if highlights[player] then
        highlights[player]:Destroy()
        highlights[player] = nil
    end

    if nameplates[player] then
        nameplates[player]:Destroy()
        nameplates[player] = nil
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    connectPlayer(player)
end

Players.PlayerAdded:Connect(connectPlayer)
Players.PlayerRemoving:Connect(removePlayer)

-- Información del jugador apuntado
local thumbnailCache = {}

local function setPortrait(player)
    if thumbnailCache[player.UserId] then
        portrait.Image = thumbnailCache[player.UserId]
        return
    end

    task.spawn(function()
        local ok, image = pcall(function()
            return Players:GetUserThumbnailAsync(
                player.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size100x100
            )
        end)

        if ok then
            thumbnailCache[player.UserId] = image
            if nameLabel.Text == player.DisplayName then
                portrait.Image = image
            end
        end
    end)
end

local function getNpcTarget(camera)
    local center = camera.ViewportSize / 2
    local bestHumanoid
    local bestScreenDistance = math.huge

    for _, object in ipairs(npcFolder:GetDescendants()) do
        if object:IsA("Model") then
            local humanoid = object:FindFirstChildOfClass("Humanoid")
            local head = object:FindFirstChild("Head")

            if humanoid and humanoid.Health > 0 and head then
                local point, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local offset = Vector2.new(point.X, point.Y) - center
                    local screenDistance = offset.Magnitude
                    if screenDistance < bestScreenDistance then
                        bestScreenDistance = screenDistance
                        bestHumanoid = humanoid
                    end
                end
            end
        end
    end

    return bestHumanoid
end

RunService.RenderStepped:Connect(function()
    local camera = Workspace.CurrentCamera
    if not camera then
        panel.Visible = false
        return
    end

    if holdingT and settings.npcCamera then
        local target = getNpcTarget(camera)
        if target then
            if not savedCameraType then
                savedCameraType = camera.CameraType
                savedCameraSubject = camera.CameraSubject
            end

            camera.CameraType = Enum.CameraType.Custom
            camera.CameraSubject = target
        end
    elseif savedCameraType then
        restoreCamera()
    end

    local ray = camera:ViewportPointToRay(
        camera.ViewportSize.X / 2,
        camera.ViewportSize.Y / 2
    )

    local closestPlayer
    local closestCharacter
    local closestHumanoid
    local closestDistance

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local root = character and character:FindFirstChild("HumanoidRootPart")

            if humanoid and humanoid.Health > 0 and root then
                local offset = root.Position - ray.Origin
                local distance = offset.Magnitude

                if distance >= 1 and ray.Direction:Dot(offset.Unit) > 0.995 then
                    local closestPoint = ray.Origin + ray.Direction * distance
                    local missDistance = (root.Position - closestPoint).Magnitude

                    if missDistance < 5 and (not closestDistance or distance < closestDistance) then
                        closestPlayer = player
                        closestCharacter = character
                        closestHumanoid = humanoid
                        closestDistance = distance
                    end
                end
            end
        end
    end

    if settings.panel and closestPlayer then
        local myRoot = localPlayer.Character
            and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetRoot = closestCharacter:FindFirstChild("HumanoidRootPart")
        local distance = closestDistance

        if myRoot and targetRoot then
            distance = (myRoot.Position - targetRoot.Position).Magnitude
        end

        local health = math.max(0, math.floor(closestHumanoid.Health + 0.5))
        local maxHealth = math.max(1, math.floor(closestHumanoid.MaxHealth + 0.5))

        nameLabel.Text = closestPlayer.DisplayName
        healthText.Text = string.format("%d/%d", health, maxHealth)
        healthFill.Size = UDim2.fromScale(
            math.clamp(closestHumanoid.Health / maxHealth, 0, 1),
            1
        )
        details.Text = string.format(
            "dist: %dm   cuenta: %d días",
            math.floor(distance + 0.5),
            closestPlayer.AccountAge
        )

        setPortrait(closestPlayer)
        panel.Visible = true
    else
        panel.Visible = false
    end

    for player, highlight in pairs(highlights) do
        highlight.Enabled = settings.highlights and player.Parent == Players
    end

    for player, nameplate in pairs(nameplates) do
        nameplate.Enabled = settings.nameplates and player.Parent == Players
    end
end)
